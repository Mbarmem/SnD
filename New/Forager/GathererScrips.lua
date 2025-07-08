--[[

***********************************************
*                  Forager                    *
*       Script for Gathering & Turning In     *
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
    -> GatherBuddy
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

ScripColor = "Orange"
ItemToBuy = "Mount Token"
HubCity = "Ul'dah"  --Options:Limsa/Gridania/Ul'dah/Solution Nine.
EnableGBR = true
MsgDelay = 10
verbose = true
Timeout = 10
RepairThreshold = 20
MinItemsForTurnIns = 1
MinInventoryFreeSlots = 15
ItemCount = tonumber(GetInventoryFreeSlotCount())

----------------
--    Food    --
----------------

Food = false
Medicine = false
ConsumableTime = 10

----------------
--    Misc    --
----------------

DoExtract = true
DoReplace = true
DoRepair = true
DoAutoRetainers = true

----------------
--    Loop    --
----------------

local stop_main = false
local loop = 1

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
    "GatherbuddyReborn",
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
    mounted=4,
    gathering=6,
    casting=27,
    tradeOpen=37,
    occupied=39,
    gathering_2=42,
    betweenAreas=45,
    occupiedSummoningBell=50,
    betweenAreas_2=51,
    inFlight=77,
    diving=81
}

-----------------
--    Items    --
-----------------

ScripExchangeItems = {
    {
        itemName = "Mount Token",
        categoryMenu = 4,
        subcategoryMenu = 8,
        listIndex = 6,
        price = 1000
    },
    {
        itemName = "Gatherer's Guerdon Materia XII",
        categoryMenu = 5,
        subcategoryMenu = 2,
        listIndex = 0,
        price = 500
    },
    {
        itemName = "Gatherer's Guile Materia XII",
        categoryMenu = 5,
        subcategoryMenu = 2,
        listIndex = 1,
        price = 500
    },
    {
        itemName = "Gatherer's Grasp Materia XII",
        categoryMenu = 5,
        subcategoryMenu = 2,
        listIndex = 2,
        price = 500
    },
    {
        itemName = "Gatherer's Guerdon Materia XI",
        categoryMenu = 5,
        subcategoryMenu = 1,
        listIndex = 0,
        price = 250
    },
    {
        itemName = "Gatherer's Guile Materia XI",
        categoryMenu = 5,
        subcategoryMenu = 1,
        listIndex = 1,
        price = 250
    },
    {
        itemName = "Gatherer's Grasp Materia XI",
        categoryMenu = 5,
        subcategoryMenu = 1,
        listIndex = 2,
        price = 250
    },
    {
        itemName = "Gatherer's Guerdon Materia IX",
        categoryMenu = 5,
        subcategoryMenu = 1,
        listIndex = 6,
        price = 200
    },
    {
        itemName = "Gatherer's Guile Materia IX",
        categoryMenu = 5,
        subcategoryMenu = 1,
        listIndex = 7,
        price = 200
    },
    {
        itemName = "Gatherer's Guile Materia V",
        categoryMenu = 5,
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
        className="Miner",
        classId=16,
        itemName="Rarefied Ra'Kaznar Ore",
        itemId=43922,
        turninRow=0,
        turninIndex=8,
        turninType=39
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Ash Soil",
        itemId=43923,
        turninRow=1,
        turninIndex=8,
        turninType=39
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Magnesite Ore",
        itemId=43921,
        turninRow=3,
        turninIndex=8,
        turninType=39
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Acacia Log",
        itemId=43929,
        turninRow=0,
        turninIndex=9,
        turninType=39
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Windsbalm Bay Leaf",
        itemId=43930,
        turninRow=1,
        turninIndex=9,
        turninType=39
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Dark Mahogany Log",
        itemId=43928,
        turninRow=3,
        turninIndex=9,
        turninType=39
    }
}

PurpleScrips =
{
    {
        className="Miner",
        classId=16,
        itemName="Rarefied White Gold Ore",
        itemId=44233,
        turninRow=4,
        turninIndex=8,
        turninType=38
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Titanium Gold Ore",
        itemId=43920,
        turninRow=5,
        turninIndex=8,
        turninType=38
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Raw Dark Amber",
        itemId=43919,
        turninRow=6,
        turninIndex=8,
        turninType=38
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Annite",
        itemId=36299,
        turninRow=8,
        turninIndex=8,
        turninType=38
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Pewter Ore",
        itemId=36300,
        turninRow=9,
        turninIndex=8,
        turninType=38
    },
    {
        className="Miner",
        classId=16,
        itemName="Rarefied Eblan Alumen",
        itemId=36298,
        turninRow=11,
        turninIndex=8,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Acacia Bark",
        itemId=44234,
        turninRow=4,
        turninIndex=9,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Sweet Kukuru Bean",
        itemId=43927,
        turninRow=5,
        turninIndex=9,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Mountain Flax",
        itemId=43926,
        turninRow=6,
        turninIndex=9,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Iceberg Lettuce",
        itemId=36309,
        turninRow=8,
        turninIndex=9,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied AR-Caean Cotton Boll",
        itemId=36310,
        turninRow=9,
        turninIndex=9,
        turninType=38
    },
    {
        className="Botanist",
        classId=17,
        itemName="Rarefied Elder Nutmeg",
        itemId=36308,
        turninRow=11,
        turninIndex=9,
        turninType=38
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
            x=-161, y=-1, z=21
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
            yield("/echo [Forager] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [Forager] Stopping the script..!!")
        yield("/snd stop")
    end
end

------------------
--    Checks    --
------------------

function Checks()
    if ScripColor == "Orange" then
        CollectableScrip = OrangeScrips
    elseif ScripColor == "Purple" then
        CollectableScrip = PurpleScrips
    else
        yield("/echo [Forager] Cannot recognize crafter scrip color: "..ScripColor)
        yield("/wait 1")
        yield("/snd stop")
    end

    for _, item in ipairs(ScripExchangeItems) do
        if item.itemName == ItemToBuy then
            SelectedItemToBuy = item
        end
    end
    if SelectedItemToBuy == nil then
        yield("/echo [Forager] Could not find "..ItemToBuy.." on the list of scrip exchange items.")
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

----------------
--    Move    --
----------------

function MoveTo(valuex, valuey, valuez, stopdistance, FlyOrWalk)
    local function Truncate1Dp(num)
        return truncate and ("%.1f"):format(num) or num
    end
    while not NavIsReady() do
        LogInfo("[Debug]Building navmesh, currently at "..Truncate1Dp(NavBuildProgress() - 100).."%")
        yield("/wait 1")
    end
    if FlyOrWalk then
        if TerritorySupportsMounting() then
            while GetCharacterCondition(CharacterCondition.mounted, false) do
                yield("/wait 1")
                if GetCharacterCondition(CharacterCondition.casting) then
                    yield("/wait 2")
                else
                    yield('/gaction "mount roulette"')
                end
            end
            if HasFlightUnlocked(GetZoneID()) then
                PathfindAndMoveTo(valuex, valuey, valuez, true) -- flying
            else
                LogInfo("[MoveTo] Can't fly trying to walk.")
                PathfindAndMoveTo(valuex, valuey, valuez, false) -- walking
            end
        else
            LogInfo("[MoveTo] Can't mount trying to walk.")
            PathfindAndMoveTo(valuex, valuey, valuez, false) -- walking
        end
    else
        PathfindAndMoveTo(valuex, valuey, valuez, false) -- walking
    end
    while ((PathIsRunning() or PathfindInProgress()) and GetDistanceToPoint(valuex, valuey, valuez) > stopdistance) do
        yield("/wait 1")
    end
    PathStop()
    LogInfo("[MoveTo] Completed")
end

function CheckNavmeshReady()
    was_ready = NavIsReady()
    while not NavIsReady() do
        Id_Print("Building navmesh, currently at "..Truncate1Dp(NavBuildProgress() * 100).."%")
        yield("/wait 1")
    end
    if not was_ready then Id_Print("Navmesh is ready!") end
end

function NodeMoveFly(node, force_moveto)
    local force_moveto = force_moveto or false
    local x = tonumber(ParseNodeDataString(node)[2]) or 0
    local y = tonumber(ParseNodeDataString(node)[3]) or 0
    local z = tonumber(ParseNodeDataString(node)[4]) or 0
    last_move_type = last_move_type or "NA"
    CheckNavmeshReady()
    start_pos = Truncate1Dp(GetPlayerRawXPos()) ..
        ","..Truncate1Dp(GetPlayerRawYPos())..","..Truncate1Dp(GetPlayerRawZPos())
    if not force_moveto and ((GetCharacterCondition(CharacterCondition.mounted) and GetCharacterCondition(CharacterCondition.inFlight)) or GetCharacterCondition(CharacterCondition.diving)) then
        last_move_type = "fly"
        PathfindAndMoveTo(x, y, z, true)
    else
        last_move_type = "walk"
        PathfindAndMoveTo(x, y, z)
    end
    while PathfindInProgress() do
        Id_Print("[VERBOSE] Pathfinding from "..start_pos.." to "..PrintNode(node).." in progress...", verbose)
        yield("/wait 1")
    end
    Id_Print("[VERBOSE] Pathfinding complete.", verbose)
end

function StopMoveFly()
    PathStop()
    while PathIsRunning() do
        yield("/wait 1")
    end
end

function VNavMovement()
    repeat
        yield("/wait 1")
    until not PathIsRunning()
end

function Dismount()
    if GetCharacterCondition(CharacterCondition.inFlight) then
        local random_j = 0
        ::DISMOUNT_START::
        CheckNavmeshReady()

        local land_x
        local land_y
        local land_z
        local i = 0
        while not land_x or not land_y or not land_z do
            land_x = QueryMeshPointOnFloorX(GetPlayerRawXPos() + math.random(0, random_j),
                GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            land_y = QueryMeshPointOnFloorY(GetPlayerRawXPos() + math.random(0, random_j),
                GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            land_z = QueryMeshPointOnFloorZ(GetPlayerRawXPos() + math.random(0, random_j),
                GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            i = i + 1
        end
        NodeMoveFly("land,"..land_x..","..land_y..","..land_z)

        local Timeout_Start = os.clock()
        repeat
            yield("/wait 1")
            if os.clock() - Timeout_Start > Timeout then
                Id_Print("Failed to navigate to dismountable terrain.")
                Id_Print("Trying another place to dismount...")
                random_j = random_j + 1
                goto DISMOUNT_START
            end
        until not PathIsRunning()

        yield('/gaction "Mount Roulette"')
        Timeout_Start = os.clock()
        repeat
            yield("/wait 1")
            if os.clock() - Timeout_Start > Timeout then
                Id_Print("Failed to dismount.")
                Id_Print("Trying another place to dismount...")
                random_j = random_j + 1
                goto DISMOUNT_START
            end
        until not GetCharacterCondition(CharacterCondition.inFlight)
    end
    if GetCharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "Mount Roulette"')
        repeat
            yield("/wait 1")
        until not GetCharacterCondition(CharacterCondition.mounted)
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
        yield("/echo [Forager] Could not find hub city: "..HubCity)
        yield("/snd stop")
    end
    StateReached = false
    yield("/echo [Forager] Moving to Collectable Appraiser")
    while not StateReached do
        ScripExchangeDistance = GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        if IsInZone(SelectedHubCity.aethernet.aethernetZoneId) and ScripExchangeDistance > 1 and ScripExchangeDistance < 100 then
            if not (PathfindInProgress() or PathIsRunning()) then
                MoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z, SelectedHubCity.scripExchange.s, false)
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

function MoveForRetainers()
    for _, city in ipairs(HubCities) do
        if city.zoneName == HubCity then
            SelectedHubCity = city
            SelectedHubCity.aetheryte = GetAetheryteName(GetAetherytesInZone(city.zoneId)[0])
        end
    end
    if SelectedHubCity == nil then
        yield("/echo [Forager] Could not find hub city: "..HubCity)
        yield("/snd stop")
    end
    StateReached = false
    yield("/echo [Forager] Moving to Retainer Bell")
    while not StateReached do
        RetainerBellDistance = GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z)
        if IsInZone(SelectedHubCity.aethernet.aethernetZoneId) and RetainerBellDistance > 1 and RetainerBellDistance < 100 then
            if not (PathfindInProgress() or PathIsRunning()) then
                MoveTo(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z, SelectedHubCity.retainerBell.s, false)
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

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function Split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function AddToSet(set, key)
    set[key] = true
end

function ParseNodeDataString(string)
    return Split(string, ",")
end

function PrintNode(node)
    local printable_node = node or ""
    if truncate then
        local data = ParseNodeDataString(node)
        local x = Truncate1Dp(data[2])
        local y = Truncate1Dp(data[3])
        local z = Truncate1Dp(data[4])
        printable_node = data[1]..","..x..","..y..","..z
    end
    return printable_node
end

function Id_Print(string, print, debug)
    local time = -MsgDelay
    if print == nil then print = true end
    if debug == nil then debug = false end
    print_history = print_history or Set {}
    script_start = script_start or os.clock()

    if debug then
        LogDebug("[Forager] [DEBUG] "..string)
        return
    end

    for k, _ in pairs(print_history) do
        entry = Split(k, "_")
        if entry and time < tonumber(entry[1]) and entry[2] == string then
            time = tonumber(entry[1])
        end
    end

    if print and os.clock() - script_start >= time + MsgDelay then
        yield("/echo [Forager] "..string)
        AddToSet(print_history, (os.clock() - script_start).."_"..string)
    end
end

function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end

function RepairExtractReduceCheck()
    if GetZoneID() == 1055 then
        return true
    end

    function SelfRepair()
        if DoRepair and NeedsRepair(RepairThreshold) then
            StopMoveFly()
            if GetCharacterCondition(CharacterCondition.mounted) then
                Id_Print("[Forager] Attempting to dismount...")
                Dismount()
            end
            while not IsAddonVisible("Repair") do
                yield("/generalaction repair")
                yield("/wait 1")
            end
            yield("/callback Repair true 0")
            yield("/wait 1")
            if GetNodeText("_TextError", 1) == "You do not have the dark matter required to repair that item." and
                IsAddonVisible("_TextError") then
                LogInfo("[Forager] Set to False not enough dark matter")
            end
            if IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            while GetCharacterCondition(CharacterCondition.occupied) do
                yield("/wait 3")
            end
            yield("/wait 2")
            if IsAddonVisible("Repair") then
                yield("/callback Repair true -1")
            end
            Id_Print("[Forager] Repair Completed")
        end
    end

    SelfRepair()

    function MateriaExtract()
        if DoExtract and CanExtractMateria(100) then
            StopMoveFly()
            if GetCharacterCondition(CharacterCondition.mounted) then
                Id_Print("[Forager] Attempting to dismount...")
                Dismount()
            end
            Id_Print("Attempting to extract materia...")
            yield("/generalaction \"Materia Extraction\"")
            yield("/waitaddon Materialize")

            while CanExtractMateria(100) == true do
                yield("/callback Materialize true 2 0")
                yield("/wait 1")
                if IsAddonVisible("MaterializeDialog") then
                    yield("/callback MaterializeDialog true 0")
                end
                while GetCharacterCondition(CharacterCondition.occupied) do
                    yield("/wait 3")
                end
                yield("/wait 1")
            end
            yield("/wait 1")
            yield("/callback Materialize true -1")
            Id_Print("[Forager] Materia extraction complete!")
        end
    end

    MateriaExtract()

    function HasReducibles()
        while not IsAddonVisible("PurifyItemSelector") and not IsAddonReady("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local Timeout_Start = os.clock()
            repeat
                yield("/wait 1")
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - Timeout_Start > Timeout
        end
        yield("/wait 1")
        local visible = IsNodeVisible("PurifyItemSelector", 1, 7) and not IsNodeVisible("PurifyItemSelector", 1, 6)
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local Timeout_Start = os.clock()
            repeat
                yield("/wait 1")
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - Timeout_Start >= Timeout
        end
        return not visible
    end

    if DoReplace and HasReducibles() and GetInventoryFreeSlotCount() < MinInventoryFreeSlots then
        StopMoveFly()
        if GetCharacterCondition(CharacterCondition.mounted) then
            Id_Print("[Forager] Attempting to dismount...")
            Dismount()
        end
        Id_Print("[Forager] Attempting to perform aetherial reduction...")
        repeat
            yield('/gaction "Aetherial Reduction"')
            local Timeout_Start = os.clock()
            repeat
                yield("/wait 1")
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - Timeout_Start > Timeout
        until IsAddonVisible("PurifyItemSelector") and IsAddonReady("PurifyItemSelector")
        yield("/wait 1")
        while not IsNodeVisible("PurifyItemSelector", 1, 7) and IsNodeVisible("PurifyItemSelector", 1, 6) do
            yield("/callback PurifyItemSelector true 12 0")
            repeat
                yield("/wait 2")
            until not GetCharacterCondition(CharacterCondition.occupied)
        end
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local Timeout_Start = os.clock()
            repeat
                yield("/wait 1")
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - Timeout_Start >= Timeout
        end
        Id_Print("[Forager] Aetherial reduction complete!")
    end
    return true
end

-------------------
--    Utility    --
-------------------

function getOutOfGathering()
    while GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2) do
        yield("/wait 1")
        yield("/echo waiting to disable GBR")
        yield("/callback Gathering true -1")
        yield("/wait 1")
        yield("/callback GatheringMasterpiece true -1")
    end
end

function setSNDPropertyIfNotSet(propertyName)
    if GetSNDProperty(propertyName) == false then
        SetSNDProperty(propertyName, "true")
        LogInfo("[SetSNDPropertys] "..propertyName.." set to True")
    end
end

function unsetSNDPropertyIfSet(propertyName)
    if GetSNDProperty(propertyName) then
        SetSNDProperty(propertyName, "false")
        LogInfo("[SetSNDPropertys] "..propertyName.." set to False")
    end
end

function DeliverooEnable()
    if not DeliverooIsTurnInRunning() then
        yield("/wait 1")
        yield("/deliveroo enable")
    end
end

function GBRAutoenable()
    yield("/wait 1")
    yield("/gbr auto on")
end

function GBRAutodisable()
    yield("/wait 1")
    yield("/vnav stop")
    while (GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2) or GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.betweenAreas_2)) do
        yield("/wait 1")
        yield("/echo [Forager] Waiting for gathering or teleport to be completed before disabling GBR")
    end
    yield("/gbr auto off")
    yield("/wait 1")
    getOutOfGathering()
    yield("/wait 1")
end

----------------------
--    Consumables   --
----------------------

function UseMedicine()
    if type(Medicine) ~= "string" and type(Medicine) ~= "table" then
        return
    end
    if GetZoneID() == 1055 then
        return
    end
    if not HasStatus("Medicated") then
        local Timeout_Start = os.clock()
        local user_settings = { GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"),
        GetSNDProperty("StopMacroIfCantUseItem") }
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(Medicine) == "string" then
                Id_Print("Attempt to use "..Medicine)
                yield("/item "..Medicine)
            elseif type(Medicine) == "table" then
                for _, medicine in ipairs(Medicine) do
                    Id_Print("Attempting to use "..medicine, verbose)
                    yield("/item "..medicine)
                    yield("/wait 1")
                    if HasStatus("Medicated") then break end
                end
            end
            yield("/wait 1")
        until HasStatus("Medicated") or os.clock() - Timeout_Start > ConsumableTime
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

function EatFood()
    if type(Food) ~= "string" and type(Food) ~= "table" then
        return
    end
    if GetZoneID() == 1055 then
        return
    end
    if not HasStatus("Well Fed") then
        local Timeout_Start = os.clock()
        local user_settings = { GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"),
        GetSNDProperty("StopMacroIfCantUseItem") }
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(Food) == "string" then
                Id_Print("Attempt to eat "..Food)
                yield("/item "..Food)
            elseif type(Food) == "table" then
                for _, food in ipairs(Food) do
                    Id_Print("Attempting to eat "..food, verbose)
                    yield("/item "..food)
                    yield("/wait 1")
                    if HasStatus("Well Fed") then break end
                end
            end
            yield("/wait 1")
        until HasStatus("Well Fed") or os.clock() - Timeout_Start > ConsumableTime
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

---------------------
--    Retainers    --
---------------------

function DoAR()
    if ARRetainersWaitingToBeProcessed() and DoAutoRetainers then
        Timeout_Start = os.clock()
        if PathIsRunning() then
            repeat
                yield("/wait 1")
            until ((not PathIsRunning()) and IsPlayerAvailable()) or (os.clock() - Timeout_Start > Timeout)
            yield("/wait 1")
            yield("/vnavmesh stop")
        end
        if not IsPlayerAvailable() then
            Timeout_Start = os.clock()
            repeat
                yield("/wait 1")
            until IsPlayerAvailable() or (os.clock() - Timeout_Start > Timeout)
        end
        MoveForRetainers()
        yield("/wait 1")
        yield("/target Summoning Bell")
        yield("/wait 1")
        if GetTargetName() == "Summoning Bell" and GetDistanceToTarget() <= 4.5 then
            yield("/interact")
            yield("/ays multi")
            yield("/wait 1")
            yield("/ays e")
            LogInfo("[Forager] AR Started")
            while ARRetainersWaitingToBeProcessed() do
                yield("/wait 1")
            end
        else
            yield("No Summoning Bell")
        end
        yield("/wait 10")
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
            yield("/wait 1")
        end
        if GetTargetName() ~= "" then
            ClearTarget()
        end
        yield("/wait 1")
        yield("/ays multi")
    end
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
        for i, item in ipairs(CollectableScrip) do
            ItemId = item.itemId
            CollectableTurninRow = item.turninRow
            CollectableTurninIndex = item.turninIndex
            CollectableTurninType = item.turninType
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
    for i, item in ipairs(ScripExchangeItems) do
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
        ItemId = item.itemId
        if GetItemCount(ItemId) >= MinItemsForTurnIns then
            flag = true
        end
    end
    return flag
end

function CollectableAppraiserScripExchange()
    if IsPlayerAvailable() and DoScrips then
        MoveForExchange()
        yield("/wait 1")
        while CanTurnin() do
            CollectableAppraiser()
            yield("/wait 1")
            ScripExchange()
            yield("/wait 1")
        end
        yield("/wait 1")
        ScripExchange()
    end
end

----------------
--    Main    --
----------------

function Main()
    ItemCount = tonumber(GetInventoryFreeSlotCount())
    while (not (ItemCount < MinInventoryFreeSlots)) and (not CanExtractMateria(100)) do
        yield("/wait 30")
        ItemCount = tonumber(GetInventoryFreeSlotCount())
        yield("/echo [Forager] Gathering...")
        yield("/echo [Forager] Slots Remaining: "..ItemCount)

        if DoAutoRetainers and (ARRetainersWaitingToBeProcessed()) then
            break
            yield("/echo [Forager] Stopping to Process Retainers...")
        end
    end

    if (GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2)) then
        yield("/wait 2")
    end

    yield("/echo [Forager] Disabling GBR to process additional enabled tasks")
    yield("/echo [Forager] Food/Potion Check, Extract/Repair, Reduce/Scrips and Retainers")
    GBRAutodisable()
    yield("/wait 8")

    --On site tasks
    yield("/wait 1")
    Dismount()
    yield("/wait 1")
    RepairExtractReduceCheck()
    yield("/wait 1")
    UseMedicine()
    yield("/wait 1")
    EatFood()
    yield("/wait 1")

    ItemCount = tonumber(GetInventoryFreeSlotCount())
    if ItemCount < MinInventoryFreeSlots then
        yield("/echo [Forager] Moving to do Collectable Appraiser and Scrip Exchnage")
        CollectableAppraiserScripExchange()
    end
    yield("/wait 2")

    if (ARRetainersWaitingToBeProcessed() and DoAutoRetainers) then
        yield("/echo [Forager] AR required")
        DoAR()
        yield("/wait 2")
    end
    yield("/wait 2")
    yield("/echo [Forager] Reanable GBR Auto and start gathering again!")
    if EnableGBR then
        GBRAutoenable()
    end
end

-------------------------------- Execution --------------------------------

Plugins()
Checks()
ItemCount = tonumber(GetInventoryFreeSlotCount())
GBRAutodisable()
yield("/wait 1")
Dismount()
yield("/wait 1")
yield("/echo [Forager] Starting GBR-Legendary Farmer for Gathering & Support Tasks")
yield("/wait 1")
RepairExtractReduceCheck()
yield("/wait 1")
UseMedicine()
yield("/wait 1")
EatFood()
yield("/wait 1")

ItemCount = tonumber(GetInventoryFreeSlotCount())
if (ItemCount < MinInventoryFreeSlots) and CanTurnin() then
    yield("/echo [Forager] Moving to do Collectable Appraiser and Scrip Exchange")
    CollectableAppraiserScripExchange()
    yield("/wait 3")
end

if EnableGBR then
    GBRAutoenable()
end

setSNDPropertyIfNotSet("UseSNDTargeting")
unsetSNDPropertyIfSet("StopMacroIfTargetNotFound")
while not stop_main do
    ItemCount = tonumber(GetInventoryFreeSlotCount())
    yield("/echo [Forager] Going into Gathering Mode")
    yield("/wait 1")
    Main()
    loop = loop + 1
    yield("/echo [Forager] cycle count "..loop)
    yield("/wait 1")
end

----------------------------------- End -----------------------------------