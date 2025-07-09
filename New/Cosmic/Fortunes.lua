--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Cosmic Fortunes
plugin_dependencies:
- vnavmesh
dependencies:
- source: https://raw.githubusercontent.com/Mbarmem/SnD/refs/heads/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

local fullAuto = true
local minimumCreditsLeft = 0
local EchoPrefix = "[CosmicFortunes]"

local npc = {
    name = "Orbitingway",
    x = 17,
    y = -1,
    z = -16
}

local itemsWanted = {
    ["Vacuum Suit Identification Key"]              = 200,
    ["Ballroom Etiquette - Personal Per..."]        = 50,  -- Ballroom Etiquette - Personal Perfection
    ["Cosmosuit Coffer"]                            = 40,
    ["Micro Rover"]                                 = 25,
    ["Loparasol"]                                   = 5,
    ["The Faces We Wear - Tinted Sungl..."]         = 5,  -- The Faces We Wear - Tinted Sunglasses
    ["Verdant Partition"]                           = 5,
    ["Stellar Opportunity"]                         = 0,
    ["Metallic Cobalt Green Dye"]                   = 0,
    ["Metallic Dark Blue Dye"]                      = 0,
    ["Metallic Pink Dye"]                           = 0,
    ["Metallic Ruby Red Dye"]                       = 0,
    ["Cracked Prismaticrystal"]                     = 0,
    ["Cracked Novacrystal"]                         = 0,
    ["Echoes in the Distance Orchestri..."]         = 0,  -- Echoes in the Distance Orchestrion Roll
    ["Close in the Distance (Instrumen..."]         = 0,  -- Close in the Distance (Instrumental) Orchestrion Roll
    ["Stargazers Orchestrion Roll"]                 = 0,
    ["Crafter's Delineation"]                       = 0,
    ["Drafting Table"]                              = 0,
    ["Cosmotable"]                                  = 0,
    ["Cosmolamp"]                                   = 0,
    ["Cordial "]                                   = 0,
    ["Magicked Prism (Cosmic Explorat..."]          = 0   -- Magicked Prism (Cosmic Exploration)
}

--=========================== FUNCTIONS ==========================--

local function calculateTotalWeight()
    local itemsInFirstWheel = {}
    local itemsInSecondWheel = {}
    local weightFirstWheel = 0
    local weightSecondWheel = 0

    for i = 1, 7 do
        if IsNodeVisible("WKSLottery", 1, 30, 38 - i) then
            local itemName = GetNodeText("WKSLottery", 1, 30, 38 - i, 10)
            itemsInFirstWheel[itemName] = (itemsInFirstWheel[itemName] or 0) + 1
        end

        if IsNodeVisible("WKSLottery", 1, 40, 48 - i) then
            local itemName = GetNodeText("WKSLottery", 1, 40, 48 - i, 10)
            itemsInSecondWheel[itemName] = (itemsInSecondWheel[itemName] or 0) + 1
        end
    end

    for itemName, count in pairs(itemsInFirstWheel) do
        local weight = itemsWanted[itemName]
        if weight and weight > 0 then
            weightFirstWheel = weightFirstWheel + (weight * count)
        end
    end

    for itemName, count in pairs(itemsInSecondWheel) do
        local weight = itemsWanted[itemName]
        if weight and weight > 0 then
            weightSecondWheel = weightSecondWheel + (weight * count)
        end
    end

    return weightFirstWheel, weightSecondWheel
end

--=========================== EXECUTION ==========================--

if not IsAddonReady("WKSLottery") then
    while GetDistanceToPoint(npc.x, npc.y, npc.z) > 3 do
        if not PathfindInProgress() and not PathIsRunning() then
            if GetDistanceToPoint(npc.x, npc.y, npc.z) > 80 then
                yield('/ac "Duty Action I"')
            else
                MoveTo(npc.x, npc.y, npc.z)
            end
        end
        WaitForPlayer()
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
    end

    Interact(npc.name)

    while not IsPlayerAvailable() do
        Wait(0.1)

        if IsAddonVisible("Talk") then
            yield("/callback Talk true 0")
        end

        if IsAddonVisible("SelectString") then
            Wait(0.5)
            yield("/callback SelectString true 0")
        end

        if IsAddonVisible("WKSLottery") then
            break
        end
    end
end

while GetItemCount(45691) >= 1000 or IsAddonReady("WKSLottery") do
    repeat
        Wait(0.5)
    until IsNodeVisible("WKSLottery", 1, 30) and IsNodeVisible("WKSLottery", 1, 40)

    if not fullAuto then
        Wait(1)
    end

    local weightFirstWheel, weightSecondWheel = calculateTotalWeight()

    if weightFirstWheel > weightSecondWheel then
        Echo(string.format("First wheel is better with total weight: %s", weightFirstWheel), EchoPrefix)

        if fullAuto then
            yield("/callback WKSLottery true 0 0")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end

    elseif weightSecondWheel > weightFirstWheel then
        Echo(string.format("Second wheel is better with total weight: %s", weightSecondWheel), EchoPrefix)

        if fullAuto then
            yield("/callback WKSLottery true 0 1")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end

    else
        Echo(string.format("Both wheels are equal in weight."), EchoPrefix)

        if fullAuto then
            yield("/callback WKSLottery true 0 0")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end
    end

    repeat
        Wait(0.5)
    until not (IsNodeVisible("WKSLottery", 1, 30) and IsNodeVisible("WKSLottery", 1, 40))

    if not fullAuto then
        Wait(1)
    end

    yield("/callback WKSLottery true 0 0")
    Wait(0.1)
    yield("/callback WKSLottery true 1 0")
    Wait(0.1)
    yield("/callback WKSLottery true 2 0")
    Wait(0.5)

    if minimumCreditsLeft >= 1000 and GetItemCount(45691) < minimumCreditsLeft + 1000 then
        if IsAddonReady("SelectYesno") then
            yield("/callback SelectYesno true 1")
        end
        break
    else
        if IsAddonReady("SelectYesno") then
            yield("/callback SelectYesno true 0")
        end
    end

    if IsAddonVisible("Talk") then
        CloseAddons()
    end
end

--============================== END =============================--