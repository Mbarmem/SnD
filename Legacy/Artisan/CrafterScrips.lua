--[[

***********************************************
*                  Artisan                    *
*       Script for Crafting & Turning In      *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

            *********************
            *  Required Plugins *
            *********************

Plugins that are used are:
    -> Artisan
    -> Teleporter
    -> Lifestream : https://github.com/NightmareXIV/Lifestream/blob/main/Lifestream/Lifestream.json
    -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat
    -> Vnavmesh
    -> YesAlready
    -> PandorasBox
    -> AutoRetainer

]]

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

CrafterClass = "Culinarian"
ScripColor = "Purple"
ItemToBuy = "Crafter's Command Materia XI"
HubCity = "Ul'dah"  --Options:Limsa/Gridania/Ul'dah/Solution Nine.
MinItemsForTurnIns = 1
MinInventoryFreeSlots = 15
RepairThreshold = 20
DoAutoRetainers = true
ExtractMateria = true

----------------
--    Loop    --
----------------

local LoopAmount
local loop = 1
local HowManyLoops = 10

-----------------
--    Scrips   --
-----------------

DoScrips = true
MinScripExchange = 2500
ScripOvercapLimit = 3900

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "Artisan",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "YesAlready",
    "PandorasBox"
}

if DoAutoRetainers then
    table.insert(RequiredPlugins, "AutoRetainer")
end

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    casting=27,
    occupied=39,
    betweenAreas=45,
    occupiedSummoningBell=50
}

-----------------
--    Class    --
-----------------

ClassList =
{
    crp = { classId=8, className="Carpenter" },
    bsm = { classId=9, className="Blacksmith" },
    arm = { classId=10, className="Armorer" },
    gsm = { classId=11, className="Goldsmith" },
    ltw = { classId=12, className="Leatherworker" },
    wvr = { classId=13, className="Weaver" },
    alc = { classId=14, className="Alchemist" },
    cul = { classId=15, className="Culinarian"}
}

-----------------
--    Items    --
-----------------

ScripExchangeItems = {
    {
        itemName = "Condensed Solution",
        categoryMenu = 1,
        subcategoryMenu = 10,
        listIndex = 0,
        price = 125
    },
    {
        itemName = "Crafter's Competence Materia XII",
        categoryMenu = 2,
        subcategoryMenu = 2,
        listIndex = 0,
        price = 500
    },
    {
        itemName = "Crafter's Cunning Materia XII",
        categoryMenu = 2,
        subcategoryMenu = 2,
        listIndex = 1,
        price = 500
    },
    {
        itemName = "Crafter's Command Materia XII",
        categoryMenu = 2,
        subcategoryMenu = 2,
        listIndex = 2,
        price = 500
    },
    {
        itemName = "Crafter's Competence Materia XI",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 0,
        price = 250
    },
    {
        itemName = "Crafter's Cunning Materia XI",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 1,
        price = 250
    },
    {
        itemName = "Crafter's Command Materia XI",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 2,
        price = 250
    },
    {
        itemName = "Crafter's Cunning Materia IX",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 7,
        price = 200
    },
    {
        itemName = "Crafter's Cunning Materia VII",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 13,
        price = 200
    },
    {
        itemName = "Crafter's Cunning Materia V",
        categoryMenu = 2,
        subcategoryMenu = 1,
        listIndex = 19,
        price = 200
    }
}

------------------------
--    Collectables    --
------------------------

OrangeScrips =
{
    {
        className="Carpenter",
        classId=8,
        itemName="Rarefied Claro Walnut Fishing Rod",
        itemId=44190,
        turninRow=0,
        turninIndex=0,
        turninType=39,
        artisanListId=0
    },
    {
        className="Blacksmith",
        classId=9,
        itemName="Rarefied Ra'Kaznar Round Knife",
        itemId=44196,
        turninRow=0,
        turninIndex=1,
        turninType=39,
        artisanListId=0
    },
    {
        className="Armorer",
        classId=10,
        itemName="Rarefied Ra'Kaznar Ring",
        itemId=44202,
        turninRow=0,
        turninIndex=2,
        turninType=39,
        artisanListId=0
    },
    {
        className="Goldsmith",
        classId=11,
        itemName="Rarefied Black Star Earrings",
        itemId=44208,
        turninRow=0,
        turninIndex=3,
        turninType=39,
        artisanListId=0
    },
    {
        className="Leatherworker",
        classId=12,
        itemName="Rarefied Gargantuaskin Hat",
        itemId=44214,
        turninRow=0,
        turninIndex=4,
        turninType=39,
        artisanListId=0
    },
    {
        className="Weaver",
        classId=13,
        itemName="Rarefied Thunderyard Silk Culottes",
        itemId=44220,
        turninRow=0,
        turninIndex=5,
        turninType=39,
        artisanListId=0
    },
    {
        className="Alchemist",
        classId=14,
        itemName="Rarefied Claro Walnut Flat Brush",
        itemId=44226,
        turninRow=0,
        turninIndex=6,
        turninType=39,
        artisanListId=0
    },
    {
        className="Culinarian",
        classId=15,
        itemName="Rarefied Tacos de Carne Asada",
        itemId=44232,
        turninRow=0,
        turninIndex=7,
        turninType=39,
        artisanListId=14783  -- 14783/21193
    }
}

PurpleScrips =
{
    {
        className="Carpenter",
        classId=8,
        itemName="Rarefied Claro Walnut Grinding Wheel",
        itemId=44189,
        turninRow=1,
        turninIndex=0,
        turninType=38,
        artisanListId=0
    },
    {
        className="Blacksmith",
        classId=9,
        itemName="Rarefied Ra'Kaznar War Scythe",
        itemId=44195,
        turninRow=1,
        turninIndex=1,
        turninType=38,
        artisanListId=0
    },
    {
        className="Armorer",
        classId=10,
        itemName="Rarefied Ra'Kaznar Greaves",
        itemId=44201,
        turninRow=1,
        turninIndex=2,
        turninType=38,
        artisanListId=0
    },
    {
        className="Goldsmith",
        classId=11,
        itemName="Rarefied Ra'Kaznar Orrery",
        itemId=44207,
        turninRow=1,
        turninIndex=3,
        turninType=38,
        artisanListId=0
    },
    {
        className="Leatherworker",
        classId=12,
        itemName="Rarefied Gargantuaskin Trouser",
        itemId=44213,
        turninRow=1,
        turninIndex=4,
        turninType=38,
        artisanListId=0
    },
    {
        className="Weaver",
        classId=13,
        itemName="Rarefied Thunderyards Silk Gloves",
        itemId=44219,
        turninRow=1,
        turninIndex=5,
        turninType=38,
        artisanListId=0
    },
    {
        className="Alchemist",
        classId=14,
        itemName="Rarefied Gemdraught of Vitality",
        itemId=44225,
        turninRow=1,
        turninIndex=6,
        turninType=38,
        artisanListId=0
    },
    {
        className="Culinarian",
        classId=15,
        itemName="Rarefied Sykon Bavarois",
        itemId=36626,
        turninRow=6,
        turninIndex=7,
        turninType=38,
        artisanListId=14291  -- 14291/46432
    }
}

-------------------
--    HubCity    --
-------------------

HubCities =
{
    {
        zoneName="Limsa",
        zoneId = 129,
        aethernet = {
            aethernetZoneId = 129,
            aethernetName = "Hawkers' Alley",
            x=-213.61108, y=16.739136, z=51.80432
        },
        retainerBell = { x=-124.703, y=18, z=19.887, s=2, requiresAethernet=false },
        scripExchange = { x=-258.52585, y=16.2, z=40.65883, s=2, requiresAethernet=true }
    },
    {
        zoneName="Gridania",
        zoneId = 132,
        aethernet = {
            aethernetZoneId = 133,
            aethernetName = "Leatherworkers' Guild & Shaded Bower",
            x=131.9447, y=4.714966, z=-29.800903
        },
        retainerBell = { x=168.72, y=15.5, z=-100.06, s=2, requiresAethernet=true },
        scripExchange = { x=142.15, y=13.74, z=-105.39, s=2, requiresAethernet=true },
    },
    {
        zoneName="Ul'dah",
        zoneId = 130,
        aethernet = {
            aethernetZoneId = 131,
            aethernetName = "Sapphire Avenue Exchange",
            x=101, y=9, z=-112
        },
        retainerBell = { x=146.760, y=4, z=-42.992, s=2, requiresAethernet=true },
        scripExchange = { x=147.73, y=4, z=-18.19, s=2, requiresAethernet=true },
    },
    {
        zoneName="Solution Nine",
        zoneId = 1186,
        aethernet = {
            aethernetZoneId = 1186,
            aethernetName = "Nexus Arcade",
            x=-161, y=-1, z=212
        },
        retainerBell = { x=-152.465, y=0.660, z=-13.557, s=2, requiresAethernet=true },
        scripExchange = { x=-158.019, y=0.922, z=-37.884, s=2, requiresAethernet=true }
    }
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [Artisan] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [Artisan] Stopping the script..!!")
        yield("/snd stop")
    end
end

------------------
--    Checks    --
------------------

function Checks()
    for _, class in pairs(ClassList) do
        if CrafterClass == class.className then
            classId = class.classId
        end
    end
    if not classId then
        yield("/echo [Artisan] Could not find crafter class: "..CrafterClass)
        yield("/snd stop")
    elseif GetClassJobId() ~= classId then
        yield("/gearset change "..CrafterClass)
        yield("/wait 1")
        yield("/echo [Artisan] Crafter class changed to: "..CrafterClass)
    else
        yield("/echo [Artisan] Crafter class is: "..CrafterClass)
    end

    if ScripColor == "Orange" then
        CollectableScrip = OrangeScrips
    elseif ScripColor == "Purple" then
        CollectableScrip = PurpleScrips
    else
        yield("/echo [Artisan] Cannot recognize crafter scrip color: "..ScripColor)
        yield("/wait 1")
        yield("/snd stop")
    end

    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            SelectedItemToBuy = item
        end
    end
    if SelectedItemToBuy == nil then
        yield("/echo [Artisan] Could not find "..ItemToBuy.." on the list of scrip exchange items.")
        yield("/snd stop")
    end
end

----------------
--    Wait    --
----------------

function PlayerTest()
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

function WaitForLifeStream()
    repeat
        yield("/wait 1")
    until not LifestreamIsBusy()
    PlayerTest()
end

function WaitForTp()
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait 1")
    end
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 1")
    end
    PlayerTest()
    yield("/wait 1")
end

function WaitForAR()
    if ARRetainersWaitingToBeProcessed() and DoAutoRetainers then
        yield("/echo [Artisan] Waiting for AutoRetainers to complete")
        yield("/wait 1")
        while GetCharacterCondition(CharacterCondition.occupiedSummoningBell) do
            PlayerTest()
        end
    end
    yield("/wait 1")
end

----------------
--    Move    --
----------------

function MoveTo(valuex, valuey, valuez, stopdistance)
    local function Truncate1Dp(num)
        return truncate and ("%.1f"):format(num) or num
    end
    while not NavIsReady() do
        LogInfo("[Debug]Building navmesh, currently at "..Truncate1Dp(NavBuildProgress() - 100).."%")
        yield("/wait 1")
    end
    PathfindAndMoveTo(valuex, valuey, valuez, false)
    while ((PathIsRunning() or PathfindInProgress()) and GetDistanceToPoint(valuex, valuey, valuez) > stopdistance) do
        yield("/wait 1")
    end
    PathStop()
    LogInfo("[MoveTo] Completed")
end

function MoveToInn()
    local WhereAmI = GetZoneID()
    if (WhereAmI ~= 177) and (WhereAmI ~= 178) and (WhereAmI ~= 179) and (WhereAmI ~= 1205) then
        yield("/li Inn")
        yield("/echo [Artisan] Moving to Inn")
        WaitForLifeStream()
    end
end

function MoveForExchange()
    for _, city in ipairs(HubCities) do
        if city.zoneName == HubCity then
            SelectedHubCity = city
            SelectedHubCity.aetheryte = GetAetheryteName(GetAetherytesInZone(city.zoneId)[0])
        end
    end
    if SelectedHubCity == nil then
        yield("/echo [Artisan] Could not find hub city: "..HubCity)
        yield("/snd stop")
    end
    StateReached = false
    yield("/echo [Artisan] Moving to Collectable Appraiser")
    while not StateReached do
        ScripExchangeDistance = GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        if IsInZone(SelectedHubCity.aethernet.aethernetZoneId) and ScripExchangeDistance > 1 and ScripExchangeDistance < 100 then
            if not (PathfindInProgress() or PathIsRunning()) then
                MoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z, SelectedHubCity.scripExchange.s)
                StateReached = true
            end
        else
            yield("/tp "..SelectedHubCity.aetheryte)
            WaitForTp()
            if not LifestreamIsBusy() then
                yield("/li "..SelectedHubCity.aethernet.aethernetName)
                WaitForTp()
            end
        end
    end
end

----------------
--    Misc    --
----------------

function Loop()
    if HowManyLoops == "true" or HowManyLoops == "0" then
        LoopAmount = true
    else
        LoopAmount = HowManyLoops
    end
end

function LoopCount()
    loop = loop + 1
end

function ArtisanCraftingList()
    for _, item in ipairs(CollectableScrip) do
        if classId == item.classId then
            ItemName = item.itemName
            ArtisanListId = item.artisanListId
        end
    end
    yield("/echo [Artisan] Preparing to Craft: "..ItemName)
    while GetInventoryFreeSlotCount() > MinInventoryFreeSlots do
        if not ArtisanIsListRunning() then
            ArtisanTimeoutStartTime = os.clock()
            yield("/artisan lists "..ArtisanListId.." start")
            yield("/wait 5")
            if os.clock() - ArtisanTimeoutStartTime > 5 and IsNotCrafting() then
                StopFlag = true
                yield("/echo [Artisan] Stopping Artisan Crafting List..Out of Mats..")
                yield("/wait 1")
                return
            end
        else
            yield("/wait 1")
        end
    end
    PlayerTest()
end

function Repair()
    if NeedsRepair(RepairThreshold) then
        yield("/echo [Artisan] Repairing Gear")
        while not IsAddonVisible("Repair") do
            yield("/generalaction repair")
            yield("/wait 1")
        end
        yield("/callback Repair true 0")
        yield("/wait 1")
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            yield("/wait 1")
        end
        while GetCharacterCondition(CharacterCondition.occupied) do
            yield("/wait 1")
        end
        yield("/wait 1")
        yield("/callback Repair true -1")
    end
    PlayerTest()
    yield("/wait 1")
end

function ExtractMateria()
    if ExtractMateria == true then
        if CanExtractMateria(100) then
            yield("/echo [Artisan] Extracting Materia")
            yield("/generalaction \"Materia Extraction\"")
            yield("/waitaddon Materialize")
            while CanExtractMateria(100) == true do
                if not IsAddonVisible("Materialize") then
                    yield("/generalaction \"Materia Extraction\"")
                end
                yield("/callback Materialize true 2")
                yield("/wait 1")
                if IsAddonVisible("MaterializeDialog") then
                    yield("/callback MaterializeDialog true 0")
                    yield("/wait 1")
                end
                while GetCharacterCondition(CharacterCondition.occupied) do
                    yield("/wait 1")
                end
            end
            yield("/wait 1")
            yield("/callback Materialize true -1")
            yield("/wait 1")
        end
    end
    PlayerTest()
    yield("/wait 1")
end

function GetOUT()
    repeat
        yield("/wait 1")
        if IsAddonVisible("SelectIconString") then
            yield("/callback SelectIconString true -1")
        end
        if IsAddonVisible("SelectString") then
            yield("/callback SelectString true -1")
        end
        if IsAddonVisible("ShopExchangeItem") then
            yield("/callback ShopExchangeItem true -1")
        end
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        end
        if IsAddonVisible("InventoryRetainer") then
            yield("/callback InventoryRetainer true -1")
        end
    until IsPlayerAvailable()
end

---------------------
--    Retainers    --
---------------------

function DoAR()
    if ARRetainersWaitingToBeProcessed() and DoAutoRetainers then
        yield("/echo [Artisan] Assinging ventures to Retainers")
        yield("/target Summoning Bell")
        yield("/wait 1")
        if GetTargetName() == "Summoning Bell" and GetDistanceToTarget() <= 4.5 then
            yield("/interact")
            while ARRetainersWaitingToBeProcessed() do
                yield("/wait 1")
            end
            GetOUT()
        else
            yield("[Artisan] No Summoning Bell")
        end
    else
        yield("/echo [Artisan] Retainers busy on ventures")
    end
    if GetTargetName() ~= "" then
        ClearTarget()
    end
    WaitForAR()
end

---------------------------------
--    Collectable Appraiser    --
---------------------------------

function CollectableAppraiser()
    while not IsAddonVisible("CollectablesShop") and not IsAddonReady("CollectablesShop") do
        if GetTargetName() ~= "Collectable Appraiser" then
            yield("/target Collectable Appraiser")
        elseif not IsAddonVisible("SelectIconString") then
            yield("/interact")
        else
            yield("/callback SelectIconString true 0")
        end
        yield("/wait 1")
    end
    yield("/wait 1")

    local Orange_Scrips_Raw = GetNodeText("CollectablesShop", 39, 1):gsub(",", ""):match("^([%d,]+)/")
    local Purple_Scrips_Raw = GetNodeText("CollectablesShop", 38, 1):gsub(",", ""):match("^([%d,]+)/")

    local Orange_Scrips = tonumber(Orange_Scrips_Raw)
    local Purple_Scrips = tonumber(Purple_Scrips_Raw)

    if (Orange_Scrips < ScripOvercapLimit) and (Purple_Scrips < ScripOvercapLimit) then
        for _, item in ipairs(CollectableScrip) do
            if item.classId == classId then
                ItemId = item.itemId
                CollectableTurninRow = item.turninRow
                CollectableTurninIndex = item.turninIndex
                CollectableTurninType = item.turninType
            end
        end
        if GetItemCount(ItemId) > 0 then
            yield("/callback CollectablesShop true 14 "..CollectableTurninIndex)
            yield("/wait 1")
            yield("/callback CollectablesShop true 12 "..CollectableTurninRow)
            yield("/wait 1")
            Scrips_Owned = tonumber(GetNodeText("CollectablesShop", CollectableTurninType, 1):gsub(",", ""):match("^([%d,]+)/"))
            while (Scrips_Owned <= ScripOvercapLimit) and (not IsAddonVisible("SelectYesno")) and (GetItemCount(ItemId) > 0) do
                yield("/callback CollectablesShop true 15 0")
                yield("/wait 1")
                Scrips_Owned = tonumber(GetNodeText("CollectablesShop", CollectableTurninType, 1):gsub(",", ""):match("^([%d,]+)/"))
            end
            yield("/wait 1")
        end
        yield("/wait 1")
        if IsAddonVisible("Selectyesno") then
            yield("/callback Selectyesno true 1")
        end
        yield("/wait 1")
        yield("/callback CollectablesShop true -1")

        if GetTargetName() ~= "" then
            ClearTarget()
            yield("/wait 1")
        end
    end
end

---------------------------
--    Scrips Exchange    --
---------------------------

function ScripExchange()
    --EXCHANGE OPEN--
    while not IsAddonVisible("InclusionShop") and not IsAddonReady("InclusionShop") do
        if GetTargetName() ~= "Scrip Exchange" then
            yield("/target Scrip Exchange")
        elseif not IsAddonVisible("SelectIconString") then
            yield("/interact")
        else
            yield("/callback SelectIconString true 0")
        end
        yield("/wait 1")
    end
    yield("/wait 1")

    --EXCHANGE CATEGORY--
    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            ScripCategoryMenu = item.categoryMenu
            ScripSubcategoryMenu = item.subcategoryMenu
            ScripListIndex = item.listIndex
            ScripPrice = item.price
        end
    end
    yield("/callback InclusionShop true 12 "..ScripCategoryMenu)
    yield("/wait 1")
    yield("/callback InclusionShop true 13 "..ScripSubcategoryMenu)
    yield("/wait 1")

    --EXCHANGE PURCHASE--
    Scrips_Owned_Str = GetNodeText("InclusionShop", 21):gsub(",", "")
    Scrips_Owned = tonumber(Scrips_Owned_Str)
    if Scrips_Owned >= MinScripExchange then
        Scrip_Shop_Item_Row = ScripListIndex + 21
        Scrip_Item_Number_To_Buy = Scrips_Owned // ScripPrice
        Scrip_Item_Number_To_Buy_Final = math.min(Scrip_Item_Number_To_Buy,99)
        yield("/callback InclusionShop true 14 "..ScripListIndex.." "..Scrip_Item_Number_To_Buy_Final)
        yield("/wait 1")
        if IsAddonVisible("ShopExchangeItemDialog") then
            yield("/callback ShopExchangeItemDialog true 0")
            yield("/wait 1")
        end
    end

    --EXCHANGE CLOSE--
    yield("/wait 1")
    yield("/callback InclusionShop true -1")

    if GetTargetName() ~= "" then
        ClearTarget()
        yield("/wait 1")
    end
end

------------------
--    TurnIn    --
------------------

function CanTurnin()
    local flag = false
    for _, item in ipairs(CollectableScrip) do
        if item.classId == classId then
            ItemId = item.itemId
        end
    end
    if GetItemCount(ItemId) >= MinItemsForTurnIns then
        flag = true
    end
    return flag
end

function CollectableAppraiserScripExchange()
    if IsPlayerAvailable() and DoScrips then
        while CanTurnin() do
            CollectableAppraiser()
            yield("/wait 1")
            ScripExchange()
            yield("/wait 1")
        end
    else yield("/wait 1")
        ScripExchange()
    end
end

-------------------------------- Execution --------------------------------

Plugins()
Checks()
Loop()
while LoopAmount == true or loop <= LoopAmount and not StopFlag do
    yield("[Artisan] Loop Count: "..loop)
    MoveToInn()
    DoAR()
    ArtisanCraftingList()
    Repair()
    ExtractMateria()
    MoveForExchange()
    CollectableAppraiserScripExchange()
    LoopCount()
end

----------------------------------- End -----------------------------------