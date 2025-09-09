--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Artisan - Script for Crafting & Turning In
plugin_dependencies:
- Artisan
- AutoRetainer
- Lifestream
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  CrafterClass:
    description: Select the crafting class to use for turn-ins and crafting tasks.
    is_choice: true
    choices:
        - "Carpenter"
        - "Blacksmith"
        - "Armorer"
        - "Goldsmith"
        - "Leatherworker"
        - "Weaver"
        - "Alchemist"
        - "Culinarian"
  DoScrips:
    description: Enable or disable the use of scrips for crafting and purchases.
    default: true
  ScripColor:
    description: Type of scrip to use for crafting / purchases.
    is_choice: true
    choices:
        - "Orange"
        - "Purple"
  MinScripExchange:
    description: Minimum number of scrips required before making an exchange.
    default: 2500
    min: 0
    max: 4000
  ScripOvercapLimit:
    description: Scrip amount at which to trigger spending to avoid overcapping.
    default: 3900
    min: 0
    max: 4000
  ItemToBuy:
    description: Name of the item to purchase using scrips.
    is_choice: true
    choices:
        - "Mason's Abrasive"
        - "Condensed Solution"
        - "Craftsman's Competence Materia XII"
        - "Craftsman's Cunning Materia XII"
        - "Craftsman's Command Materia XII"
        - "Craftsman's Competence Materia XI"
        - "Craftsman's Cunning Materia XI"
        - "Craftsman's Command Materia XI"
        - "Craftsman's Cunning Materia IX"
        - "Craftsman's Cunning Materia VII"
        - "Craftsman's Cunning Materia V"
  HubCity:
    description: Main city to use as a hub for turn-ins and purchases.
    is_choice: true
    choices:
        - "Limsa"
        - "Gridania"
        - "Ul'dah"
        - "Solution Nine"
  MinItemsForTurnIns:
    description: Minimum number of collectible items required before performing turn-ins.
    default: 1
    min: 0
    max: 140
  MinInventoryFreeSlots:
    description: Minimum free inventory slots required to start crafting or turn-ins.
    default: 5
    min: 0
    max: 140
  RepairThreshold:
    description: Durability percentage at which tools should be repaired.
    default: 20
    min: 0
    max: 100
  DoAutoRetainers:
    description: Automatically interact with retainers for ventures.
    default: true
  ExtractMateria:
    description: Automatically extract materia from fully spiritbonded gear.
    default: true
  Loop:
    description: Initial Loop count
    default: 1
    min: 1
    max: 99
  HowManyLoops:
    description: Number of times to repeat the crafting and turn-in cycle (99 for unlimited).
    default: 99
    min: 1
    max: 99

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

CrafterClass           = Config.Get("CrafterClass")
ItemToBuy              = Config.Get("ItemToBuy")
HubCity                = Config.Get("HubCity")
MinItemsForTurnIns     = Config.Get("MinItemsForTurnIns")
MinInventoryFreeSlots  = Config.Get("MinInventoryFreeSlots")
RepairThreshold        = Config.Get("RepairThreshold")
DoAutoRetainers        = Config.Get("DoAutoRetainers")
ExtractMateria         = Config.Get("ExtractMateria")
LogPrefix              = "[Artisan]"

----------------
--    Loop    --
----------------

Loop                   = Config.Get("Loop")
HowManyLoops           = Config.Get("HowManyLoops")

------------------
--    Scrips    --
------------------

DoScrips               = Config.Get("DoScrips")
ScripColor             = Config.Get("ScripColor")
MinScripExchange       = Config.Get("MinScripExchange")
ScripOvercapLimit      = Config.Get("ScripOvercapLimit")

--============================ CONSTANT ==========================--

-----------------
--    Class    --
-----------------

ClassList = {
    crp = { classId =  8, className = "Carpenter"     },
    bsm = { classId =  9, className = "Blacksmith"    },
    arm = { classId = 10, className = "Armorer"       },
    gsm = { classId = 11, className = "Goldsmith"     },
    ltw = { classId = 12, className = "Leatherworker" },
    wvr = { classId = 13, className = "Weaver"        },
    alc = { classId = 14, className = "Alchemist"     },
    cul = { classId = 15, className = "Culinarian"    },
}

-----------------
--    Items    --
-----------------

ScripExchangeItems = {
    {
        itemName        = "Mason's Abrasive",
        categoryMenu    = 1,
        subcategoryMenu = 10,
        listIndex       = 0,
        price           = 500
    },
    {
        itemName        = "Condensed Solution",
        categoryMenu    = 1,
        subcategoryMenu = 11,
        listIndex       = 5,
        price           = 125
    },
    {
        itemName        = "Craftsman's Competence Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 0,
        price           = 500
    },
    {
        itemName        = "Craftsman's Cunning Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 1,
        price           = 500
    },
    {
        itemName        = "Craftsman's Command Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 2,
        price           = 500
    },
    {
        itemName        = "Craftsman's Competence Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 0,
        price           = 250
    },
    {
        itemName        = "Craftsman's Cunning Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 1,
        price           = 250
    },
    {
        itemName        = "Craftsman's Command Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 2,
        price           = 250
    },
    {
        itemName        = "Craftsman's Cunning Materia IX",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 7,
        price           = 200
    },
    {
        itemName        = "Craftsman's Cunning Materia VII",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 13,
        price           = 200
    },
    {
        itemName        = "Craftsman's Cunning Materia V",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 19,
        price           = 200
    }
}

------------------------
--    Collectables    --
------------------------

OrangeScrips = {
    {
        className      = "Carpenter",
        classId        = 8,
        itemName       = "Rarefied Claro Walnut Fishing Rod",
        itemId         = 44190,
        recipeId       = 35787,
        turninRow      = 0,
        turninIndex    = 0,
        turninType     = 15
    },
    {
        className      = "Blacksmith",
        classId        = 9,
        itemName       = "Rarefied Ra'Kaznar Round Knife",
        itemId         = 44196,
        recipeId       = 35793,
        turninRow      = 0,
        turninIndex    = 1,
        turninType     = 15
    },
    {
        className      = "Armorer",
        classId        = 10,
        itemName       = "Rarefied Ra'Kaznar Ring",
        itemId         = 44202,
        recipeId       = 35799,
        turninRow      = 0,
        turninIndex    = 2,
        turninType     = 15
    },
    {
        className      = "Goldsmith",
        classId        = 11,
        itemName       = "Rarefied Black Star Earrings",
        itemId         = 44208,
        recipeId       = 35805,
        turninRow      = 0,
        turninIndex    = 3,
        turninType     = 15
    },
    {
        className      = "Leatherworker",
        classId        = 12,
        itemName       = "Rarefied Gargantuaskin Hat",
        itemId         = 44214,
        recipeId       = 35811,
        turninRow      = 0,
        turninIndex    = 4,
        turninType     = 15
    },
    {
        className      = "Weaver",
        classId        = 13,
        itemName       = "Rarefied Thunderyards Silk Culottes",
        itemId         = 44220,
        recipeId       = 35817,
        turninRow      = 0,
        turninIndex    = 5,
        turninType     = 15
    },
    {
        className      = "Alchemist",
        classId        = 14,
        itemName       = "Rarefied Claro Walnut Flat Brush",
        itemId         = 44226,
        recipeId       = 35823,
        turninRow      = 0,
        turninIndex    = 6,
        turninType     = 15
    },
    {
        className      = "Culinarian",
        classId        = 15,
        itemName       = "Rarefied Tacos de Carne Asada",
        itemId         = 44232,
        recipeId       = 35829,
        turninRow      = 0,
        turninIndex    = 7,
        turninType     = 15
    }
}

PurpleScrips = {
    {
        className      = "Carpenter",
        classId        = 8,
        itemName       = "Rarefied Claro Walnut Grinding Wheel",
        itemId         = 44189,
        recipeId       = 35786,
        turninRow      = 1,
        turninIndex    = 0,
        turninType     = 16
    },
    {
        className      = "Blacksmith",
        classId        = 9,
        itemName       = "Rarefied Ra'Kaznar War Scythe",
        itemId         = 44195,
        recipeId       = 35792,
        turninRow      = 1,
        turninIndex    = 1,
        turninType     = 16
    },
    {
        className      = "Armorer",
        classId        = 10,
        itemName       = "Rarefied Ra'Kaznar Greaves",
        itemId         = 44201,
        recipeId       = 35798,
        turninRow      = 1,
        turninIndex    = 2,
        turninType     = 16
    },
    {
        className      = "Goldsmith",
        classId        = 11,
        itemName       = "Rarefied Ra'Kaznar Orrery",
        itemId         = 44207,
        recipeId       = 35804,
        turninRow      = 1,
        turninIndex    = 3,
        turninType     = 16
    },
    {
        className      = "Leatherworker",
        classId        = 12,
        itemName       = "Rarefied Gargantuaskin Trouser",
        itemId         = 44213,
        recipeId       = 35810,
        turninRow      = 1,
        turninIndex    = 4,
        turninType     = 16
    },
    {
        className      = "Weaver",
        classId        = 13,
        itemName       = "Rarefied Thunderyards Silk Gloves",
        itemId         = 44219,
        recipeId       = 35816,
        turninRow      = 1,
        turninIndex    = 5,
        turninType     = 16
    },
    {
        className      = "Alchemist",
        classId        = 14,
        itemName       = "Rarefied Gemdraught of Vitality",
        itemId         = 44225,
        recipeId       = 35822,
        turninRow      = 1,
        turninIndex    = 6,
        turninType     = 16
    },
    {
        className      = "Culinarian",
        classId        = 15,
        itemName       = "Rarefied Sykon Bavarois",
        itemId         = 36626,
        recipeId       = 34908,
        turninRow      = 6,
        turninIndex    = 7,
        turninType     = 16
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
        aethernet     = { aethernetZoneId = 133, aethernetName = "Leatherworkers' Guild & Shaded Bower", x = 131.9447, y = 4.714966, z = -29.800903 },
        retainerBell  = { x = 168.72, y = 15.5, z = -100.06, requiresAethernet = true },
        scripExchange = { x = 142.15, y = 13.74, z = -105.39, requiresAethernet = true }
    },
    {
        zoneName      = "Ul'dah",
        zoneId        = 130,
        aethernet     = { aethernetZoneId = 131, aethernetName = "Sapphire Avenue Exchange", x = 101, y = 9, z = -112 },
        retainerBell  = { x = 146.760, y = 4, z = -42.992, requiresAethernet = true },
        scripExchange = { x = 147.73, y = 4, z = -18.19, requiresAethernet = true }
    },
    {
        zoneName      = "Solution Nine",
        zoneId        = 1186,
        aethernet     = { aethernetZoneId = 1186, aethernetName = "Nexus Arcade", x = -161, y = -1, z = 212 },
        retainerBell  = { x = -152.465, y = 0.660, z = -13.557, requiresAethernet = true },
        scripExchange = { x = -158.019, y = 0.922, z = -37.884, requiresAethernet = true }
    }
}

--=========================== FUNCTIONS ==========================--

------------------
--    Checks    --
------------------

function Checks()
    ClassId = nil
    for _, class in pairs(ClassList) do
        if CrafterClass == class.className then
            ClassId = class.classId
            break
        end
    end

    if not ClassId then
        Echo(string.format("Could not find crafter class: %s", CrafterClass), LogPrefix)
        LogInfo(string.format("%s Could not find crafter class: %s", LogPrefix, CrafterClass))
        StopRunningMacros()
    elseif not GetClassJobId(ClassId) then
        Execute(string.format("/gs change %s", CrafterClass))
        Wait(1)
        LogInfo(string.format("%s Crafter class changed to: %s", LogPrefix, CrafterClass))
    else
        LogInfo(string.format("%s Crafter class is: %s", LogPrefix, CrafterClass))
    end

    if ScripColor == "Orange" then
        CollectableScrip = OrangeScrips
    elseif ScripColor == "Purple" then
        CollectableScrip = PurpleScrips
    else
        Echo(string.format("Cannot recognize crafter scrip color: %s", ScripColor), LogPrefix)
        LogInfo(string.format("%s Cannot recognize crafter scrip color: %s", LogPrefix, ScripColor))
        StopRunningMacros()
    end

    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            SelectedItemToBuy = item
            break
        end
    end

    if not SelectedItemToBuy then
        Echo(string.format("Could not find %s on the list of scrip exchange items.", ItemToBuy), LogPrefix)
        LogInfo(string.format("%s Could not find %s on the list of scrip exchange items.", LogPrefix, ItemToBuy))
        StopRunningMacros()
    end
end

----------------
--    Move    --
----------------

function MoveForExchange()
    local selectedHubCity = nil
    for _, city in ipairs(HubCities) do
        if city.zoneName == HubCity then
            selectedHubCity = city
            break
        end
    end

    if not selectedHubCity then
        Echo(string.format("Could not find hub city: %s", HubCity), LogPrefix)
        LogInfo(string.format("%s Could not find hub city: %s", LogPrefix, HubCity))
        StopRunningMacros()
        return -- appease the analyzer
    end

    LogInfo(string.format("%s Moving to Collectable Appraiser", LogPrefix))

    local needTeleport = false
    if not IsInZone(selectedHubCity.aethernet.aethernetZoneId) then
        needTeleport = true
    else
        local distToAethernet = GetDistanceToPoint(selectedHubCity.aethernet.x, selectedHubCity.aethernet.y, selectedHubCity.aethernet.z)

        if distToAethernet > 100 then
            needTeleport = true
        end
    end

    if needTeleport then
        Teleport(selectedHubCity.aethernet.aethernetName)
    end

    local distToExchange = GetDistanceToPoint(selectedHubCity.scripExchange.x, selectedHubCity.scripExchange.y, selectedHubCity.scripExchange.z)
    if IsInZone(selectedHubCity.aethernet.aethernetZoneId) and distToExchange > 3 then
        MoveTo(selectedHubCity.scripExchange.x, selectedHubCity.scripExchange.y, selectedHubCity.scripExchange.z, 2)
    end
end

----------------
--    Misc    --
----------------

function InitializeLoop()
    local numericLoop = tonumber(HowManyLoops)

    if numericLoop == 99 then
        LoopAmount = "infinite"
    elseif numericLoop and numericLoop > 0 then
        LoopAmount = numericLoop
    else
        Echo("Invalid loop count (must be >0 or 99). Stopping script.", LogPrefix)
        LogInfo(string.format("%s Invalid loop count (must be >0 or 99). Stopping script.", LogPrefix))
        StopRunningMacros()
    end
end

function LoopCount()
    if StopFlag then
        Echo(string.format("Stopping the script. Out of Mats..."), LogPrefix)
        LogInfo(string.format("%s Stopping the script. Out of Mats...", LogPrefix))
        StopRunningMacros()
    end

    Loop = (Loop or 0) + 1

    if LoopAmount == "infinite" then
        LogInfo(string.format("%s Loop %d", LogPrefix, Loop))
    else
        LogInfo(string.format("%s Loop %d of %d", LogPrefix, Loop, LoopAmount))
    end
end

function ArtisanCrafting()
    local itemName = nil
    local recipeId = nil

    for _, item in ipairs(CollectableScrip) do
        if ClassId == item.classId then
            itemName = item.itemName
            recipeId = item.recipeId
            break
        end
    end

    if not recipeId then
        Echo(string.format("No valid Recipe Id found for this class."), LogPrefix)
        LogInfo(string.format("%s No valid Recipe Id found for this class.", LogPrefix))
        StopRunningMacros()
        return -- appease the analyzer
    end

    while GetInventoryFreeSlotCount() > MinInventoryFreeSlots do
        repeat
            if ArtisanGetEnduranceStatus() then
                Wait(1)
                break
            end

            if IsAddonReady("Synthesis") then
                Wait(1)
                break
            end

            if IsAddonReady("RecipeNote") then
                if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
                    Wait(1)
                    break
                end

                local timeoutClock = os.clock()
                repeat
                    Wait(1)
                    if IsAddonReady("Synthesis") then
                        break
                    end
                until (os.clock() - timeoutClock) > 20

                StopFlag = true
                LogInfo(string.format("%s Stopping Artisan Crafting.. Out of mats or Synthesis not opening.", LogPrefix))
                Wait(1)
                ArtisanSetEnduranceStatus(false)
                CloseAddons()
                WaitForPlayer()
                return
            end

            local nCraft = GetInventoryFreeSlotCount() - MinInventoryFreeSlots
            if not nCraft or nCraft <= 0 then
                Wait(1)
                break
            end

            LogInfo(string.format("%s Crafting: %s | Count: %d", LogPrefix, itemName, nCraft))
            ArtisanCraftItem(recipeId, nCraft)
            Wait(3)

        until true
    end

    Wait(1)
    ArtisanSetEnduranceStatus(false)
    CloseAddons()
    WaitForPlayer()
end

---------------------------------
--    Collectable Appraiser    --
---------------------------------

function CollectableAppraiser()
    while not IsAddonReady("CollectablesShop") do
        if not IsAddonReady("SelectIconString") then
            Interact("Collectable Appraiser")
        else
            Execute("/callback SelectIconString true 0")
        end
        Wait(0.3)
    end

    local orangeRaw = GetNodeText("CollectablesShop", 1, 14, 15, 4)
    local purpleRaw = GetNodeText("CollectablesShop", 1, 14, 16, 4)

    local orangeScrips = tonumber((orangeRaw):gsub(",", ""):match("^([%d,]+)/"))
    local purpleScrips = tonumber((purpleRaw):gsub(",", ""):match("^([%d,]+)/"))

    if not (orangeScrips and purpleScrips) then
        LogInfo(string.format("%s Could not parse scrip counts (Orange = %s, Purple = %s). Skipping Turn-in.", LogPrefix, tostring(orangeScrips), tostring(purpleScrips)))
        Execute("/callback CollectablesShop true -1")
        ClearTarget()
        Wait(0.3)
        return
    end

    local itemId                 = nil
    local collectableTurninRow   = nil
    local collectableTurninIndex = nil
    local collectableTurninType  = nil

    if (orangeScrips < ScripOvercapLimit) and (purpleScrips < ScripOvercapLimit) then
        for _, item in ipairs(CollectableScrip) do
            if item.classId == ClassId then
                itemId = item.itemId
                collectableTurninRow = item.turninRow
                collectableTurninIndex = item.turninIndex
                collectableTurninType = item.turninType
                break
            end
        end

        if not itemId then
            Echo("No class turn-in mapping found; aborting turn-in.", LogPrefix)
            Execute("/callback CollectablesShop true -1")
            ClearTarget()
            Wait(0.3)
            return
        end

        if GetItemCount(itemId) > 0 then
            Execute(string.format("/callback CollectablesShop true 14 %d", collectableTurninIndex))
            Wait(0.3)
            Execute(string.format("/callback CollectablesShop true 12 %d", collectableTurninRow))
            Wait(0.3)

            local scripsRaw    = GetNodeText("CollectablesShop", 1, 14, collectableTurninType, 4)
            local scripsConv   = scripsRaw:gsub(",", ""):match("^([%d,]+)/")
            local scripsOwned  = tonumber(scripsConv)

            while (scripsOwned <= ScripOvercapLimit) and (not IsAddonReady("SelectYesno")) and (GetItemCount(itemId) > 0) do
                Execute("/callback CollectablesShop true 15 0")
                Wait(0.3)
                scripsOwned = tonumber(GetNodeText("CollectablesShop", 1, 14, collectableTurninType, 4):gsub(",", ""):match("^([%d,]+)/"))
            end
        end

        if IsAddonReady("SelectYesno") then
            Execute("/callback SelectYesno true 1")
            Wait(0.3)
        end

        Execute("/callback CollectablesShop true -1")
        ClearTarget()
        Wait(0.3)
    else
        LogInfo(string.format("%s Scrips near/over cap (Orange = %s, Purple = %s). Skipping Turn-in.", LogPrefix, tostring(orangeScrips), tostring(purpleScrips)))
    end
end

---------------------------
--    Scrips Exchange    --
---------------------------

function ScripExchange()
    while not IsAddonReady("InclusionShop") do
        if not IsAddonReady("SelectIconString") then
            Interact("Scrip Exchange")
        else
            Execute("/callback SelectIconString true 0")
        end
        Wait(0.3)
    end

    local scripCategoryMenu    = SelectedItemToBuy.categoryMenu
    local scripSubcategoryMenu = SelectedItemToBuy.subcategoryMenu
    local scripListIndex       = SelectedItemToBuy.listIndex
    local scripPrice           = SelectedItemToBuy.price

    Execute(string.format("/callback InclusionShop true 12 %d", scripCategoryMenu))
    Wait(0.3)
    Execute(string.format("/callback InclusionShop true 13 %d", scripSubcategoryMenu))
    Wait(0.3)

    local scripsRaw    = GetNodeText("InclusionShop", 1, 2, 4)
    local scripsConv   = scripsRaw:gsub(",", "")
    local scripsOwned  = tonumber(scripsConv)

    if scripsOwned >= MinScripExchange then
        local scrip_Item_Number_To_Buy       = scripsOwned // scripPrice
        local scrip_Item_Number_To_Buy_Final = math.min(scrip_Item_Number_To_Buy, 99)

        Execute(string.format("/callback InclusionShop true 14 %d %d", scripListIndex, scrip_Item_Number_To_Buy_Final))
        Wait(0.3)

        if IsAddonReady("ShopExchangeItemDialog") then
            Execute("/callback ShopExchangeItemDialog true 0")
            Wait(0.3)
        end
    end

    Execute("/callback InclusionShop true -1")
    ClearTarget()
    Wait(0.3)
end

------------------
--    TurnIn    --
------------------

function CanTurnin()
    local itemId = nil
    for _, item in ipairs(CollectableScrip) do
        if item.classId == ClassId then
            itemId = item.itemId
            break
        end
    end

    if not itemId then
        return false
    end

    if GetItemCount(itemId) >= MinItemsForTurnIns then
        return true
    end

    return false
end

function CollectableAppraiserScripExchange()
    if DoScrips then
        while CanTurnin() do
            CollectableAppraiser()
            ScripExchange()
        end
    else
        ScripExchange()
    end
end

--=========================== EXECUTION ==========================--

Checks()
InitializeLoop()
while LoopAmount == "infinite" or Loop < LoopAmount do
    MoveToInn()
    DoAR(DoAutoRetainers)
    ArtisanCrafting()
    Repair(RepairThreshold)
    MateriaExtraction(ExtractMateria)
    MoveForExchange()
    CollectableAppraiserScripExchange()
    LoopCount()
end

Echo(string.format("Artisan script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Artisan script completed successfully..!!", LogPrefix))

--============================== END =============================--