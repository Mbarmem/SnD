--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Lord of Verminion - A barebones script for weeklies
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  RunsToPlay:
    description: Number of runs to play.
    default: 5
  RunsPlayed:
    description: Initial run count.
    default: 0

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunsToPlay   = Config.Get("RunsToPlay")
RunsPlayed   = Config.Get("RunsPlayed")
LogPrefix    = "[LoV]"

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function DutyFinder()
    LogInfo(string.format("%s Starting new match. Currently at %s/%s runs.", LogPrefix, RunsPlayed, RunsToPlay))

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
    Execute("/callback ContentsFinder true 3 6")
    Wait(1)
    Execute("/callback ContentsFinder true 12 0")
    Wait(1)

    while not IsPlayingLordOfVerminion() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            Execute("/click ContentsFinderConfirm Commence")
        end
    end
end

function EndMatch()
    WaitForAddon("LovmResult", 500)

    RunsPlayed = RunsPlayed + 1

    Execute("/callback LovmResult false -2")
    Execute("/callback LovmResult true -1")
    WaitForAddon("NamePlate", 60)

    LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))

    WaitForPlayer()
end

--=========================== EXECUTION ==========================--

while RunsPlayed < RunsToPlay do
    DutyFinder()
    EndMatch()
end

Echo("Lord of Verminion script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Lord of Verminion script completed successfully..!!", LogPrefix))

--============================== END =============================--