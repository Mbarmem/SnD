--[[

***********************************************
*             Weekly Triple Triad             *
*           Play TT for Weekly Logs           *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

            *********************
            *  Required Plugins *
            *********************

Plugins that are used are:
    -> Saucy : https://love.puni.sh/ment.json
    -> Triple Triad:
        -> Open Saucy when challenging an NPC = YES
        -> Automatically choose your deck with the best win chance = YES
    -> Teleporter
    -> Lifestream : https://github.com/NightmareXIV/Lifestream/blob/main/Lifestream/Lifestream.json
    -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat
    -> Vnavmesh
    -> TextAdvance
    -> YesAlready : https://love.puni.sh/ment.json
        -> For each of the following categories add the given inputs:
            -> List (Target Restricted = YES)
                -> text: "Triple Triad Challenge" target: "Nell Half-full"

]]

-------------------------------- Variables --------------------------------

--------------------
--    Genereal    --
--------------------

-- The NPC you will be playing agains (Nell Half-full)
PlayAgainstNpc = 0

-- This is used when teleporting, interacting or targeting. When one of these fails, the script will automatically try to do it again.
-- It will try again 5 times, this will be handled as a single falilure. Upon a failure the script will run from the beginning.
-- Once it reaches a total of x failures it will stop the script. This is that x value
maxFailuresAllowed = 5

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "Saucy",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "YesAlready",
    "TextAdvance"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    boundByDuty=34
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [TT] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [TT] Stopping the script..!!")
        yield("/snd stop")
    end
end

----------------
--    Duty    --
----------------

function Battlehall()
    if IsAddonVisible("JournalDetail")==false then yield("/dutyfinder") end
    yield("/wait 1")
    yield("/waitaddon JournalDetail")
    yield("/wait 1")
    yield("/callback ContentsFinder true 12 1") --clears duty selection if applicable
    yield("/wait 1")
    yield("/callback ContentsFinder true 1 9") --open gold saucer tab in DF
    yield("/wait 1")
    yield("/callback ContentsFinder true 3 1") --select duty (Battlehall)
    yield("/wait 1")
    yield("/callback ContentsFinder true 12 0") --click join
    yield("/wait 1")
    while not GetCharacterCondition(CharacterCondition.boundByDuty) do
        yield("/wait 1")
        if IsAddonVisible("ContentsFinderConfirm") then
            yield("/wait 1")
            yield("/click ContentsFinderConfirm Commence")
        end
    end
end

------------------
--    Helper    --
------------------

FailedToTargetCount = 0
FailedToInteractCount = 0

function PlayerTest()
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

function PathFinding()
    yield("/wait 0.2")
    while PathfindInProgress() do
        yield("/wait 0.5")
    end
end

function moveToTarget(minDistanceOverride)
    minDistance = minDistanceOverride or 7
    targetX = GetTargetRawXPos()
    targetY = GetTargetRawYPos()
    targetZ = GetTargetRawZPos()
    PathfindAndMoveTo(targetX, targetY, targetZ, false)
    PathFinding()
    while GetDistanceToPoint(targetX, targetY, targetZ) > minDistance do
        yield("/wait 0.1")
    end
    PathStop()
end

-- Try to target an object/npc. In case of failure, jump to beginning
function Target(destination)
    attemptsCount = 0
    yield("/target "..destination)
    yield("/wait 0.5")
    while GetTargetName():lower() ~= destination:lower() do
        yield("/target "..destination)
        attemptsCount = attemptsCount + 1
        if attemptsCount > 5 then
            yield("/echo [TT] Unable to Target "..destination.." Starting from the top..!!")
            FailedToTargetCount = FailedToTargetCount + 1
            CheckForConsecutiveFailures("target")
            StartScript()
        end
        yield("/wait 0.5")
    end
    FailedToTargetCount = 0
end

-- Try to interact with current target. In case of failure, jump to beginning
function Interact()
    attemptsCount = 0
    yield("/at y")
    yield("/wait 1")
    yield("/interact")
    yield("/wait 1")
    while IsPlayerOccupied() == false do
        yield("/interact")
        attemptsCount = attemptsCount + 1
        if attemptsCount > 5 then
            yield("/echo [TT] Unable to Interact starting from the top..!!")
            FailedToInteractCount = FailedToInteractCount + 1
            CheckForConsecutiveFailures("interact")
            StartScript()
        end
        yield("/wait 0.5")
    end
    FailedToInteractCount = 0
end

-- In case of multiple repeated failures. This will stop the script
function CheckForConsecutiveFailures(reason)
    if FailedToInteractCount > maxFailuresAllowed or FailedToTargetCount > maxFailuresAllowed then
        yield("/echo [TT] Fatal Error - Could not "..reason..". Stopping Script..!!")
        yield("/snd stop")
    end
end

-------------------
--    General    --
-------------------

function StartScript()
    if PlayAgainstNpc == 0 then
        if IsInZone(579) == false then
            Battlehall()
            Play()
        else
            Play()
        end
    end
end

function StopScript()
    yield("/echo [TT] Stopping script, thanks for using..!!")
    yield("/wait 1")
end

-----------------
--    Triad    --
-----------------

function PlayTTUntilNeeded()
    while IsPlayerOccupied()==false do --make sure that player is in playing ui before starting to play
        yield("/wait 0.5")
        yield("/echo [TT] Waiting for game UI..!!")
    end
    yield("/saucy tt play 15")
    yield("/wait 1")
    while IsPlayerOccupied()==true do --make sure that player is in playing ui before starting to play
        yield("/wait 15")
    end
    LeaveDuty()
    repeat
        yield("/wait 1")
    until not GetCharacterCondition(CharacterCondition.boundByDuty)
    PlayerTest()
    yield("/echo [TT] Loop Finished..!!")
end

function Play()
    if IsInZone(579) == true then
        Target("Nell Half-full")
        moveToTarget()
        Interact()
        PlayTTUntilNeeded()
    else
        yield("/echo [TT] Not in Battlehall..!!")
    end
end

-------------------------------- Execution --------------------------------

Plugins()
StartScript()
StopScript()

----------------------------------- End -----------------------------------