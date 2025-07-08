-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

use_gbr                    = true
return_to_gc_town          = true
inventory_threshold        = 10
msgDelay                   = 10
crystal_check              = false
verbose                    = true
interval_rate              = 1
timeout_threshold          = 10
RepairAmount               = 50

----------------
--    Food    --
----------------

food_to_eat                = false
medicine_to_use            = false
consume_threshold          = 10

----------------
--    Misc    --
----------------

do_extract                 = true
do_reduce                  = true
do_repair                  = true
do_scrips                  = true
do_ar                      = true
do_gc_delivery             = false
use_tickets                = false
ar_all_characters          = false

----------------
--    Loop    --
----------------

local stop_main            = false
local i_count              = tonumber(GetInventoryFreeSlotCount())
local loop                 = 1

-----------------
--    Scrips   --
-----------------

scrip_exchange             = true
scrip_exchange_location    = "solution"
scrip_exchange_sublocation = "nexus"
min_items_before_turnins   = 1
scrip_overcap_limit        = 3900
min_scrip_for_exchange     = 2500

--collectible_to_turnin_row, item_id, job_for_turnin, turnin_scrip_type (follow examples shared here)
collectible_item_table   =
{
    --MINER
    --orange scips --39 for orange scrips
    { 0, 43922, 8, 39 },  --ra'kaznar ore
    { 1, 43923, 8, 39 },  --ash soil
    { 3, 43921, 8, 39 },  --magnesite ore
    --BOTANIST
    { 0, 43929, 9, 39 },  --acacia log
    { 1, 43930, 9, 39 },  --windsbalm bay lef
    { 3, 43928, 9, 39 },  --dark mahagony

    --MINER
    --purple scips --38 for purple scrips
    { 4, 44233, 8, 38 },  --white gold ore
    { 5, 43920, 8, 38 },  --titanium gold ore
    { 6, 43919, 8, 38 },  --dark amber
    { 8, 36299, 8, 38 },  --annite
    { 9, 36300, 8, 38 },  --pewter ore
    { 11, 36298, 8, 38 }, --eblan alumen
    --BOTANIST
    { 4, 44234, 9, 38 },  --acacia bark
    { 5, 43927, 9, 38 },  --kukuru beans
    { 6, 43926, 9, 38 },  --mountain flax
    { 8, 36309, 9, 38 },  --iceberg lettuce
    { 9, 36310, 9, 38 },  --cotton boll
    { 11, 36308, 9, 38 }  --elder nutmeg
}

--scrip_exchange_category,scrip_exchange_subcategory,scrip_exchange_item_to_buy_row, collectible_scrip_price (follow examples shared here) change as needed

exchange_item_table      = {
    { 5, 2, 0, 500 }, --what to spend orange (Gatherer's Guerdon Materia XII (Gathering + 36))
    { 5, 1, 0, 250 },   --what to spend purple on (Gatherer's Guerdon Materia XI (Gathering + 20))
}

--example setup
--Purple Scrips
--{ 5, 1, 0, 250 } -Gatherer's Guerdon Materia XI (Gathering + 20)
--{ 5, 1, 1, 250 } -Gatherer's Guile Materia XI (Perception + 20)
--{ 5, 1, 2, 250 } -Gatherer's Grasp Materia XI (GP + 9)
--{ 4, 1, 0, 20 } -High Coridals

--Orange Scrips
--{ 5, 2, 0, 500 } -Gatherer's Guerdon Materia XII (Gathering + 36)
--{ 5, 2, 1, 500 } -Gatherer's Guile Materia XII (Perception + 36)
--{ 5, 2, 2, 500 } -Gatherer's Grasp Materia XII (GP + 11)
--{ 4, 8, 2, 100 } -Sunglit Sand
--{ 4, 8, 3, 200 } -Mythload Sand
--{ 4, 8, 4, 200 } -Mythroot Sand
--{ 4, 8, 5, 200 } -Mythbrine Sand
--{ 4, 8, 6, 1000 } -RRoneek Horn Tokens

----------------------
--    Coordinates   --
----------------------

paths_to_mb = {
    { -124.703, 18.00, 19.887,  129 },
    { 168.72,   15.5,  -100.06, 132 },
    { 146.760,  4,     -42.992, 130 },
    { -152.465, 0.660, -13.557, 1186 }
}

paths_to_scrip = {
    { -258.09,  16.079, 42.089,  129 },
    { 142.15,   13.74,  -105.39, 132 },
    { 149.349,  4,      -18.722, 130 },
    { -158.019, 0.922, -37.884, 1186}

}

--------------------------------- Constant --------------------------------

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

-------------------------------- Functions --------------------------------

--------------------
--    Warnings    --
--------------------

function Warning()
    if not HasPlugin("vnavmesh") then
        yield("/echo [Gather] Please Install vnavmesh")
    end

    if not HasPlugin("PandorasBox") then
        yield("/echo [Gather] Please Install Pandora's Box")
    end

    if not HasPlugin("YesAlready") then
        yield("/echo [Gather] Please Install YesAlready")
    end

    if not HasPlugin("Lifestream") then
        yield("/echo [Gather] Please Install Lifestream")
    end

    if not HasPlugin("AutoRetainer") then
        yield("/echo [Gather] Please Install AutoRetainer")
    end

    if not HasPlugin("Deliveroo") then
        yield("/echo [Gather] Please Install Deliveroo")
    end
end

----------------
--    Wait    --
----------------

function PlayerTest()
    repeat
        yield("/wait " .. interval_rate)
    until IsPlayerAvailable()
end

function WaitForTp()
    yield("/wait " .. interval_rate)
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait " .. interval_rate)
    end
    yield("/wait " .. interval_rate)
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait " .. interval_rate)
    end
    PlayerTest()
    yield("/wait " .. interval_rate)
end

----------------
--    Move    --
----------------

function MoveTo(valuex, valuey, valuez, stopdistance, FlyOrWalk)
    function MeshCheck()
        function Truncate1Dp(num)
            return truncate and ("%.1f"):format(num) or num
        end
        local was_ready = NavIsReady()
        if not NavIsReady() then
            while not NavIsReady() do
                LogInfo("[Debug]Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
                yield("/wait " .. interval_rate)
                local was_ready = NavIsReady()
                if was_ready then
                    LogInfo("[Debug]Navmesh ready!")
                end
            end
        else
            LogInfo("[Debug]Navmesh ready!")
        end
    end

    MeshCheck()
    if FlyOrWalk then
        if TerritorySupportsMounting() then
            while GetCharacterCondition(CharacterCondition.mounted, false) do
                yield("/wait " .. interval_rate)
                if GetCharacterCondition(CharacterCondition.casting) then
                    yield("/wait " .. interval_rate * 2)
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
        yield("/wait " .. interval_rate)
    end
    PathStop()
    LogInfo("[MoveTo] Completed")
end

function CheckNavmeshReady()
    was_ready = NavIsReady()
    while not NavIsReady() do
        Id_Print("Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
        yield("/wait " .. interval_rate)
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
        "," .. Truncate1Dp(GetPlayerRawYPos()) .. "," .. Truncate1Dp(GetPlayerRawZPos())
    if not force_moveto and ((GetCharacterCondition(CharacterCondition.mounted) and GetCharacterCondition(CharacterCondition.inFlight)) or GetCharacterCondition(CharacterCondition.diving)) then
        last_move_type = "fly"
        PathfindAndMoveTo(x, y, z, true)
    else
        last_move_type = "walk"
        PathfindAndMoveTo(x, y, z)
    end
    while PathfindInProgress() do
        Id_Print("[VERBOSE] Pathfinding from " .. start_pos .. " to " .. PrintNode(node) .. " in progress...", verbose)
        yield("/wait " .. interval_rate)
    end
    Id_Print("[VERBOSE] Pathfinding complete.", verbose)
end

function StopMoveFly()
    PathStop()
    while PathIsRunning() do
        yield("/wait " .. interval_rate)
    end
end

function VNavMovement()
    repeat
        yield("/wait " .. interval_rate)
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
        NodeMoveFly("land," .. land_x .. "," .. land_y .. "," .. land_z)

        local timeout_start = os.clock()
        repeat
            yield("/wait " .. interval_rate)
            if os.clock() - timeout_start > timeout_threshold then
                Id_Print("Failed to navigate to dismountable terrain.")
                Id_Print("Trying another place to dismount...")
                random_j = random_j + 1
                goto DISMOUNT_START
            end
        until not PathIsRunning()

        yield('/gaction "Mount Roulette"')
        timeout_start = os.clock()
        repeat
            yield("/wait " .. interval_rate)
            if os.clock() - timeout_start > timeout_threshold then
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
            yield("/wait " .. interval_rate)
        until not GetCharacterCondition(CharacterCondition.mounted)
    end
end

----------------
--    Path    --
----------------

function PathToScrip()
    if scrip_exchange then
        local x = paths_to_scrip[4][1]
        local y = paths_to_scrip[4][2]
        local z = paths_to_scrip[4][3]
        local zoneid = paths_to_scrip[4][4]
        yield("/vnav stop")
        yield("/tp " .. scrip_exchange_location)
        WaitForTp()
        repeat
            yield("/wait " .. interval_rate)
        until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
        yield("/wait " .. interval_rate)
        yield("/li " .. scrip_exchange_sublocation)
        WaitForTp()
        MoveTo(x, y, z, 0.1, false)
        yield("/wait " .. interval_rate)
    else
        if return_to_gc_town then
            yield("/return")
            WaitForTp()
        else
            TeleportToGCTown()
            WaitForTp()
        end

        local gc_no = GetPlayerGC()
        if gc_no == 1 then
            local zoneid = paths_to_scrip[1][4]
            local x = paths_to_scrip[1][1]
            local y = paths_to_scrip[1][2]
            local z = paths_to_scrip[1][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            yield("/wait " .. interval_rate)
            PathfindAndMoveTo(x, y, z, false)
        elseif gc_no == 2 then
            local zoneid = paths_to_scrip[2][4]
            local x = paths_to_scrip[2][1]
            local y = paths_to_scrip[2][2]
            local z = paths_to_scrip[2][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            yield("/li leatherworker")
            WaitForTp()
            PathfindAndMoveTo(x, y, z, false)
        elseif gc_no == 3 then
            local zoneid = paths_to_scrip[3][4]
            local x = paths_to_scrip[3][1]
            local y = paths_to_scrip[3][2]
            local z = paths_to_scrip[3][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            yield("/li sapphire")
            WaitForTp()
            PathfindAndMoveTo(x, y, z, false)
        end
        yield("/wait " .. interval_rate)
        if PathIsRunning() then
            repeat
                yield("/wait " .. interval_rate)
            until not PathIsRunning()
        end
    end
end

function PathToMB()
    if scrip_exchange then
        local x = paths_to_mb[4][1]
        local y = paths_to_mb[4][2]
        local z = paths_to_mb[4][3]
        local zoneid = paths_to_mb[4][4]
        yield("/vnav stop")
        yield("/tp " .. scrip_exchange_location)
        WaitForTp()
        repeat
            yield("/wait " .. interval_rate)
        until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
        yield("/wait " .. interval_rate)
        yield("/li " .. scrip_exchange_sublocation)
        WaitForTp()
        MoveTo(x, y, z, 0.1, false)
        yield("/wait " .. interval_rate)
    else
        if return_to_gc_town then
            yield("/return")
            WaitForTp()
        else
            TeleportToGCTown()
            WaitForTp()
        end

        local gc_no = GetPlayerGC()
        if gc_no == 1 then
            local zoneid = paths_to_mb[1][4]
            local x = paths_to_mb[1][1]
            local y = paths_to_mb[1][2]
            local z = paths_to_mb[1][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            PathfindAndMoveTo(x, y, z, false)
        elseif gc_no == 2 then
            local zoneid = paths_to_mb[2][4]
            local x = paths_to_mb[2][1]
            local y = paths_to_mb[2][2]
            local z = paths_to_mb[2][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            yield("/li leatherworker")
            WaitForTp()
            PathfindAndMoveTo(x, y, z, false)
        elseif gc_no == 3 then
            local zoneid = paths_to_mb[3][4]
            local x = paths_to_mb[3][1]
            local y = paths_to_mb[3][2]
            local z = paths_to_mb[3][3]
            repeat
                yield("/wait " .. interval_rate)
            until (zoneid == GetZoneID()) and (not GetCharacterCondition(CharacterCondition.casting)) and (not GetCharacterCondition(CharacterCondition.betweenAreas)) and (not GetCharacterCondition(CharacterCondition.betweenAreas_2))
            yield("/li sapphire")
            WaitForTp()
            PathfindAndMoveTo(x, y, z, false)
        end
        yield("/wait " .. interval_rate)
        if PathIsRunning() then
            repeat
                yield("/wait " .. interval_rate)
            until not PathIsRunning()
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
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
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
        printable_node = data[1] .. "," .. x .. "," .. y .. "," .. z
    end
    return printable_node
end

function Id_Print(string, print, debug)
    local time = -msgDelay
    if print == nil then print = true end
    if debug == nil then debug = false end
    print_history = print_history or Set {}
    script_start = script_start or os.clock()

    if debug then
        LogDebug("[LegendaryFarmer] [DEBUG] " .. string)
        return
    end

    for k, _ in pairs(print_history) do
        entry = Split(k, "_")
        if entry and time < tonumber(entry[1]) and entry[2] == string then
            time = tonumber(entry[1])
        end
    end

    if print and os.clock() - script_start >= time + msgDelay then
        yield("/echo [LegendaryFarmer] " .. string)
        AddToSet(print_history, (os.clock() - script_start) .. "_" .. string)
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
        if do_repair and NeedsRepair(RepairAmount) then
            StopMoveFly()
            if GetCharacterCondition(CharacterCondition.mounted) then
                Id_Print("[LegendaryFarmer] Attempting to dismount...")
                Dismount()
            end
            while not IsAddonVisible("Repair") do
                yield("/generalaction repair")
                yield("/wait " .. interval_rate)
            end
            yield("/callback Repair true 0")
            yield("/wait " .. interval_rate)
            if GetNodeText("_TextError", 1) == "You do not have the dark matter required to repair that item." and
                IsAddonVisible("_TextError") then
                LogInfo("[LegendaryFarmer] Set to False not enough dark matter")
            end
            if IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            while GetCharacterCondition(CharacterCondition.occupied) do
                yield("/wait " .. interval_rate * 3)
            end
            yield("/wait " .. interval_rate * 2)
            if IsAddonVisible("Repair") then
                yield("/callback Repair true -1")
            end
            Id_Print("[LegendaryFarmer] Repair Completed")
        end
    end

    SelfRepair()
    function MateriaExtract()
        if do_extract and CanExtractMateria(100) then
            StopMoveFly()
            if GetCharacterCondition(CharacterCondition.mounted) then
                Id_Print("[LegendaryFarmer] Attempting to dismount...")
                Dismount()
            end
            Id_Print("Attempting to extract materia...")
            yield("/generalaction \"Materia Extraction\"")
            yield("/waitaddon Materialize")

            while CanExtractMateria(100) == true do
                yield("/callback Materialize true 2 0")
                yield("/wait " .. interval_rate)
                if IsAddonVisible("MaterializeDialog") then
                    yield("/callback MaterializeDialog true 0")
                end
                while GetCharacterCondition(CharacterCondition.occupied) do
                    yield("/wait " .. interval_rate * 3)
                end
                yield("/wait " .. interval_rate * 2)
            end
            yield("/wait " .. interval_rate)
            yield("/callback Materialize true -1")
            Id_Print("[LegendaryFarmer] Materia extraction complete!")
        end
    end

    MateriaExtract()

    function HasReducibles()
        while not IsAddonVisible("PurifyItemSelector") and not IsAddonReady("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait " .. interval_rate)
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - timeout_start > timeout_threshold
        end
        yield("/wait " .. interval_rate)
        local visible = IsNodeVisible("PurifyItemSelector", 1, 7) and not IsNodeVisible("PurifyItemSelector", 1, 6)
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait " .. interval_rate)
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - timeout_start >= timeout_threshold
        end
        return not visible
    end

    if do_reduce and HasReducibles() and GetInventoryFreeSlotCount() < inventory_threshold then
        StopMoveFly()
        if GetCharacterCondition(CharacterCondition.mounted) then
            Id_Print("[LegendaryFarmer] Attempting to dismount...")
            Dismount()
        end
        Id_Print("[LegendaryFarmer] Attempting to perform aetherial reduction...")
        repeat
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait " .. interval_rate)
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - timeout_start > timeout_threshold
        until IsAddonVisible("PurifyItemSelector") and IsAddonReady("PurifyItemSelector")
        yield("/wait " .. interval_rate)
        while not IsNodeVisible("PurifyItemSelector", 1, 7) and IsNodeVisible("PurifyItemSelector", 1, 6) do
            yield("/callback PurifyItemSelector true 12 0")
            repeat
                yield("/wait " .. interval_rate * 2)
            until not GetCharacterCondition(CharacterCondition.occupied)
        end
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait " .. interval_rate)
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - timeout_start >= timeout_threshold
        end
        Id_Print("[LegendaryFarmer] Aetherial reduction complete!")
    end
    return true
end

-------------------
--    Utility    --
-------------------

function CrystalCheck()
    if crystal_check then
        Id_Print("[LegendaryFarmer] Current Crystals/Clusters in Inventory")
        Id_Print("***Fire Crystals/Clusters:" .. GetItemCount(8) .. "/ " .. GetItemCount(14))
        Id_Print("***Wind Crystals:" .. GetItemCount(10) .. "/ " .. GetItemCount(16))
        Id_Print("***Earth Crystals:" .. GetItemCount(11) .. "/ " .. GetItemCount(17))
        Id_Print("***Lightning Crystals:" .. GetItemCount(12) .. "/ " .. GetItemCount(18))
        if ((GetItemCount(8) > 9900) or (GetItemCount(10) > 9900) or (GetItemCount(11) > 9900) or (GetItemCount(12) > 9900)) then
            Id_Print("[LegendaryFarmer] This maybe good time to dump your crystals to your retainers or MB")
        end
    end
end

function getOutOfGathering()
    while GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2) do
        yield("/wait " .. interval_rate)
        yield("/echo waiting to disable GBR")
        yield("/callback Gathering true -1")
        yield("/wait " .. interval_rate)
        yield("/callback GatheringMasterpiece true -1")
    end
end

function setSNDPropertyIfNotSet(propertyName)
    if GetSNDProperty(propertyName) == false then
        SetSNDProperty(propertyName, "true")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to True")
    end
end

function unsetSNDPropertyIfSet(propertyName)
    if GetSNDProperty(propertyName) then
        SetSNDProperty(propertyName, "false")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to False")
    end
end

function DeliverooEnable()
    if not DeliverooIsTurnInRunning() then
        yield("/wait " .. interval_rate)
        yield("/deliveroo enable")
    end
end

function GBRAutoenable()
    yield("/wait " .. interval_rate)
    yield("/gbr auto on")
end

function GBRAutodisable()
    yield("/wait " .. interval_rate)
    yield("/vnav stop")
    while (GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2) or GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.betweenAreas_2)) do
        yield("/wait " .. interval_rate)
        yield("/echo [LegendaryFarmer] Waiting for gathering or teleport to be completed before disabling GBR")
    end
    yield("/gbr auto off")
    yield("/wait " .. interval_rate)
    getOutOfGathering()
    yield("/wait " .. interval_rate)
end

----------------------
--    Consumables   --
----------------------

function UseMedicine()
    if type(medicine_to_use) ~= "string" and type(medicine_to_use) ~= "table" then
        return
    end
    if GetZoneID() == 1055 then
        return
    end
    if not HasStatus("Medicated") then
        local timeout_start = os.clock()
        local user_settings = { GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"),
        GetSNDProperty("StopMacroIfCantUseItem") }
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(medicine_to_use) == "string" then
                Id_Print("Attempt to use " .. medicine_to_use)
                yield("/item " .. medicine_to_use)
            elseif type(medicine_to_use) == "table" then
                for _, medicine in ipairs(medicine_to_use) do
                    Id_Print("Attempting to use " .. medicine, verbose)
                    yield("/item " .. medicine)
                    yield("/wait " .. math.max(interval_rate, 1))
                    if HasStatus("Medicated") then break end
                end
            end
            yield("/wait " .. math.max(interval_rate, 1))
        until HasStatus("Medicated") or os.clock() - timeout_start > consume_threshold
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

function EatFood()
    if type(food_to_eat) ~= "string" and type(food_to_eat) ~= "table" then
        return
    end
    if GetZoneID() == 1055 then
        return
    end
    if not HasStatus("Well Fed") then
        local timeout_start = os.clock()
        local user_settings = { GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"),
        GetSNDProperty("StopMacroIfCantUseItem") }
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(food_to_eat) == "string" then
                Id_Print("Attempt to eat " .. food_to_eat)
                yield("/item " .. food_to_eat)
            elseif type(food_to_eat) == "table" then
                for _, food in ipairs(food_to_eat) do
                    Id_Print("Attempting to eat " .. food, verbose)
                    yield("/item " .. food)
                    yield("/wait " .. math.max(interval_rate, 1))
                    if HasStatus("Well Fed") then break end
                end
            end
            yield("/wait " .. math.max(interval_rate, 1))
        until HasStatus("Well Fed") or os.clock() - timeout_start > consume_threshold
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

---------------------
--    Retainers    --
---------------------

function DoAR()
    if ARRetainersWaitingToBeProcessed(ar_all_characters) and do_ar then
        timeout_start = os.clock()
        if PathIsRunning() then
            repeat
                yield("/wait " .. interval_rate)
            until ((not PathIsRunning()) and IsPlayerAvailable()) or (os.clock() - timeout_start > timeout_threshold)
            yield("/wait " .. interval_rate)
            yield("/vnavmesh stop")
        end
        if not IsPlayerAvailable() then
            timeout_start = os.clock()
            repeat
                yield("/wait " .. interval_rate)
            until IsPlayerAvailable() or (os.clock() - timeout_start > timeout_threshold)
        end
        PathToMB()
        yield("/wait " .. interval_rate)
        yield("/target Summoning Bell")
        yield("/wait " .. interval_rate)
        if GetTargetName() == "Summoning Bell" and GetDistanceToTarget() <= 4.5 then
            yield("/interact")
            yield("/ays multi")
            yield("/wait " .. interval_rate)
            yield("/ays e")
            LogInfo("[LegendaryFarmer] AR Started")
            while ARRetainersWaitingToBeProcessed(ar_all_characters) do
                yield("/wait " .. interval_rate)
            end
        else
            yield("No Summoning Bell")
        end
        yield("/wait " .. interval_rate * 10)
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
            yield("/wait " .. interval_rate)
        end
        if GetTargetName() ~= "" then
            ClearTarget()
        end
        yield("/wait " .. interval_rate)
        yield("/ays multi")
    end
end

---------------------
--    GC TurnIn    --
---------------------

function DoGCTurnin()
    if do_gc_delivery then
        if PathIsRunning() then
            yield("/wait " .. interval_rate)
            yield("/vnavmesh stop")
        end
        if not IsPlayerAvailable() then
            repeat
                yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        yield("/wait " .. interval_rate)
        local gc_no = GetPlayerGC()
        local zoneid = paths_to_mb[gc_no][4]
        yield("/li gc")
        WaitForTp()
        while (not IsInZone(zoneid)) and (not GetCharacterCondition(CharacterCondition.tradeOpen)) do
            yield("/wait " .. interval_rate)
        end
        yield("/wait " .. interval_rate * 4)
        VNavMovement()
        yield("/wait " .. interval_rate * 20)
        LogInfo("[LegendaryFarmer] Reached Player's GC")
        DeliverooEnable()
        while DeliverooIsTurnInRunning() do
            yield("/wait " .. interval_rate)
        end
        yield("/echo [LegendaryFarmer] Turnins done!")
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
        yield("/wait " .. interval_rate)
    end
    yield("/wait " .. interval_rate)

    local orange_scrips_raw = GetNodeText("CollectablesShop", 39, 1):gsub(",", ""):match("^([%d,]+)/")
    local purple_scrips_raw = GetNodeText("CollectablesShop", 38, 1):gsub(",", ""):match("^([%d,]+)/")

    local orange_scrips = tonumber(orange_scrips_raw)
    local purple_scrips = tonumber(purple_scrips_raw)

    if (orange_scrips < scrip_overcap_limit) or (purple_scrips < scrip_overcap_limit) then
        for i, item in ipairs(collectible_item_table) do
            local collectible_to_turnin_row = item[1]
            local collectible_item_id = item[2]
            local job_for_turnin = item[3]
            local turnins_scrip_type = item[4]
            if GetItemCount(collectible_item_id) > 0 then
                yield("/callback CollectablesShop true 14 " .. job_for_turnin)
                yield("/wait " .. interval_rate)
                yield("/callback CollectablesShop true 12 " .. collectible_to_turnin_row)
                yield("/wait " .. interval_rate)
                scrips_owned = tonumber(GetNodeText("CollectablesShop", turnins_scrip_type, 1):gsub(",", ""):match("^([%d,]+)/"))
                while (scrips_owned <= scrip_overcap_limit) and (not IsAddonVisible("SelectYesno")) and (GetItemCount(collectible_item_id) > 0) do
                    yield("/callback CollectablesShop true 15 0")
                    yield("/wait " .. interval_rate)
                    scrips_owned = tonumber(GetNodeText("CollectablesShop", turnins_scrip_type, 1):gsub(",", ""):match("^([%d,]+)/"))
                end
                yield("/wait " .. interval_rate)
            end
            yield("/wait " .. interval_rate)
            if IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 1")
                break
            end
        end
    end
    yield("/wait " .. interval_rate)
    yield("/callback CollectablesShop true -1")

    if GetTargetName() ~= "" then
        ClearTarget()
        yield("/wait " .. interval_rate)
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
        yield("/wait " .. interval_rate)
    end
    yield("/wait " .. interval_rate)

    --EXCHANGE CATEGORY--
    for i, reward in ipairs(exchange_item_table) do
        local scrip_exchange_category = reward[1]
        local scrip_exchange_subcategory = reward[2]
        local scrip_exchange_item_to_buy_row = reward[3]
        local collectible_scrip_price = reward[4]
        yield("/wait " .. interval_rate)
        yield("/callback InclusionShop true 12 " .. scrip_exchange_category)
        yield("/wait " .. interval_rate)
        yield("/callback InclusionShop true 13 " .. scrip_exchange_subcategory)
        yield("/wait " .. interval_rate)

        --EXCHANGE PURCHASE--
        scrips_owned_str = GetNodeText("InclusionShop", 21):gsub(",", "")
        scrips_owned = tonumber(scrips_owned_str)
        if scrips_owned >= min_scrip_for_exchange then
            scrip_shop_item_row = scrip_exchange_item_to_buy_row + 21
            scrip_item_number_to_buy = scrips_owned // collectible_scrip_price
            local scrip_item_number_to_buy_final = math.min(scrip_item_number_to_buy, 99)
            yield("/callback InclusionShop true 14 " .. scrip_exchange_item_to_buy_row .. " " .. scrip_item_number_to_buy_final)
            yield("/wait " .. interval_rate * 5)
            if IsAddonVisible("ShopExchangeItemDialog") then
                yield("/callback ShopExchangeItemDialog true 0")
                yield("/wait " .. interval_rate)
            end
        end
    end

    --EXCHANGE CLOSE--
    yield("/wait " .. interval_rate)
    yield("/callback InclusionShop true -1")

    if GetTargetName() ~= "" then
        ClearTarget()
        yield("/wait " .. interval_rate)
    end
end

------------------
--    TurnIn    --
------------------

function CanTurnin()
    local flag = false
    for i, item in ipairs(collectible_item_table) do
        local collectible_item_id = item[2]
        if GetItemCount(collectible_item_id) >= min_items_before_turnins then
            flag = true
        end
    end
    return flag
end

function CollectableAppraiserScripExchange()
    if IsPlayerAvailable() and do_scrips then
        PathToScrip()
        yield("/wait " .. interval_rate)
        while CanTurnin() do
            CollectableAppraiser()
            yield("/wait " .. interval_rate)
            ScripExchange()
            yield("/wait " .. interval_rate)
        end
        yield("/wait " .. interval_rate)
        ScripExchange()
    end
end

----------------
--    Main    --
----------------

function Main()
    i_count = tonumber(GetInventoryFreeSlotCount())
    while (not (i_count < inventory_threshold)) and (not CanExtractMateria(100)) do
        yield("/wait " .. interval_rate * 30)
        i_count = tonumber(GetInventoryFreeSlotCount())
        yield("/echo [LegendaryFarmer] Gathering...")
        yield("/echo [LegendaryFarmer] Slots Remaining: " .. i_count)

        if do_ar and (ARRetainersWaitingToBeProcessed(ar_all_characters)) then
            break
            yield("/echo [LegendaryFarmer] Stopping to Process Retainers...")
        end
    end

    if (GetCharacterCondition(CharacterCondition.gathering) or GetCharacterCondition(CharacterCondition.gathering_2)) then
        yield("/wait " .. interval_rate * 2)
    end

    yield("/echo [LegendaryFarmer] Disabling GBR to process additional enabled tasks")
    yield("/echo [LegendaryFarmer] Food/Potion Check, Extract/Repair, Reduce/Scrips and Retainers/GC Turnins")
    GBRAutodisable()
    yield("/wait " .. interval_rate * 8)
    CrystalCheck()

    --On site tasks
    yield("/wait " .. interval_rate)
    Dismount()
    yield("/wait " .. interval_rate)
    RepairExtractReduceCheck()
    yield("/wait " .. interval_rate)
    UseMedicine()
    yield("/wait " .. interval_rate)
    EatFood()
    yield("/wait " .. interval_rate)

    i_count = tonumber(GetInventoryFreeSlotCount())
    if i_count < inventory_threshold then
        yield("/echo [LegendaryFarmer] Moving to do Collectable Appraiser and Scrip Exchnage")
        CollectableAppraiserScripExchange()
    end
    yield("/wait " .. interval_rate * 2)

    if (ARRetainersWaitingToBeProcessed(ar_all_characters) and do_ar) then
        yield("/echo [LegendaryFarmer] AR required")
        DoAR()
        yield("/wait " .. interval_rate * 2)
        if do_gc_delivery then
            yield("/echo [LegendaryFarmer] GCTurins required")
            yield("/wait " .. interval_rate * 2)
            DoGCTurnin()
            yield("/wait " .. interval_rate * 5)
        end
    end
    yield("/wait " .. interval_rate * 2)
    yield("/echo [LegendaryFarmer] Reanable GBR Auto and start gathering again!")
    if use_gbr then
        GBRAutoenable()
    end
end

-------------------------------- Execution --------------------------------

Warning()
i_count = tonumber(GetInventoryFreeSlotCount())
GBRAutodisable()
yield("/wait " .. interval_rate)
Dismount()
yield("/wait " .. interval_rate)
yield("/echo [LegendaryFarmer] Starting GBR-Legendary Farmer for Gathering & Support Tasks")
yield("/wait " .. interval_rate)
CrystalCheck()
RepairExtractReduceCheck()
yield("/wait " .. interval_rate)
UseMedicine()
yield("/wait " .. interval_rate)
EatFood()
yield("/wait " .. interval_rate)

i_count = tonumber(GetInventoryFreeSlotCount())
if (i_count < inventory_threshold) and CanTurnin() then
    yield("/echo [LegendaryFarmer] Moving to do Collectable Appraiser and Scrip Exchange")
    CollectableAppraiserScripExchange()
    yield("/wait " .. interval_rate * 3)
end

if use_gbr then
    GBRAutoenable()
end

setSNDPropertyIfNotSet("UseSNDTargeting")
unsetSNDPropertyIfSet("StopMacroIfTargetNotFound")
while not stop_main do
    i_count = tonumber(GetInventoryFreeSlotCount())
    yield("/echo [LegendaryFarmer] Going into Gathering Mode")
    yield("/wait " .. interval_rate)
    Main()
    loop = loop + 1
    yield("/echo [LegendaryFarmer] cycle count " .. loop)
    yield("/wait " .. interval_rate)
end

----------------------------------- End -----------------------------------