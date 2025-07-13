--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Artisan - Script for Crafting & Turning In
plugin_dependencies:
- Artisan
- TeleporterPlugin
- Lifestream
- vnavmesh
- AutoRetainer
dependencies:
- source: https://raw.githubusercontent.com/Mbarmem/SnD/refs/heads/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  CrafterClass:
    default:
    description: Select the crafting class to use for turn-ins and crafting tasks.
    type: string
    required: true
  DoScrips:
    default: true
    description: Enable or disable the use of scrips for crafting and purchases.
    type: boolean
  ScripColor:
    default: Orange
    description: Type of scrip to use for crafting / purchases (Orange, Purple).
    type: string
  MinScripExchange:
    default: 2500
    description: Minimum number of scrips required before making an exchange.
    type: int
    min: 0
    max: 4000
  ScripOvercapLimit:
    default: 3900
    description: Scrip amount at which to trigger spending to avoid overcapping.
    type: int
    min: 0
    max: 4000
  ItemToBuy:
    default: Crafter's Command Materia XII
    description: Name of the item to purchase using scrips.
    type: string
  HubCity:
    default: "Ul'dah"
    description: Main city to use as a hub for turn-ins and purchases (Ul'dah, Limsa, Gridania, or Solution Nine).
    type: string
  MinItemsForTurnIns:
    default: 1
    description: Minimum number of collectible items required before performing turn-ins.
    type: int
    min: 0
    max: 140
  MinInventoryFreeSlots:
    default: 15
    description: Minimum free inventory slots required to start crafting or turn-ins.
    type: int
    min: 0
    max: 140
    required: true
  RepairThreshold:
    default: 20
    description: Durability percentage at which tools should be repaired.
    type: int
    min: 0
    max: 100
  DoAutoRetainers:
    default: true
    description: Automatically interact with retainers for ventures.
    type: boolean
  ExtractMateria:
    default: true
    description: Automatically extract materia from fully spiritbonded gear.
    type: boolean
  Loop:
    default: 1
    description: Initial Loop count
    type: int
  HowManyLoops:
    default: 99
    description: Number of times to repeat the crafting and turn-in cycle (99 for unlimited).
    type: int

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
EchoPrefix             = "[Artisan]"

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
        itemName        = "Condensed Solution",
        categoryMenu    = 1,
        subcategoryMenu = 10,
        listIndex       = 0,
        price           = 125,
    },
    {
        itemName        = "Crafter's Competence Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 0,
        price           = 500,
    },
    {
        itemName        = "Crafter's Cunning Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 1,
        price           = 500,
    },
    {
        itemName        = "Crafter's Command Materia XII",
        categoryMenu    = 2,
        subcategoryMenu = 2,
        listIndex       = 2,
        price           = 500,
    },
    {
        itemName        = "Crafter's Competence Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 0,
        price           = 250,
    },
    {
        itemName        = "Crafter's Cunning Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 1,
        price           = 250,
    },
    {
        itemName        = "Crafter's Command Materia XI",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 2,
        price           = 250,
    },
    {
        itemName        = "Crafter's Cunning Materia IX",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 7,
        price           = 200,
    },
    {
        itemName        = "Crafter's Cunning Materia VII",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 13,
        price           = 200,
    },
    {
        itemName        = "Crafter's Cunning Materia V",
        categoryMenu    = 2,
        subcategoryMenu = 1,
        listIndex       = 19,
        price           = 200,
    },
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
        turninRow      = 0,
        turninIndex    = 0,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Blacksmith",
        classId        = 9,
        itemName       = "Rarefied Ra'Kaznar Round Knife",
        itemId         = 44196,
        turninRow      = 0,
        turninIndex    = 1,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Armorer",
        classId        = 10,
        itemName       = "Rarefied Ra'Kaznar Ring",
        itemId         = 44202,
        turninRow      = 0,
        turninIndex    = 2,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Goldsmith",
        classId        = 11,
        itemName       = "Rarefied Black Star Earrings",
        itemId         = 44208,
        turninRow      = 0,
        turninIndex    = 3,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Leatherworker",
        classId        = 12,
        itemName       = "Rarefied Gargantuaskin Hat",
        itemId         = 44214,
        turninRow      = 0,
        turninIndex    = 4,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Weaver",
        classId        = 13,
        itemName       = "Rarefied Thunderyard Silk Culottes",
        itemId         = 44220,
        turninRow      = 0,
        turninIndex    = 5,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Alchemist",
        classId        = 14,
        itemName       = "Rarefied Claro Walnut Flat Brush",
        itemId         = 44226,
        turninRow      = 0,
        turninIndex    = 6,
        turninType     = 15,
        artisanListId  = 0,
    },
    {
        className      = "Culinarian",
        classId        = 15,
        itemName       = "Rarefied Tacos de Carne Asada",
        itemId         = 44232,
        turninRow      = 0,
        turninIndex    = 7,
        turninType     = 15,
        artisanListId  = 14783,  -- 14783 / 21193
    },
}

PurpleScrips = {
    {
        className      = "Carpenter",
        classId        = 8,
        itemName       = "Rarefied Claro Walnut Grinding Wheel",
        itemId         = 44189,
        turninRow      = 1,
        turninIndex    = 0,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Blacksmith",
        classId        = 9,
        itemName       = "Rarefied Ra'Kaznar War Scythe",
        itemId         = 44195,
        turninRow      = 1,
        turninIndex    = 1,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Armorer",
        classId        = 10,
        itemName       = "Rarefied Ra'Kaznar Greaves",
        itemId         = 44201,
        turninRow      = 1,
        turninIndex    = 2,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Goldsmith",
        classId        = 11,
        itemName       = "Rarefied Ra'Kaznar Orrery",
        itemId         = 44207,
        turninRow      = 1,
        turninIndex    = 3,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Leatherworker",
        classId        = 12,
        itemName       = "Rarefied Gargantuaskin Trouser",
        itemId         = 44213,
        turninRow      = 1,
        turninIndex    = 4,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Weaver",
        classId        = 13,
        itemName       = "Rarefied Thunderyards Silk Gloves",
        itemId         = 44219,
        turninRow      = 1,
        turninIndex    = 5,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Alchemist",
        classId        = 14,
        itemName       = "Rarefied Gemdraught of Vitality",
        itemId         = 44225,
        turninRow      = 1,
        turninIndex    = 6,
        turninType     = 16,
        artisanListId  = 0,
    },
    {
        className      = "Culinarian",
        classId        = 15,
        itemName       = "Rarefied Sykon Bavarois",
        itemId         = 36626,
        turninRow      = 6,
        turninIndex    = 7,
        turninType     = 16,
        artisanListId  = 14291,  -- 14291 / 46432
    },
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
        scripExchange = { x = -258.52585, y = 16.2, z = 40.65883, requiresAethernet = true },
    },
    {
        zoneName      = "Gridania",
        zoneId        = 132,
        aethernet     = { aethernetZoneId = 133, aethernetName = "Leatherworkers' Guild & Shaded Bower", x = 131.9447, y = 4.714966, z = -29.800903 },
        retainerBell  = { x = 168.72, y = 15.5, z = -100.06, requiresAethernet = true },
        scripExchange = { x = 142.15, y = 13.74, z = -105.39, requiresAethernet = true },
    },
    {
        zoneName      = "Ul'dah",
        zoneId        = 130,
        aethernet     = { aethernetZoneId = 131, aethernetName = "Sapphire Avenue Exchange", x = 101, y = 9, z = -112 },
        retainerBell  = { x = 146.760, y = 4, z = -42.992, requiresAethernet = true },
        scripExchange = { x = 147.73, y = 4, z = -18.19, requiresAethernet = true },
    },
    {
        zoneName      = "Solution Nine",
        zoneId        = 1186,
        aethernet     = { aethernetZoneId = 1186, aethernetName = "Nexus Arcade", x = -161, y = -1, z = 212 },
        retainerBell  = { x = -152.465, y = 0.660, z = -13.557, requiresAethernet = true },
        scripExchange = { x = -158.019, y = 0.922, z = -37.884, requiresAethernet = true },
    },
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
        LogInfo(string.format("%s Could not find crafter class: %s", EchoPrefix, CrafterClass))
        yield("/snd stop all")
        return
    elseif GetClassJobId() ~= ClassId then
        yield("/gearset change " .. CrafterClass)
        Wait(1)
        LogInfo(string.format("%s Crafter class changed to: %s", EchoPrefix, CrafterClass))
    else
        LogInfo(string.format("%s Crafter class is: %s", EchoPrefix, CrafterClass))
    end

    if ScripColor == "Orange" then
        CollectableScrip = OrangeScrips
    elseif ScripColor == "Purple" then
        CollectableScrip = PurpleScrips
    else
        LogInfo(string.format("%s Cannot recognize crafter scrip color: %s", EchoPrefix, ScripColor))
        Wait(1)
        yield("/snd stop all")
        return
    end

    local SelectedItemToBuy = nil
    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            SelectedItemToBuy = item
            break
        end
    end

    if SelectedItemToBuy == nil then
        LogInfo(string.format("%s Could not find %s on the list of scrip exchange items.", EchoPrefix, ItemToBuy))
        yield("/snd stop all")
        return
    end
end

----------------
--    Move    --
----------------

function MoveForExchange()
    for _, city in ipairs(HubCities) do
        if city.zoneName == HubCity then
            SelectedHubCity = city
            SelectedHubCity.aetheryte = GetAetheryteName(city.zoneId)
        end
    end

    if SelectedHubCity == nil then
        LogInfo(string.format("%s Could not find hub city: %s", EchoPrefix, HubCity))
        yield("/snd stop all")
        return
    end

    StateReached = false
    LogInfo(string.format("%s Moving to Collectable Appraiser", EchoPrefix))

    while not StateReached do
        ScripExchangeDistance = GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)

        if IsInZone(SelectedHubCity.aethernet.aethernetZoneId) and ScripExchangeDistance > 1 and ScripExchangeDistance < 100 then
            if not (PathfindInProgress() or PathIsRunning()) then
                MoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z, 2)
                StateReached = true
            end
        else
            Teleport(SelectedHubCity.aetheryte)
            if not LifestreamIsBusy() then
                Lifestream(SelectedHubCity.aethernet.aethernetName)
                WaitForTeleport()
            end
        end
    end
end

----------------
--    Misc    --
----------------

function InitializeLoop()
    local loopValue = tostring(HowManyLoops):lower()

    if loopValue == "true" or 99 then
        LoopAmount = true
    else
        local numericLoop = tonumber(HowManyLoops)
        if numericLoop and numericLoop > 0 then
            LoopAmount = numericLoop
        else
            LogInfo(string.format("%s Invalid loop count. Stopping script.", EchoPrefix))
            yield("/snd stop all")
            return
        end
    end
end

function LoopCount()
    Loop = (Loop or 0) + 1
end

function ArtisanCraftingList()
    for _, item in ipairs(CollectableScrip) do
        if ClassId == item.classId then
            ItemName = item.itemName
            ArtisanListId = item.artisanListId
            break
        end
    end

    if not ArtisanListId or ArtisanListId == 0 then
        LogInfo(string.format("%s No valid Artisan list found for this class.", EchoPrefix))
        yield("/snd stop all")
        return
    end

    LogInfo(string.format("%s Preparing to Craft: %s", EchoPrefix, ItemName))

    while GetInventoryFreeSlotCount() > MinInventoryFreeSlots do
        if not ArtisanIsListRunning() then
            yield("/artisan lists ".. ArtisanListId .." start")
            Wait(3)

            ArtisanTimeoutStartTime = os.clock()
            repeat
                Wait(2)
            until os.clock() - ArtisanTimeoutStartTime > 15 or IsCrafting()

            if not IsCrafting() then
                StopFlag = true
                LogInfo(string.format("%s Stopping Artisan Crafting List..Out of Mats..", EchoPrefix))
                Wait(1)
                return
            end
        else
            Wait(1)
        end
    end
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
            yield("/callback SelectIconString true 0")
        end
        Wait(1)
    end

    local orangeRaw = GetNodeText("CollectablesShop", 1, 14, 15, 4)
    local purpleRaw = GetNodeText("CollectablesShop", 1, 14, 16, 4)

    local Orange_Scrips = tonumber((orangeRaw):gsub(",", ""):match("^([%d,]+)/"))
    local Purple_Scrips = tonumber((purpleRaw):gsub(",", ""):match("^([%d,]+)/"))

    if (Orange_Scrips < ScripOvercapLimit) and (Purple_Scrips < ScripOvercapLimit) then
        for _, item in ipairs(CollectableScrip) do
            if item.classId == ClassId then
                ItemId = item.itemId
                CollectableTurninRow = item.turninRow
                CollectableTurninIndex = item.turninIndex
                CollectableTurninType = item.turninType
            end
        end

        if GetItemCount(ItemId) > 0 then
            yield("/callback CollectablesShop true 14 "..CollectableTurninIndex)
            Wait(1)
            yield("/callback CollectablesShop true 12 "..CollectableTurninRow)
            Wait(1)

            ScripsRaw = GetNodeText("CollectablesShop", 1, 14, CollectableTurninType, 4)
            ScripsConv = ScripsRaw:gsub(",", ""):match("^([%d,]+)/")
            Scrips_Owned = tonumber(ScripsConv)

            while (Scrips_Owned <= ScripOvercapLimit) and (not IsAddonReady("SelectYesno")) and (GetItemCount(ItemId) > 0) do
                yield("/callback CollectablesShop true 15 0")
                Wait(1)
                Scrips_Owned = tonumber(GetNodeText("CollectablesShop", 1, 14, CollectableTurninType, 4):gsub(",", ""):match("^([%d,]+)/"))
            end
        end

        if IsAddonReady("Selectyesno") then
            yield("/callback Selectyesno true 1")
            Wait(1)
        end

        yield("/callback CollectablesShop true -1")
        ClearTarget()
        Wait(1)
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
            yield("/callback SelectIconString true 0")
        end
        Wait(1)
    end

    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            ScripCategoryMenu = item.categoryMenu
            ScripSubcategoryMenu = item.subcategoryMenu
            ScripListIndex = item.listIndex
            ScripPrice = item.price
        end
    end

    yield("/callback InclusionShop true 12 "..ScripCategoryMenu)
    Wait(1)
    yield("/callback InclusionShop true 13 "..ScripSubcategoryMenu)
    Wait(1)

    ScripsRaw = GetNodeText("InclusionShop", 1, 2, 4)
    ScripsConv = ScripsRaw:gsub(",", "")
    Scrips_Owned = tonumber(ScripsConv)

    if Scrips_Owned >= MinScripExchange then
        Scrip_Item_Number_To_Buy = Scrips_Owned // ScripPrice
        Scrip_Item_Number_To_Buy_Final = math.min(Scrip_Item_Number_To_Buy, 99)

        yield("/callback InclusionShop true 14 "..ScripListIndex.." "..Scrip_Item_Number_To_Buy_Final)
        Wait(1)

        if IsAddonReady("ShopExchangeItemDialog") then
            yield("/callback ShopExchangeItemDialog true 0")
            Wait(1)
        end
    end

    yield("/callback InclusionShop true -1")
    ClearTarget()
    Wait(1)
end

------------------
--    TurnIn    --
------------------

function CanTurnin()
    for _, item in ipairs(CollectableScrip) do
        if item.classId == ClassId then
            ItemId = item.itemId
            break
        end
    end

    if GetItemCount(ItemId) >= MinItemsForTurnIns then
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
while LoopAmount == true or Loop <= LoopAmount and not StopFlag do
    LogInfo(string.format("%s Loop Count: %s", EchoPrefix, Loop))
    MoveToInn()
    DoAR(DoAutoRetainers)
    ArtisanCraftingList()
    Repair()
    MateriaExtraction(ExtractMateria)
    MoveForExchange()
    CollectableAppraiserScripExchange()
    LoopCount()
end

--============================== END =============================--