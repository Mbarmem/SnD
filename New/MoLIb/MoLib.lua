---------------------------------- Import ---------------------------------

import("System.Numerics")

--------------------------------- Constant --------------------------------

---------------------
--    Condition    --
---------------------

-- Defines character condition constants
CharacterCondition = {
    normalConditions        = 1,
    dead                    = 2,
    mounted                 = 4,
    crafting                = 5,
    gathering               = 6,
    chocoboRacing           = 12,
    playingLordOfVerminion  = 14,
    occupied                = 25,
    inCombat                = 26,
    casting                 = 27,
    occupiedInEvent         = 31,
    occupiedInQuestEvent    = 32,
    boundByDuty             = 34,
    occupiedInCutscene      = 35,
    tradeOpen               = 37,
    occupied39              = 39,
    gathering42             = 42,
    betweenAreas            = 45,
    occupiedSummoningBell   = 50,
    betweenArea51           = 51,
    boundByDuty56           = 56,
    beingMoved              = 70,
    inFlight                = 77,
    diving                  = 81
}

--------------
--    Log   --
--------------

-- Defines available log levels
local LogLevel = {
    Info    = "Info",
    Debug   = "Debug",
    Verbose = "Verbose"
}

-------------------------------- Functions --------------------------------

----------------
--    Wait    --
----------------

-- Wait function to pause execution for a specified time
-- @param time (number) - Duration to wait in seconds
function Wait(time)
    -- Yield control and issue a wait command for the given duration
    yield("/wait " .. time)
end

-- PlayerTest function to wait until the player is available
-- Continuously yields in defined intervals until IsPlayerAvailable() returns true
function PlayerTest()
    repeat
        Wait(0.1)
    until Player.Available  -- Check if the player is available
end

-- Waits until the specified condition is cleared, or until a timeout is reached
-- Returns true if the condition was cleared, false if it timed out
function WaitForCondition(name, timeout)
    local startTime = os.clock()

    repeat
        if timeout and (os.clock() - startTime) >= timeout then
            return false  -- Timeout reached
        end
        Wait(0.1)
    until Svc.Condition[name]
    return true
end

-- Waits until the navigation mesh system is ready before continuing
function WaitForNavMesh()
    LogInfo("[MoLib] Waiting for navmesh to become ready...")
    while not IPC.vnavmesh.IsReady() do
        Wait(0.1)
    end
    LogInfo("[MoLib] Navmesh is ready.")
end

-- Waits for the Navmesh pathing process to complete.
-- Typically used after starting a pathing command to ensure it finishes before proceeding.
function WaitForPathRunning()
    LogInfo("[MoLib] Waiting for navmesh pathing to complete...")
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        Wait(0.1)
    end
    LogInfo("[MoLib] Pathing complete.")
end

-- WaitForLifeStream function to pause execution until Lifestream is no longer busy
-- Then ensures the player is available before continuing
function WaitForLifeStream()
    -- Wait while Lifestream is busy
    repeat
        Wait(0.1)
    until (not IPC.Lifestream.IsBusy() and Player.Available)
end

-- WaitForTp function to pause execution during teleport/loading transitions
-- Prevents actions like mounting or movement while the player is zoning
function WaitForTp()
    -- Wait for zoning to begin
    repeat
        Wait(0.1)
    until Svc.Condition[CharacterCondition.betweenAreas]
    -- Wait for zoning to complete
    repeat
        Wait(0.1)
    until (not Svc.Condition[CharacterCondition.betweenAreas] and Player.Available)
	Wait(0.1)
end

-- WaitForAR function to pause execution while AutoRetainers are processing
-- Checks if retainers are waiting and AutoRetainers is enabled
-- Waits until the summoning bell is no longer occupied
function WaitForAR()
    -- If retainers are queued and AutoRetainers is enabled
    if IPC.AutoRetainer.AreAnyRetainersAvailableForCurrentChara() and DoAutoRetainers then
        -- Notify user via echo and wait briefly
        LogInfo("[MoLib] Waiting for AutoRetainers to complete")
        Wait(0.1)
        -- While the character is interacting with the summoning bell, wait
        while Svc.Condition[CharacterCondition.occupiedSummoningBell] do
            PlayerTest()  -- Ensure player is available before rechecking
        end
    end
    -- Final short wait to ensure stability after processing
    Wait(0.1)
end

----------------
--    Move    --
----------------

-- Function to use vnavmesh IPC to pathfind and move to a XYZ coordinate.
-- Issues PathfindAndMoveTo request, waits for pathing to begin, and monitors movement.
-- Optionally stops early if player reaches specified stopDistance from destination.
-- Returns true if path completed successfully or stopped early, false if path could not start.
-- Usage: MoveTo(-67.457, -0.502, -8.274)           -- Normal ground movement
--        MoveTo(x, y, z, true)                     -- Flying movement
--        MoveTo(x, y, z, false, 4.0)               -- Ground path, stop within 4.0 units
function MoveTo(x, y, z, fly, stopDistance)
    fly = fly or false
    stopDistance = stopDistance or 0.0

    local destination = Vector3(x, y, z)

    local success = IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
    if not success then
        LogInfo("[MoLib] Navmesh's PathfindAndMoveTo() failed to start pathing!")
        return false
    end

    LogDebug("[MoLib] Navmesh pathing has been issued to (%.3f, %.3f, %.3f)", x, y, z)

    local startupRetries = 0
    local maxStartupRetries = 10
    while not IPC.vnavmesh.IsRunning() and startupRetries < maxStartupRetries do
        Wait(0.1)
        startupRetries = startupRetries + 1
    end

    if not IPC.vnavmesh.IsRunning() then
        LogInfo("[MoLib] Navmesh failed to start movement after creating a path.")
        return false
    end

    -- Actively monitor movement
    while IPC.vnavmesh.IsRunning() do
        Wait(0.1)

        if stopDistance > 0 then
            local pos = Player.Entity.Position
            local dx = pos.X - x
            local dy = pos.Y - y
            local dz = pos.Z - z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

            if dist <= stopDistance then
                IPC.vnavmesh.Stop()
                LogDebug("[MoLib] Navmesh has been stopped early at distance %.2f", dist)
                break
            end
        end
    end

    LogInfo("[MoLib] Navmesh is done pathing")
    return true
end

-- Function to find nearest object by name substring (case-insensitive)
function FindNearestObjectByName(targetName)
    local player = Svc.ClientState.LocalPlayer
    local closestObject = nil
    local closestDistance = math.huge

    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj then
            local name = obj.Name.TextValue
            if name and string.find(string.lower(name), string.lower(targetName)) then
                local distance = GetDistance(obj.Position, player.Position)
                if distance < closestDistance then
                    closestDistance = distance
                    closestObject = obj
                end
            end
        end
    end

    if closestObject then
        local name = closestObject.Name.TextValue
        local pos = closestObject.Position
        LogInfo("[MoLib] Found nearest '%s': %s (%.2f units) | XYZ: (%.3f, %.3f, %.3f)", targetName, name, closestDistance, pos.X, pos.Y, pos.Z)
    else
        LogInfo("[MoLib] No object matching '%s' found nearby.", targetName)
    end

    return closestObject, closestDistance
end

-- Function to pathfind directly to an entity by name
-- Looks up the entity, retrieves its position, and calls MoveTo()
-- Usage: PathToObject("Summoning Bell"), PathToObject("Retainer Vocate", false, 4.0)
function PathToObject(targetName, fly, stopDistance)
    fly = fly or false
    stopDistance = stopDistance or 0.0

    local obj, dist = FindNearestObjectByName(targetName)
    if obj then
        local name = obj.Name.TextValue
        local pos = obj.Position

        LogInfo("[MoLib] Pathing to nearest '%s': %s (%.2f units) at (%.3f, %.3f, %.3f)", targetName, name, dist, pos.X, pos.Y, pos.Z)

        return MoveTo(pos.X, pos.Y, pos.Z, fly, stopDistance)
    else
        LogInfo("[MoLib] Could not find '%s' nearby.", targetName)
        return false
    end
end

-------------------
--    Targets    --
-------------------

-- Function to perform a case-insensitive "startsWith" string comparison
-- Allows partial name targeting similar to how /target works in-game
function StringStartsWithIgnoreCase(fullString, partialString)
    fullString = string.lower(fullString)
    partialString = string.lower(partialString)
    return string.sub(fullString, 1, #partialString) == partialString
end

-- Core targeting function to attempt acquiring a target based on name
-- Issues /target, then waits for client to update Entity.Target, validates match
-- Returns true if successful, false if target not acquired after retries
function AcquireTarget(name, maxRetries, sleepTime)
    maxRetries = maxRetries or 20 -- Default retries if not provided
    sleepTime = sleepTime or 0.1 -- Default sleep interval if not provided

    yield('/target ' .. tostring(name))

    local retries = 0
    while (Entity == nil or Entity.Target == nil) and retries < maxRetries do
        Sleep(sleepTime)
        retries = retries + 1
    end

    if Entity and Entity.Target and StringStartsWithIgnoreCase(Entity.Target.Name, name) then
        Entity.Target:SetAsTarget()
        LogInfo("[MoLib] Target acquired: %s [Word: %s]", Entity.Target.Name, name)
        return true
    else
        LogInfo("[MoLib] Failed to acquire target [%s] after %d retries", name, retries)
        return false
    end
end

-- Simplified function to acquire a target
-- Calls AcquireTarget and logs failure if unsuccessful
-- Usage: Target("Aetheryte"), Target("Aetheryte", 50, 0.05)
function Target(name, maxRetries, sleepTime)
    local success = AcquireTarget(name, maxRetries, sleepTime)

    if not success then
        LogInfo("[MoLib] Target() failed.")
    end
end

------------------
--    Addons    --
------------------

-- Checks if the specified addon is loaded and ready
-- Returns true if the addon exists and is marked as ready
function IsAddonReady(name)
    local addon = Addons.GetAddon(name)
    return addon.Ready
end

-- Waits until the specified addon is ready before continuing execution
-- Repeatedly checks using IsAddonReady, pausing briefly between checks
function WaitForAddon(name)
    repeat
        Wait(0.1)  -- Brief pause to prevent tight loop
    until IsAddonReady(name)
end

-- Retrieves the text of a node from a ready addon
-- Returns the node's text as a string, or an empty string if the addon is not ready
function GetNodeText(addonName, ...)
    if IsAddonReady(addonName) then
        local addon = Addons.GetAddon(addonName)
        local node = addon:GetNode(...)
        return tostring(node.Text)
    end
end

-- Closes all known blocking addons until the player is available
function CloseAddons()
    local closableAddons = {
        "SelectIconString",
        "SelectString",
        "SelectYesno",
        "ShopExchangeItem",
        "RetainerList",
        "InventoryRetainer",
        "Talk"
    }

    repeat
        Wait(0.1)

        for _, addon in ipairs(closableAddons) do
            if IsAddonVisible(addon) then
                LogInfo("[MoLib] Closing addon: %s", addon)
                yield(string.format("/callback %s true -1", addon))
            end
        end

    until IsPlayerAvailable()
end

----------------
--    Zone    --
----------------

-- Helper to get current zone ID
function ZoneID()
    return Svc.ClientState.TerritoryType
end

-- Returns true if the player is currently in the specified zone
function IsInZone(zoneId)
    return ZoneID() == zoneId
end

--- Retrieves the Territory ID of the currently flagged map.
--- @return integer territoryId The ID of the zone where the current map flag is set.
function FlagZoneID()
    return Instances.Map.Flag.TerritoryId
end

-- Initiates teleport to the given location and waits for it to complete
function Teleport(location)
    LogInfo(string.format("[MoLib] Initiating teleport to '%s'.", location))
    yield("/tp " .. location)
    Wait(0.1)
    WaitForTp()
    PlayerTest()
end

-- Teleports the player to the flag's zone if they are not already there
function TeleportFlagZone()
    local flagZone = FlagZoneID()

    -- Check if player is already in the correct zone
    if not IsInZone(flagZone) then
        -- Retrieve the Aetheryte name from the TerritoryType Excel sheet
        local territoryData = Excel.GetRow("TerritoryType", flagZone)

        if territoryData and territoryData.Aetheryte and territoryData.Aetheryte.PlaceName then
            local flagAetheryte = tostring(territoryData.Aetheryte.PlaceName.Name)
            LogInfo(string.format("[MoLib] Teleporting to map zone: '%s'.", flagAetheryte))
            Teleport(flagAetheryte)
        else
            LogDebug("[MoLib] Failed to retrieve Aetheryte information for teleportation.")
        end
    else
        LogInfo("[MoLib] Already in the correct zone. No teleport needed.")
    end
end

------------------
--    Player    --
------------------

-- Wrapper for Player.Available
-- Returns true if the player is available (i.e., not in cutscenes, loading screens, etc.)
function IsPlayerAvailable()
    return Player and Player.Available or false
end

-- Wrapper for Player.Entity.IsCasting
-- Returns true if the player is currently casting a spell or ability
function IsPlayerCasting()
    return Player.Entity and Player.Entity.IsCasting or false
end

-- Wrapper for Svc.Condition
-- Returns a specific condition value by index, or the full condition table if no index is provided
function GetCharacterCondition(index)
    if index then
        return Svc.Condition[index]
    else
        return Svc.Condition
    end
end

--------------------
--    Utilities   --
--------------------

-- Wrapper for /echo that safely converts and outputs any message type (string, number, boolean, etc.)
-- Allows an optional prefix (default: "[MoLib]")
function Echo(msg, echoprefix)
    echoprefix = echoprefix or "[MoLib]"
    yield(string.format("/echo %s %s", tostring(echoprefix), tostring(msg)))
end

-- Executes a Lifestream command and waits for its completion
-- Logs the command execution for debugging purposes
function Lifestream(command)
    if not command or command == "" then
        LogInfo("[MoLib] No Lifestream command provided.")
        return
    end
    LogInfo("[MoLib] Executing Lifestream command: '%s'", command)
    IPC.Lifestream.ExecuteCommand(command)
    WaitForLifeStream()
end

-- Calculates the distance between two positions.
-- If use2D is true, calculates 2D distance (ignores Z axis),
-- otherwise calculates full 3D Euclidean distance.
function GetDistance(pos1, pos2, use2D)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    if use2D then
        return math.sqrt(dx * dx + dy * dy)
    else
        local dz = pos1.Z - pos2.Z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
end

--------------
--    Log   --
--------------

-- Core log function with support for formatting and log levels
function Log(msg, level, ...)
    level = level or LogLevel.Info

    -- Format message if additional arguments are provided
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end

    if level == LogLevel.Info then
        Dalamud.Log(msg)
    elseif level == LogLevel.Debug then
        Dalamud.LogDebug(msg)
    elseif level == LogLevel.Verbose then
        Dalamud.LogVerbose(msg)
    else
        Dalamud.Log("[UNKNOWN LEVEL] " .. msg)
    end
end

-- Logs a message at the Info level
function LogInfo(msg, ...)
    Log(msg, LogLevel.Info, ...)
end

-- Logs a message at the Debug level
function LogDebug(msg, ...)
    Log(msg, LogLevel.Debug, ...)
end

-- Logs a message at the verbose level
function LogVerbose(msg, ...)
    Log(msg, LogLevel.Verbose, ...)
end