--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Forager - Script for Fishing Gatherer Scrips
plugin_dependencies:
- AutoHook
- AutoRetainer
- Lifestream
- vnavmesh
- YesAlready
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  ScripColorToFarm:
    default: Purple
    description: Type of scrip to farm (Orange, Purple).
    type: string
    required: true
  ItemToExchange:
    default: Hi-Cordial
    description: Name of the item to purchase using scrips.
    type: string
  Food:
    default:
    description: Leave blank if you don't want to use any food. If its HQ include <hq> next to the name "Baked Eggplant <hq>"
    type: string
  Potion:
    default:
    description: Leave blank if you don't want to use any potions. If its HQ include <hq> next to the name "Superior Spiritbond Potion <hq>"
    type: string
  HubCity:
    default: Solution Nine
    description: Main city to use as a hub for turn-ins and purchases (Ul'dah, Limsa, Gridania, or Solution Nine).
    type: string
  MinInventoryFreeSlots:
    default: 15
    description: Minimum free inventory slots required to start turn-ins.
    type: integer
    min: 0
    max: 140
    required: true
  ReturnToGCTown:
    default: false
    description: Whether to return to the Grand Company town.
    type: boolean
  DoAutoRetainers:
    default: true
    description: Automatically interact with retainers for ventures.
    type: boolean
  GrandCompanyTurnIn:
    default: false
    description: Automatically turn in eligible items to your Grand Company for seals.
    type: boolean
  SelfRepair:
    default: true
    description: Automatically repair your own gear when durability is low.
    type: boolean
  RepairThreshold:
    default: 20
    description: Durability percentage at which tools should be repaired.
    type: integer
    min: 0
    max: 100
  ExtractMateria:
    default: true
    description: Automatically extract materia from fully spiritbonded gear.
    type: boolean
  ReduceEphemerals:
    default: true
    description: Automatically reduce items gathered from ephemeral nodes.
    type: boolean
  MoveSpotsAfter:
    default: 30
    description: Number of minutes to fish one spot before moving to the next.
    type: integer
  ResetHardAmissAfter:
    default: 120
    description: Number of minutes to farm in current instance before teleporting away and back.
    type: integer

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

ScripColorToFarm       = Config.Get("ScripColorToFarm")
ItemToExchange         = Config.Get("ItemToExchange")
Food                   = Config.Get("Food")
Potion                 = Config.Get("Potion")
HubCity                = Config.Get("HubCity")
MinInventoryFreeSlots  = Config.Get("MinInventoryFreeSlots")
ReturnToGCTown         = Config.Get("ReturnToGCTown")
DoAutoRetainers        = Config.Get("DoAutoRetainers")
GrandCompanyTurnIn     = Config.Get("GrandCompanyTurnIn")
SelfRepair             = Config.Get("SelfRepair")
RepairThreshold        = Config.Get("RepairThreshold")
ExtractMateria         = Config.Get("ExtractMateria")
ReduceEphemerals       = Config.Get("ReduceEphemerals")
MoveSpotsAfter         = Config.Get("MoveSpotsAfter")
ResetHardAmissAfter    = Config.Get("ResetHardAmissAfter")
LogPrefix              = "[Forager]"

------------------
--    Scrips    --
------------------

OrangeGathererScripId = 41785
PurpleGathererScripId = 33914

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

-----------------
--    Items    --
-----------------

ScripExchangeItems = {
    {
        itemName        = "Mount Token",
        categoryMenu    = 4,
        subcategoryMenu = 8,
        listIndex       = 6,
        price           = 1000
    },
    {
        itemName        = "Hi-Cordial",
        categoryMenu    = 4,
        subcategoryMenu = 1,
        listIndex       = 0,
        price           = 20
    }
}

--------------------
--    Merchant    --
--------------------

FishingBaitMerchant = {
    npcName   = "Merchant & Mender",
    x         = -398,
    y         = 3,
    z         = 80,
    zoneId    = 129,
    aetheryte = "Limsa Lominsa",
    aethernet = { name = "Arcanists' Guild", x = -336, y = 12, z = 56 }
}

------------------------
--    Collectables    --
------------------------

FishTable = {
    {
        fishName                    = "Zorgor Condor",
        fishId                      = 43761,
        baitName                    = "Versatile Lure",
        zoneId                      = 1190,
        zoneName                    = "Shaaloani",
        autoHookPreset              = "[SND] Zorgor Condor - Orange Scrips",
        fishingSpots = {
            maxHeight               = 1024,
            waypoints = {
                { x =  -4.47, y = -6.85, z =  747.47 },
                { x =  59.27, y = -2.00, z =  735.09 },
                { x = 135.71, y =  6.12, z =  715.00 },
                { x = 212.50, y = 12.20, z =  739.26 }
            },
            pointToFace             = { x = 134.07, y = 6.07, z = 10000 }
        },
        scripColor                  = "Orange",
        scripId                     = 39,
        collectiblesTurnInListIndex = 6
    },
    {
        fishName                    = "Fleeting Brand",
        fishId                      = 36473,
        baitName                    = "Versatile Lure",
        zoneId                      = 959,
        zoneName                    = "Mare Lamentorum",
        autoHookPreset              = "[SND] Fleeting Brand - Purple Scrips",
        fishingSpots = {
            maxHeight               = 35,
            waypoints = {
                { x = 10.05, y = 26.89, z = 448.99 },
                { x = 37.71, y = 22.36, z = 481.05 },
                { x = 58.87, y = 22.22, z = 487.95 },
                { x = 71.79, y = 22.39, z = 477.65 }
            },
            pointToFace             = { x = 37.71, y = 22.36, z = 1000 }
        },
        scripColor                  = "Purple",
        scripId                     = 38,
        collectiblesTurnInListIndex = 28
    }
}

-------------------
--    HubCity    --
-------------------

HubCities = {
    {
        zoneName      = "Limsa",
        zoneId        = 129,
        aethernet     = { aethernetZoneId = 129, aethernetName = "Hawkers' Alley", x = -213.61108, y = 16.739136, z = 51.80432 },
        retainerBell  = { x = -124.703, y = 18, z = 19.887, requiresAethernet = false },
        scripExchange = { x = -258.52585, y = 16.2, z = 40.65883, requiresAethernet = true }
    },
    {
        zoneName      = "Gridania",
        zoneId        = 132,
        aethernet     = { aethernetZoneId = 133, aethernetName = "Leatherworkers' Guild & Shaded Bower", x = 101, y = 9, z = -112 },
        retainerBell  = { x = 168.72, y = 15.5, z = -100.06, requiresAethernet = true },
        scripExchange = { x = 142.15, y = 13.74, z = -105.39, requiresAethernet = true }
    },
    {
        zoneName      = "Ul'dah",
        zoneId        = 130,
        aethernet     = { aethernetZoneId = 131, aethernetName = "Sapphire Avenue Exchange", x = 131.9447, y = 4.714966, z = -29.800903 },
        retainerBell  = { x = 148, y = 3, z = -45, requiresAethernet = true },
        scripExchange = { x = 148.39, y = 3.99, z = -18.4, requiresAethernet = true }
    },
    {
        zoneName      = "Solution Nine",
        zoneId        = 1186,
        aethernet     = { aethernetZoneId = 1186, aethernetName = "Nexus Arcade", x = -161, y = -1, z = 21 },
        retainerBell  = { x = -152.465, y = 0.66, z = -13.557, requiresAethernet = true },
        scripExchange = { x = -158.019, y = 0.922, z = -37.884, requiresAethernet = true }
    }
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Utility    --
-------------------

function OnChatMessage()
    local message = TriggerData.message
    local patternToMatch = "The fish sense something amiss. Perhaps it is time to try another location."

    if message and message:find(patternToMatch) then
        LogInfo(string.format("%s OnChatMessage triggered for Fish sense..!!", LogPrefix))
        State = CharacterState.fishSense
        LogInfo(string.format("%s State changed to: FishSense", LogPrefix))
    end
end

function CharacterState.fishSense()
    if IsGathering() or IsFishing() then
        ExecuteAction(CharacterAction.Actions.quitFishing)
    end

    WaitForPlayer()
    Teleport("Inn")
    State = CharacterState.awaitingAction
    LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
end

-------------------
--    Fishing    --
-------------------

function InterpolateCoordinates(startCoords, endCoords, n)
    local x = startCoords.x + n * (endCoords.x - startCoords.x)
    local y = startCoords.y + n * (endCoords.y - startCoords.y)
    local z = startCoords.z + n * (endCoords.z - startCoords.z)
    LogInfo(string.format("%s Resulting coordinates: x=%.2f, y=%.2f, z=%.2f", LogPrefix, x, y, z))
    return { waypointX = x, waypointY = y, waypointZ = z }
end

function GetWaypoint(coords, n)
    LogInfo(string.format("%s Calculating waypoint for n = %.2f", LogPrefix, n))
    local total_distance = 0
    local distances = {}

    -- Calculate distances between each pair of coordinates
    for i = 1, #coords - 1 do
        local dx = coords[i + 1].x - coords[i].x
        local dy = coords[i + 1].y - coords[i].y
        local dz = coords[i + 1].z - coords[i].z
        local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
        table.insert(distances, distance)
        total_distance = total_distance + distance
    end

    -- Find the target distance
    local target_distance = n * total_distance

    -- Walk through the coordinates to find the target coordinates
    local accumulated_distance = 0
    for i = 1, #coords - 1 do
        if accumulated_distance + distances[i] >= target_distance then
            local remaining_distance = target_distance - accumulated_distance
            local t = remaining_distance / distances[i]
            return InterpolateCoordinates(coords[i], coords[i + 1], t)
        end
        accumulated_distance = accumulated_distance + distances[i]
    end

    -- If n is 1 (100%), return the last coordinate
    return { waypointX = coords[#coords].x, waypointY = coords[#coords].y, waypointZ = coords[#coords].z }
end

function SelectNewFishingHole()
    LogInfo(string.format("%s Selecting new fishing hole", LogPrefix))

    -- If there are waypoints defined, select a random interpolated waypoint
    SelectedFishingSpot = GetWaypoint(SelectedFish.fishingSpots.waypoints, math.random())
    local point = QueryMeshPointOnFloor(SelectedFishingSpot.waypointX, SelectedFish.fishingSpots.maxHeight, SelectedFishingSpot.waypointZ, false, 50)
    SelectedFishingSpot.waypointY = (point and point.Y) or SelectedFishingSpot.waypointY or 0

    -- Set facing direction coordinates
    SelectedFishingSpot.x = SelectedFish.fishingSpots.pointToFace.x
    SelectedFishingSpot.y = SelectedFish.fishingSpots.pointToFace.y
    SelectedFishingSpot.z = SelectedFish.fishingSpots.pointToFace.z

    SelectedFishingSpot.startTime = os.clock()
    SelectedFishingSpot.lastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos() }
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local distance = maxDistance * math.random()

    local randomX = x + distance * math.cos(angle)
    local randomY = y + maxDistance
    local randomZ = z + distance * math.sin(angle)

    return randomX, randomY, randomZ
end

function CharacterState.teleportFishingZone()
    if not IsInZone(SelectedFish.zoneId) then
        local aetheryteName = GetAetheryteName(SelectedFish.zoneId)
        if aetheryteName then
            Teleport(aetheryteName)
        end
    elseif IsPlayerAvailable() then
        Wait(3)
        SelectNewFishingHole()
        ResetHardAmissTime = os.clock()
        State = CharacterState.goToFishingHole
        LogInfo(string.format("%s State changed to: GoToFishingHole", LogPrefix))
    end
end

function CharacterState.goToFishingHole()
    if not IsInZone(SelectedFish.zoneId) then
        State = CharacterState.teleportFishingZone
        LogInfo(string.format("%s State changed to: TeleportFishingZone", LogPrefix))
        return
    end

    -- if stuck for over 10s, adjust
    local now = os.clock()
    if now - SelectedFishingSpot.startTime > 10 then
        SelectedFishingSpot.startTime = now
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()

        local lastStuckCheckPosition = SelectedFishingSpot.lastStuckCheckPosition

        if lastStuckCheckPosition and lastStuckCheckPosition.x and lastStuckCheckPosition.y and lastStuckCheckPosition.z then
            if GetDistanceToPoint(lastStuckCheckPosition.x, lastStuckCheckPosition.y, lastStuckCheckPosition.z) < 2 then
                LogInfo(string.format("%s Stuck in same spot for over 10 seconds.", LogPrefix))
                if PathfindInProgress() or PathIsRunning() then
                    PathStop()
                end
                local rX, rY, rZ = RandomAdjustCoordinates(x, y, z, 20)
                if rX and rY and rZ then
                    PathfindAndMoveTo(rX, rY, rZ, IsMounted())
                    WaitForPathRunning()
                end
                return
            end
        end

        -- Update the last check position if it's nil or we moved
        SelectedFishingSpot.lastStuckCheckPosition = { x = x, y = y, z = z }
    end

    local distanceToWaypoint = GetDistanceToPoint(SelectedFishingSpot.waypointX, GetPlayerRawYPos(), SelectedFishingSpot.waypointZ)
    if distanceToWaypoint > 10 then
        if not IsMounted() then
            Mount()
            State = CharacterState.goToFishingHole
            LogInfo(string.format("%s State changed to: GoToFishingHole", LogPrefix))
        elseif not (PathfindInProgress() or PathIsRunning()) then
            LogInfo(string.format("%s Moving to waypoint: (%.2f, %.2f, %.2f)", LogPrefix, SelectedFishingSpot.waypointX, SelectedFishingSpot.waypointY, SelectedFishingSpot.waypointZ))
            PathfindAndMoveTo(SelectedFishingSpot.waypointX, SelectedFishingSpot.waypointY, SelectedFishingSpot.waypointZ, true)
            WaitForPathRunning()
        end
        Wait(1)
        return
    end

    Dismount()

    State = CharacterState.fishing
    LogInfo(string.format("%s State changed to: Fishing", LogPrefix))
end

ResetHardAmissTime = os.clock()

function CharacterState.fishing()
    if GetItemCount(29717) == 0 then
        State = CharacterState.buyFishingBait
        LogInfo(string.format("%s State changed to: Buy Fishing Bait", LogPrefix))
        return
    end

    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        LogInfo(string.format("%s Not enough inventory space", LogPrefix))
        if IsGathering() then
            ExecuteAction(CharacterAction.Actions.quitFishing)
            Wait(1)
        else
            State = CharacterState.turnIn
            LogInfo(string.format("%s State changed to: TurnIn", LogPrefix))
        end
        return
    end

    if os.clock() - ResetHardAmissTime > (ResetHardAmissAfter*60) then
        if IsGathering() then
            if not IsFishing() then
                ExecuteAction(CharacterAction.Actions.quitFishing)
                Wait(1)
            end
        else
            State = CharacterState.turnIn
            LogInfo(string.format("%s State changed to: Forced TurnIn to avoid hard amiss", LogPrefix))
        end
        return
    elseif os.clock() - SelectedFishingSpot.startTime > (MoveSpotsAfter*60) then
        LogInfo(string.format("%s Switching fishing spots", LogPrefix))
        if IsGathering() then
            if not IsFishing() then
                ExecuteAction(CharacterAction.Actions.quitFishing)
                Wait(1)
            end
        else
            SelectNewFishingHole()
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: Timeout AwaitingAction", LogPrefix))
        end
        return
    elseif IsGathering() then
        if PathfindInProgress() or PathIsRunning() then
            PathStop()
        end
        Wait(1)
        return
    end

    local now = os.clock()
    if now - SelectedFishingSpot.startTime > 10 then
        SelectedFishingSpot.startTime = now
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()

        local lastStuckCheckPosition = SelectedFishingSpot.lastStuckCheckPosition

        if lastStuckCheckPosition and lastStuckCheckPosition.x and lastStuckCheckPosition.y and lastStuckCheckPosition.z then
            if GetDistanceToPoint(lastStuckCheckPosition.x, lastStuckCheckPosition.y, lastStuckCheckPosition.z) < 2 then
                LogInfo(string.format("%s Stuck in same spot for over 10 seconds.", LogPrefix))
                if PathfindInProgress() or PathIsRunning() then
                    PathStop()
                end
                local rX, rY, rZ = RandomAdjustCoordinates(x, y, z, 20)
                if rX and rY and rZ then
                    PathfindAndMoveTo(rX, rY, rZ, IsMounted())
                    WaitForPathRunning()
                end
                return
            end
        end

        -- Update the last check position if it's nil or we moved
        SelectedFishingSpot.lastStuckCheckPosition = { x = x, y = y, z = z }
    end

    Execute("/vnavmesh movedir 0 0 10")
    Wait(1)
    ExecuteAction(CharacterAction.Actions.castFishing)
    Wait(0.5)
end

function CharacterState.buyFishingBait()
    if GetItemCount(29717) >= 1 then
        if IsAddonReady("Shop") then
            Execute("/callback Shop true -1")
        else
            State = CharacterState.goToFishingHole
            LogInfo(string.format("%s State changed to: GoToFishingHole", LogPrefix))
        end
        return
    end

    if not IsInZone(FishingBaitMerchant.zoneId) then
        Teleport(FishingBaitMerchant.aetheryte)
        LogInfo(string.format("%s Teleporting to %s", LogPrefix, FishingBaitMerchant.aetheryte))
        return
    end

    local distanceToMerchant = GetDistanceToPoint(FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)
    local distanceViaAethernet = DistanceBetween(FishingBaitMerchant.aethernet.x, FishingBaitMerchant.aethernet.y, FishingBaitMerchant.aethernet.z, FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)

    if distanceToMerchant > distanceViaAethernet + 20 then
        if not LifestreamIsBusy() then
            Teleport(FishingBaitMerchant.aethernet.name)
        end
        return
    end

    if IsAddonReady("TelepotTown") then
        Execute("/callback TelepotTown true -1")
        return
    end

    if distanceToMerchant > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)
            WaitForPathRunning()
            LogInfo(string.format("%s Moving to merchant at (%.2f, %.2f, %.2f)", LogPrefix, FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z))
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
        return
    end

    if not HasTarget(FishingBaitMerchant.npcName) then
        Target(FishingBaitMerchant.npcName)
        return
    end

    if IsAddonReady("SelectIconString") then
        Execute("/callback SelectIconString true 0")
    elseif IsAddonReady("SelectYesno") then
        Execute("/callback SelectYesno true 0")
    elseif IsAddonReady("Shop") then
        Execute("/callback Shop true 0 3 99 0")
    else
        Interact(FishingBaitMerchant.npcName)
    end
end

--------------------
--    Movement    --
--------------------

function CharacterState.goToHubCity()
    if not IsPlayerAvailable() then
        Wait(1)
        return
    end

    if not IsInZone(SelectedHubCity.zoneId) then
        LogInfo(string.format("%s Not in hub city zone. Teleporting to %s.", LogPrefix, tostring(SelectedHubCity.zoneName)))
        Teleport(SelectedHubCity.aetheryte)
        return
    end

    State = CharacterState.awaitingAction
    LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
end

------------------
--    TurnIn    --
------------------

function CharacterState.turnIn()
    if GetItemCount(SelectedFish.fishId) == 0 then
        if IsAddonReady("CollectablesShop") then
            Execute("/callback CollectablesShop true -1")
        elseif GetItemCount(GathererScripId) >= ScripExchangeItem.price then
            State = CharacterState.scripExchange
            LogInfo(string.format("%s State changed to: ScripExchange", LogPrefix))
        else
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        end

    elseif not IsInZone(SelectedHubCity.zoneId) then
        State = CharacterState.goToHubCity
        LogInfo(string.format("%s State changed to: GoToHubCity", LogPrefix))

    elseif SelectedHubCity.scripExchange.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            Teleport(SelectedHubCity.aethernet.aethernetName)
        end
        Wait(1)

    elseif IsAddonReady("TelepotTown") then
        Execute("/callback TelepotTown false -1")

    elseif GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
            WaitForPathRunning()
        end

    elseif GetItemCount(GathererScripId) >= 3800 then
        if IsAddonReady("CollectablesShop") then
            Execute("/callback CollectablesShop true -1")
        else
            State = CharacterState.scripExchange
            LogInfo(string.format("%s State changed to: ScripExchange", LogPrefix))
        end

    else
        if PathfindInProgress() or PathIsRunning() then
            PathStop()
        end

        if not IsAddonReady("CollectablesShop") then
            Interact("Collectable Appraiser")
            Wait(0.5)
        else
            Execute(string.format("/callback CollectablesShop true 12 %s", SelectedFish.collectiblesTurnInListIndex))
            Wait(0.1)
            Execute("/callback CollectablesShop true 15 0")
            Wait(1)
        end
    end
end

---------------------------
--    Scrips Exchange    --
---------------------------

function CharacterState.scripExchange()
    if GetItemCount(GathererScripId) < ScripExchangeItem.price then
        if IsAddonReady("InclusionShop") then
            Execute("/callback InclusionShop true -1")
        elseif GetItemCount(SelectedFish.fishId) > 0 then
            State = CharacterState.turnIn
            LogInfo(string.format("%s State changed to: TurnIn", LogPrefix))
        else
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        end

    elseif not IsInZone(SelectedHubCity.zoneId) then
        State = CharacterState.goToHubCity
        LogInfo(string.format("%s State changed to: GoToHubCity", LogPrefix))

    elseif SelectedHubCity.scripExchange.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            Teleport(SelectedHubCity.aethernet.aethernetName)
        end
        Wait(1)

    elseif IsAddonReady("TelepotTown") then
        Execute("/callback TelepotTown false -1")

    elseif GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        LogInfo(string.format("%s Moving to Scrip Exchange.", LogPrefix))
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
            WaitForPathRunning()
        end

    elseif IsAddonReady("ShopExchangeItemDialog") then
        Execute("/callback ShopExchangeItemDialog true 0")

    elseif IsAddonReady("SelectIconString") then
        Execute("/callback SelectIconString true 0")

    elseif IsAddonReady("InclusionShop") then
        Execute(string.format("/callback InclusionShop true 12 %s", ScripExchangeItem.categoryMenu))
        Wait(1)
        Execute(string.format("/callback InclusionShop true 13 %s", ScripExchangeItem.subcategoryMenu))
        Wait(1)
        Execute(string.format("/callback InclusionShop true 14 %d %d", ScripExchangeItem.listIndex, math.min(99, GetItemCount(GathererScripId) // ScripExchangeItem.price)))
        Wait(1)

    else
        Wait(1)
        Interact("Scrip Exchange")
    end
end

----------------
--    Misc    --
----------------

function CharacterState.processAutoRetainers()
    if (not ARRetainersWaitingToBeProcessed() or GetInventoryFreeSlotCount() <= 1) then
        if IsAddonReady("RetainerList") then
            Execute("/callback RetainerList true -1")
        elseif not ARRetainersWaitingToBeProcessed() and IsPlayerAvailable() then
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        end

    elseif not (IsInZone(SelectedHubCity.zoneId) or IsInZone(SelectedHubCity.aethernet.aethernetZoneId)) then
        LogInfo(string.format("%s Not in hub city zone. Teleporting to hub city.", LogPrefix))
        Teleport(SelectedHubCity.aetheryte)

    elseif SelectedHubCity.retainerBell.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) + 10) then
        if not LifestreamIsBusy() then
            Teleport(SelectedHubCity.aethernet.aethernetName)
        end
        Wait(1)

    elseif IsAddonReady("TelepotTown") then
        Execute("/callback TelepotTown false -1")

    elseif GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z)
            WaitForPathRunning()
        end

    elseif PathfindInProgress() or PathIsRunning() then
        WaitForPathRunning()
        return

    elseif not HasTarget("Summoning Bell") then
        Target("Summoning Bell")
        return

    elseif IsPlayerAvailable() then
        Interact("Summoning Bell")

    elseif IsAddonReady("RetainerList") then
        Execute("/ays e")
        Wait(1)
    end
end

local deliveroo = false
function CharacterState.gcTurnIn()
    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and not deliveroo then
        Teleport("gc")
        Wait(1)
        LogInfo(string.format("%s Starting Deliveroo turn-in.", LogPrefix))
        Execute("/deliveroo enable")
        Wait(1)
        deliveroo = true
        return

    elseif IPC.Deliveroo.IsTurnInRunning() then
        return

    else
        State = CharacterState.awaitingAction
        LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        deliveroo = false
    end
end

function CharacterState.executeRepair()
    if IsAddonReady("SelectYesno") then
        Execute("/callback SelectYesno true 0")
        return
    end

    if IsAddonReady("Repair") then
        if not NeedsRepair(RepairThreshold) then
            LogInfo(string.format("%s Repair not needed. Closing Repair menu.", LogPrefix))
            Execute("/callback Repair true -1")
        else
            Execute("/callback Repair true 0")
        end
        return
    end

    if IsOccupied() then
        Wait(1)
        return
    end

    local hawkersAlleyAethernetShard = { x = -213.95, y = 15.99, z = 49.35 }

    if SelfRepair then
        if GetItemCount(33916) > 0 then -- Dark Matter
            if NeedsRepair(RepairThreshold) and not IsAddonReady("Repair") then
                LogInfo(string.format("%s Opening self-repair menu.", LogPrefix))
                ExecuteGeneralAction(CharacterAction.GeneralActions.repair)
            elseif not NeedsRepair(RepairThreshold) then
                State = CharacterState.awaitingAction
                LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
            end

        elseif ShouldAutoBuyDarkMatter then
            if not IsInZone(129) then
                LogInfo(string.format("%s Teleporting to Limsa to buy Dark Matter.", LogPrefix))
                Teleport("Limsa Lominsa Lower Decks")
                return
            end

            local vendor = { npcName = "Unsynrael", x = -257.71, y = 16.19, z = 50.11, wait = 0.08 }
            if GetDistanceToPoint(vendor.x, vendor.y, vendor.z) > DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z, vendor.x, vendor.y, vendor.z) + 10 then
                Teleport("Hawkers' Alley")
                Wait(1)
            elseif IsAddonReady("TelepotTown") then
                Execute("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(vendor.x, vendor.y, vendor.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(vendor.x, vendor.y, vendor.z)
                    WaitForPathRunning()
                end
            else
                if not HasTarget(vendor.npcName) then
                    Target(vendor.npcName)
                elseif not IsOccupiedInQuestEvent() then
                    Interact(vendor.npcName)
                elseif IsAddonReady("SelectYesno") then
                    Execute("/callback SelectYesno true 0")
                elseif IsAddonReady("Shop") then
                    Execute("/callback Shop true 0 40 99")
                end
            end

        else
            LogInfo(string.format("%s SelfRepair disabled. Using Limsa mender instead.", LogPrefix))
            SelfRepair = false
        end

    else
        if NeedsRepair(RepairThreshold) then
            if not IsInZone(129) then
                LogInfo(string.format("%s Teleporting to Limsa for mender.", LogPrefix))
                Teleport("Limsa Lominsa Lower Decks")
                return
            end

            local mender = { npcName = "Alistair", x = -246.87, y = 16.19, z = 49.83 }
            if GetDistanceToPoint(mender.x, mender.y, mender.z) > DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z, mender.x, mender.y, mender.z) + 10 then
                Teleport("Hawkers' Alley")
                Wait(1)
            elseif IsAddonReady("TelepotTown") then
                Execute("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.x, mender.y, mender.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(mender.x, mender.y, mender.z)
                    WaitForPathRunning()
                end
            else
                if not HasTarget(mender.npcName) then
                    Target(mender.npcName)
                elseif not IsOccupiedInQuestEvent() then
                    Interact(mender.npcName)
                end
            end

        else
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        end
    end
end

function CharacterState.extractMateria()
    Dismount()

    if not IsPlayerAvailable() then
        return
    end

    if CanExtractMateria() > 0 and GetInventoryFreeSlotCount() > 1 then
        LogInfo(string.format("%s Extracting materia...", LogPrefix))
        MateriaExtraction(true)

    else
        if IsAddonReady("Materialize") then
            Execute("/callback Materialize true -1")
        else
            State = CharacterState.awaitingAction
            LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))
        end
    end
end

function FoodCheck()
    if not HasStatusId(48) and Food ~= "" then
        LogInfo(string.format("%s Using food: %s", LogPrefix, Food))
        Execute("/item " .. Food)
    end
end

function PotionCheck()
    if not HasStatusId(49) and Potion ~= "" then
        LogInfo(string.format("%s Using potion: %s", LogPrefix, Potion))
        Execute("/item " .. Potion)
    end
end

function SelectFishTable()
    for _, fishTable in ipairs(FishTable) do
        if ScripColorToFarm == fishTable.scripColor then
            LogInfo(string.format("%s Selected fish table for scrip color: %s", LogPrefix, ScripColorToFarm))
            return fishTable
        end
    end

    LogInfo(string.format("%s No matching fish table found for scrip color: %s", LogPrefix, ScripColorToFarm))
    return nil
end

function CharacterState.awaitingAction()
    FoodCheck()
    PotionCheck()

    if not IsPlayerAvailable() then
        LogInfo(string.format("%s Player not available. Waiting...", LogPrefix))
        return
    end

    if RepairThreshold > 0 and NeedsRepair(RepairThreshold) and (SelfRepair and GetItemCount(33916) > 0) then
        State = CharacterState.executeRepair
        LogInfo(string.format("%s State changed to: ExecuteRepair", LogPrefix))

    elseif ExtractMateria and CanExtractMateria() > 0 and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo(string.format("%s State changed to: ExtractMateria", LogPrefix))

    elseif DoAutoRetainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.processAutoRetainers
        LogInfo(string.format("%s State changed to: ProcessingRetainers", LogPrefix))

    elseif GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and GetItemCount(SelectedFish.fishId) > 0 then
        State = CharacterState.turnIn
        LogInfo(string.format("%s State changed to: TurnIn", LogPrefix))

    elseif GrandCompanyTurnIn and GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        State = CharacterState.gcTurnIn
        LogInfo(string.format("%s State changed to: GCTurnIn", LogPrefix))

    elseif GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and GetItemCount(SelectedFish.fishId) == 0 then
        State = CharacterState.goToHubCity
        LogInfo(string.format("%s State changed to: GoToSolutionNine", LogPrefix))

    elseif GetItemCount(29717) == 0 then -- no bait
        State = CharacterState.buyFishingBait
        LogInfo(string.format("%s State changed to: Buy Fishing Bait", LogPrefix))

    else
        State = CharacterState.goToFishingHole
        LogInfo(string.format("%s State changed to: GoToFishingHole", LogPrefix))
    end
end

--=========================== EXECUTION ==========================--

LastStuckCheckTime = os.clock()
LastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos()}

if ScripColorToFarm == "Orange" then
    GathererScripId = OrangeGathererScripId
else
    GathererScripId = PurpleGathererScripId
end

for _, item in ipairs(ScripExchangeItems) do
    if item.itemName == ItemToExchange then
        ScripExchangeItem = item
    end
end

if ScripExchangeItem == nil then
    Echo(string.format("Cannot recognize item: %s. Stopping script.", ItemToExchange), LogPrefix)
    LogInfo(string.format("%s Cannot recognize item: %s. Stopping script.", LogPrefix, ItemToExchange))
    StopRunningMacros()
end

SelectedFish = SelectFishTable()

if IsInZone(SelectedFish.zoneId) then
    LogInfo(string.format("%s In fishing zone already. Selecting new fishing hole.", LogPrefix))
    SelectNewFishingHole()
end

SetAutoHookState(true)
LogInfo(string.format("%s AutoHook enabled.", LogPrefix))

SetAutoHookPreset(SelectedFish.autoHookPreset)
LogInfo(string.format("%s Set AutoHook preset: %s", LogPrefix, SelectedFish.autoHookPreset))

SelectedHubCity = nil
for _, city in ipairs(HubCities) do
    if city.zoneName == HubCity then
        SelectedHubCity = city
        local aetherytes = GetAetheryteName(city.zoneId)
        if aetherytes then
            SelectedHubCity.aetheryte = GetAetheryteName(city.zoneId)
        end
        break
    end
end

if SelectedHubCity == nil then
    Echo(string.format("Could not find hub city: %s. Stopping script.", HubCity), LogPrefix)
    LogInfo(string.format("%s Could not find hub city: %s. Stopping script.", LogPrefix, HubCity))
    StopRunningMacros()
end

LogInfo(string.format("%s Selected hub city: %s (%s)", LogPrefix, SelectedHubCity.zoneName, SelectedHubCity.aetheryte or "Unknown Aetheryte"))

if not GetClassJobId(18) then
    LogInfo(string.format("%s Switching to Fisher.", LogPrefix))
    Execute("/gs change Fisher")
    Wait(1)
end

State = CharacterState.awaitingAction
LogInfo(string.format("%s State changed to: AwaitingAction", LogPrefix))

while true do
    State()
    Wait(0.1)
end

--============================== END =============================--