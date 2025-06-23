--[[============================================================
    Crescent Occult - FFXIV CE Farming Automation Script
    ------------------------------------------------------------
    Author   : Mo
    Version  : 1.0.0
    Purpose  : Automates CE farming in South Horn using
               Phantom Jobs and navigation tools.

    Dependencies:
        - RotationSolver
        - BossModReborn
        - Lifestream
        - TeleporterPlugin
        - vnavmesh
        - visland
        - YesAlready

============================================================]]--


-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

local buffMacro = "Job Buffs"
local runBuffs = false
local mountCommand = '/gaction "Mount Roulette"'
local vislandRoute = "Chests"
local runChestsRoute = true
local logPrefix = "[CEFarm] "
local actionsOC = {
    OccultReturn = 41343
}

---------------------
--    Constants    --
---------------------

local wait_Short = 1.0
local wait_Medium = 2.0
local wait_Long = 3.0
local wait_vLong = 5.0
local timeout_Moving = 120
local timeout_Visland = 1200
local timeout_OCHelper = 7200

----------------
--    Zone    --
----------------

local zoneID = GetZoneID()
local zones = {
    SouthHorn = 1252,
    PhantomVillage = 1278
}

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

requiredPlugins = {
    "RotationSolver",
    "BossModReborn",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "visland",
    "YesAlready"
}

---------------------
--    Condition    --
---------------------

characterCondition = {
    mounted=4,
    inCombat=26,
    casting=27,
    boundByDuty=34,
    occupiedInCutSceneEvent=35,
    occupied=39,
    betweenAreas=45
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function plugins()
    local missing = {}
    for _, plugin in ipairs(requiredPlugins) do
        if not HasPlugin(plugin) then
            table.insert(missing, plugin)
        end
    end
    if #missing > 0 then
        for _, plugin in ipairs(missing) do
            yield("/echo ".. logPrefix .. "Missing required plugin: "..plugin)
        end
        yield("/echo ".. logPrefix .. "One or more required plugins are missing. Stopping the script.")
        yield("/snd stop")
    end
end

----------------
--    Wait    --
----------------

function wait(seconds)
    yield(string.format("/wait %.1f", seconds))
end

function waitWhileMoving()
    LogVerbose(logPrefix .. "Waiting until navigation is finished...")
    local timeout = os.time() + (timeout_Moving or 120)  -- default 2 minutes if not specified
    while (PathIsRunning() or PathfindInProgress()) and os.time() < timeout do
        LogDebug(string.format(logPrefix .. "Looping: PathIsRunning=%s, PathfindInProgress=%s, TimeLeft=%d", tostring(PathIsRunning()), tostring(PathfindInProgress()), timeout - os.time()))
        wait(wait_Short)
    end
    LogInfo(logPrefix .. "Navigation finished or timed out.")
end

function awaitReady()
    LogVerbose(logPrefix .. "Checking Readiness...")
    -- Wait until not busy
    while GetCharacterCondition(characterCondition.inCombat) or GetCharacterCondition(characterCondition.casting) or IsMoving() or not IsPlayerAvailable() do
        LogDebug(logPrefix .. "Waiting for Player...")
        wait(wait_Short)
    end
    -- Wait for NavMesh
    while not NavIsReady() do
        LogDebug(logPrefix .. "Waiting for NavMesh...")
        wait(wait_Short)
    end
    -- Cutscene check
    while GetCharacterCondition(characterCondition.occupiedInCutSceneEvent) do
        LogDebug(logPrefix .. "In cutscene. Waiting...")
        wait(wait_Short)
    end
    -- Between areas
    while GetCharacterCondition(characterCondition.betweenAreas) do
        LogDebug(logPrefix .. "Waiting for inbetween Areas...")
        wait(wait_Short)
    end
    wait(wait_Short)
    LogInfo(logPrefix .. "Player is ready.")
end

function waitForLifeStream()
    LogVerbose(logPrefix .. "Waiting for Lifestream...")
    while LifestreamIsBusy() do
        wait(wait_Short)
    end
    LogInfo(logPrefix .. "Lifestream complete. Awaiting readiness...")
    awaitReady()
end
 
----------------
--    Move    --
----------------

function moveTo(x, y, z, randomness)
    if not IsInZone(zones.SouthHorn) then
        return
    end
    local randX = rand(x, randomness)
    local randZ = rand(z, randomness)
    awaitReady()
    LogInfo(logPrefix .. "Moving to coordinates: " .. tostring(randX) .. ", " .. tostring(y) .. ", " .. tostring(randZ))
    yield("/vnav moveto " .. randX .. " " .. y .. " " .. randZ)
    wait(wait_Short)
    waitWhileMoving()
end

function moveToOC()
    awaitReady()
    local command = "/li Occult"
    wait(wait_Short)
    if IsInZone(zones.PhantomVillage) then
        command = "/li EnterOC"
    end
    wait(wait_Short)
    yield(command)
    LogInfo(logPrefix .. "Teleporting to Occult Crescent...")
    waitForLifeStream()
end

-----------------
--    Mount    --
-----------------

function mountUp()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    LogVerbose(logPrefix .. "Mounting...")
    while not GetCharacterCondition(characterCondition.mounted) and IsInZone(zones.SouthHorn) do
        yield(mountCommand)
        wait(wait_Long)
    end
    LogInfo(logPrefix .. "Mounted successfully.")
end

function dismount()
    if not GetCharacterCondition(characterCondition.mounted) then
        return
    end
    LogVerbose(logPrefix .. "Dismounting...")
    while GetCharacterCondition(characterCondition.mounted) do
        yield("/gaction Dismount")
        wait(wait_Short)
    end
    LogInfo(logPrefix .. "Dismounted successfully.")
end

----------------
--    Misc    --
----------------

function stanceOff()
    if not IsPlayerAvailable() then
        return
    end
    if HasStatus("Defiance") then
        LogInfo(logPrefix .. "Turning off Defiance stance...")
        yield("/action Defiance")
        wait(wait_Short)
    end
end

function rotationON()
    LogInfo(logPrefix .. "Setting rotation to LowHP mode...")
    yield("/rotation auto LowHP")
    wait(wait_Short)
end

function aiON()
    LogInfo(logPrefix .. "Enabling BattleMod AI...")
    yield("/bmrai on")
    wait(wait_Short)
end

function useBuffs()
    if not runBuffs or not IsInZone(zones.SouthHorn) then
        return
    end
    LogInfo(logPrefix .. "Applying support buffs...")
    moveTo(836.92, 73.12, -707.14, 0.2)
    dismount()
    yield("/snd run "..buffMacro)
    repeat
        wait(wait_Short)
    until not IsMacroRunningOrQueued(buffMacro)
    wait(wait_Short)
end

function runVislandRoute(routeName, timeoutSeconds)
    if not runChestsRoute or not IsInZone(zones.SouthHorn) then
        return
    end
    -- Start the route via IPC
    awaitReady()
    yield("/visland execonce "..routeName)
    wait(wait_Short)
    if not IsVislandRouteRunning() then
        LogDebug(logPrefix .. "Failed to start Visland route: " .. routeName)
        return false
    end
    LogInfo(logPrefix .. "Visland Route started: " .. routeName)
    -- Wait for the route to complete via IPC
    local timeout = os.time() + (timeoutSeconds or 1200)  -- default 20 minutes if not specified
    while IsVislandRouteRunning() do
        if os.time() >= timeout then
    -- Timeout reached
            LogDebug(logPrefix .. "Timeout waiting for Visland route to finish.")
            yield("/visland stop")
            return false
        end
        LogDebug(string.format(logPrefix .. "Looping: IsVislandRouteRunning=%s, TimeLeft=%d", tostring(IsVislandRouteRunning()), timeout - os.time()))
        wait(wait_Long)
    end
    LogInfo(logPrefix .. "Visland Route completed successfully.")
    wait(wait_Short)
    return true
end

function rand(value, range)
    return value + (math.random() * 2 - 1) * (range or 0)
end

----------------
--    Main    --
----------------

function startFarm()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    LogInfo(logPrefix .. "Starting CE farm...")
    stanceOff()
    rotationON()
    aiON()
    useBuffs()
    yield("/ochillegal on")
    local timeout = os.time() + (timeout_OCHelper or 7200)  -- default 2 hours in seconds (7200)
    while IsInZone(zones.SouthHorn) do
        if os.time() >= timeout then
            LogInfo(logPrefix .. "Timeout reached. Exiting loop...")
            awaitReady()
            yield("/ochillegal off")
            wait(wait_vLong)
            awaitReady()
            break
        end
        stanceOff()
        LogDebug(string.format(logPrefix .. "Looping: CEFarm, TimeLeft=%d", timeout - os.time()))
        wait(wait_vLong)
    end
    awaitReady()
    yield("/rotation off")
    yield("/bmrai off")
    awaitReady()
    ExecuteAction(actionsOC.OccultReturn)
    awaitReady()
    runVislandRoute(vislandRoute, timeout_Visland)
    if IsInZone(zones.SouthHorn) then
        LeaveDuty()
    end
end

-------------------------------- Execution --------------------------------

plugins()
while true do
    if IsInZone(zones.SouthHorn) then
        LogInfo(logPrefix .. "In SouthHorn zone. Beginning CE farm cycle.")
        startFarm()
        awaitReady()
    else
        LogInfo(logPrefix .. "Not in SouthHorn. Moving to Occult Crescent zone...")
        moveToOC()
        awaitReady()
    end
    wait(wait_Short)
end

----------------------------------- End -----------------------------------