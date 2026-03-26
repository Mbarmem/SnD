--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dungeon Farm for TT Cards - A barebones script
plugin_dependencies:
- AutoDuty
- Automaton
- BossMod
- Lifestream
- RotationSolver
- SkipCutscene
- TextAdvance
- vnavmesh
- YesAlready
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunsPlayed = 0
LogPrefix = "[Variant]"

--============================ CONSTANT ==========================--

-----------------
--    Zones    --
-----------------

Zones = {
    MerchantTale = { Id = 1316, Name = "The Merchant's Tale" }
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function RotationON()
    LogInfo(string.format("%s Setting rotation to Auto mode...", LogPrefix))
    Execute("/rotation auto LowHP")
    Wait(0.5)
end

function RotationOFF()
    LogInfo(string.format("%s Turning rotation OFF...", LogPrefix))
    Execute("/rotation off")
    Wait(0.5)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    Execute("/vbmai on")
    Wait(0.5)
end

function AiOFF()
    LogInfo(string.format("%s Turning BattleMod AI OFF...", LogPrefix))
    Execute("/vbmai off")
    Wait(0.5)
end

--=========================== EXECUTION ==========================--

MoveToInn()
WaitForLifestream()
WaitForPlayer()

while not IsInZone(Zones.MerchantTale.Id) do
    Wait(1)
    if IsAddonReady("ContentsFinderConfirm") then
        Execute("/callback ContentsFinderConfirm Commence")
        Wait(2)
    end
end

RunsPlayed = RunsPlayed + 1
LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))
WaitForPlayer()

while not IsAddonReady("VVDVoteRoute") do
    Wait(0.5)
end
Wait(1)
Execute("/callback VVDVoteRoute true 1")

while not Target("Aetherial Flow") do
    Wait(1)
end

MoveToTarget("Aetherial Flow")
Interact("Aetherial Flow")
Wait(5)
WaitForPlayer()

MoveToTarget("Pari of Plenty")
RotationON()
AiON()

repeat
    Wait(2)
until not IsInCombat() and not Target("Pari of Plenty")

RotationOFF()
AiOFF()

LogInfo(string.format("%s Variant Advanced script completed successfully..!!", LogPrefix))

--============================== END =============================--