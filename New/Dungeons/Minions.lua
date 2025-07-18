--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dungeon Farm for Minions  - A barebones script
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
- source: ''
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LogPrefix = "[MinionFarmer]"

--============================ CONSTANT ==========================--

--------------------
--    Dungeons    --
--------------------

Dungeons = {
    {
        Name         = "The Grand Cosmos",
        dutyId       = 884,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 28626,
    },
    {
        Name         = "Anamnesis Anyder",
        dutyId       = 898,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 30096,
    },
    {
        Name         = "Paglth'an",
        dutyId       = 938,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 33693,
    },
    {
        Name         = "Matoya's Relict",
        dutyId       = 933,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 32856,
    },
    {
        Name         = "The Antitower",
        dutyId       = 1111,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 14099,
    },
    {
        Name         = "Dohn Mheg",
        dutyId       = 821,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 26801,
    },
    {
        Name         = "The Heroes' Gauntlet",
        dutyId       = 916,
        dutyMode     = "Regular",
        dutyUnsynced = "true",
        minionId     = 30872,
    },
}

--=========================== EXECUTION ==========================--

for _, minions in ipairs(Dungeons) do
    RunCount = 1
    while GetItemCount(minions.minionId) < 1 do
        LogInfo(string.format("%s [Run: %d] DutyMode: %s - %s", LogPrefix, RunCount, minions.dutyMode, minions.Name))
        yield("/ad cfg Unsynced "..minions.dutyUnsynced)
        yield("/ad run "..minions.dutyMode.." "..minions.dutyId.." 1 true")
        yield("/bmrai on")
        yield("/rotation auto")
        Wait(10)
        while IsBetweenAreas() or IsBoundByDuty() do -- wait for duty to be finished
            Wait(1)
        end
        RunCount = RunCount + 1
    end
    LogInfo(string.format("%s %s is done.", LogPrefix, minions.Name))
end

Echo(string.format("Minion Farmer script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Minion Farmer script completed successfully..!!", LogPrefix))

--============================== END =============================--