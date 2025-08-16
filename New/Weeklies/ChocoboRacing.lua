--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Chocobo Racing - A barebones script for weeklies
plugin_dependencies:
- SkipCutscene
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  RunsToPlay:
    default: 20
    description: Number of runs to play.
    type: integer
    required: true
  RunsPlayed:
    default: 0
    description: Initial run count.
    type: integer
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

--------------------
--    Genereal    --
--------------------

RunsToPlay   = Config.Get("RunsToPlay")
RunsPlayed   = Config.Get("RunsPlayed")
LogPrefix    = "[ChocoboRacing]"

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function DutyFinder()
    LogInfo(string.format("%s Starting new race. Currently at %s/%s runs.", LogPrefix, RunsPlayed, RunsToPlay))

    if not IsAddonReady("JournalDetail") then
        Execute("/dutyfinder")
    end

    Wait(1)
    WaitForAddon("JournalDetail")
    Wait(1)

    Execute("/callback ContentsFinder true 12 1")
    Wait(1)
    Execute("/callback ContentsFinder true 1 9")
    Wait(1)
    Execute("/callback ContentsFinder true 3 11")
    Wait(1)
    Execute("/callback ContentsFinder true 12 0")
    Wait(1)

    while not IsOccupiedInCutScene() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            Execute("/click ContentsFinderConfirm Commence")
        end
    end
end

function SuperSprint()
    if IsOccupiedInCutScene() then
        WaitForCondition("OccupiedInCutscene", false)
    end
    Wait(6)
    ExecuteAction(CharacterAction.ChocoboRaceAbility.superSprint, ActionType.ChocoboRaceAbility)
    Wait(3)
end

function KeySpam()
    repeat
        Execute("/send KEY_1")
        Wait(5)
    until IsAddonReady("RaceChocoboResult")
end

function EndMatch()
    WaitForAddon("RaceChocoboResult", 500)

    RunsPlayed = RunsPlayed + 1

    Execute("/callback RaceChocoboResult true 1")
    LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))

    WaitForPlayer()
    Wait(1)
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