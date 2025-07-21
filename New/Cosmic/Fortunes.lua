--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Cosmic Fortunes
plugin_dependencies:
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  FullAuto:
    default: true
    description: Enable or disable the use of FullAuto.
    type: boolean
  MinimumCreditsLeft:
    default: 0
    description: Minimum number of credits to retain before stopping further spending or actions.
    type: int
    min: 0
    max: 10000

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

FullAuto           = Config.Get("FullAuto")
MinimumCreditsLeft = Config.Get("MinimumCreditsLeft")
LogPrefix          = "[CosmicFortunes]"

--============================ CONSTANT ==========================--

---------------
--    NPC    --
---------------

Npc = {
    Name = "Orbitingway",
    X = 17,
    Y = -1,
    Z = -16
}

-----------------
--    Items    --
-----------------

ItemsWanted = {
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

function CalculateTotalWeight()
    local itemsInFirstWheel = {}
    local itemsInSecondWheel = {}
    local weightFirstWheel = 0
    local weightSecondWheel = 0

    for i = 1, 7 do
        if IsNodeVisible("WKSLottery", 1, 30, 38 - i) then
            local itemName = GetNodeText("WKSLottery", 1, 30, 38 - i, 10) or 0
            itemsInFirstWheel[itemName] = (itemsInFirstWheel[itemName] or 0) + 1
        end

        if IsNodeVisible("WKSLottery", 1, 40, 48 - i) then
            local itemName = GetNodeText("WKSLottery", 1, 40, 48 - i, 10) or 0
            itemsInSecondWheel[itemName] = (itemsInSecondWheel[itemName] or 0) + 1
        end
    end

    for itemName, count in pairs(itemsInFirstWheel) do
        local weight = ItemsWanted[itemName]
        if weight and weight > 0 then
            weightFirstWheel = weightFirstWheel + (weight * count)
        end
    end

    for itemName, count in pairs(itemsInSecondWheel) do
        local weight = ItemsWanted[itemName]
        if weight and weight > 0 then
            weightSecondWheel = weightSecondWheel + (weight * count)
        end
    end

    return weightFirstWheel, weightSecondWheel
end

--=========================== EXECUTION ==========================--

if not IsAddonReady("WKSLottery") then
    while GetDistanceToPoint(Npc.X, Npc.Y, Npc.Z) > 3 do
        if not PathfindInProgress() and not PathIsRunning() then
            if GetDistanceToPoint(Npc.X, Npc.Y, Npc.Z) > 80 then
                yield('/ac "Duty Action I"')
            else
                MoveTo(Npc.X, Npc.Y, Npc.Z)
            end
        end
        WaitForPlayer()
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
    end

    Interact(Npc.Name)

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

    if not FullAuto then
        Wait(1)
    end

    local weightFirstWheel, weightSecondWheel = CalculateTotalWeight()

    if weightFirstWheel > weightSecondWheel then
        Echo(string.format("First wheel is better with total weight: %s", weightFirstWheel), LogPrefix)

        if FullAuto then
            yield("/callback WKSLottery true 0 0")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end

    elseif weightSecondWheel > weightFirstWheel then
        Echo(string.format("Second wheel is better with total weight: %s", weightSecondWheel), LogPrefix)

        if FullAuto then
            yield("/callback WKSLottery true 0 1")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end

    else
        Echo(string.format("Both wheels are equal in weight."), LogPrefix)

        if FullAuto then
            yield("/callback WKSLottery true 0 0")
            Wait(1)
            yield("/callback WKSLottery true 1 0")
        end
    end

    repeat
        Wait(0.5)
    until not (IsNodeVisible("WKSLottery", 1, 30) and IsNodeVisible("WKSLottery", 1, 40))

    if not FullAuto then
        Wait(1)
    end

    yield("/callback WKSLottery true 0 0")
    Wait(0.1)
    yield("/callback WKSLottery true 1 0")
    Wait(0.1)
    yield("/callback WKSLottery true 2 0")
    Wait(0.5)

    if MinimumCreditsLeft >= 1000 and GetItemCount(45691) < MinimumCreditsLeft + 1000 then
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

Echo(string.format("Cosmic Fortunes script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Cosmic Fortunes script completed successfully..!!", LogPrefix))

--============================== END =============================--