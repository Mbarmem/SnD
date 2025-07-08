--[[

****************************************************
*               Weekly Chocobo Racing              *
*                A barebones script.               *
****************************************************

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
    -> Something Need Doing [Expanded Edition] : Main Plugin for everything to work (https://puni.sh/api/repository/croizat)
    -> Skip Cutscene

]]

-------------------------------- Variables --------------------------------

--------------------
--    Genereal    --
--------------------

runs_to_play = 20 --number of runs you want to play, 20 is default for max weekly challenge log reward
runs_played = 0 --leave default, no reason to change this

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
    choboRacing=12,
    occupiedInCutSceneEvent=35
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [ChoboRacing] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [ChoboRacing] Stopping the script..!!")
        yield("/snd stop")
    end
end

----------------
--    Main    --
----------------

function dutyFinder()
    if IsAddonVisible("JournalDetail")==false then yield("/dutyfinder") end
    yield("/wait 1")
    yield("/waitaddon JournalDetail")
    yield("/wait 1")
    yield("/callback ContentsFinder true 12 1") --clears duty selection if applicable
    yield("/wait 1")
    yield("/callback ContentsFinder true 1 9") --open gold saucer tab in DF
    yield("/wait 1")
    yield("/callback ContentsFinder true 3 11") --select duty
    yield("/wait 1")
    yield("/callback ContentsFinder true 12 0") --click join
    yield("/wait 1")
    while not GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent) do
        yield("/wait 1")
        if IsAddonVisible("ContentsFinderConfirm") then
            yield("/wait 1")
            yield("/click ContentsFinderConfirm Commence")
        end
    end
end

function superSprint()
    if GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent) then
        repeat
            yield("/wait 1")
        until not GetCharacterCondition(CharacterCondition.occupiedInCutSceneEvent)
    end
    yield("/wait 6")
    yield("/send KEY_2")
    yield("/wait 3")
end

function keySpam()
    repeat
        yield("/send KEY_1")
        yield("/wait 5")
    until IsAddonVisible("RaceChocoboResult")
end

function endMatch()
    yield("/waitaddon RaceChocoboResult <maxwait.500>")
    runs_played = runs_played + 1
    yield("/callback RaceChocoboResult true 1")
    yield("/echo [ChoboRacing] Runs played: "..runs_played)
    yield("/wait 1")
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
    yield("/wait 3")
end

-------------------------------- Execution --------------------------------

Plugins()
while runs_played < runs_to_play do
    dutyFinder()
    superSprint()
    keySpam()
    endMatch()
end
yield("/echo [ChoboRacing] Loop Finished..!!")

----------------------------------- End -----------------------------------