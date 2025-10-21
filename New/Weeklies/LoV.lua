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
  Mode:
    description: Mode to play.
    is_choice: true
    choices:
      - "Normal"
      - "Hard"
      - "Extreme"

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunsToPlay   = Config.Get("RunsToPlay")
RunsPlayed   = Config.Get("RunsPlayed")
Mode         = Config.Get("Mode")
LogPrefix    = "[LoV]"

--=========================== CONSTANTS ==========================--

----------------
--    Mode    --
----------------

ModeIDs = {
    Normal    = 576,
    Hard      = 577,
    Extreme   = 578
}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function DutyFinder()
    local modeId = ModeIDs[Mode]

    if not modeId then
        LogInfo(string.format("%s Invalid mode '%s' — defaulting to Normal (576).", LogPrefix, tostring(Mode)))
        modeId = ModeIDs.Normal
    end

    LogInfo(string.format("%s Starting new match. Currently at %s/%s runs.", LogPrefix, RunsPlayed, RunsToPlay))
    DFSetUnrestrictedParty(false)
    DFSetLevelSync(false)
    DFQueueDuty(modeId)

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
    Execute("/callback LovmResult false -2")
    Execute("/callback LovmResult true -1")
    WaitForAddon("NamePlate", 60)

    RunsPlayed = RunsPlayed + 1
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