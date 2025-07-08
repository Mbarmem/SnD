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

local runsBeforeExit = 10
local mountCommand = '/gaction "Mount Roulette"'
local vislandRoute = "Chests"
local logPrefix = "[CEFarm] "
local actionsOC = {
    OccultReturn = 41343
}
local originalJob = "Samurai"
local jobBuffs = {
    "Knight", "Bard"  --Monk crashes the game
}
local phantomJobs = {
    { className = "Freelancer", classAbility = "" },
    { className = "Knight", classAbility = 32 },
    { className = "Berserker", classAbility = "" },
    { className = "Monk", classAbility = "" },
    { className = "Ranger", classAbility = "" },
    { className = "Samurai", classAbility = "" },
    { className = "Bard", classAbility = 32 },
    { className = "Geomancer", classAbility = "" },
    { className = "TimeMage", classAbility = "" },
    { className = "Cannoneer", classAbility = "" },
    { className = "Oracle", classAbility = "" },
    { className = "Chemist", classAbility = "" },
    { className = "Thief", classAbility = "" },
}

---------------------
--    Constants    --
---------------------

local wait_Short = 1.0
local wait_Medium = 2.0
local wait_Long = 3.0
local wait_vLong = 5.0
local timeout_CE = 480
local timeout_Moving = 120
local timeout_Visland = 1200

----------------
--    Zone    --
----------------

local zoneID = GetZoneID()
local zones = {
    SouthHorn = 1252,
    PhantomVillage = 1278
}
local ceAetherytes = {
    [zones.SouthHorn] = {
        Northwest = {
            name = "The Wanderer's Haven",
        },
        West = {
            name = "Crystallized Caverns",
        },
        Southwest = {
            name = "Stonemarsh",
        },
        Southeast = {
            name = "Eldergrowth",
        },
        Home = {
            name = "Expedition Base Camp",
            coord = { 831, 73, -699 },
        },
    },
}
local ceData = {
    [zones.SouthHorn] = {
        name = "South Horn",
        aetherytes = ceAetherytes[zones.SouthHorn],
        ceList = {
            [1] = {
                eventID = 1,
                name = "Scourge of the Mind",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 320, 70, 719 },
            },
            [2] = {
                eventID = 2,
                name = "The Black Regiment",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 428, 65, 337 },
            },
            [3] = {
                eventID = 3,
                name = "The Unbridled",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 621, 79, 777 },
            },
            [4] = {
                eventID = 4,
                name = "Crawling Death",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 680, 74, 511 },
            },
            [5] = {
                eventID = 5,
                realType = 1,
                name = "Calamity Bound",
                aetheryte = ceAetherytes[zones.SouthHorn].Southwest,
                coord = { -351, 75, 779 },
            },
            [6] = {
                eventID = 6,
                name = "Trial by Claw",
                aetheryte = ceAetherytes[zones.SouthHorn].West,
                coord = { -410, 92, 56 },
            },
            [7] = {
                eventID = 7,
                name = "From Times Bygone",
                aetheryte = ceAetherytes[zones.SouthHorn].Southwest,
                coord = { -799, 44, 266 },
            },
            [8] = {
                eventID = 8,
                realType = 3,
                name = "Company of Stone",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 665, 96, -261 },
            },
            [9] = {
                eventID = 9,
                name = "Shark Attack",
                aetheryte = ceAetherytes[zones.SouthHorn].Northwest,
                coord = { -119, 1, -836 },
            },
            [10] = {
                eventID = 10,
                name = "On the Hunt",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 644, 108, -30 },
            },
            [11] = {
                eventID = 11,
                name = "With Extreme Prejudice",
                aetheryte = ceAetherytes[zones.SouthHorn].Northwest,
                coord = { -335, 5, -607 },
            },
            [12] = {
                eventID = 12,
                name = "Noise Complaint",
                aetheryte = ceAetherytes[zones.SouthHorn].Home,
                coord = { 485, 97, -371 },
            },
            [13] = {
                eventID = 13,
                name = "Cursed Concern",
                aetheryte = ceAetherytes[zones.SouthHorn].Northwest,
                coord = { 47, 20, -547 },
            },
            [14] = {
                eventID = 14,
                name = "Eternal Watch",
                aetheryte = ceAetherytes[zones.SouthHorn].Southeast,
                coord = { 857, 122, 168 },
            },
            [15] = {
                eventID = 15,
                name = "Flame of Dusk",
                aetheryte = ceAetherytes[zones.SouthHorn].West,
                coord = { -552, 97, -149 },
            },
        },
    },
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

function awaitCEPop()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    awaitReady()
    buffs()
    mountUp()
    inactivity()
    local timeout = os.time() + (timeout_CE or 480)  -- default 8 minutes if not specified
    while os.time() < timeout and IsInZone(zones.SouthHorn) do
        local ceList = GetOccultCrescentEvents()
        for i = 0, ceList.Count - 1 do
            local eventId = tonumber(ceList[i])
            local eventState = GetOccultCrescentEventState(eventId)
            if eventState == "Register" then
                local ce = ceData[zoneID].ceList[eventId]
                if ce then
                    LogInfo(logPrefix .. "Found active CE: " .. ce.name)
                    return ce
                end
            end
        end
        LogDebug(string.format(logPrefix .. "No CE ready. Rechecking in 3 seconds..., TimeLeft=%d", timeout - os.time()))
        wait(wait_Long)
    end
    LogDebug(logPrefix .. "CE pop wait ended (timeout or zone exit).")
    wait(wait_Medium)
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
    if IsInZone(zones.PhantomVillage) then
        command = "/li EnterOC"
    end
    yield(command)
    LogInfo(logPrefix .. "Teleporting to Occult Crescent...")
    waitForLifeStream()
end

function moveToCE(activeCE)
    if not (IsInZone(zones.SouthHorn) and activeCE) then
        return
    end
    local ceData = ceData[zoneID]
    if not ceData or not ceData.ceList then
        return
    end
    local ce = ceData.ceList[activeCE.eventID]
    if ce and ce.coord then
        local x, y, z = ce.coord[1], ce.coord[2], ce.coord[3]
        moveTo(x, y, z, 1)
    end
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

function inactivity()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    -- Move to idle spot and dismount
    moveTo(776.68, 66.33, -767.60, 0.5)
    dismount()
    wait(wait_vLong)
    -- Wait until combat ends
    while GetCharacterCondition(characterCondition.inCombat) do
        LogDebug(logPrefix .. "Waiting for Combat...")
        wait(wait_Short)
    end
    -- Return to home aetheryte
    mountUp()
    local homeCoord = ceAetherytes[zoneID].Home.coord
    moveTo(homeCoord[1], homeCoord[2], homeCoord[3], 0.5)
    dismount()
end

function changeSupportJob(jobName)
    if not IsInZone(zones.SouthHorn) or not jobName then
        return
    end
    LogInfo(logPrefix .. "Changing support job to: " .. jobName)
    yield("/phantomjob " .. jobName)
    wait(wait_Medium)
end

function useSupportAction(jobBuffs)
    if not IsInZone(zones.SouthHorn) then
        return
    end
    for _, buff in ipairs(jobBuffs) do
        for _, job in ipairs(phantomJobs) do
            if job.className == buff and job.classAbility and job.classAbility ~= "" then
                changeSupportJob(job.className)
                LogInfo(logPrefix .. "Using support action: " .. job.classAbility .. " (" .. job.className .. ")")
                ExecuteGeneralAction(job.classAbility)
                wait(wait_Medium)
            end
        end
    end
end

function buffs()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    LogInfo(logPrefix .. "Applying support buffs...")
    moveTo(836.92, 73.12, -707.14, 0.2)
    dismount()
    useSupportAction(jobBuffs)
    changeSupportJob(originalJob)
    wait(wait_Short)
end

function runVislandRoute(routeName, timeoutSeconds)
    if not IsInZone(zones.SouthHorn) then
        return
    end
    -- Start the route via IPC
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

function goToCE(activeCE)
    if not (IsInZone(zones.SouthHorn) and activeCE) then
        return
    end
    LogVerbose(logPrefix .. "Starting CE navigation process...")
    awaitReady()
    -- Navigate to home aetheryte
    local homeCoord = ceAetherytes[zoneID].Home.coord
    LogVerbose(logPrefix .. "Navigating to home aetheryte at coordinates: (" .. homeCoord[1] .. ", " .. homeCoord[2] .. ", " .. homeCoord[3] .. ")")
    moveTo(homeCoord[1], homeCoord[2], homeCoord[3], 0.5)
    LogVerbose(logPrefix .. "Reached home aetheryte.")
    -- Teleport to the CE's aetheryte if different from current
    local currentAetheryte = ceAetherytes[zoneID].Home.name
    local targetAetheryte = activeCE.aetheryte.name
    if targetAetheryte ~= currentAetheryte and IsInZone(zones.SouthHorn) then
        dismount()
        LogVerbose(logPrefix .. "Teleporting to CE aetheryte: " .. targetAetheryte)
        yield("/li " .. targetAetheryte)
        wait(wait_Long)
    end
    awaitReady()
    -- Navigate to the CE location
    LogVerbose(logPrefix .. "Navigating to CE location...")
    mountUp()
    moveToCE(activeCE)
    LogInfo(logPrefix .. "Successfully arrived at CE: " .. activeCE.name)
    return true
end

function awaitCEFinish(activeCE)
    if not (IsInZone(zones.SouthHorn) and activeCE) then
        return
    end
    LogVerbose(logPrefix .. "Waiting for CE to finish: " .. activeCE.name)
    while IsInZone(zones.SouthHorn) do
        local eventState = GetOccultCrescentEventState(activeCE.eventID)
        if eventState == "Inactive" then
            LogDebug(logPrefix .. "CE is now inactive...")
            break
        end
        LogDebug(logPrefix .. "CE still active (state: " .. eventState .. "). Checking again in 5 seconds...")
        wait(wait_vLong)
    end
    wait(wait_Short)
    awaitReady()
    LogInfo(logPrefix .. "Finished waiting. CE concluded...")
    return true
end

function goHome()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    LogVerbose(logPrefix .. "Initiating return home sequence...")
    awaitReady()
    if IsInZone(zones.SouthHorn) then
        LogDebug(logPrefix .. "Too far from home. Executing Occult Return...")
        ExecuteAction(actionsOC.OccultReturn)
    end
    -- Wait for transition (between areas) to begin
    while not GetCharacterCondition(characterCondition.betweenAreas) and IsInZone(zones.SouthHorn) do
        LogDebug(logPrefix .. "Waiting for inbetween Areas...")
        wait(wait_Short)
    end
    awaitReady()
    LogInfo(logPrefix .. "Successfully returned home...")
    return true
end

function startFarm()
    if not IsInZone(zones.SouthHorn) then
        return
    end
    local ceCount = 0
    LogInfo(logPrefix .. "Starting CE farm...")
    stanceOff()
    rotationON()
    aiON()
    while ceCount < runsBeforeExit and IsInZone(zones.SouthHorn) do
        LogInfo(logPrefix .. "Waiting for CE #" .. (ceCount + 1) .. " to appear...")
        local activeCE = awaitCEPop()
        if not activeCE then
            LogDebug(logPrefix .. "No CE detected. Aborting farm.")
            break
        end
        goToCE(activeCE)
        awaitCEFinish(activeCE)
        goHome()
        wait(wait_Short)
        ceCount = ceCount + 1
        LogInfo(logPrefix .. "Completed CE #" .. ceCount)
    end
    yield("/rotation off")
    yield("/bmrai off")
    LogInfo(logPrefix .. "Stopping CE farm. Total CEs completed: " .. ceCount)
    runVislandRoute(vislandRoute, 1200)
    if IsInZone(zones.SouthHorn) then
        LeaveDuty()
    end
    return ceCount
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