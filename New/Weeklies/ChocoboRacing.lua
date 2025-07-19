--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Chocobo Racing - A barebones script for weeklies
plugin_dependencies:
- SkipCutscene
dependencies:
- source: ''
  name: SnD
  type: git
configs:
  RunsToPlay:
    default: 20
    description: Number of runs to play.
    type: int
    required: true
  RunsPlayed:
    default: 0
    description: Initial run count.
    type: int
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

--------------------
--    Genereal    --
--------------------

RunsToPlay   = Config.Get("RunsToPlay")
RunsPlayed   = Config.Get("RunsPlayed")
LogPrefix    = "[ChoboRacing]"

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function DutyFinder()
    LogInfo(string.format("%s Starting new race. Currently at %s/%s runs.", LogPrefix, RunsPlayed, RunsToPlay))
    if not IsAddonReady("JournalDetail") then
        yield("/dutyfinder")
    end
    Wait(1)
    WaitForAddon("JournalDetail")
    Wait(1)
    yield("/callback ContentsFinder true 12 1")
    Wait(1)
    yield("/callback ContentsFinder true 1 9")
    Wait(1)
    yield("/callback ContentsFinder true 3 11")
    Wait(1)
    yield("/callback ContentsFinder true 12 0")
    Wait(1)

    while not IsOccupiedInCutScene() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            yield("/click ContentsFinderConfirm Commence")
        end
    end
end

function SuperSprint()
    if IsOccupiedInCutScene() then
        repeat
            Wait(1)
        until not IsOccupiedInCutScene()
    end
    Wait(6)
    Actions.ExecuteAction(58, ActionType.ChocoboRaceAbility)
    Wait(3)
end

function KeySpam()
    repeat
        yield("/send KEY_1")
        Wait(5)
    until IsAddonReady("RaceChocoboResult")
end

function EndMatch()
    WaitForAddon("RaceChocoboResult", 500)
    RunsPlayed = RunsPlayed + 1
    yield("/callback RaceChocoboResult true 1")
    LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))
    Wait(1)
    repeat
        Wait(1)
    until IsPlayerAvailable()
    Wait(3)
end

--=========================== EXECUTION ==========================--

while RunsPlayed < RunsToPlay do
    DutyFinder()
    SuperSprint()
    KeySpam()
    EndMatch()
end

Echo("Chocobo Racing script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Chocobo Racing script completed successfully..!!", LogPrefix))

--============================== END =============================--