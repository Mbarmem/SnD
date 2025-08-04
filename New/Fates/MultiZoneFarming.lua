--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Multi Zone Farming - Secondary script for FateFarming
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

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

FateMacro  = Config.Get("FateMacro")
LogPrefix  = "[MultiZoneFarming]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

ZonesToFarm = {
    { zoneName = "Urqopacha",       zoneId = 1187 },
    { zoneName = "Kozama'uka",      zoneId = 1188 },
    { zoneName = "Yak T'el",        zoneId = 1189 },
    { zoneName = "Shaaloani",       zoneId = 1190 },
    { zoneName = "Heritage Found",  zoneId = 1191 },
    { zoneName = "Living Memory",   zoneId = 1192 }
}

--=========================== EXECUTION ==========================--

Execute("/at y")

FarmingZoneIndex     = 1
OldBicolorGemCount   = GetItemCount(26807)

while true do
    if IsPlayerAvailable() and not IsMacroRunningOrQueued(FateMacro) then
        if IsDead() or IsInCombat() or GetZoneID() == ZonesToFarm[FarmingZoneIndex].zoneId then
            LogInfo(string.format("%s Starting FateMacro in zone: %s", LogPrefix, ZonesToFarm[FarmingZoneIndex].zoneName))
            Execute("/snd run " .. FateMacro)

            repeat
                Wait(3)
            until not IsMacroRunningOrQueued(FateMacro)

            LogInfo(string.format("%s FateMacro has stopped", LogPrefix))

            NewBicolorGemCount = GetItemCount(26807)

            if NewBicolorGemCount == OldBicolorGemCount then
                LogInfo(string.format("%s No FATE completed. Bicolor Gem count unchanged: %d", LogPrefix, NewBicolorGemCount))
                FarmingZoneIndex = (FarmingZoneIndex % #ZonesToFarm) + 1
            else
                LogInfo(string.format("%s FATE completed. Updated Bicolor Gem count: %d", LogPrefix, NewBicolorGemCount))
                OldBicolorGemCount = NewBicolorGemCount
            end
        else
            LogInfo(string.format("%s Teleporting to zone: %s", LogPrefix, ZonesToFarm[FarmingZoneIndex].zoneName))
            Teleport(GetAetheryteName(ZonesToFarm[FarmingZoneIndex].zoneId))
        end
    end
    Wait(1)
end