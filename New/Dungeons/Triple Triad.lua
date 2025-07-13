--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dungeon Farm for TT Cards - A barebones script
plugin_dependencies:
- AutoDuty
- RotationSolver
- BossModReborn
- vnavmesh
- TeleporterPlugin
- Lifestream
- YesAlready
- SkipCutscene
- Automaton
- TextAdvance
dependencies:
- source: https://raw.githubusercontent.com/Mbarmem/SnD/refs/heads/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

EchoPrefix = "[TTFarmer]"

--============================ CONSTANT ==========================--

--------------------
--    Dungeons    --
--------------------

Dungeons = {
    {
        Name         = "Pharos Sirius (Hard)",
        dutyId       = 510,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 13369,
    },
    {
        Name         = "The Drowned City Of Skalla",
        dutyId       = 1172,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 21184,
    },
    {
        Name         = "The Ghimlyt Dark",
        dutyId       = 1174,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 24872,
    },
    {
        Name         = "The Burn",
        dutyId       = 1173,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 23910,
    },
    {
        Name         = "Saint Mocianne's Arboretum (Hard)",
        dutyId       = 788,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 23909,
    },
    {
        Name         = "Baelsar's Wall",
        dutyId       = 1114,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 17683,
    },
    {
        Name         = "The Fractal Continuum (Hard)",
        dutyId       = 743,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 22381,
    },
    {
        Name         = "The Swallow's Compass",
        dutyId       = 768,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        cardId       = 23047,
    },
}

--=========================== EXECUTION ==========================--

for _, cards in ipairs(Dungeons) do
    RunCount = 1
    while GetItemCount(cards.cardId) < 1 do
        LogInfo(string.format("%s [Run: %d] DutyMode: %s - %s", EchoPrefix, RunCount, cards.dutyMode, cards.Name))
        yield("/ad cfg Unsynced "..cards.dutyUnsynced)
        yield("/ad run "..cards.dutyMode.." "..cards.dutyId.." 1 true")
        yield("/bmrai on")
        yield("/rotation auto")
        Wait(10)
        while IsBetweenAreas() or IsBoundByDuty() do -- wait for duty to be finished
            Wait(1)
        end
        RunCount = RunCount + 1
    end
    LogInfo(string.format("%s %s is done.", EchoPrefix, cards.Name))
end

--============================== END =============================--