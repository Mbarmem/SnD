--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Critical mission crafting automation aka RedAlerts
plugin_dependencies:
- Artisan
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  MissionName:
    description: Name of the mission to accept.
    is_choice: true
    choices:
        - "Work Ladders"
        - "Kindling"
        - "Fungal Building Materials"
        - "Meteorite Drills"
        - "Vacuum Muzzles"
        - "Flamethrower Parts"
        - "Spare Vacuum Tanks"
        - "Vehicular Plating"
        - "Gas Tanks"
        - "Lighting Repair Tools"
        - "Intricate Vacuum Parts"
        - "Spare Vehicle Parts"
        - "Impenetrable Gloves"
        - "Reinforced Gas Masks"
        - "Flame-resistant Workboots"
        - "Spare Cloth"
        - "Flame-resistant Work Cloth"
        - "Fungal Cloth"
        - "Aether-resistant Agent"
        - "Gas Poisoning Antidote"
        - "Flamethrower Fuel"
        - "Cured Foodstuffs"
        - "Nutrient Supplement Jelly"
        - "Irregular Spongoi Analysis"


[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

MissionName = Config.Get("MissionName")
LogPrefix   = "[RedAlerts]"

--============================ CONSTANT ==========================--

--------------------
--    Missions    --
--------------------

Missions = {
    ["Work Ladders"]               = 512,
    ["Kindling"]                   = 513,
    ["Fungal Building Materials"]  = 514,
    ["Meteorite Drills"]           = 515,
    ["Vacuum Muzzles"]             = 516,
    ["Flamethrower Parts"]         = 517,
    ["Spare Vacuum Tanks"]         = 518,
    ["Vehicular Plating"]          = 519,
    ["Gas Tanks"]                  = 520,
    ["Lighting Repair Tools"]      = 521,
    ["Intricate Vacuum Parts"]     = 522,
    ["Spare Vehicle Parts"]        = 523,
    ["Impenetrable Gloves"]        = 524,
    ["Reinforced Gas Masks"]       = 525,
    ["Flame-resistant Workboots"]  = 526,
    ["Spare Cloth"]                = 527,
    ["Flame-resistant Work Cloth"] = 528,
    ["Fungal Cloth"]               = 529,
    ["Aether-resistant Agent"]     = 530,
    ["Gas Poisoning Antidote"]     = 531,
    ["Flamethrower Fuel"]          = 532,
    ["Cured Foodstuffs"]           = 533,
    ["Nutrient Supplement Jelly"]  = 534,
    ["Irregular Spongoi Analysis"] = 535,
}

--=========================== FUNCTIONS ==========================--

function Find_Mission_ID(mission)
    local lower_search = mission:lower()
    for name, id in pairs(Missions) do
        if name:lower():find(lower_search, 1, true) then
            return id
        end
    end
    return nil
end

--=========================== EXECUTION ==========================--

local mission_id = Find_Mission_ID(MissionName)

if not mission_id then
    LogInfo(string.format("%s Mission name not found, stopping script", LogPrefix))
    return
end

while true do
    if not IsAddonReady("WKSMission") then
        Execute("/callback WKSHud true 11")
    end

    WaitForAddon("WKSMission")

    LogInfo(string.format("%s Selecting mission ID: %s", LogPrefix, tostring(mission_id)))
    Execute("/callback WKSMission true 12 216 2 1")
    Execute(string.format("/callback WKSMission true 13 %d", mission_id))

    repeat
        if IsAddonReady("SelectYesno") then
            Execute("/callback SelectYesno true 0")
        end
        Wait(0.1)
    until IsAddonReady("WKSRecipeNotebook")

    ArtisanSetEnduranceStatus(true)
    LogInfo(string.format("%s Crafting started.", LogPrefix))
    Wait(5)

    WaitForPlayer()
    ArtisanSetEnduranceStatus(false)

    LogInfo(string.format("%s Reporting to Collection Point.", LogPrefix))
    MoveToTarget("Collection Point", 4)
    Interact("Collection Point")
    Wait(3)

    WaitForPlayer()
    Wait(0.5)
end

--============================== END =============================--