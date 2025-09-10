--========================= DEPENDENCIES =========================--

import("System")
import("System.Numerics")

--=========================== CONSTANT ===========================--

--==============--
--    Action    --
--==============--

--- Defines character action constants
CharacterAction = {
    Actions = {
        defiance           =     48,
        castFishing        =    289,
        quitFishing        =    299,
        feint              =   7549,
        dokumori           =  36957,
        occultReturn       =  41343,
        stellarReturn      =  42149,
    },

    ChocoboRaceAbility = {
        superSprint        =     58,
    },

    GeneralActions = {
        jump               =      2,
        sprint             =      4,
        desynthesis        =      5,
        repair             =      6,
        mount              =      9,
        materiaExtraction  =     14,
        decipher           =     19,
        dig                =     20,
        aetherialReduction =     21,
        dismount           =     23,
        dutyActionI        =     26,
        dutyActionII       =     27,
        phantomActionI     =     31,
        phantomActionII    =     32,
        phantomActionIII   =     33,
        phantomActionIV    =     34,
        phantomActionV     =     35,
    }
}

--=================--
--    Condition    --
--=================--

--- Defines character condition constants
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

--========================== FUNCTIONS ===========================--

--==============--
--    Player    --
--==============--

--- Wrapper for Player.Available
--- Checks if the player is currently available and not busy
--- @return boolean isAvailable    true if the player is available; false otherwise
function IsPlayerAvailable()
    local isAvailable = Player and Player.Available and not Player.IsBusy
    LogDebug(string.format("[MoLib] IsPlayerAvailable: %s", tostring(isAvailable)))
    return isAvailable
end

---------------------------------------------------------------------

--- Checks if the player is currently dead
--- @return boolean isDead    true if player is dead; false otherwise
function IsDead()
    local isDead = Svc.Condition[CharacterCondition.dead]
    LogDebug(string.format("[MoLib] IsDead: %s", tostring(isDead)))
    return isDead
end

---------------------------------------------------------------------

--- Checks if the player is currently mounted
--- @return boolean isMounted    true if player is mounted; false otherwise
function IsMounted()
    local isMounted = Svc.Condition[CharacterCondition.mounted]
    LogDebug(string.format("[MoLib] IsMounted: %s", tostring(isMounted)))
    return isMounted
end

---------------------------------------------------------------------

--- Checks if the player is currently crafting
--- @return boolean isCrafting    true if player is crafting, false otherwise
function IsCrafting()
    local isCrafting = Svc.Condition[CharacterCondition.crafting]
    LogDebug(string.format("[MoLib] IsCrafting: %s", tostring(isCrafting)))
    return isCrafting
end

---------------------------------------------------------------------

--- Checks if the player is currently gathering
--- @return boolean isGathering    true if player is gathering; false otherwise
function IsGathering()
    local isGathering = Svc.Condition[CharacterCondition.gathering]
    LogDebug(string.format("[MoLib] IsGathering: %s", tostring(isGathering)))
    return isGathering
end

---------------------------------------------------------------------

--- Checks if the player is currently occupied in a mini-game
--- @return boolean isMiniGame    true if player is playing a mini-game; false otherwise
function IsPlayingMiniGame()
    local isMiniGame = Svc.Condition[CharacterCondition.playingMiniGame]
    LogDebug(string.format("[MoLib] IsPlayingMiniGame: %s", tostring(isMiniGame)))
    return isMiniGame
end

---------------------------------------------------------------------

--- Checks if the player is currently playing Lord of Verminion
--- @return boolean isPlaying    true if player is playing Lord of Verminion; false otherwise
function IsPlayingLordOfVerminion()
    local isPlaying = Svc.Condition[CharacterCondition.playingLordOfVerminion]
    LogDebug(string.format("[MoLib] IsPlayingLordOfVerminion: %s", tostring(isPlaying)))
    return isPlaying
end

---------------------------------------------------------------------

--- Checks if the player is currently in an occupied state
--- @return boolean isOccupied    true if player is occupied; false otherwise
function IsOccupied()
    local isOccupied = Svc.Condition[CharacterCondition.occupied] or Svc.Condition[CharacterCondition.occupied39]
    LogDebug(string.format("[MoLib] IsOccupied: %s", tostring(isOccupied)))
    return isOccupied
end

---------------------------------------------------------------------

--- Checks if the player is currently in combat
--- @return boolean isInCombat    true if player is in combat; false otherwise
function IsInCombat()
    local isInCombat = Player and Player.Entity and Player.Entity.IsInCombat or false
    LogDebug(string.format("[MoLib] IsInCombat: %s", tostring(isInCombat)))
    return isInCombat
end

---------------------------------------------------------------------

--- Wrapper for Player.Entity.IsCasting
--- @return boolean isCasting    true if player is casting, false otherwise
function IsPlayerCasting()
    local isCasting = Player.Entity and Player.Entity.IsCasting
    LogDebug(string.format("[MoLib] IsPlayerCasting: %s", tostring(isCasting)))
    return isCasting
end

---------------------------------------------------------------------

--- Checks if the player is currently occupied in a quest event (e.g. cutscene or interactive scene)
--- @return boolean inQuestEvent    true if player is occupied in a quest event; false otherwise
function IsOccupiedInQuestEvent()
    local inQuestEvent = Svc.Condition[CharacterCondition.occupiedInQuestEvent]
    LogDebug(string.format("[MoLib] IsOccupiedInQuestEvent: %s", tostring(inQuestEvent)))
    return inQuestEvent
end

---------------------------------------------------------------------

--- Checks if the player is currently bound by duty
--- @return boolean isBoundByDuty    true if player is bound by duty; false otherwise
function IsBoundByDuty()
    local isBoundByDuty = Svc.Condition[CharacterCondition.boundByDuty] or Svc.Condition[CharacterCondition.boundByDuty56]
    LogDebug(string.format("[MoLib] IsBoundByDuty: %s", tostring(isBoundByDuty)))
    return isBoundByDuty
end

---------------------------------------------------------------------

--- Checks if the player is currently occupied in a cutscene
--- @return boolean inCutscene    true if player is occupied in a cutscene; false otherwise
function IsOccupiedInCutScene()
    local inCutscene = Svc.Condition[CharacterCondition.occupiedInCutscene]
    LogDebug(string.format("[MoLib] IsOccupiedInCutScene: %s", tostring(inCutscene)))
    return inCutscene
end

---------------------------------------------------------------------

--- Checks if the player is currently fishing
--- @return boolean isFishing    true if player is fishing; false otherwise
function IsFishing()
    local isFishing = Svc.Condition[CharacterCondition.fishing]
    LogDebug(string.format("[MoLib] IsFishing: %s", tostring(isFishing)))
    return isFishing
end

---------------------------------------------------------------------

--- Checks if the player is currently between areas
--- @return boolean isBetweenAreas    true if player is between areas; false otherwise
function IsBetweenAreas()
    local isBetweenAreas = Svc.Condition[CharacterCondition.betweenAreas]
    LogDebug(string.format("[MoLib] IsBetweenAreas: %s", tostring(isBetweenAreas)))
    return isBetweenAreas
end

---------------------------------------------------------------------

--- Checks if the player is currently occupied with the summoning bell
--- @return boolean isSummoningBell    true if player is occupied with the summoning bell; false otherwise
function IsOccupiedSummoningBell()
    local isSummoningBell = Svc.Condition[CharacterCondition.occupiedSummoningBell]
    LogDebug(string.format("[MoLib] IsOccupiedSummoningBell: %s", tostring(isSummoningBell)))
    return isSummoningBell
end

---------------------------------------------------------------------

--- Waits until the player is available
--- Continuously yields in short intervals until IsPlayerAvailable returns true
--- @return nil
function WaitForPlayer()
    LogDebug(string.format("[MoLib] WaitForPlayer: Waiting for player..."))

    repeat
        Wait(0.1)
    until IsPlayerAvailable()
    LogDebug(string.format("[MoLib] WaitForPlayer: Player is now available"))
    Wait(0.1)
end

--------------------------------------------------------------------

--- Returns the current player's character name
--- @return string|nil name    the character name, or nil if unavailable
function GetCharacterName()
    local name = Entity and Entity.Player and Entity.Player.Name

    if name then
        LogDebug(string.format("[MoLib] GetCharacterName: %s", tostring(name)))
        return name
    end
    return nil
end

--------------------------------------------------------------------

--- Returns the current player's class/job ID, or compares it with a given ID
--- @param id number?                    [optional] job ID to compare against
--- @return number|boolean|nil result    job ID if no compare ID is provided, boolean if comparing, or nil if unavailable
--- @overload fun(): number|nil
--- @overload fun(id: number): boolean
function GetClassJobId(id)
    local jobId = Player and Player.Job and Player.Job.Id
    LogDebug(string.format("[MoLib] GetClassJobId: %s", tostring(jobId)))

    if id then
        return jobId == id
    end
    return jobId
end

--------------------------------------------------------------------

--- Checks if the player has a target, optionally matching a given name
--- @param targetName string?    [optional] target name to match
--- @return boolean hasTarget    true if a target exists and matches (if provided), false otherwise
--- @overload fun(targetName?: string): boolean
function HasTarget(targetName)
    local currentTarget = Entity and Entity.Player and Entity.Player.Target

    if targetName then
        local hasTarget = currentTarget and currentTarget.Name == targetName
        LogDebug(string.format("[MoLib] HasTarget '%s': %s", targetName, tostring(hasTarget)))
        return hasTarget
    end
    local hasTarget = currentTarget ~= nil
    LogDebug(string.format("[MoLib] HasTarget: %s", tostring(hasTarget)))
    return hasTarget
end

--------------------------------------------------------------------

--- Checks if the player currently has a status with the specified StatusId
--- @param targetId number     the status ID to check for
--- @return boolean success    true if the status is found, false otherwise
function HasStatusId(targetId)
    local statusList = Player.Status
    LogDebug(string.format("[MoLib] Checking for StatusId = %d", targetId))

    if not statusList then
        LogDebug("[MoLib] Player.Status is nil")
        return false
    end

    for i = 0, statusList.Count - 1 do
        local status = statusList:get_Item(i)

        if status and status.StatusId == targetId then
            LogDebug(string.format("[MoLib] Found matching StatusId at index %d", i))
            return true
        end
    end
    LogDebug(string.format("[MoLib] StatusId %d not found in Player.Status list", targetId))
    return false
end

--------------------------------------------------------------------

--- Checks if the player has a specific status and returns its remaining time
--- @param targetId number           the status ID to check for
--- @return number? remainingTime    remaining time in seconds if the status is found, nil otherwise
function GetStatusTimeRemaining(targetId)
    local statusList = Player.Status
    LogDebug(string.format("[MoLib] Checking remaining time for StatusId = %d", targetId))

    if not statusList then
        LogDebug("[MoLib] Player.Status is nil")
        return nil
    end

    for i = 0, statusList.Count - 1 do
        local status = statusList:get_Item(i)

        if status and status.StatusId == targetId then
            LogDebug(string.format("[MoLib] Found StatusId %d at index %d with remaining time %.2f seconds", targetId, i, status.RemainingTime))
            return status.RemainingTime
        end
    end
    LogDebug(string.format("[MoLib] StatusId %d not found in Player.Status list", targetId))
    return nil
end

--============================= IPC ==============================--

--===============--
--    Artisan    --
--===============--

--- Checks if an Artisan crafting list is currently running
--- @return boolean isRunning    true if Artisan crafting list is running, false otherwise
function ArtisanIsListRunning()
    local isRunning = IPC.Artisan.IsListRunning()
    LogDebug(string.format("[MoLib] Artisan list running: %s", tostring(isRunning)))
    return isRunning
end

--------------------------------------------------------------------

--- Checks if an Artisan crafting list is currently paused
--- @return boolean isPaused    true if Artisan crafting list is paused, false otherwise
function ArtisanIsListPaused()
    local isPaused = IPC.Artisan.IsListPaused()
    LogDebug(string.format("[MoLib] Artisan list paused: %s", tostring(isPaused)))
    return isPaused
end

--------------------------------------------------------------------

--- Retrieves the current endurance status from the Artisan system
--- @return boolean status    true if endurance is enabled, false otherwise
function ArtisanGetEnduranceStatus()
    local status = IPC.Artisan.GetEnduranceStatus()
    LogDebug(string.format("[MoLib] Artisan endurance status retrieved: %s", tostring(status)))
    return status
end

--------------------------------------------------------------------

--- Sets the endurance status for the Artisan system
--- @param status boolean    the endurance status value to set (true to enable, false to disable)
--- @return nil
function ArtisanSetEnduranceStatus(status)
    LogDebug(string.format("[MoLib] Artisan endurance status set to: %s", tostring(status)))
    IPC.Artisan.SetEnduranceStatus(status)
end

--------------------------------------------------------------------

--- Queues a crafting request in Artisan for the specified item and quantity
--- @param itemId number      the recipe ID of the item to craft
--- @param quantity number    the number of items to craft (must be > 0)
--- @return nil
function ArtisanCraftItem(itemId, quantity)
    local id  = tonumber(itemId) or 0
    local qty = math.floor(tonumber(quantity) or 0)

    if id <= 0 then
        LogDebug("[MoLib] ArtisanCraftItem: invalid itemId, ignoring craft request")
        return
    end

    if qty <= 0 then
        LogDebug("[MoLib] ArtisanCraftItem: quantity <= 0, ignoring craft request")
        return
    end
    LogDebug(string.format("[MoLib] Queuing Artisan craft: itemId = %d, quantity = %d", id, qty))
    IPC.Artisan.CraftItem(id, qty)
end

--------------------------------------------------------------------

--================--
--    AutoDuty    --
--================--

--- Sets a configuration key-value pair for AutoDuty via IPC
--- @param key string    the configuration key
--- @param value any     the configuration value
--- @return nil
function AutoDutyConfig(key, value)
    LogDebug(string.format("[MoLib] AutoDuty config: %s = %s", tostring(key), tostring(value)))
    IPC.AutoDuty.SetConfig(key, value)
end

--------------------------------------------------------------------

--- Starts an AutoDuty run with the specified territory and parameters
--- @param territoryType number    the territory ID to run
--- @param loops number            the number of loops to run
--- @param bareMode boolean        whether to run in bare mode
--- @return nil
function AutoDutyRun(territoryType, loops, bareMode)
    LogDebug(string.format("[MoLib] Running duty: territoryType = %s, loops = %s, bareMode = %s", tostring(territoryType), tostring(loops), tostring(bareMode)))
    IPC.AutoDuty.Run(territoryType, loops, bareMode)
end

--------------------------------------------------------------------

--- Starts an AutoDuty run with the specified start flag
--- @param startFromZero boolean    whether to start from zero
--- @return nil
function AutoDutyStart(startFromZero)
    LogDebug(string.format("[MoLib] Starting AutoDuty with startFromZero: %s", tostring(startFromZero)))
    IPC.AutoDuty.Start(startFromZero)
end

--------------------------------------------------------------------

--- Stops the AutoDuty run
--- @return nil
function AutoDutyStop()
    LogDebug(string.format("[MoLib] AutoDuty stopped"))
    IPC.AutoDuty.Stop()
end

--------------------------------------------------------------------

--- Checks if AutoDuty is currently running
--- @return boolean isRunning    true if AutoDuty is running, false otherwise
function AutoDutyIsRunning()
    local isRunning = IPC.AutoDuty.IsLooping() or false
    LogDebug(string.format("[MoLib] AutoDuty is running: %s", tostring(isRunning)))
    return isRunning
end

--------------------------------------------------------------------

--- Checks if AutoDuty is currently stopped
--- @return boolean isStopped    true if AutoDuty is stopped, false otherwise
function AutoDutyIsStopped()
    local isStopped = IPC.AutoDuty.IsStopped() or false
    LogDebug(string.format("[MoLib] AutoDuty is stopped: %s", tostring(isStopped)))
    return isStopped
end

--------------------------------------------------------------------

--================--
--    AutoHook    --
--================--

--- Sets the AutoHook plugin to use a specific preset
--- @param presetName string    the name of the preset to set
--- @return nil
function SetAutoHookPreset(presetName)
    LogDebug(string.format("[MoLib] AutoHook preset set to: %s", tostring(presetName)))
    IPC.AutoHook.SetPreset(presetName)
end

--------------------------------------------------------------------

--- Sets the AutoHook plugin state
--- @param state boolean    the desired plugin state (true to enable, false to disable)
--- @return nil
function SetAutoHookState(state)
    LogDebug(string.format("[MoLib] AutoHook state set to: %s", tostring(state)))
    IPC.AutoHook.SetPluginState(state)
end

--------------------------------------------------------------------

--====================--
--    AutoRetainer    --
--====================--

--- Checks if there are any AutoRetainers waiting to be processed for the current character
--- @return boolean hasRetainers    true if any retainers are waiting; false otherwise
function ARRetainersWaitingToBeProcessed()
    local hasRetainers = IPC.AutoRetainer.AreAnyRetainersAvailableForCurrentChara()
    LogDebug(string.format("[MoLib] Retainers waiting to be processed: %s", tostring(hasRetainers)))
    return hasRetainers
end

--------------------------------------------------------------------

--==================--
--    Lifestream    --
--==================--

--- Executes a Lifestream command and waits for its completion
--- @param command string    the Lifestream command to execute
--- @return nil
function Lifestream(command)
    if not command or command == "" then
        LogDebug("[MoLib] LifestreamExecuteCommand: no command provided")
        return
    end

    LogDebug(string.format("[MoLib] Executing Lifestream command: '%s'", command))
    IPC.Lifestream.ExecuteCommand(command)
    WaitForLifestream()
end

--------------------------------------------------------------------

--- Executes a Lifestream Aethernet teleport to the specified destination and waits for completion
--- @param destination string    the Aethernet destination to teleport to
--- @return boolean success      true if teleport succeeded, false otherwise
function LifestreamAethernet(destination)
    if not destination or destination == "" then
        LogDebug("[MoLib] LifestreamAethernetTeleport: no destination provided")
        return false
    end

    LogDebug(string.format("[MoLib] Executing Lifestream Aethernet teleport to '%s'", destination))
    local success = IPC.Lifestream.AethernetTeleport(destination)
    WaitForLifestream()
    return success
end

--------------------------------------------------------------------

--- Checks whether Lifestream is currently busy performing a teleport or other action
--- @return boolean busy    true if Lifestream is busy, false otherwise
function LifestreamIsBusy()
    local busy = IPC.Lifestream.IsBusy()
    LogDebug(string.format("[MoLib] LifestreamIsBusy: %s", tostring(busy)))
    return busy
end

--------------------------------------------------------------------

--- Waits until Lifestream is no longer busy and the player is available
--- @return nil
function WaitForLifestream()
    LogDebug("[MoLib] Waiting for Lifestream to become not busy and player to be available")
    Wait(0.1)

    repeat
        Wait(0.1)
    until not LifestreamIsBusy() and IsPlayerAvailable()
    LogDebug("[MoLib] Lifestream is no longer busy and player is available")
end

--------------------------------------------------------------------

--====================--
--    Questionable    --
--====================--

--- Checks whether the Questionable plugin is currently running
--- @return boolean running    true if Questionable is running, false otherwise
function QuestionableIsRunning()
    local running = IPC.Questionable.IsRunning()
    LogDebug(string.format("[MoLib] QuestionableIsRunning: %s", tostring(running)))
    return running
end

--------------------------------------------------------------------

--- Retrieves the current quest ID from Questionable
--- @return string questId    the current quest ID
function QuestionableGetCurrentQuestId()
    local questId = IPC.Questionable.GetCurrentQuestId()
    LogDebug(string.format("[MoLib] QuestionableGetCurrentQuestId: %s", tostring(questId)))
    return questId
end

--------------------------------------------------------------------

--- Adds a quest to the priority list in Questionable
--- @param questId string      the quest ID to prioritize
--- @return boolean success    true if the quest was added, false otherwise
function QuestionableAddQuestPriority(questId)
    local success = IPC.Questionable.AddQuestPriority(questId)
    LogDebug(string.format("[MoLib] QuestionableAddQuestPriority: questId = %s, success = %s", tostring(questId), tostring(success)))
    return success
end

--------------------------------------------------------------------

--- Clears all quest priorities in Questionable
--- @return boolean success    true if priorities were cleared, false otherwise
function QuestionableClearQuestPriority()
    local success = IPC.Questionable.ClearQuestPriority()
    LogDebug(string.format("[MoLib] QuestionableClearQuestPriority: success = %s", tostring(success)))
    return success
end

--------------------------------------------------------------------

--- Checks whether a specific quest is locked in Questionable
--- @param questId string       the ID of the quest to check
--- @return boolean isLocked    true if the quest is locked, false otherwise
function QuestionableIsQuestLocked(questId)
    local isLocked = IPC.Questionable.IsQuestLocked(questId)
    LogDebug(string.format("[MoLib] QuestionableIsQuestLocked: questId = %s, locked = %s", tostring(questId), tostring(isLocked)))
    return isLocked
end

--------------------------------------------------------------------

--===============--
--    Visland    --
--===============--

--- Checks if the Visland route is currently running
--- @return boolean running    true if the Visland route is running, false otherwise
function IsVislandRouteRunning()
    local running = IPC.visland.IsRouteRunning()
    LogDebug(string.format("[MoLib] Visland route running: %s", tostring(running)))
    return running
end

--------------------------------------------------------------------

--- Checks if the Visland route is currently paused
--- @return boolean paused    true if the Visland route is paused, false otherwise
function IsVislandRoutePaused()
    local paused = IPC.visland.IsRoutePaused()
    LogDebug(string.format("[MoLib] Visland route paused: %s", tostring(paused)))
    return paused
end

--------------------------------------------------------------------

--- Starts the specified Visland route, with optional looping
--- @param routeName string    the name of the route to start
--- @param loop boolean?       [optional] whether to loop the route (default false)
--- @return nil
--- @overload fun(routeName: string, loop?: boolean): nil
function VislandRouteStart(routeName, loop)
    loop = loop or false
    LogDebug(string.format("[MoLib] Starting Visland route: %s (loop = %s)", routeName, tostring(loop)))
    IPC.visland.StartRoute(routeName, loop)
end

--------------------------------------------------------------------

--- Stops the Visland route if it is currently running
--- @return nil
function VislandRouteStop()
    if IsVislandRouteRunning() then
        LogDebug("[MoLib] Stopping Visland route")
        IPC.visland.StopRoute()
    else
        LogDebug("[MoLib] Visland route not running, nothing to stop")
    end
end

--------------------------------------------------------------------

--- Sets the Visland route to pause state
--- @param paused boolean  true to pause the route, false to resume
--- @return nil
function VislandSetRoutePaused(paused)
    LogDebug(string.format("[MoLib] Setting Visland route paused: %s", tostring(paused)))
    IPC.visland.SetRoutePaused(paused)
end

--------------------------------------------------------------------

--================--
--    Vnavmesn    --
--================--

--- Checks whether a vnavmesh pathfinding operation is currently in progress
--- @return boolean inProgress    true if pathfinding is in progress; false otherwise
function PathfindInProgress()
    local inProgress = IPC.vnavmesh.PathfindInProgress()
    LogDebug(string.format("[MoLib] PathfindInProgress: %s", tostring(inProgress)))
    return inProgress
end

--------------------------------------------------------------------

--- Checks whether the vnavmesh path is currently running
--- @return boolean isRunning    true if the path is running; false otherwise
function PathIsRunning()
    local isRunning = IPC.vnavmesh.IsRunning()
    LogDebug(string.format("[MoLib] PathIsRunning: %s", tostring(isRunning)))
    return isRunning
end

--------------------------------------------------------------------

--- Initiates pathfinding and movement to the specified 3D coordinates using vnavmesh
--- @param x number        X coordinate
--- @param y number        Y coordinate
--- @param z number        Z coordinate
--- @param fly boolean?    [optional] whether to enable flying movement (default false)
--- @return nil
--- @overload fun(x: number, y: number, z: number): nil
--- @overload fun(x: number, y: number, z: number, fly: boolean): nil
function PathfindAndMoveTo(x, y, z, fly)
    fly = fly or false
    local destination = Vector3(x, y, z)
    LogDebug(string.format("[MoLib] PathfindAndMoveTo: Destination = %s, Fly = %s", tostring(destination), tostring(fly)))
    IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
end

--------------------------------------------------------------------

--- Initiates movement without pathfinding using vnavmesh
--- Accepts either a single waypoint {x, y, z} or a table of waypoints { {x,y,z}, {x,y,z}, ... }
--- @param coordinates table    a single waypoint {x,y,z} or a list of waypoints
--- @param fly boolean?         [optional] whether to enable flying movement (default false)
--- @return nil
--- @overload fun(coordinates: number[], fly?: boolean): nil
--- @overload fun(coordinates: table,    fly?: boolean): nil
function PathMoveTo(coordinates, fly)
    fly = fly or false

    local vector3ListType = Type.GetType("System.Collections.Generic.List`1[System.Numerics.Vector3]")
    local pathPoints = Activator.CreateInstance(vector3ListType)

    if type(coordinates[1]) == "number" then
        local vector = Vector3(coordinates[1], coordinates[2], coordinates[3])
        pathPoints:Add(vector)
    else
        for _, coord in ipairs(coordinates) do
            local vector = Vector3(coord[1], coord[2], coord[3])
            pathPoints:Add(vector)
        end
    end
    IPC.vnavmesh.MoveTo(pathPoints, fly)
end

--------------------------------------------------------------------

--- Waits until the navigation mesh system is ready before continuing
--- @return nil
function WaitForNavMesh()
    LogDebug(string.format("[MoLib] Waiting for navmesh to become ready..."))

    while not IPC.vnavmesh.IsReady() do
        Wait(0.1)
    end
    LogDebug(string.format("[MoLib] Navmesh is ready"))
end

--------------------------------------------------------------------

--- Waits for the Navmesh pathing process to complete
--- @param timeout number?     [optional] timeout in seconds (default 300)
--- @return boolean success    true if pathing completed before timeout; false if timed out
--- @overload fun(timeout?: number): boolean
function WaitForPathRunning(timeout)
    timeout = timeout or 300
    LogDebug(string.format("[MoLib] Waiting for navmesh pathing to complete..."))

    local startTime = os.clock()
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        if (os.clock() - startTime) >= timeout then
            LogDebug(string.format("[MoLib] WaitForPathRunning: Timeout reached waiting for pathing to complete"))
            return false
        end
        Wait(0.1)
    end

    LogDebug(string.format("[MoLib] Pathing complete"))
    return true
end

--------------------------------------------------------------------

--- Stops the current vnavmesh pathfinding movement, if any is active
--- @return nil
function PathStop()
    LogDebug(string.format("[MoLib] PathStop: Attempting to stop pathfinding"))
    IPC.vnavmesh.Stop()
end

--------------------------------------------------------------------

--- Queries the nearest point on the navigation mesh floor
--- Supports overloads for either a Vector3 position or x/y/z coordinates
--- @param positionOrX userdata|number    either a Vector3 position or the X coordinate
--- @param y number|boolean               Y coordinate if positionOrX is number, or allowUnlandable if positionOrX is Vector3
--- @param z number|number                Z coordinate if positionOrX is number, or halfExtentXZ if positionOrX is Vector3
--- @param allowUnlandable boolean?       [optional] whether to allow unlandable positions
--- @param halfExtentXZ number?           [optional] horizontal search radius
--- @return Vector3 result                the nearest point on the navmesh floor
--- @overload fun(position: userdata, allowUnlandable?: boolean, halfExtentXZ?: number): Vector3
--- @overload fun(x: number, y: number, z: number, allowUnlandable?: boolean, halfExtentXZ?: number): Vector3
function QueryMeshPointOnFloor(positionOrX, y, z, allowUnlandable, halfExtentXZ)
    local position
    local allowUnlandableBool = false
    local halfExtentSafe = 0

    if type(positionOrX) == "userdata" then
        position = positionOrX
        allowUnlandableBool = (type(y) == "boolean") and y or false
        halfExtentSafe = (type(z) == "number") and math.floor(z) or 0
    else
        local xNum = positionOrX
        local yNum = (type(y) == "number") and y or 0
        local zNum = (type(z) == "number") and z or 0
        position = Vector3(xNum, yNum, zNum)
        allowUnlandableBool = (allowUnlandable == true)
        halfExtentSafe = (type(halfExtentXZ) == "number") and math.floor(halfExtentXZ) or 0
    end
    LogDebug(string.format("[MoLib] QueryMeshPointOnFloor called with position: %s, allowUnlandable: %s, halfExtentXZ: %d", tostring(position), tostring(allowUnlandableBool), halfExtentSafe))
    local result = IPC.vnavmesh.PointOnFloor(position, allowUnlandableBool, halfExtentSafe)
    LogDebug(string.format("[MoLib] PointOnFloor result: %s", tostring(result)))
    return result
end

--------------------------------------------------------------------

--==================--
--    YesAlready    --
--==================--

--- Checks if the YesAlready plugin is currently enabled
--- @return boolean enabled    true if the plugin is enabled, false otherwise
function IsYesAlreadyRunning()
    local enabled = IPC.YesAlready.IsPluginEnabled()
    LogDebug(string.format("[MoLib] YesAlready plugin enabled: %s", tostring(enabled)))
    return enabled
end

--------------------------------------------------------------------

--- Enables or disables the YesAlready plugin
--- @param state boolean    true to enable the plugin, false to disable it
--- @return nil
function SetYesAlready(state)
    LogDebug(string.format("[MoLib] Setting YesAlready plugin enabled state to: %s", tostring(state)))
    IPC.YesAlready.SetPluginEnabled(state)
end

--------------------------------------------------------------------

--- Pauses the YesAlready plugin for the specified duration
--- @param sleepTime number?    [optional] pause duration in milliseconds (default 300000 = 5 minutes)
--- @return nil
--- @overload fun(): nil
function PauseYesAlready(sleepTime)
    sleepTime = sleepTime or 300000
    LogDebug(string.format("[MoLib] YesAlready plugin paused for: %d milliseconds", sleepTime))
    IPC.YesAlready.PausePlugin(sleepTime)
end

--============================= WAIT =============================--

--============--
--    Wait    --
--============--

--- Pauses execution for the specified duration
--- @param time number    the duration to wait in seconds
--- @return nil
function Wait(time)
    yield(string.format("/wait %g", time))
end

--------------------------------------------------------------------

--- Waits until the specified condition becomes true or false, depending on expectedState, or until a timeout is reached
--- @param name string              the name of the condition to wait for (case-insensitive)
--- @param expectedState boolean    if true waits for the condition to become true; if false waits for it to clear
--- @param timeout number?          [optional] timeout in seconds (default 300)
--- @return boolean success         true if the condition matched before timeout, false if it timed out or was not found
--- @overload fun(name: string, expectedState: boolean): boolean
function WaitForCondition(name, expectedState, timeout)
    timeout = timeout or 300
    LogDebug(string.format("[MoLib] WaitForCondition: waiting for '%s' to become %s (timeout: %.0fs)", tostring(name), tostring(expectedState), timeout))

    local conditionName = string.lower(name)
    local conditionKey

    for k, v in pairs(CharacterCondition) do
        if type(k) == "string" and string.lower(k) == conditionName then
            conditionKey = v
            break
        end
    end

    if not conditionKey then
        LogDebug(string.format("[MoLib] WaitForCondition: unknown condition '%s'", tostring(name)))
        return false
    end

    local startTime = os.clock()
    repeat
        if (os.clock() - startTime) >= timeout then
            LogDebug(string.format("[MoLib] WaitForCondition: timeout while waiting for '%s' to become %s", tostring(name), tostring(expectedState)))
            return false
        end
        Wait(0.1)
    until Svc.Condition[conditionKey] == expectedState
    LogDebug(string.format("[MoLib] WaitForCondition: '%s' is now %s", tostring(name), tostring(expectedState)))
    Wait(0.1)
    return true
end

--------------------------------------------------------------------

--- Waits for a teleport to fully complete
--- [Casting → Wait → BetweenAreas → Wait → PlayerAvailable]
--- @param timeout number?     [optional] timeout in seconds (default 300)
--- @return boolean success    true if teleport completed, false if timed out
--- @overload fun(): boolean
function WaitForTeleport(timeout)
    timeout = timeout or 300
    LogDebug(string.format("[MoLib] Waiting for teleport to begin (timeout: %.0fs)...", timeout))

    local startTime = os.clock()
    repeat
        if (os.clock() - startTime) >= timeout then
            LogDebug("[MoLib] Timeout reached while waiting for teleport to begin")
            return false
        end
        Wait(0.1)
    until not IsPlayerCasting()
    Wait(0.1)
    LogDebug("[MoLib] Teleport started, waiting for zoning to complete...")

    repeat
        if (os.clock() - startTime) >= timeout then
            LogDebug("[MoLib] Timeout reached while waiting for teleport zoning to complete")
            return false
        end
        Wait(0.1)
    until not IsBetweenAreas() and IsPlayerAvailable()
    Wait(0.1)
    LogDebug("[MoLib] Teleport complete")
    return true
end

--------------------------------------------------------------------

--- Pauses execution until the player is no longer zoning
--- Prevents issues from mounting or moving while teleporting or loading
--- @param timeout number?     [optional] timeout in seconds (default 300)
--- @return boolean success    true if zoning completed, false if timed out
--- @overload fun(): boolean
function WaitForZoneChange(timeout)
    timeout = timeout or 300
    LogDebug(string.format("[MoLib] Waiting for zoning to start (timeout: %.0fs)...", timeout))

    local startTime = os.clock()
    repeat
        if (os.clock() - startTime) >= timeout then
            LogDebug("[MoLib] Timeout reached while waiting for zoning to start")
            return false
        end
        Wait(0.1)
    until IsBetweenAreas()
    LogDebug("[MoLib] Zoning detected, waiting for zoning to complete...")

    repeat
        if (os.clock() - startTime) >= timeout then
            LogDebug("[MoLib] Timeout reached while waiting for zoning to complete")
            return false
        end
        Wait(0.1)
    until not IsBetweenAreas() and IsPlayerAvailable()
    LogDebug("[MoLib] Zoning complete, player is available")
    return true
end

--============================= MOVE =============================--

--============--
--    Move    --
--============--

--- Uses vnavmesh IPC to pathfind and move to a world position
--- Issues PathfindAndMoveTo, waits for motion to begin, then monitors until completion
--- Optionally stops early if player reaches specified stopDistance from destination
--- @overload fun(x: number, y: number, z: number): boolean
--- @overload fun(x: number, y: number, z: number, stopDistance: number): boolean
--- @param x number             X coordinate
--- @param y number             Y coordinate
--- @param z number             Z coordinate
--- @param stopDistance? number [Optional] distance threshold to stop early (default 0, disables early stop)
--- @param fly? boolean         [Optional] whether to enable flying movement (default false)
--- @return boolean success     true if path completed successfully or stopped early, false if path failed to start
function MoveTo(x, y, z, stopDistance, fly)
    fly = fly or false
    stopDistance = stopDistance or 0.0

    local destination = Vector3(x, y, z)

    local success = IPC.vnavmesh.PathfindAndMoveTo(destination, fly)
    if not success then
        LogDebug(string.format("[MoLib] Navmesh's PathfindAndMoveTo() failed to start pathing!"))
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
        LogDebug(string.format("[MoLib] Navmesh failed to start movement after creating a path."))
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

    LogDebug(string.format("[MoLib] Navmesh is done pathing"))
    return true
end

--------------------------------------------------------------------

--- Finds the nearest object whose name contains the given substring (case-insensitive)
--- @param targetName string Substring to search for in object names
--- @return object? closestObject The nearest matching object, or nil if none found
--- @return number closestDistance returns the distance to the nearest object, or math.huge if none found
function FindNearestObjectByName(targetName)
    local player = Svc.ClientState.LocalPlayer
    if not player or not player.Position then
        LogDebug(string.format("[MoLib] FindNearestObjectByName: Player position unavailable."))
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

--- Pathfinds to the nearest entity matching the given name substring
--- Finds the object, gets its position, and calls MoveTo()
--- @param targetName string The name substring to search for (case-insensitive)
--- @param fly boolean Whether to allow flying movement (default: false)
--- @param stopDistance number? [Optional] distance to stop short of the object (default: 0)
--- @return boolean true if pathing succeeded, false if object not found or pathing failed
function PathToObject(targetName, stopDistance, fly)
    stopDistance = stopDistance or 0.0
    fly = fly or false

    local obj, dist = FindNearestObjectByName(targetName)
    if obj then
        local name = obj.Name.TextValue
        local pos = obj.Position

        LogDebug(string.format("[MoLib] Pathing to nearest '%s': %s (%.2f units) at (%.3f, %.3f, %.3f)", targetName, name, dist, pos.X, pos.Y, pos.Z))

        return MoveTo(pos.X, pos.Y, pos.Z, stopDistance, fly)
    else
        LogDebug(string.format("[MoLib] Could not find '%s' nearby.", targetName))
        return false
    end
end

--------------------------------------------------------------------

--- Calculates the 3D distance between two Vector3 positions
--- @param pos1 Vector3 The first position
--- @param pos2 Vector3 The second position
--- @return number distance returns the distance between the two points, or math.huge if either position is nil
function GetDistance(pos1, pos2)
    if not pos1 or not pos2 then
        LogDebug(string.format("[MoLib] [GetDistance] One or both positions are nil. Returning math.huge."))
        return math.huge
    end

    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z

    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    LogDebug(string.format("[MoLib] [GetDistance] pos1=(%.2f, %.2f, %.2f), pos2=(%.2f, %.2f, %.2f), distance = %.2f", pos1.X, pos1.Y, pos1.Z, pos2.X, pos2.Y, pos2.Z, distance))

    return distance
end

--------------------------------------------------------------------

--- Calculates the 3D Euclidean distance between two coordinate points
--- @param px1 number X coordinate of the first point
--- @param py1 number Y coordinate of the first point
--- @param pz1 number Z coordinate of the first point
--- @param px2 number X coordinate of the second point
--- @param py2 number Y coordinate of the second point
--- @param pz2 number Z coordinate of the second point
--- @return number distance returns the distance between the two points
function DistanceBetween(px1, py1, pz1, px2, py2, pz2)
    local dx = px2 - px1
    local dy = py2 - py1
    local dz = pz2 - pz1

    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    LogDebug(string.format("[MoLib] [DistanceBetween] pos1=(%.2f, %.2f, %.2f), pos2=(%.2f, %.2f, %.2f), distance = %.2f", px1, py1, pz1, px2, py2, pz2, distance))

    return distance
end

--------------------------------------------------------------------

--- Calculates the 3D distance from the player to a given coordinate point
--- @param dX number Destination X coordinate
--- @param dY number Destination Y coordinate
--- @param dZ number Destination Z coordinate
--- @return number distance returns the distance to the point, or math.huge if player position is unavailable
function GetDistanceToPoint(dX, dY, dZ)
    local player = Svc.ClientState.LocalPlayer
    if not player or not player.Position then
        LogDebug(string.format("[MoLib] GetDistanceToPoint: Player position unavailable."))
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

--- Teleports the player to their Inn room if they are not already in one of the Inn zones
--- Zone IDs: 177 (Limsa), 178 (Gridania), 179 (Ul'dah), 1205 (Solution Nine)
function MoveToInn()
    local WhereAmI = GetZoneID()

    -- Only move if not already in an Inn zone
    if (WhereAmI ~= 177) and (WhereAmI ~= 178) and (WhereAmI ~= 179) and (WhereAmI ~= 1205) then
        LogDebug(string.format("[MoLib] Moving to Inn."))
        Lifestream("Inn")
    else
        LogDebug(string.format("[MoLib] Already in an Inn zone, no action taken."))
    end
end

--=========================== TARGETS ============================--

--===============--
--    Targets    --
--===============--

--- Performs a case-insensitive "startsWith" comparison between two strings
--- Useful for partial name matching like in-game /target behavior
--- @param fullString string The full string to check
--- @param partialString string The prefix to compare against
--- @return boolean true if fullString starts with partialString (case-insensitive), false otherwise
function StringStartsWithIgnoreCase(fullString, partialString)
    if not fullString or not partialString then
        LogDebug(string.format("[MoLib] [StringStartsWithIgnoreCase] One or both input strings are nil."))
        return false
    end

    local fullLower = string.lower(fullString)
    local partialLower = string.lower(partialString)
    local result = string.sub(fullLower, 1, #partialLower) == partialLower

    LogDebug(string.format("[MoLib] [StringStartsWithIgnoreCase] Comparing '%s' with '%s' -> %s", fullString, partialString, tostring(result)))
    return result
end

--------------------------------------------------------------------

--- Attempts to acquire a target by (partial) name using in-game /target-like behavior.
--- Uses Entity.GetEntityByName() and retries until Entity.Target is updated.
--- @param name string The full or partial name of the target (prefix match, case-insensitive)
--- @param maxRetries number? [Optional] Maximum retry attempts (default: 20)
--- @param sleepTime number? [Optional] Wait time between retries in seconds (default: 0.1)
--- @return boolean true if target was successfully acquired, false otherwise
function Target(name, maxRetries, sleepTime)
    maxRetries = maxRetries or 20
    sleepTime = sleepTime or 0.1

    local targetEntity = Entity.GetEntityByName(name)
    if not targetEntity then
        LogDebug(string.format("[MoLib] No entity found with name matching [%s]", name))
        return false
    end

    targetEntity:SetAsTarget()

    local retries = 0
    while retries < maxRetries do
        Wait(sleepTime)
        if Entity.Target and StringStartsWithIgnoreCase(Entity.Target.Name, name) then
            LogDebug(string.format("[MoLib] Target acquired: %s [Word: %s]", Entity.Target.Name, name))
            return true
        end
        retries = retries + 1
    end

    LogDebug(string.format("[MoLib] Failed to acquire target [%s] after %d retries", name, retries))
    return false
end

--------------------------------------------------------------------

--- Gets the name of the current target, if available
--- @return string? name returns the name of the current target, or nil if no target exists
function GetTargetName()
    local name = Entity.Target and Entity.Target.Name or nil
    LogDebug(string.format("[MoLib] Current target name: %s", name or "None"))
    return name
end

--------------------------------------------------------------------

--- Clears the current target if one is selected
function ClearTarget()
    if Entity.Target then
        LogDebug(string.format("[MoLib] Clearing target: %s", Entity.Target.Name))
        Entity.Target:ClearTarget()
    else
        LogDebug(string.format("[MoLib] ClearTarget() called, but no valid target was selected."))
    end
end

--------------------------------------------------------------------

--- Moves the player to a named target entity, stopping within a specified distance
--- @param targetName string The name of the target entity to move toward
--- @param distanceThreshold number? [Optional] Distance at which to stop near the target (default 2.0)
--- @param maxRetries number? [Optional] Number of target acquisition retries (default 20)
--- @param sleepTime number? [Optional] Wait time between retries in seconds (default 0.1)
--- @param fly boolean? [Optional] Whether to enable flying movement (default false)
--- @return boolean true if move command was issued successfully, false otherwise
function MoveToTarget(targetName, distanceThreshold, maxRetries, sleepTime, fly)
    distanceThreshold = distanceThreshold or 2.0
    maxRetries = maxRetries or 20
    sleepTime = sleepTime or 0.1
    fly = fly or false

    -- Try to acquire the target
    local success = Target(targetName, maxRetries, sleepTime)
    if not success then
        LogDebug(string.format("[MoLib] MoveToTarget() failed: Unable to target [%s]", targetName))
        return false
    end

    local target = Entity.Target
    if not target or not target.Position.X or not target.Position.Y or not target.Position.Z then
        LogDebug(string.format("[MoLib] MoveToTarget() failed: Target entity position is nil."))
        return false
    end

    LogDebug(string.format("[MoLib] Moving to target [%s] at (%.2f, %.2f, %.2f) with stop distance %.2f", target.Name, target.Position.X, target.Position.Y, target.Position.Z, distanceThreshold))

    -- Use the provided MoveTo function
    return MoveTo(target.Position.X, target.Position.Y, target.Position.Z, distanceThreshold, fly)
end

--------------------------------------------------------------------

--- Attempts to acquire a target by name and interact with it
--- @param name string Target name
--- @param maxRetries number? [Optional] max retries for targeting (default: 20)
--- @param sleepTime number? [Optional] sleep time between retries (default: 0.1)
function Interact(name, maxRetries, sleepTime)
    local success = Target(name, maxRetries, sleepTime)
    if success then
        Entity.Target:Interact()
        LogDebug(string.format("[MoLib] Interacted with: %s", Entity.Target.Name))
        Wait(1)
    else
        LogDebug(string.format("[MoLib] Interact() failed to acquire target."))
    end
end

--------------------------------------------------------------------

--- Calculates the distance between the player and the current target
--- @return number? distance returns the distance in game units, or nil if player or target is unavailable
function GetDistanceToTarget()
    if not Entity or not Entity.Player then
        LogDebug(string.format("[MoLib] Entity.Player is not available."))
        return nil
    end

    if not Entity.Target then
        LogDebug(string.format("[MoLib] No valid target selected."))
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

--- Checks if the specified addon is loaded and ready
--- @param name string The name of the addon to check
--- @return boolean true if the addon exists and is marked as ready; false otherwise
function IsAddonReady(name)
    local addon = Addons.GetAddon(name)

    local ready = addon and addon.Exists and addon.Ready
    LogDebug(string.format("[MoLib] IsAddonReady('%s') = %s", name, tostring(ready)))

    return ready
end

--------------------------------------------------------------------

--- Checks if an addon is visible
--- @param name string The name of the addon to check
--- @return boolean true if the addon is visible (ready), false otherwise
function IsAddonVisible(name)
    local visible = IsAddonReady(name)
    LogDebug(string.format("[MoLib] IsAddonVisible('%s') = %s", name, tostring(visible)))
    return visible
end

--------------------------------------------------------------------

--- Returns the visibility of a node within an addon
--- @param addonName string The name of the addon
--- @param ... any Additional parameters to identify the node (varies by addon)
--- @return boolean true if the node exists and is visible, false otherwise
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

--- Retrieves the text of a node from a ready addon
--- @param addonName string The name of the addon to query
--- @param ... any Additional parameters passed to addon:GetNode(...)
--- @return string text returns the node's text as a string, or an empty string if the addon or node is not ready
function GetNodeText(addonName, ...)
    if not IsAddonReady(addonName) then
        LogDebug(string.format("[MoLib] GetNodeText('%s', ...): Addon not ready.", addonName))
        return ""
    end

    local addon = Addons.GetAddon(addonName)
    local node = addon and addon:GetNode(...)
    local text = node and tostring(node.Text) or ""

    LogDebug(string.format("[MoLib] GetNodeText('%s', ...): '%s'", addonName, text))
    return text
end

--------------------------------------------------------------------

--- Waits until the specified addon is ready before continuing execution
--- @param name string The name of the addon to wait for
--- @param timeout number? [Optional] timeout in seconds (default 60)
--- @return boolean true if the addon became ready within the timeout, false if timed out
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

--- Closes all known blocking addons until the player is available
function CloseAddons()
    local closableAddons = {
        "SelectIconString",
        "SelectString",
        "SelectYesno",
        "ShopExchangeItem",
        "RecipeNote",
        "ContentsInfo",
        "RetainerList",
        "InventoryRetainer",
        "Talk"
    }

    LogDebug(string.format("[MoLib] CloseAddons() started. Waiting for player to become available..."))

    repeat
        Wait(0.1)

        for _, addon in ipairs(closableAddons) do
            if IsAddonReady(addon) then
                LogDebug(string.format("[MoLib] Closing addon: %s", addon))
                if addon == "Talk" then
                    Execute(string.format("/callback %s true 0", addon))
                else
                    Execute(string.format("/callback %s true -1", addon))
                end
            end
        end

    until IsPlayerAvailable()

    LogDebug(string.format("[MoLib] Player is now available. CloseAddons() complete."))
end


--============================= ZONE =============================--

--============--
--    Zone    --
--============--

--- Helper to get current zone ID
--- @return number zoneId returns the territory (zone) ID
function GetZoneID()
    local zoneId = Svc.ClientState.TerritoryType
    LogDebug(string.format("[MoLib] Current zone ID: %d", zoneId))
    return zoneId
end

--------------------------------------------------------------------

--- Checks if the player is currently in the specified zone
--- @param ZoneID number The zone ID to check
--- @return boolean true if the current zone matches ZoneID, false otherwise
function IsInZone(ZoneID)
    local currentZone = GetZoneID()
    local result = currentZone == ZoneID
    LogDebug(string.format("[MoLib] IsInZone(%d) → %s (current: %d)", ZoneID, tostring(result), currentZone))
    return result
end

--------------------------------------------------------------------

--- Retrieves the Territory ID of the currently flagged map
--- @return integer TerritoryId returns the ID of the zone where the current map flag is set
function FlagZoneID()
    local territoryId = Instances.Map.Flag.TerritoryId
    LogDebug(string.format("[MoLib] FlagZoneID() → %d", territoryId))
    return territoryId
end

--------------------------------------------------------------------

--- Initiates teleport to the given location and waits for it to complete
--- @param location string The destination location name to teleport to
function Teleport(location)
    LogDebug(string.format("[MoLib] Initiating teleport to '%s'.", location))
    Lifestream(location)
    Wait(0.1)
    WaitForTeleport()
end

--------------------------------------------------------------------

--- Teleports the player to the flag's zone if they are not already there
function TeleportFlagZone()
    local flagZone = FlagZoneID()

    if not IsInZone(flagZone) then
        local territoryData = Excel.GetRow("TerritoryType", flagZone)

        if territoryData and territoryData.Aetheryte and territoryData.Aetheryte.PlaceName then
            local flagAetheryte = tostring(territoryData.Aetheryte.PlaceName.Name)
            LogDebug(string.format("[MoLib] Teleporting to map zone: '%s'.", flagAetheryte))
            Teleport(flagAetheryte)
        else
            LogDebug(string.format("[MoLib] Failed to retrieve Aetheryte information for teleportation."))
        end
    else
        LogDebug(string.format("[MoLib] Already in the correct zone. No teleport needed."))
    end
end

--------------------------------------------------------------------

--- Returns the aetheryte name for a given ZoneID
--- @param ZoneID number The ID of the zone
--- @return string? name returns the name of the aetheryte, or nil if not found
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

--- Wrapper function to execute content via Engines.Run
--- @param content string The name or identifier of the content to execute
function Execute(content)
    LogDebug(string.format("[MoLib] Execute content: %s", content))
    Engines.Run(content)
end

--------------------------------------------------------------------

--- Wrapper for /echo that safely converts and outputs any message type (string, number, boolean, etc)
--- @param msg any The message to output
--- @param echoprefix string? [Optional] prefix to prepend (default: "[MoLib]")
function Echo(msg, echoprefix)
    local prefix = echoprefix or "[MoLib]"
    local message = msg ~= nil and tostring(msg) or "nil"
    Execute(string.format("/echo %s %s", prefix, message))
end

--------------------------------------------------------------------

--- Checks if a given plugin is installed and loaded
--- @param name string The internal name of the plugin to check
--- @return boolean true if the plugin is installed and loaded, false otherwise
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

--- Checks if all required plugins are installed and loaded
--- Iterates over the global `RequiredPlugins` list and verifies each one with `HasPlugin`.
--- @return boolean true if all required plugins are enabled, false otherwise
function AreAllPluginsEnabled()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            return false
        end
    end
    return true
end

--------------------------------------------------------------------

--- Attempts to mount using a specific mount name or Mount Roulette if none is provided
--- @param mountName string? The name of the mount to use; if nil or empty, uses Mount Roulette
function Mount(mountName)
    if IsMounted() then
        LogDebug(string.format("[MoLib] Already mounted"))
        return
    end

    if mountName and mountName ~= "" then
        LogDebug(string.format("[MoLib] Attempting to mount: %s", mountName))
        Execute(string.format('/mount "%s"', mountName))
    else
        LogDebug(string.format("[MoLib] Attempting Mount Roulette"))
        ExecuteGeneralAction(CharacterAction.GeneralActions.mount)
    end
end

--------------------------------------------------------------------

--- Attempts to dismount if currently mounted
function Dismount()
    if IsMounted() then
        LogDebug(string.format("[MoLib] Attempting to dismount"))
        repeat
            ExecuteGeneralAction(CharacterAction.GeneralActions.dismount)
            Wait(1)
        until not IsMounted()
    end
end

--------------------------------------------------------------------

--- Toggles a plugin collection on or off.
--- If the collection is enabled, it will be disabled.
--- If the collection is disabled, it will be enabled and optionally run an extra task.
--- @param collectionName string The name of the collection to toggle
--- @param opts table|nil Optional settings:
---   - runAfterEnable (string|nil): Command to run after enabling the collection (e.g. "MacroChainer(Dailies)")
---   - shouldRun (fun():boolean|nil): Predicate function that determines if the post-enable task should run
--- @return string One of: "Disabled", "Enabled", "Running"
function ToggleCollection(collectionName, opts)
    opts = opts or {}

    if AreAllPluginsEnabled() then
        Execute(string.format("/xldisablecollection %s", collectionName))
        return "Disabled"
    else
        Execute(string.format("/xlenablecollection %s", collectionName))

        local okToRun = true
        if type(opts.shouldRun) == "function" then
            okToRun = opts.shouldRun()
        end

        if okToRun and opts.runAfterEnable then
            Execute("/snd")
            repeat
                Wait(1)
            until AreAllPluginsEnabled()
            Execute(string.format("/snd run %s", opts.runAfterEnable))
            return "Running"
        end

        return "Enabled"
    end
end

--------------------------------------------------------------------

--- Stops a specific macro by name, or all macros if no name is provided
--- @param macroName string? The name of the macro to stop; stops all if nil or empty
function StopRunningMacros(macroName)
    if macroName and macroName ~= "" then
        LogDebug(string.format("[MoLib] Stopping macro: %s", macroName))
        return Execute(string.format("/snd stop %s", macroName))
    else
        LogDebug(string.format("[MoLib] Stopping all macros"))
        return Execute("/snd stop all")
    end
end

--============================ ACTIONS ===========================--

--- Executes an action based on its ID and type
--- @param actionID number The ID of the action to execute
--- @param actionType number? The type of the action; defaults to ActionType.Action
function ExecuteAction(actionID, actionType)
    actionType = actionType or ActionType.Action
    LogDebug(string.format("[MoLib] Executing action. ID: %s, Type: %s", tostring(actionID), tostring(actionType)))
    Actions.ExecuteAction(actionID, actionType)
end

--------------------------------------------------------------------

--- Executes a general action based on its ID
--- @param actionID number The ID of the general action to execute
function ExecuteGeneralAction(actionID)
    LogDebug(string.format("[MoLib] Executing general action. ID: %s", tostring(actionID)))
    Actions.ExecuteGeneralAction(actionID)
end

--=========================== INVENTORY ==========================--

--- Returns the number of free inventory slots the player currently has
--- @return number freeSlots returns the count of free inventory slots
function GetInventoryFreeSlotCount()
    local freeSlots = Inventory.GetFreeInventorySlots()
    LogDebug(string.format("[MoLib] Checked inventory: %d free slots available", freeSlots))
    return freeSlots
end

--------------------------------------------------------------------

--- Returns the total count of a specific item in the player's inventory
--- Checks both regular inventory and collectables
--- @param itemId number The item ID to query
--- @return number count returns the total count of the item
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

--------------------------------------------------------------------

--- Returns the total number of Triple Triad cards currently in the player's inventory
--- Scans all items in the Item sheet and matches those with category name "Triple Triad Card"
--- Only counts cards physically present in inventory (unregistered or duplicate cards)
--- @return number total The total number of Triple Triad card items in inventory
function CountTripleTriadCards()
    local total = 0
    local itemSheet = Excel.GetSheet("Item")
    LogDebug(string.format("[MoLib] Loaded Item sheet for Triple Triad card scan"))

    if not itemSheet then
        LogDebug("[MoLib] Failed to get Item sheet")
        return 0
    end

    local index = 0
    local row = itemSheet:GetRow(index)

    while row do
        if row.ItemUICategory and row.ItemUICategory.Name == "Triple Triad Card" then
            local count = Inventory.GetItemCount(row.RowId)
            LogDebug(string.format("[MoLib] Checking card: %s (ID = %d) => Count: %d", row.Name, row.RowId, count or 0))

            if count and count > 0 then
                total = total + count
            end
        end

        index = index + 1
        row = itemSheet:GetRow(index)
    end

    LogDebug(string.format("[MoLib] Total Triple Triad cards in inventory: %d", total))
    return total
end

--=========================== INSTANCE ===========================--

--- Checks if the player can leave the current instanced content
--- @return boolean true if the player can leave the instance, false otherwise
function CanLeaveInstance()
    local canLeave = InstancedContent.CanLeaveCurrentContent()
    LogDebug(string.format("[MoLib] Can leave instance: %s", tostring(canLeave)))
    return canLeave
end

--------------------------------------------------------------------

--- Attempts to leave the current instanced content if allowed
function LeaveInstance()
    if CanLeaveInstance() then
        LogDebug(string.format("[MoLib] Leaving instanced content"))
        InstancedContent.LeaveCurrentContent()
    else
        LogDebug(string.format("[MoLib] Cannot leave instance at this time"))
    end
end

--============================ REPAIRS ===========================--

--- Checks if any items in the player's inventory need repair below a given durability percentage
--- @param percentage number The durability threshold to check against (0-100)
--- @return boolean true if any items need repair, false otherwise
function NeedsRepair(percentage)
    local repairList = Inventory.GetItemsInNeedOfRepairs(percentage)
    local needsRepair = repairList.Count > 0
    LogDebug(string.format("[MoLib] Checked for items below %d%% durability: %s", percentage, needsRepair and "Needs repair" or "No repairs needed"))
    return needsRepair
end

--------------------------------------------------------------------

--- Attempts to repair gear if any items fall below the repair threshold
--- @param RepairThreshold number? [Optional] durability percentage threshold (default 20)
function Repair(RepairThreshold)
    RepairThreshold = RepairThreshold or 20

    if not NeedsRepair(RepairThreshold) then
        LogDebug(string.format("[MoLib] No gear repairs needed."))
        WaitForPlayer()
        Wait(1)
        return
    end

    LogDebug(string.format("[MoLib] Initiating gear repair process."))

    while not IsAddonReady("Repair") do
        ExecuteGeneralAction(CharacterAction.GeneralActions.repair)
        Wait(1)
    end

    Execute("/callback Repair true 0")
    Wait(1)

    if IsAddonReady("SelectYesno") then
        Execute("/callback SelectYesno true 0")
        Wait(1)
    end

    while IsOccupied() do
        Wait(1)
    end

    Wait(1)
    Execute("/callback Repair true -1")

    LogDebug(string.format("[MoLib] Gear repair process completed."))

    WaitForPlayer()
    Wait(1)
end

--============================ MATERIA ===========================--

--- Returns the number of spiritbonded items in the player's inventory
--- @return number count returns the count of spiritbonded items
function CanExtractMateria()
    local bondedItems = Inventory.GetSpiritbondedItems()
    local count = (bondedItems and bondedItems.Count) or 0
    LogDebug(string.format("[MoLib] Found %d spiritbonded items.", count))
    return count
end

--------------------------------------------------------------------

--- Extracts materia from all spiritbonded gear if enabled
--- @param ExtractMateria boolean Whether to perform materia extraction (default false)
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
        ExecuteGeneralAction(CharacterAction.GeneralActions.materiaExtraction)
        WaitForAddon("Materialize")

        while CanExtractMateria() > 0 do
            if not IsAddonReady("Materialize") then
                ExecuteGeneralAction(CharacterAction.GeneralActions.materiaExtraction)
            end

            Execute("/callback Materialize true 2")
            Wait(1)

            if IsAddonReady("MaterializeDialog") then
                Execute("/callback MaterializeDialog true 0")
                Wait(1)
            end

            while IsOccupied() do
                Wait(1)
            end
        end

        Wait(1)
        Execute("/callback Materialize true -1")
        Wait(1)

        LogDebug(string.format("[MoLib] Materia extraction completed."))
    else
        LogDebug(string.format("[MoLib] No items found for materia extraction."))
    end

    WaitForPlayer()
    Wait(1)
end

--=========================== RETAINERS ==========================--

--- Assigns ventures to retainers if auto retainers are enabled and retainers need processing
--- @param DoAutoRetainers boolean Whether to perform auto retainers actions (default: false)
function DoAR(DoAutoRetainers)
    DoAutoRetainers = DoAutoRetainers or false

    if ARRetainersWaitingToBeProcessed() and DoAutoRetainers then
        LogDebug(string.format("[MoLib] Assigning ventures to Retainers."))
        MoveToTarget("Summoning Bell", 3)
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

--- Waits for the AutoRetainers process to complete if enabled and retainers need processing
--- @param DoAutoRetainers boolean Whether to wait for AutoRetainers (default: false)
function WaitForAR(DoAutoRetainers)
    DoAutoRetainers = DoAutoRetainers or false

    if not (ARRetainersWaitingToBeProcessed() and DoAutoRetainers) then
        return
    end

    LogDebug(string.format("%[MoLib] Waiting for AutoRetainers to complete."))
    Wait(1)

    while IsOccupiedSummoningBell() do
        WaitForPlayer()
    end
end

--============================= LOG ==============================--

--===========--
--    Log    --
--===========--

-- Defines available log levels
local LogLevel = {
    Info    = "Info",
    Debug   = "Debug",
    Verbose = "Verbose"
}

--- Core log function with support for formatting and log levels
--- @param msg string The message format string
--- @param level string? [Optional] log level (Info, Debug, Verbose), default is Info
--- @param ... any [Optional] arguments to format into the message
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

--- Logs a message at the Info level
--- @param msg string The message format string
--- @param ... any [Optional] arguments to format into the message
function LogInfo(msg, ...)
    Log(msg, LogLevel.Info, ...)
end

--------------------------------------------------------------------

--- Logs a message at the Debug level
--- @param msg string The message format string
--- @param ... any [Optional] arguments to format into the message
function LogDebug(msg, ...)
    Log(msg, LogLevel.Debug, ...)
end

--------------------------------------------------------------------

--- Logs a message at the Verbose level
--- @param msg string The message format string
--- @param ... any [Optional] arguments to format into the message
function LogVerbose(msg, ...)
    Log(msg, LogLevel.Verbose, ...)
end

--------------------------------------------------------------------