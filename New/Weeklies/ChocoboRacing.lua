--[[

****************************************************
*               Weekly Chocobo Racing              *
*                A barebones script.               *
****************************************************

              **********************
              *     Author: Mo     *
              **********************

              **********************
              * Version  |  2.0.0  *
              **********************

]]

---------------------------------- Import ---------------------------------

require("MoLib")

-------------------------------- Variables --------------------------------

--------------------
--    Genereal    --
--------------------

local RunsToPlay   = 20 -- Number of runs to play (20 = max for weekly challenge log reward)
local RunsPlayed   = 0  -- Leave default; will auto-increment
local EchoPrefix   = "[ChoboRacing] "

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "SkipCutscene"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    choboRacing = 12,
    occupiedInCutSceneEvent = 35
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    local missingPlugins = {}

    -- Check for required plugins
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            table.insert(missingPlugins, plugin)
        end
    end

    -- Report and handle missing plugins
    if #missingPlugins > 0 then
        for _, plugin in ipairs(missingPlugins) do
            Echo(string.format("Missing required plugin: %s", plugin), EchoPrefix)
        end
        Echo(string.format("Stopping the script due to missing plugins."), EchoPrefix)
        yield("/snd stop all")
    end
end


----------------
--    Main    --
----------------

function DutyFinder()
    if not IsAddonReady("JournalDetail") then
        yield("/dutyfinder")
    end
    Wait(1)
    yield("/waitaddon JournalDetail")
    Wait(1)
    yield("/callback ContentsFinder true 12 1") --clears duty selection if applicable
    Wait(1)
    yield("/callback ContentsFinder true 1 9") --open gold saucer tab in DF
    Wait(1)
    yield("/callback ContentsFinder true 3 11") --select duty
    Wait(1)
    yield("/callback ContentsFinder true 12 0") --click join
    Wait(1)

    while not GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent) do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            yield("/click ContentsFinderConfirm Commence")
        end
    end
end

-- Use Sprint skill during race
function SuperSprint()
    if GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent) then
        repeat
            Wait(1)
        until not GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent)
    end
    yield("/wait 6")
    Actions.ExecuteAction(58, ActionType.ChocoboRaceAbility)
    yield("/wait 3")
end

-- Spam movement/acceleration key
function KeySpam()
    repeat
        yield("/send KEY_1")
        Wait(5)
    until IsAddonReady("RaceChocoboResult")
end

-- End match and update count
function EndMatch()
    yield("/waitaddon RaceChocoboResult <maxwait.500>")
    RunsPlayed = RunsPlayed + 1
    yield("/callback RaceChocoboResult true 1")
    Echo("Runs played: " .. RunsPlayed, EchoPrefix)
    Wait(1)
    repeat
        Wait(1)
    until IsPlayerAvailable()
    Wait(3)
end

-------------------------------- Execution --------------------------------

Plugins()
while RunsPlayed < RunsToPlay do
    DutyFinder()
    SuperSprint()
    KeySpam()
    EndMatch()
end

Echo("Loop Finished..!!", EchoPrefix)

----------------------------------- End -----------------------------------