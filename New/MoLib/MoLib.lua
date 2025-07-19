--========================= DEPENDENCIES =========================--

import("System.Numerics")

--=========================== CONSTANT ===========================--

--=================--
--    Condition    --
--=================--

-- Defines character condition constants
CharacterCondition = {
    normalConditions        =  1,
    dead                    =  2,
    mounted                 =  4,
    crafting                =  5,
    gathering               =  6,
    chocoboRacing           = 12,
    playingMiniGame         = 13,
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
    fishing                 = 43,
    betweenAreas            = 45,
    occupiedSummoningBell   = 50,
    betweenArea51           = 51,
    boundByDuty56           = 56,
    beingMoved              = 70,
    inFlight                = 77,
    diving                  = 81
}

--===========--
--    Log    --
--===========--

-- Defines available log levels
local LogLevel = {
    Info    = "Info",
    Debug   = "Debug",
    Verbose = "Verbose"
}

--========================== FUNCTIONS ===========================--

--==============--
--    Player    --
--==============--

-- Wrapper for Player.Available
function IsPlayerAvailable()
    local isAvailable = Player and Player.Available and not Player.IsBusy
    LogDebug(string.format("[MoLib] IsPlayerAvailable: %s", tostring(isAvailable)))
    return isAvailable
end

---------------------------------------------------------------------

-- Checks if the player is currently dead.
function IsDead()
    local isDead = Svc.Condition[CharacterCondition.dead]
    LogDebug(string.format("[MoLib] IsDead: %s", tostring(isDead)))
    return isDead
end

---------------------------------------------------------------------

-- Checks if the player is currently mounted.
function IsMounted()
    local isMounted = Svc.Condition[CharacterCondition.mounted]
    LogDebug(string.format("[MoLib] IsMounted: %s", tostring(isMounted)))
    return isMounted
end

---------------------------------------------------------------------

-- Checks if the player is currently crafting.
function IsCrafting()
    local isCrafting = Svc.Condition[CharacterCondition.crafting]
    LogDebug(string.format("[MoLib] IsCrafting: %s", tostring(isCrafting)))
    return isCrafting
end

---------------------------------------------------------------------

-- Checks if the player is currently gathering.
function IsGathering()
    local isGathering = Svc.Condition[CharacterCondition.gathering]
    LogDebug(string.format("[MoLib] IsGathering: %s", tostring(isGathering)))
    return isGathering
end

---------------------------------------------------------------------

-- Checks if the player is currently occupied in a mini-game.
function IsPlayingMiniGame()
    local isMiniGame = Svc.Condition[CharacterCondition.playingMiniGame]
    LogDebug(string.format("[MoLib] IsPlayingMiniGame: %s", tostring(isMiniGame)))
    return isMiniGame
end

---------------------------------------------------------------------

-- Checks if the player is currently InCombat.
function IsInCombat()
    local isInCombat = Entity.Player.IsInCombat
    LogDebug(string.format("[MoLib] IsInCombat: %s", tostring(isInCombat)))
    return isInCombat
end

---------------------------------------------------------------------

-- Wrapper for Player.Entity.IsCasting
function IsPlayerCasting()
    local isCasting = Player.Entity and Player.Entity.IsCasting
    LogDebug(string.format("[MoLib] IsPlayerCasting: %s", tostring(isCasting)))
    return isCasting
end

---------------------------------------------------------------------

-- Checks if the player is currently occupied in a quest event (e.g., cutscene or interactive scene)
function IsOccupiedInQuestEvent()
    local inQuestEvent = Svc.Condition[CharacterCondition.occupiedInQuestEvent]
    LogDebug(string.format("[MoLib] IsOccupiedInQuestEvent: %s", tostring(inQuestEvent)))
    return inQuestEvent
end

---------------------------------------------------------------------

-- Checks if the player is currently bound by duty
function IsBoundByDuty()
    local isBoundByDuty = Svc.Condition[CharacterCondition.boundByDuty] or Svc.Condition[CharacterCondition.boundByDuty56]
    LogDebug(string.format("[MoLib] IsBoundByDuty: %s", tostring(isBoundByDuty)))
    return isBoundByDuty
end

---------------------------------------------------------------------

-- Checks if the player is currently occupied in a cutscene
function IsOccupiedInCutScene()
    local inCutscene = Svc.Condition[CharacterCondition.occupiedInCutscene]
    LogDebug(string.format("[MoLib] OccupiedInCutscene: %s", tostring(inCutscene)))
    return inCutscene
end

---------------------------------------------------------------------

-- Checks if the player is currently fishing
function IsFishing()
    local isFishing = Svc.Condition[CharacterCondition.fishing]
    LogDebug(string.format("[MoLib] IsFishing: %s", tostring(isFishing)))
    return isFishing
end

---------------------------------------------------------------------

-- Checks if the player is currently between Areas
function IsBetweenAreas()
    local isBetweenAreas = Svc.Condition[CharacterCondition.betweenAreas]
    LogDebug(string.format("[MoLib] IsBetweenAreas: %s", tostring(isBetweenAreas)))
    return isBetweenAreas
end

---------------------------------------------------------------------

-- WaitForPlayer function to wait until the player is available
-- Continuously yields in defined intervals until IsPlayerAvailable() returns true
function WaitForPlayer()
    LogDebug("[MoLib] WaitForPlayer: Waiting for player to become available...")
    repeat
        Wait(0.1)
    until IsPlayerAvailable()
    LogDebug("[MoLib] WaitForPlayer: Player is now available.")
    Wait(0.1)
end

--------------------------------------------------------------------

-- Returns the current character's name.
function GetCharacterName()
    local name = Entity and Entity.Player and Entity.Player.Name
    LogDebug(string.format("[MoLib] GetCharacterName: %s", tostring(name)))
    return name
end

--------------------------------------------------------------------

-- Get the current player's class/job ID.
function GetClassJobId()
    local jobId = Player and Player.Job and Player.Job.Id
    LogDebug(string.format("[MoLib] GetClassJobId: %s", tostring(jobId)))
    return jobId
end

--------------------------------------------------------------------

-- Wrapper for Character Condition
-- Returns a specific condition value by index, or the full condition table if no index is provided
function GetCharacterCondition(index)
    if index then
        local condition = Svc.Condition and Svc.Condition[index] or nil
        LogDebug(string.format("[MoLib] GetCharacterCondition[%s]: %s", tostring(index), tostring(condition)))
        return condition
    else
        LogDebug("[MoLib] GetCharacterCondition: Returning full condition table")
        return Svc.Condition
    end
end

--------------------------------------------------------------------

-- Retrieves the player's current X position in the game world
function GetPlayerRawXPos()
    local x = Player.Entity.Position.X
    LogDebug(string.format("[MoLib] Player X Position: %.2f", x))
    return x
end

--------------------------------------------------------------------

-- Retrieves the player's current Y position in the game world
function GetPlayerRawYPos()
    local y = Player.Entity.Position.Y
    LogDebug(string.format("[MoLib] Player Y Position: %.2f", y))
    return y
end

--------------------------------------------------------------------

-- Retrieves the player's current Z position in the game world
function GetPlayerRawZPos()
    local z = Player.Entity.Position.Z
    LogDebug(string.format("[MoLib] Player Z Position: %.2f", z))
    return z
end

--------------------------------------------------------------------

-- Checks if the player currently has a status with the specified StatusId.
function HasStatusId(targetId)
    local statusList = Player.Status
    LogDebug(string.format("[MoLib] Checking for StatusId = %d", targetId))

    if not statusList then
        LogDebug("[MoLib] Player.Status is nil.")
        return false
    end

    for i = 0, statusList.Count - 1 do
        local status = statusList:get_Item(i)

        if status and status.StatusId == targetId then
            LogDebug(string.format("[MoLib] Found matching StatusId at index %d", i))
            return true
        end
    end

    LogDebug(string.format("[MoLib] StatusId %d not found in Player.Status list.", targetId))
    return false
end

--------------------------------------------------------------------

-- Checks if the player has a specific status and returns its remaining time.
function GetStatusTimeRemaining(targetId)
    local statusList = Player.Status
    LogDebug(string.format("[MoLib] Checking remaining time for StatusId = %d", targetId))

    if not statusList then
        LogDebug("[MoLib] Player.Status is nil.")
        return nil
    end

    for i = 0, statusList.Count - 1 do
        local status = statusList:get_Item(i)

        if status and status.StatusId == targetId then
            LogDebug(string.format("[MoLib] Found StatusId %d at index %d with remaining time %.2f seconds.", targetId, i, status.RemainingTime))
            return status.RemainingTime
        end
    end

    LogDebug(string.format("[MoLib] StatusId %d not found in Player.Status list.", targetId))
    return nil
end

--------------------------------------------------------------------

--============================= IPC ==============================--

--===============--
--    Artisan    --
--===============--

-- Checks if an Artisan crafting list is currently running.
function ArtisanIsListRunning()
    local isRunning = IPC.Artisan.IsListRunning()
    LogDebug(string.format("[MoLib] Artisan list running: %s", tostring(isRunning)))
    return isRunning
end

--------------------------------------------------------------------

-- Retrieves the current endurance status from the Artisan system.
function ArtisanGetEnduranceStatus()
    local status = IPC.Artisan.GetEnduranceStatus()
    LogDebug(string.format("[MoLib] Artisan endurance status retrieved: %s", tostring(status)))
    return status
end

--------------------------------------------------------------------

-- Sets the endurance status for the Artisan system.
function ArtisanSetEnduranceStatus(status)
    LogDebug(string.format("[MoLib] Artisan endurance status set to: %s", tostring(status)))
    return IPC.Artisan.SetEnduranceStatus(status)
end

--------------------------------------------------------------------

--================--
--    AutoDuty    --
--================--

-- Starts an AutoDuty run with the specified territory and parameters.
function AutoDutyRun(territoryType, loops, bareMode)
    LogDebug(string.format("[MoLib] Running duty: territoryType=%s, loops=%s, bareMode=%s", tostring(territoryType), tostring(loops), tostring(bareMode)))
    IPC.AutoDuty.Run(territoryType, loops, bareMode)
end

--------------------------------------------------------------------

-- Sets a configuration key-value pair for AutoDuty via IPC.
function AutoDutyConfig(key, value)
    LogDebug(string.format("[MoLib] AutoDuty config: %s = %s", tostring(key), tostring(value)))
    return IPC.AutoDuty.SetConfig(key, value)
end

--------------------------------------------------------------------

--================--
--    AutoHook    --
--================--

-- Sets the AutoHook plugin to use a specific preset.
function SetAutoHookPreset(presetName)
    LogDebug(string.format("[MoLib] AutoHook preset set to: %s", tostring(presetName)))
    return IPC.AutoHook.SetPreset(presetName)
end

--------------------------------------------------------------------

-- Sets the AutoHook state.
function SetAutoHookState(state)
    LogDebug(string.format("[MoLib] AutoHook state set to: %s", tostring(state)))
    return IPC.AutoHook.SetPluginState(state)
end

--------------------------------------------------------------------

--====================--
--    AutoRetainer    --
--====================--

-- Checks if there are any AutoRetainers waiting to be processed for the current character.
function ARRetainersWaitingToBeProcessed()
    local hasRetainers = IPC.AutoRetainer.AreAnyRetainersAvailableForCurrentChara()
    LogDebug(string.format("[MoLib] Retainers waiting to be processed: %s", tostring(hasRetainers)))
    return hasRetainers
end

--------------------------------------------------------------------

--==================--
--    Lifestream    --
--==================--

-- Executes a Lifestream command and waits for its completion
function Lifestream(command)
    if not command or command == "" then
        LogDebug("[MoLib] No Lifestream command provided.")
        return
    end

    LogDebug("[MoLib] Executing Lifestream command: '%s'", command)
    IPC.Lifestream.ExecuteCommand(command)
    WaitForLifeStream()
end

--------------------------------------------------------------------

-- Checks whether Lifestream is currently performing a teleport or is otherwise busy.
function LifestreamIsBusy()
    local busy = IPC.Lifestream.IsBusy()
    LogDebug(string.format("[MoLib] LifestreamIsBusy: %s", tostring(busy)))
    return busy
end

--------------------------------------------------------------------

-- WaitForLifeStream function to pause execution until Lifestream is no longer busy
-- Then ensures the player is available before continuing
function WaitForLifeStream()
    LogDebug("[MoLib] Waiting for Lifestream to become not busy and player to be available...")

    repeat
        Wait(0.1)
    until not IPC.Lifestream.IsBusy() and IsPlayerAvailable()

    LogDebug("[MoLib] Lifestream is no longer busy and player is available.")
end

--------------------------------------------------------------------

--====================--
--    Questionable    --
--====================--

-- Returns whether Questionable is currently running.
function QuestionableIsRunning()
    local running = IPC.Questionable.IsRunning()
    LogDebug(string.format("[MoLib] QuestionableIsRunning: %s", tostring(running)))
    return running
end

--------------------------------------------------------------------

-- Adds a quest to the priority list in Questionable.
function QuestionableAddQuestPriority(questId)
    LogDebug(string.format("[MoLib] QuestionableAddQuestPriority: QuestID=%d", questId))
    return IPC.Questionable.AddQuestPriority(questId)
end

--------------------------------------------------------------------

-- Clears all quest priorities in Questionable.
function QuestionableClearQuestPriority()
    LogDebug("[MoLib] QuestionableClearQuestPriority called")
    return IPC.Questionable.ClearQuestPriority()
end

--------------------------------------------------------------------

-- Checks if a specific quest is locked in Questionable.
function QuestionableIsQuestLocked(questId)
    local locked = IPC.Questionable.IsQuestLocked(questId)
    LogDebug(string.format("[MoLib] QuestionableIsQuestLocked: QuestID=%d, Locked=%s", questId, tostring(locked)))
    return locked
end

--------------------------------------------------------------------

--===============--
--    Visland    --
--===============--

-- Checks if the Visland route is currently running
function IsVislandRouteRunning()
    local running = IPC.visland.IsRouteRunning()
    LogDebug(string.format("[MoLib] Visland route running status: %s", tostring(running)))
    return running
end

--------------------------------------------------------------------

-- Checks if the Visland route is currently paused
function IsVislandRoutePaused()
    local paused = IPC.visland.IsRoutePaused()
    LogDebug(string.format("[MoLib] Visland route paused status: %s", tostring(paused)))
    return paused
end

--------------------------------------------------------------------

-- Starts the specified Visland route, with optional looping
function VislandRouteStart(routeName, loop)
    loop = loop or false
    LogInfo(string.format("[MoLib] Starting Visland route: %s (Loop: %s)", routeName, tostring(loop)))
    return IPC.visland.StartRoute(routeName, loop)
end

--------------------------------------------------------------------

-- Stops the Visland route if it is running
function VislandRouteStop()
    if IsVislandRouteRunning() then
        LogDebug(string.format("[MoLib] Stopping Visland route"))
        return IPC.visland.StopRoute()
    end
end

--------------------------------------------------------------------

-- Sets the Visland route pause state to true or false
function VislandSetRoutePaused(paused)
    LogDebug(string.format("[MoLib] Setting Visland route paused: %s", tostring(paused)))
    return IPC.visland.SetRoutePaused(paused)
end

--------------------------------------------------------------------

--================--
--    Vnavmesn    --
--================--

-- Checks whether a vnavmesh pathfinding operation is currently in progress.
function PathfindInProgress()
    local inProgress = IPC.vnavmesh.PathfindInProgress()
    LogDebug(string.format("[MoLib] PathfindInProgress: %s", tostring(inProgress)))
    return inProgress
end

--------------------------------------------------------------------

-- Checks whether the vnavmesh path is currently running.
-- This indicates whether the navigation system is actively moving toward a target.
function PathIsRunning()
    local isRunning = IPC.vnavmesh.IsRunning()
    LogDebug(string.format("[MoLib] PathIsRunning: %s", tostring(isRunning)))
    return isRunning
end

--------------------------------------------------------------------

-- Initiates pathfinding and movement to the specified 3D coordinates using vnavmesh.
-- Can optionally enable flying movement if supported.
function PathfindAndMoveTo(x, y, z, fly)
    fly = fly or false
    local destination = Vector3(x, y, z)
    LogDebug(string.format("[MoLib] PathfindAndMoveTo: Destination = %s, Fly = %s", tostring(destination), tostring(fly)))
    return IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
end

--------------------------------------------------------------------

-- Initiates movement without pathfinding to the specified 3D coordinates using vnavmesh.
-- Can optionally enable flying movement if supported.
function PathMoveTo(x, y, z, fly)
    fly = fly or false
    local destination = Vector3(x, y, z)
    LogDebug(string.format("[MoLib] PathMoveTo: Destination = %s, Fly = %s", tostring(destination), tostring(fly)))
    return IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
end

--------------------------------------------------------------------

-- Waits until the navigation mesh system is ready before continuing
function WaitForNavMesh()
    LogDebug("[MoLib] Waiting for navmesh to become ready...")
    while not IPC.vnavmesh.IsReady() do
        Wait(0.1)
    end
    LogDebug("[MoLib] Navmesh is ready.")
end

--------------------------------------------------------------------

-- Waits for the Navmesh pathing process to complete.
-- Typically used after starting a pathing command to ensure it finishes before proceeding.
-- Default timeout is 300 seconds (5 minutes).
function WaitForPathRunning(timeout)
    timeout = timeout or 300  -- Default timeout to 5 minutes (300 seconds)
    LogDebug("[MoLib] Waiting for navmesh pathing to complete...")

    local startTime = os.clock()
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        if (os.clock() - startTime) >= timeout then
            LogDebug("[MoLib] WaitForPathRunning: Timeout reached waiting for pathing to complete.")
            return false
        end
        Wait(0.1)
    end

    LogDebug("[MoLib] Pathing complete.")
    return true
end

--------------------------------------------------------------------

-- Stops the current vnavmesh pathfinding movement, if any is active.
function PathStop()
    LogDebug("[MoLib] PathStop: Attempting to stop pathfinding.")
    return IPC.vnavmesh.Stop()
end

--------------------------------------------------------------------

-- Queries the nearest point on the navigation mesh floor from a Vector3 or x/y/z coordinates.
function QueryMeshPointOnFloor(positionOrX, y, z, allowUnlandable, halfExtentXZ)
    local position

    if type(positionOrX) == "userdata" then
        -- Case: Vector3 passed
        position = positionOrX
        allowUnlandable = y
        halfExtentXZ = z
    else
        -- Case: raw x, y, z passed
        position = Vector3(positionOrX, y, z)
        -- allowUnlandable and halfExtentXZ remain unchanged
    end

    LogDebug(string.format("[MoLib] QueryMeshPointOnFloor called with position: %s, allowUnlandable: %s, halfExtentXZ: %s", tostring(position), tostring(allowUnlandable), tostring(halfExtentXZ)))
    local result = IPC.vnavmesh.PointOnFloor(position, allowUnlandable, halfExtentXZ)
    LogDebug(string.format("[MoLib] PointOnFloor result: %s", tostring(result)))
    return result
end

--------------------------------------------------------------------

--==================--
--    YesAlready    --
--==================--

-- Pauses the YesAlready plugin.
function PauseYesAlready(sleepTime)
    sleepTime = sleepTime or 300
    LogDebug(string.format("[MoLib] YesAlready plugin paused for: %s seconds", tostring(sleepTime)))
    return IPC.YesAlready.PausePlugin(sleepTime)
end

--============================= WAIT =============================--

--============--
--    Wait    --
--============--

-- Wait function to pause execution for a specified time
-- @param time (number) - Duration to wait in seconds
function Wait(time)
    -- Yield control and issue a wait command for the given duration
    yield("/wait " .. time)
end

--------------------------------------------------------------------

-- Waits until the specified condition is cleared, or until a timeout is reached
-- Returns true if the condition was cleared, false if it timed out
function WaitForCondition(name, timeout)
    LogDebug(string.format("[MoLib] WaitForCondition: Waiting for condition '%s' to clear...", tostring(name)))

    local conditionName = string.lower(name)
    local conditionKey = nil

    for k, v in pairs(CharacterCondition) do
        if string.lower(k) == conditionName then
            conditionKey = v
            break
        end
    end

    if not conditionKey then
        LogDebug(string.format("[MoLib] WaitForCondition: Unknown condition name '%s'.", tostring(name)))
        return false
    end

    local startTime = os.clock()

    repeat
        if timeout and (os.clock() - startTime) >= timeout then
            LogDebug(string.format("[MoLib] WaitForCondition: Timeout reached while waiting for '%s' to clear.", tostring(name)))
            return false
        end

        Wait(0.1)
    until Svc.Condition[conditionKey]

    LogDebug(string.format("[MoLib] WaitForCondition: Condition '%s' has been cleared.", tostring(name)))
    return true
end

--------------------------------------------------------------------

function WaitForTeleport()
    LogDebug("[MoLib] Waiting for teleport to begin...")

    repeat
        Wait(0.1)
    until not Svc.Condition[CharacterCondition.casting]
    Wait(0.1)

    LogDebug("[MoLib] Teleport started, waiting for zoning to complete...")

    repeat
        Wait(0.1)
    until not Svc.Condition[CharacterCondition.betweenAreas] and IsPlayerAvailable()
    Wait(0.1)

    LogDebug("[MoLib] Teleport complete.")
end

--------------------------------------------------------------------

-- Function to pause execution until the player is no longer zoning.
-- This prevents issues from mounting or moving while teleporting/loading.
function WaitForZoneChange()
    LogDebug("[MoLib] Waiting for zoning to start...")
    repeat
        Wait(0.1)
    until Svc.Condition[CharacterCondition.betweenAreas]

    LogDebug("[MoLib] Zoning detected! Now waiting for zoning to complete...")

    repeat
        Wait(0.1)
    until not Svc.Condition[CharacterCondition.betweenAreas] and IsPlayerAvailable()

    LogDebug("[MoLib] Zoning complete. Player is available.")
end

--============================= MOVE =============================--

--============--
--    Move    --
--============--

-- Function to use vnavmesh IPC to pathfind and move to a XYZ coordinate.
-- Issues PathfindAndMoveTo request, waits for pathing to begin, and monitors movement.
-- Optionally stops early if player reaches specified stopDistance from destination.
-- Returns true if path completed successfully or stopped early, false if path could not start.
-- Usage: MoveTo(-67.457, -0.502, -8.274)           -- Normal ground movement
--        MoveTo(x, y, z, true)                     -- Flying movement
--        MoveTo(x, y, z, false, 4.0)               -- Ground path, stop within 4.0 units
function MoveTo(x, y, z, stopDistance, fly)
    fly = fly or false
    stopDistance = stopDistance or 0.0

    local destination = Vector3(x, y, z)

    local success = IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
    if not success then
        LogDebug("[MoLib] Navmesh's PathfindAndMoveTo() failed to start pathing!")
        return false
    end

    LogDebug(string.format("[MoLib] Navmesh pathing has been issued to (%.3f, %.3f, %.3f)", x, y, z))

    local startupRetries = 0
    local maxStartupRetries = 10
    while not IPC.vnavmesh.IsRunning() and startupRetries < maxStartupRetries do
        Wait(0.1)
        startupRetries = startupRetries + 1
    end

    if not IPC.vnavmesh.IsRunning() then
        LogDebug("[MoLib] Navmesh failed to start movement after creating a path.")
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
                LogDebug(string.format("[MoLib] Navmesh has been stopped early at distance %.2f", dist))
                break
            end
        end
    end

    LogDebug("[MoLib] Navmesh is done pathing")
    return true
end

--------------------------------------------------------------------

-- Function to find nearest object by name substring (case-insensitive)
function FindNearestObjectByName(targetName)
    local player = Svc.ClientState.LocalPlayer
    if not player or not player.Position then
        LogDebug("[MoLib] FindNearestObjectByName: Player position unavailable.")
        return nil, math.huge
    end

    local closestObject = nil
    local closestDistance = math.huge

    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj then
            local name = obj.Name and obj.Name.TextValue
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
        LogDebug(string.format("[MoLib] Found nearest '%s': %s (%.2f units) | XYZ: (%.3f, %.3f, %.3f)", targetName, name, closestDistance, pos.X, pos.Y, pos.Z))
    else
        LogDebug(string.format("[MoLib] No object matching '%s' found nearby.", targetName))
    end

    return closestObject, closestDistance
end

--------------------------------------------------------------------

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

        LogDebug(string.format("[MoLib] Pathing to nearest '%s': %s (%.2f units) at (%.3f, %.3f, %.3f)", targetName, name, dist, pos.X, pos.Y, pos.Z))

        return MoveTo(pos.X, pos.Y, pos.Z, fly, stopDistance)
    else
        LogDebug(string.format("[MoLib] Could not find '%s' nearby.", targetName))
        return false
    end
end

--------------------------------------------------------------------

-- Calculates distance between two Vector3 positions
function GetDistance(pos1, pos2)
    if not pos1 or not pos2 then
        return math.huge
    end

    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--------------------------------------------------------------------

-- Calculates the 3D Euclidean distance between two points
function DistanceBetween(px1, py1, pz1, px2, py2, pz2)
    local dx = px2 - px1
    local dy = py2 - py1
    local dz = pz2 - pz1

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--------------------------------------------------------------------

-- Calculates the distance from the player to a given 3D point.
function GetDistanceToPoint(dX, dY, dZ)
    local player = Svc.ClientState.LocalPlayer
    if not player or not player.Position then
        LogDebug("[MoLib] GetDistanceToPoint: Player position unavailable.")
        return math.huge
    end

    local px = player.Position.X
    local py = player.Position.Y
    local pz = player.Position.Z

    local dx = dX - px
    local dy = dY - py
    local dz = dZ - pz

    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    LogDebug(string.format("[MoLib] [Distance] From (%.2f, %.2f, %.2f) to (%.2f, %.2f, %.2f) = %.2f", px, py, pz, dX, dY, dZ, distance))
    return distance
end

--------------------------------------------------------------------

-- Teleports the player to their Inn room if they are not already in one of the Inn zones.
-- Zone IDs: 177 (Limsa), 178 (Gridania), 179 (Ul'dah), 1205 (Solution Nine)
function MoveToInn()
    local WhereAmI = GetZoneID()

    -- Only move if not already in an Inn zone
    if (WhereAmI ~= 177) and (WhereAmI ~= 178) and (WhereAmI ~= 179) and (WhereAmI ~= 1205) then
        LogDebug("[MoLib] Moving to Inn.")
        IPC.Lifestream.ExecuteCommand("Inn")
        WaitForLifeStream()
    else
        LogDebug("[MoLib] Already in an Inn zone, no action taken.")
    end
end

--=========================== TARGETS ============================--

--===============--
--    Targets    --
--===============--

-- Function to perform a case-insensitive "startsWith" string comparison
-- Allows partial name targeting similar to how /target works in-game
function StringStartsWithIgnoreCase(fullString, partialString)
    if not fullString or not partialString then
        return false
    end
    fullString = string.lower(fullString)
    partialString = string.lower(partialString)
    return string.sub(fullString, 1, #partialString) == partialString
end

--------------------------------------------------------------------

-- Core targeting function to attempt acquiring a target based on name
-- Issues /target, then waits for client to update Entity.Target, validates match
-- Returns true if successful, false if target not acquired after retries
function AcquireTarget(name, maxRetries, sleepTime)
    maxRetries = maxRetries or 20 -- Default retries if not provided
    sleepTime = sleepTime or 0.1 -- Default sleep interval if not provided

    yield('/target ' .. tostring(name))

    local retries = 0
    while (Entity == nil or Entity.Target == nil) and retries < maxRetries do
        Wait(sleepTime)
        retries = retries + 1
    end

    if Entity and Entity.Target and StringStartsWithIgnoreCase(Entity.Target.Name, name) then
        Entity.Target:SetAsTarget()
        LogDebug(string.format("[MoLib] Target acquired: %s [Word: %s]", Entity.Target.Name, name))
        return true
    else
        LogDebug(string.format("[MoLib] Failed to acquire target [%s] after %d retries", name, retries))
        return false
    end
end

--------------------------------------------------------------------

-- Simplified function to acquire a target
-- Calls AcquireTarget and logs failure if unsuccessful
-- Usage: Target("Aetheryte"), Target("Aetheryte", 50, 0.05)
function Target(name, maxRetries, sleepTime)
    local success = AcquireTarget(name, maxRetries, sleepTime)

    if not success then
        LogDebug("[MoLib] Target() failed.")
    end
end

--------------------------------------------------------------------

-- Gets the name of the current target, if any.
function GetTargetName()
    local name = Entity.Target and Entity.Target.Name or nil
    LogDebug(string.format("[MoLib] Current target name: %s", name or "None"))
    return name
end

--------------------------------------------------------------------

-- Clears the current target if one is selected.
function ClearTarget()
    if Entity.Target and Entity.Target.IsValid then
        LogDebug(string.format("[MoLib] Clearing target: %s", Entity.Target.Name))
        Entity.Target:ClearTarget()
    else
        LogDebug("[MoLib] ClearTarget() called, but no valid target was selected.")
    end
end

--------------------------------------------------------------------

-- Moves the player to a target entity using IPC.vnavmesh
-- Will stop when within a specified distance of the target
function MoveToTarget(targetName, distanceThreshold, maxRetries, sleepTime, fly)
    distanceThreshold = distanceThreshold or 2.0
    maxRetries = maxRetries or 20
    sleepTime = sleepTime or 0.1
    fly = fly or false

    -- Try to acquire the target
    local success = AcquireTarget(targetName, maxRetries, sleepTime)
    if not success then
        LogDebug(string.format("[MoLib] MoveToTarget() failed: Unable to target [%s]", targetName))
        return false
    end

    local target = Entity.Target
    if not target or not target.Position.X or not target.Position.Y or not target.Position.Z then
        LogDebug("[MoLib] MoveToTarget() failed: Target entity position is nil.")
        return false
    end

    LogDebug(string.format("[MoLib] Moving to target [%s] at (%.2f, %.2f, %.2f) with stop distance %.2f", target.Name, target.Position.X, target.Position.Y, target.Position.Z, distanceThreshold))

    -- Use the provided MoveTo function
    return MoveTo(target.Position.X, target.Position.Y, target.Position.Z, distanceThreshold, fly)
end

--------------------------------------------------------------------

-- Function to interact with a target.
-- Attempts to acquire the target first, then issues the '/interact' command if successful.
function Interact(name, maxRetries, sleepTime)
    local success = AcquireTarget(name, maxRetries, sleepTime)
    if success then
        yield('/interact')
        LogDebug(string.format("[MoLib] Interacted with: %s", Entity.Target.Name))
    else
        LogDebug("[MoLib] Interact() failed to acquire target.")
    end
end

--------------------------------------------------------------------

-- Calculates the distance between the player and the current target
function GetDistanceToTarget()
    if not Entity or not Entity.Player then
        LogDebug("[MoLib] Entity.Player is not available.")
        return nil
    end

    if not Entity.Target then
        LogDebug("[MoLib] No valid target selected.")
        return nil
    end

    -- Retrieve positions
    local playerPos = Entity.Player.Position
    local targetPos = Entity.Target.Position

    -- Calculate the distance manually using Euclidean formula
    local dx = playerPos.X - targetPos.X
    local dy = playerPos.Y - targetPos.Y
    local dz = playerPos.Z - targetPos.Z

    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

    -- Log the distance to the debug output
    LogDebug(string.format("[MoLib] Distance to target: %.2f", distance))

    return distance
end

--=========================== ADDONS =============================--

--==============--
--    Addons    --
--==============--

-- Checks if the specified addon is loaded and ready
-- Returns true if the addon exists and is marked as ready
function IsAddonReady(name)
    local addon = Addons.GetAddon(name)

    local ready = addon and addon.Exists and addon.Ready
    LogDebug(string.format("[MoLib] IsAddonReady('%s') = %s", name, tostring(ready)))

    return ready
end

--------------------------------------------------------------------

-- Checks if an addon is visible.
-- This is essentially the same as IsAddonReady.
function IsAddonVisible(name)
    local visible = IsAddonReady(name)
    LogDebug(string.format("[MoLib] IsAddonVisible('%s') = %s", name, tostring(visible)))
    return visible
end

--------------------------------------------------------------------

-- Returns the visibility of a node within an addon.
function IsNodeVisible(addonName, ...)
    if not IsAddonReady(addonName) then
        LogDebug(string.format("[MoLib] IsNodeVisible('%s', ...): Addon not ready.", addonName))
        return false
    end

    local addon = Addons.GetAddon(addonName)
    local node = addon and addon:GetNode(...)
    local visible = node and node.IsVisible or false

    LogDebug(string.format("[MoLib] IsNodeVisible('%s', ...): %s", addonName, tostring(visible)))
    return visible
end

--------------------------------------------------------------------

-- Retrieves the text of a node from a ready addon
-- Returns the node's text as a string, or an empty string if the addon or node is not ready
function GetNodeText(addonName, ...)
    if not IsAddonReady(addonName) then
        LogDebug(string.format("[MoLib] GetNodeText('%s', ...): Addon not ready.", addonName))
        return false
    end

    local addon = Addons.GetAddon(addonName)
    local node = addon and addon:GetNode(...)
    local text = node and tostring(node.Text) or ""

    LogDebug(string.format("[MoLib] GetNodeText('%s', ...): '%s'", addonName, text))
    return text
end

--------------------------------------------------------------------

-- Waits until the specified addon is ready before continuing execution
-- Repeatedly checks using IsAddonReady, pausing briefly between checks
-- Optional timeout (in seconds), defaults to 60s
function WaitForAddon(name, timeout)
    timeout = timeout or 60
    local startTime = os.clock()

    LogDebug(string.format("[MoLib] Waiting for addon '%s' to become ready...", name))

    while not IsAddonReady(name) do
        if os.clock() - startTime >= timeout then
            LogDebug(string.format("[MoLib] WaitForAddon('%s') timed out after %.1f seconds", name, timeout))
            return false
        end
        Wait(0.1)
    end

    LogDebug(string.format("[MoLib] Addon '%s' is ready.", name))
    return true
end

--------------------------------------------------------------------

-- Closes all known blocking addons until the player is available
function CloseAddons()
    local closableAddons = {
        "SelectIconString",
        "SelectString",
        "SelectYesno",
        "ShopExchangeItem",
        "ContentsInfo",
        "RetainerList",
        "InventoryRetainer",
        "Talk"
    }

    LogDebug("[MoLib] CloseAddons() started. Waiting for player to become available...")

    repeat
        Wait(0.1)

        for _, addon in ipairs(closableAddons) do
            if IsAddonVisible(addon) then
                LogDebug(string.format("[MoLib] Closing addon: %s", addon))
                if addon == "Talk" then
                    yield(string.format("/callback %s true 0", addon))
                else
                    yield(string.format("/callback %s true -1", addon))
                end
            end
        end

    until IsPlayerAvailable()

    LogDebug("[MoLib] Player is now available. CloseAddons() complete.")
end


--============================= ZONE =============================--

--============--
--    Zone    --
--============--

-- Helper to get current zone ID
function GetZoneID()
    local zoneId = Svc.ClientState.TerritoryType
    LogDebug(string.format("[MoLib] Current zone ID: %d", zoneId))
    return zoneId
end

--------------------------------------------------------------------

-- Returns true if the player is currently in the specified zone
function IsInZone(ZoneID)
    local currentZone = GetZoneID()
    local result = currentZone == ZoneID
    LogDebug(string.format("[MoLib] IsInZone(%d) → %s (current: %d)", ZoneID, tostring(result), currentZone))
    return result
end

--------------------------------------------------------------------

-- Retrieves the Territory ID of the currently flagged map.
--- @return integer TerritoryId The ID of the zone where the current map flag is set.
function FlagZoneID()
    local territoryId = Instances.Map.Flag.TerritoryId
    LogDebug(string.format("[MoLib] FlagZoneID() → %d", territoryId))
    return territoryId
end

--------------------------------------------------------------------

-- Initiates teleport to the given location and waits for it to complete
function Teleport(location)
    LogDebug(string.format("[MoLib] Initiating teleport to '%s'.", location))
    yield("/tp " .. location)
    Wait(0.1)
    LogDebug("[MoLib] Waiting for teleport to complete...")
    WaitForTeleport()
    WaitForPlayer()
    LogDebug("[MoLib] Teleport completed and player is available.")
end

--------------------------------------------------------------------

-- Teleports the player to the flag's zone if they are not already there
function TeleportFlagZone()
    local flagZone = FlagZoneID()

    if not IsInZone(flagZone) then
        local territoryData = Excel.GetRow("TerritoryType", flagZone)

        if territoryData and territoryData.Aetheryte and territoryData.Aetheryte.PlaceName then
            local flagAetheryte = tostring(territoryData.Aetheryte.PlaceName.Name)
            LogDebug(string.format("[MoLib] Teleporting to map zone: '%s'.", flagAetheryte))
            Teleport(flagAetheryte)
        else
            LogDebug("[MoLib] Failed to retrieve Aetheryte information for teleportation.")
        end
    else
        LogDebug("[MoLib] Already in the correct zone. No teleport needed.")
    end
end

--------------------------------------------------------------------

-- Returns the aetheryte name for a given ZoneID.
function GetAetheryteName(ZoneID)
    local territoryData = Excel.GetRow("TerritoryType", ZoneID)

    if territoryData and territoryData.Aetheryte and territoryData.Aetheryte.PlaceName then
        return tostring(territoryData.Aetheryte.PlaceName.Name)
    else
        LogDebug(string.format("[MoLib] Could not resolve aetheryte name for zone ID: %d", ZoneID))
        return nil
    end
end

--=========================== UTILITIES ==========================--

--=================--
--    Utilities    --
--=================--

-- Wrapper for /echo that safely converts and outputs any message type (string, number, boolean, etc.)
-- Allows an optional prefix (default: "[MoLib]")
function Echo(msg, echoprefix)
    local prefix = echoprefix or "[MoLib]"
    local message = msg ~= nil and tostring(msg) or "nil"
    yield(string.format("/echo %s %s", prefix, message))
end

--------------------------------------------------------------------

-- Checks if a given plugin is installed
function HasPlugin(name)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == name and plugin.IsLoaded then
            LogDebug(string.format("[MoLib] Plugin '%s' found in InstalledPlugins.", name))
            return true
        end
    end

    LogDebug(string.format("[MoLib] Plugin '%s' not found in InstalledPlugins list.", name))
    return false
end

--------------------------------------------------------------------

-- Attempts to mount using a specific mount name or Mount Roulette if none is provided.
function UseMount(mountName)
    if mountName ~= nil and mountName ~= "" then
        LogDebug(string.format("[MoLib] Attempting to mount: %s", mountName))
        yield(string.format('/mount "%s"', mountName))
    else
        LogDebug("[MoLib] Attempting Mount Roulette")
        yield('/gaction "Mount Roulette"')
    end
end

--------------------------------------------------------------------

-- Stops all currently running macros.
function StopRunningMacros()
    LogDebug(string.format("[MoLib] Stopping all macros..."))
    yield("/snd stop all")
end

--=========================== INVENTORY ==========================--

-- Returns the number of free inventory slots the player currently has.
function GetInventoryFreeSlotCount()
    local freeSlots = Inventory.GetFreeInventorySlots()
    LogDebug(string.format("[MoLib] Checked inventory: %d free slots available", freeSlots))
    return freeSlots
end

--------------------------------------------------------------------

-- Returns the total count of a specific item in the player's inventory.
function GetItemCount(itemId)
    local count = Inventory.GetItemCount(itemId)
    LogDebug(string.format("[MoLib] Queried item ID %d: Count = %d", itemId, count))

    if count == 0 then
        local collectableCount = Inventory.GetCollectableItemCount(itemId, 1)
        LogDebug(string.format("[MoLib] Checked collectables for item ID %d: Count = %d", itemId, collectableCount))
        return collectableCount
    end

    return count
end

--=========================== INSTANCE ===========================--

-- Checks if the player can leave the current instanced content
function CanLeaveInstance()
    local canLeave = InstancedContent.CanLeaveCurrentContent()
    LogDebug(string.format("[MoLib] Can leave instance: %s", tostring(canLeave)))
    return canLeave
end

--------------------------------------------------------------------

-- Attempts to leave the current instanced content if allowed
function LeaveInstance()
    if CanLeaveInstance() then
        LogInfo(string.format("[MoLib] Leaving instanced content"))
        return InstancedContent.LeaveCurrentContent()
    else
        LogDebug(string.format("[MoLib] Cannot leave instance at this time"))
    end
end

--============================ REPAIRS ===========================--

-- Checks if any items in the specified container need repair.
function NeedsRepair(percentage)
    local repairList = Inventory.GetItemsInNeedOfRepairs(percentage)
    local needsRepair = repairList.Count > 0
    LogDebug(string.format("[MoLib] Checked for items below %d%% durability: %s", percentage, needsRepair and "Needs repair" or "No repairs needed"))
    return needsRepair
end

--------------------------------------------------------------------

-- Attempts to repair gear if any items fall below the repair threshold.
function Repair(RepairThreshold)
    RepairThreshold = RepairThreshold or 20

    if not NeedsRepair(RepairThreshold) then
        LogDebug(string.format("[MoLib] No gear repairs needed."))
        WaitForPlayer()
        Wait(1)
        return
    end

    LogDebug(string.format("[MoLib] Initiating gear repair process."))

    while not IsAddonVisible("Repair") do
        yield("/generalaction repair")
        Wait(1)
    end

    yield("/callback Repair true 0")
    Wait(1)

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        Wait(1)
    end

    while Svc.Condition[CharacterCondition.occupied] do
        Wait(1)
    end

    Wait(1)
    yield("/callback Repair true -1")

    LogDebug("[MoLib] Gear repair process completed.")

    WaitForPlayer()
    Wait(1)
end

--============================ MATERIA ===========================--

-- Returns a list of spiritbonded items from the player's inventory.
function CanExtractMateria()
    local bondedItems = Inventory.GetSpiritbondedItems()
    local count = (bondedItems and bondedItems.Count) or 0
    LogDebug(string.format("[MoLib] Found %d spiritbonded items.", count))
    return count
end

--------------------------------------------------------------------

-- Extracts materia from all spiritbonded gear if enabled and above the threshold.
function MateriaExtraction(ExtractMateria)
    ExtractMateria = ExtractMateria or false

    if not ExtractMateria then
        LogDebug(string.format("[MoLib] Materia extraction is disabled (ExtractMateria = false)."))
        WaitForPlayer()
        Wait(1)
        return
    end

    local extractable = CanExtractMateria()

    if extractable > 0 then
        yield("/generalaction \"Materia Extraction\"")
        yield("/waitaddon Materialize")

        while CanExtractMateria() > 0 do
            if not IsAddonVisible("Materialize") then
                yield("/generalaction \"Materia Extraction\"")
            end

            yield("/callback Materialize true 2")
            Wait(1)

            if IsAddonVisible("MaterializeDialog") then
                yield("/callback MaterializeDialog true 0")
                Wait(1)
            end

            while Svc.Condition[CharacterCondition.occupied] do
                Wait(1)
            end
        end

        Wait(1)
        yield("/callback Materialize true -1")
        Wait(1)

        LogDebug(string.format("[MoLib] Materia extraction completed."))
    else
        LogDebug(string.format("[MoLib] No items found for materia extraction."))
    end

    WaitForPlayer()
    Wait(1)
end

--=========================== RETAINERS ==========================--

function DoAR(DoAutoRetainers)
    if ARRetainersWaitingToBeProcessed() and DoAutoRetainers then
        LogDebug(string.format("[MoLib] Assigning ventures to Retainers."))
        MoveToTarget("Summoning Bell")
        Wait(1)
        Interact("Summoning Bell")

        while ARRetainersWaitingToBeProcessed() do
            Wait(1)
        end
        WaitForAR(DoAutoRetainers)

    elseif not DoAutoRetainers then
        LogDebug(string.format("[MoLib] AutoRetainers is disabled."))
    else
        LogDebug(string.format("[MoLib] No retainers currently need venture assignment."))
    end

    CloseAddons()
    ClearTarget()
end

--------------------------------------------------------------------

function WaitForAR(DoAutoRetainers)
    if not (ARRetainersWaitingToBeProcessed() and DoAutoRetainers) then
        return
    end

    LogDebug(string.format("%[MoLib] Waiting for AutoRetainers to complete."))
    Wait(1)

    while Svc.Condition[CharacterCondition.occupiedSummoningBell] do
        WaitForPlayer()
    end
end

--============================= LOG ==============================--

--===========--
--    Log    --
--===========--

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

--------------------------------------------------------------------

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

--------------------------------------------------------------------