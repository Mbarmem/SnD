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
  SuperSprint:
    description: Use Super Sprint ability during races.
    default: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunsToPlay   = Config.Get("RunsToPlay")
RunsPlayed   = Config.Get("RunsPlayed")
SuperSprint  = Config.Get("SuperSprint")
LogPrefix    = "[ChocoboRacing]"

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function DutyFinder()
    LogInfo(string.format("%s Starting new race. Currently at %s/%s runs.", LogPrefix, RunsPlayed, RunsToPlay))
    DFQueueRoulette(22) -- Chocobo Race: Sagolii Road (No Rewards)

    while not IsOccupiedInCutScene() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            Execute("/click ContentsFinderConfirm Commence")
        end
    end
end

function UseSuperSprint()
    if IsOccupiedInCutScene() then
        WaitForCondition("OccupiedInCutscene", false)
    end

    Wait(6)

    if not SuperSprint then
        return
    end

    ExecuteAction(CharacterAction.ChocoboRaceAbility.superSprint, ActionType.ChocoboRaceAbility)
    Wait(3)
end

function KeySpam()
    Execute("/hold A")
    Wait(5)
    Execute("/release A")

    repeat
        Execute("/send KEY_1")
        Wait(1)
        Execute("/send KEY_1")
        Wait(10)
    until IsAddonReady("RaceChocoboResult")
end

function EndRace()
    WaitForAddon("RaceChocoboResult", 500)
    Execute("/callback RaceChocoboResult true 1")

    RunsPlayed = RunsPlayed + 1
    LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))
    WaitForPlayer()
    Wait(1)
end

--=========================== EXECUTION ==========================--

while RunsPlayed < RunsToPlay do
    DutyFinder()
    UseSuperSprint()
    KeySpam()
    EndRace()
end

Echo("Chocobo Racing script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Chocobo Racing script completed successfully..!!", LogPrefix))

--============================== END =============================--