--[[

****************************************************
*             Weekly Lord of Verminion             *
*              A barebones LoV script.             *
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
    -> Something Need Doing [Expanded Edition] : Main Plugin for everything to work   (https://puni.sh/api/repository/croizat)

]]

-------------------------------- Variables --------------------------------

--------------------
--    Genereal    --
--------------------

games_to_lose = 5 --number of battles you want to run, 5 is default for max weekly challenge log reward
games_played = 0 --leave default, no reason to change this

--master battle difficulty configs
hard = "3 6"
master = "3 7"

difficulty = hard --set your difficulty here

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    PlayingLordOfVerminion=14
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [LoV] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [LoV] Stopping the script..!!")
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
    yield("/callback ContentsFinder true "..difficulty) --select duty
    yield("/wait 1")
    yield("/callback ContentsFinder true 12 0") --click join
    yield("/wait 1")
    while not GetCharacterCondition(CharacterCondition.PlayingLordOfVerminion) do
        yield("/wait 1")
        if IsAddonVisible("ContentsFinderConfirm") then
            yield("/wait 1")
            yield("/click ContentsFinderConfirm Commence")
        end
    end
end

function endMatch()
    yield("/waitaddon LovmResult <maxwait.500>")
    games_played = games_played + 1
    yield("/callback LovmResult false -2")
    yield("/callback LovmResult true -1")
    yield("/waitaddon NamePlate <maxwait.60><wait.5>")
    yield("/echo [LoV] Matches played: "..games_played)
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

-------------------------------- Execution --------------------------------

Plugins()
while games_played < games_to_lose do
    dutyFinder()
    endMatch()
end
yield("/echo [LoV] Loop finished..!!")

----------------------------------- End -----------------------------------