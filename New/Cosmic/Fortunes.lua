--=========================================================--
-- Script Name: Cosmic Fortune Automation
-- Description: Automates cosmic fortune
-- Author: Censored
-- Version: 0.0.11 ?
-- How to use:
--  - When done with gathering Luna Credits just start the script.
--  - If you want to have the script in fullAutomatic mode, set `fullAuto` to true, otherwise you need to select a wheel.
--  - You can set a minimum for what the script should leave as credits.
--=========================================================--


--====================== IMPORT ===========================--

import("System.Numerics")

--====================== CONFIG ===========================--

local fullAuto = true
local minimumCreditsLeft = 0
local itemsWanted = {
    ["Vacuum Suit Identification Key"] = 200,
    ["Ballroom Etiquette - Personal Per..."] = 50, --Ballroom Etiquette - Personal Perfection
    ["Cosmosuit Coffer"] = 40,
    ["Micro Rover"] = 25,
    ["Loparasol"] = 5,
    ["The Faces We Wear - Tinted Sungl..."] = 5, --The Faces We Wear - Tinted Sunglasses
    ["Verdant Partition"] = 5,
    ["Stellar Opportunity"] = 0,
    ["Metallic Cobalt Green Dye"] = 0,
    ["Metallic Dark Blue Dye"] = 0,
    ["Metallic Pink Dye"] = 0,
    ["Metallic Ruby Red Dye"] = 0,
    ["Cracked Prismaticrystal"] = 0,
    ["Cracked Novacrystal"] = 0,
    ["Echoes in the Distance Orchestri..."] = 0, --Echoes in the Distance Orchestrion Roll
    ["Close in the Distance (Instrumen..."] = 0, --Close in the Distance (Instrumental) Orchestrion Roll
    ["Stargazers Orchestrion Roll"] = 0,
    ["Crafter's Delineation"] = 0,
    ["Drafting Table"] = 0,
    ["Cosmotable"] = 0,
    ["Cosmolamp"] = 0,
    ["Cordial "] = 0,
    ["Magicked Prism (Cosmic Explorat..."] = 0 --Magicked Prism (Cosmic Exploration)
}

--=========================================================--

--===================== CODE START ========================--
local npc = { name = "Orbitingway", x = 17, y = -1, z = -16 }

--- Calculates the distance from the player to a given 3D point.
function GetDistanceToPoint(vector3)
    local px = Svc.ClientState.LocalPlayer.Position.X
    local py = Svc.ClientState.LocalPlayer.Position.Y
    local pz = Svc.ClientState.LocalPlayer.Position.Z

    local dx = vector3.X - px
    local dy = vector3.Y - py
    local dz = vector3.Z - pz

    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    Dalamud.Log(string.format("[MoLib] [Distance] From (%.2f, %.2f, %.2f) to (%.2f, %.2f, %.2f) = %.2f", px, py, pz, vector3.X, vector3.Y, vector3.Z, distance))
    return distance
end

local function calculateTotalWeight()
    local itemsInFirstWheel = {}
    local itemsInSecondWheel = {}
    local weightFirstWheel = 0
    local weightSecondWheel = 0

    for i = 1, 7 do
        if Addons.GetAddon("WKSLottery"):GetNode(1, 30, 38 - i).IsVisible then
            local itemName = Addons.GetAddon("WKSLottery"):GetNode(1, 30, 38 - i, 10).Text

            if itemsInFirstWheel[itemName] then
                itemsInFirstWheel[itemName] = itemsInFirstWheel[itemName] + 1
            else
                itemsInFirstWheel[itemName] = 1
            end
        end

        if Addons.GetAddon("WKSLottery"):GetNode(1, 40, 48 - i).IsVisible then
            local itemName = Addons.GetAddon("WKSLottery"):GetNode(1, 40, 48 - i, 10).Text

            if itemsInSecondWheel[itemName] then
                itemsInSecondWheel[itemName] = itemsInSecondWheel[itemName] + 1
            else
                itemsInSecondWheel[itemName] = 1
            end
        end
    end

    for itemName, count in pairs(itemsInFirstWheel) do
        local itemWeight = itemsWanted[itemName]

        if itemWeight and itemWeight > 0 then
            weightFirstWheel = weightFirstWheel + (itemWeight * count)
        end
    end

    for itemName, count in pairs(itemsInSecondWheel) do
        local itemWeight = itemsWanted[itemName]

        if itemWeight and itemWeight > 0 then
            weightSecondWheel = weightSecondWheel + (itemWeight * count)
        end
    end

    return weightFirstWheel, weightSecondWheel
end

if not Addons.GetAddon("WKSLottery").Ready then
    -- Thanks to pot0to for some of this script

    while GetDistanceToPoint(Vector3(npc.x, npc.y, npc.z)) > 3 do
        if not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
            -- Thanks to Aliwen
            if GetDistanceToPoint(Vector3(npc.x, npc.y, npc.z)) > 80 then
                yield('/ac "Duty Action I"')
            else
                IPC.vnavmesh.PathfindAndMoveTo(Vector3(npc.x, npc.y, npc.z), false)
            end
        end

        repeat
            yield("/wait 1")
        until Player.Available
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        IPC.vnavmesh.Stop()
    end

    yield("/target " .. npc.name)
    yield("/wait 0.5")
    yield("/interact")

    repeat
        yield("/wait 0.5")
    until Addons.GetAddon("SelectString").Ready

    yield("/wait 0.5")
    yield("/callback SelectString true 0")

    repeat
        yield("/wait 0.5")
    until Addons.GetAddon("SelectString").Ready

    yield("/wait 0.5")
    yield("/callback SelectString true 0")
end

while Inventory.GetItemCount(45691) >= 1000 or Addons.GetAddon("WKSLottery").Ready do
    repeat
        yield("/wait 0.5")
    until Addons.GetAddon("WKSLottery"):GetNode(1, 30).IsVisible and Addons.GetAddon("WKSLottery"):GetNode(1, 40).IsVisible

    if not fullAuto then
        yield("/wait 1")
    end

    local weightFirstWheel, weightSecondWheel = calculateTotalWeight()

    if weightFirstWheel > weightSecondWheel then
        yield("/echo First wheel is better with total weight: " .. weightFirstWheel)

        if fullAuto then
            yield("/callback WKSLottery true 0 0")
            yield("/wait 0.1")
            yield("/callback WKSLottery true 1 0")
        end
    elseif weightSecondWheel > weightFirstWheel then
        yield("/echo Second wheel is better with total weight: " .. weightSecondWheel)

        if fullAuto then
            yield("/callback WKSLottery true 0 1")
            yield("/wait 0.1")
            yield("/callback WKSLottery true 1 0")
        end
    else
        yield("/echo Both wheels are equal in weight.")

        if fullAuto then
            yield("/callback WKSLottery true 0 0")
            yield("/wait 0.1")
            yield("/callback WKSLottery true 1 0")
        end
    end

    repeat
        yield("/wait 0.5")
    until not (Addons.GetAddon("WKSLottery"):GetNode(1, 30).IsVisible or Addons.GetAddon("WKSLottery"):GetNode(1, 40).IsVisible)

    if not fullAuto then
        yield("/wait 1")
    end

    yield("/callback WKSLottery true 0 0")
    yield("/wait 0.1")
    yield("/callback WKSLottery true 1 0")
    yield("/wait 0.1")
    yield("/callback WKSLottery true 2 0")
    yield("/wait 0.5")

    if minimumCreditsLeft >= 1000 and GetItemCount(45691) < minimumCreditsLeft + 1000 then
        if Addons.GetAddon("SelectYesno").Ready then
            yield("/callback SelectYesno true 1")
        end

        break
    else
        if Addons.GetAddon("SelectYesno").Ready then
            yield("/callback SelectYesno true 0")
        end
    end
end