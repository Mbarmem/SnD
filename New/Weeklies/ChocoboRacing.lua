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
    description: Number of runs to play.
    default: 20
  RunsPlayed:
    description: Initial run count.
    default: 0

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
    Instances.DutyFinder:QueueRoulette(22) -- Chocobo Race: Sagolii Road (No Rewards)

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
    Execute("/hold A")
    Wait(5)
    Execute("/release A")

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