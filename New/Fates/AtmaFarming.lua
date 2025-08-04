--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Atma Farming - Secondary script for FateFarming
plugin_dependencies:
- TeleporterPlugin
- Lifestream
- vnavmesh
- TextAdvance
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  FateMacro:
    description: Name of the primary fate macro script.
    type: string
    required: true
  NumberToFarm:
    default: 1
    description: Number of each Atma to farm.
    type: int
    min: 1
    max: 99

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

FateMacro    = Config.Get("FateMacro")
NumberToFarm = Config.Get("NumberToFarm")
LogPrefix    = "[AtmaFarming]"

--============================ CONSTANT ==========================--

----------------
--    Atma    --
----------------

Atmas = {
    { zoneName = "Middle La Noscea",   zoneId = 134, itemName = "Atma of the Ram",          itemId = 7856 },
    { zoneName = "Lower La Noscea",    zoneId = 135, itemName = "Atma of the Fish",         itemId = 7859 },
    { zoneName = "Western La Noscea",  zoneId = 138, itemName = "Atma of the Crab",         itemId = 7862 },
    { zoneName = "Upper La Noscea",    zoneId = 139, itemName = "Atma of the Water-bearer", itemId = 7853 },
    { zoneName = "Western Thanalan",   zoneId = 140, itemName = "Atma of the Twins",        itemId = 7857 },
    { zoneName = "Central Thanalan",   zoneId = 141, itemName = "Atma of the Scales",       itemId = 7861 },
    { zoneName = "Eastern Thanalan",   zoneId = 145, itemName = "Atma of the Bull",         itemId = 7855 },
    { zoneName = "Southern Thanalan",  zoneId = 146, itemName = "Atma of the Scorpion",     itemId = 7852, flying = false },
    { zoneName = "Central Shroud",     zoneId = 148, itemName = "Atma of the Maiden",       itemId = 7851 },
    { zoneName = "East Shroud",        zoneId = 152, itemName = "Atma of the Goat",         itemId = 7854 },
    { zoneName = "North Shroud",       zoneId = 154, itemName = "Atma of the Archer",       itemId = 7860 },
    { zoneName = "Outer La Noscea",    zoneId = 180, itemName = "Atma of the Lion",         itemId = 7858, flying = false }
}

--=========================== FUNCTIONS ==========================--

function GetNextAtmaTable()
    for _, atmaTable in pairs(Atmas) do
        if GetItemCount(atmaTable.itemId) < NumberToFarm then
            return atmaTable
        end
    end
end

--=========================== EXECUTION ==========================--

LogInfo(string.format("%s Starting Atma farming process...", LogPrefix))
Execute("/at y")

NextAtmaTable = GetNextAtmaTable()

while NextAtmaTable ~= nil do
    if IsPlayerAvailable() and not IsMacroRunningOrQueued(FateMacro) then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            LogInfo(string.format("%s Already have enough of %s. Moving to next.", LogPrefix, NextAtmaTable.itemName))
            NextAtmaTable = GetNextAtmaTable()
        elseif not IsInZone(NextAtmaTable.zoneId) then
            LogInfo(string.format("%s Teleporting to zone: %s", LogPrefix, NextAtmaTable.zoneName))
            Teleport(GetAetheryteName(NextAtmaTable.zoneId))
        else
            LogInfo(string.format("%s Starting FateMacro in %s for %s...", LogPrefix, NextAtmaTable.zoneName, NextAtmaTable.itemName))
            Execute("/snd run ".. FateMacro)
        end
    end
    Wait(1)
end

--============================== END =============================--