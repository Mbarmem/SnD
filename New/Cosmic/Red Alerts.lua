--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Critical mission crafting automation aka RedAlerts
plugin_dependencies:
- Artisan
- vnavmesh
dependencies:
- source: https://raw.githubusercontent.com/Mbarmem/SnD/refs/heads/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

Mission_name = "Meteorite Drills" -- mission you want to do, case insensitive
EchoPrefix   = "[RedAlerts]"

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

function Find_mission_id(mission)
    local lower_search = mission:lower()
    for name, id in pairs(Missions) do
        if name:lower():find(lower_search, 1, true) then
            return id
        end
    end
    return nil
end

--=========================== EXECUTION ==========================--

local mission_id = Find_mission_id(Mission_name)

if not mission_id then
    LogInfo(string.format("%s Mission name not found, stopping script", EchoPrefix))
    return
end

while true do
    if not IsAddonReady("WKSMission") then
        yield("/callback WKSHud true 11")
    end

    WaitForAddon("WKSMission")

    LogInfo(string.format("%s Selecting mission ID: %s", EchoPrefix, tostring(mission_id)))
    yield("/callback WKSMission true 12 216 2 1")
    yield("/callback WKSMission true 13 " .. mission_id)

    repeat
        if IsAddonReady("SelectYesno") then
            yield("/callback SelectYesno true 0")
        end
        Wait(0.1)
    until IsAddonReady("WKSRecipeNotebook")

    ArtisanSetEnduranceStatus(true)
    LogInfo(string.format("%s Crafting started.", EchoPrefix))
    Wait(5)

    WaitForPlayer()
    ArtisanSetEnduranceStatus(false)

    LogInfo(string.format("%s Reporting to Collection Point.", EchoPrefix))
    MoveToTarget("Collection Point")
    Interact("Collection Point")
    Wait(3)

    WaitForPlayer()
    Wait(0.5)
end

--============================== END =============================--