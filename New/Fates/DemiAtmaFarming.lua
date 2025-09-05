--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Demiatma Farming - Secondary script for FateFarming
plugin_dependencies:
- Lifestream
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  FateMacro:
    description: Name of the primary fate macro script.
    default: FateFarming
  NumberToFarm:
    description: Number of each DemiAtma to farm.
    default: 1
    min: 1
    max: 99
  WaitBeforeLoop:
    description: Time to wait before restarting the loop if no fates are found.
    default: 10
    min: 1
    max: 60

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

FateMacro      = Config.Get("FateMacro")
NumberToFarm   = Config.Get("NumberToFarm")
WaitBeforeLoop = Config.Get("WaitBeforeLoop")
LogPrefix      = "[DemiAtmaFarming]"

--============================ CONSTANT ==========================--

----------------
--    Atma    --
----------------

Atmas = {
    { zoneName = "Urqopacha",       zoneId = 1187, itemName = "Azurite Demiatma",          itemId = 47744 },
    { zoneName = "Kozama'uka",      zoneId = 1188, itemName = "Verdigris Demiatma",        itemId = 47745 },
    { zoneName = "Yak T'el",        zoneId = 1189, itemName = "Malachite Demiatma",        itemId = 47746 },
    { zoneName = "Shaaloani",       zoneId = 1190, itemName = "Realgar Demiatma",          itemId = 47747 },
    { zoneName = "Heritage Found",  zoneId = 1191, itemName = "Caput Mortuum Demiatma",    itemId = 47748 },
    { zoneName = "Living Memory",   zoneId = 1192, itemName = "Orpiment Demiatma",         itemId = 47749 }
}

--=========================== FUNCTIONS ==========================--

FarmingZoneIndex = 1
FullPass         = true
DidFateOnPass    = false

function OnChatMessage()
    local message = TriggerData.message
    local patternToMatch = "%[FATE%] Loop Ended !!"

    if message and message:find(patternToMatch) then
        LogInfo(string.format("%s OnChatMessage triggered", LogPrefix))
        FateMacroRunning = false
        LogInfo(string.format("%s FateMacro has stopped", LogPrefix))
    end
end

function GetNextAtmaTable()
    while FarmingZoneIndex <= #Atmas and GetItemCount(Atmas[FarmingZoneIndex].itemId) >= NumberToFarm do
        FarmingZoneIndex = FarmingZoneIndex + 1
    end

    if FarmingZoneIndex <= #Atmas then
        FullPass = false
        return Atmas[FarmingZoneIndex]
    elseif FullPass then
        LogInfo(string.format("%s Did full pass, no more zones to farm. Returning nil.", LogPrefix))
        return nil
    else
        if not DidFateOnPass then
            LogInfo(string.format("%s No FATEs completed this pass. Waiting %s seconds.", LogPrefix, WaitBeforeLoop))
            Wait(WaitBeforeLoop)
        end
        FarmingZoneIndex = (FarmingZoneIndex % #Atmas) + 1
        FullPass = true
        DidFateOnPass = false
        return GetNextAtmaTable()
    end
end

--=========================== EXECUTION ==========================--

LogInfo(string.format("%s Starting DemiAtma farming...", LogPrefix))

FateMacroRunning     = false
OldBicolorGemCount   = GetItemCount(26807)
NextAtmaTable        = GetNextAtmaTable()

while NextAtmaTable ~= nil do
    if IsPlayerAvailable() and not FateMacroRunning then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            LogInfo(string.format("%s Already have enough %s. Skipping zone: %s", LogPrefix, NextAtmaTable.itemName, NextAtmaTable.zoneName))
            NextAtmaTable = GetNextAtmaTable()

        elseif not IsInZone(NextAtmaTable.zoneId) then
            LogInfo(string.format("%s Teleporting to: %s", LogPrefix, NextAtmaTable.zoneName))
            local aetheryteName = GetAetheryteName(NextAtmaTable.zoneId)

            if aetheryteName then
                Teleport(aetheryteName)
            else
                LogInfo(string.format("%s No valid aetheryte found for zone %s", LogPrefix, NextAtmaTable.zoneId))
            end

        else
            LogInfo(string.format("%s Running FateMacro in zone: %s for %s", LogPrefix, NextAtmaTable.zoneName, NextAtmaTable.itemName))
            Execute(string.format("/snd run %s", FateMacro))

            while FateMacroRunning do
                yield("/wait 3")
            end

            LogInfo(string.format("%s FateMacro has stopped", LogPrefix))
            NewBicolorGemCount = GetItemCount(26807)

            if NewBicolorGemCount == OldBicolorGemCount then
                LogInfo(string.format("%s FateMacro exited without completing any FATEs.", LogPrefix))
                FarmingZoneIndex = FarmingZoneIndex + 1
                NextAtmaTable    = GetNextAtmaTable()
            else
                LogInfo(string.format("%s FateMacro completed a FATE successfully.", LogPrefix))
                DidFateOnPass      = true
                OldBicolorGemCount = NewBicolorGemCount
            end
        end
    end
    Wait(1)
end

LogInfo(string.format("%s Farming complete. No more Atma needed.", LogPrefix))

--============================== END =============================--