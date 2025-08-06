--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Triple Triad - A barebones script for weeklies
plugin_dependencies:
- Lifestream
- Saucy
- TextAdvance
- vnavmesh
- YesAlready
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LogPrefix = "[TT]"

--=========================== FUNCTIONS ==========================--

----------------
--    Duty    --
----------------

function BattleHall()
    LogInfo(string.format("%s Moving to Battle Hall.", LogPrefix))

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
    Execute("/callback ContentsFinder true 3 1")
    Wait(1)
    Execute("/callback ContentsFinder true 12 0")
    Wait(1)

    while not IsBoundByDuty() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            Execute("/click ContentsFinderConfirm Commence")
        end
    end
end

-----------------
--    Triad    --
-----------------

function PlayTTUntilNeeded()
    WaitForCondition("PlayingMiniGame", true)

    LogInfo(string.format("%s Starting Triple Triad...", LogPrefix))
    Execute("/saucy tt play 15")
    Execute("/saucy tt go")
    Wait(1)

    while IsPlayingMiniGame() do
        Wait(1)
    end

    LeaveInstance()

    WaitForCondition("BoundByDuty", false)

    WaitForPlayer()
end

function Play()
    if IsInZone(579) then
        WaitForPlayer()
        MoveToTarget("Nell Half-full", 3)
        Interact("Nell Half-full")
        PlayTTUntilNeeded()
    else
        LogInfo(string.format("%s Not in BattleHall..!!", LogPrefix))
    end
end

--=========================== EXECUTION ==========================--

if not IsInZone(579) then
    BattleHall()
    Play()
else
    Play()
end

Echo("Triple Triad script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Triple Triad script completed successfully..!!", LogPrefix))

--============================== END =============================--