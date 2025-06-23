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

--------------------
--    Genereal    --
--------------------

interval_rate = 1
timeout_threshold = 10
min_items_before_turnins = 1
craftingList = 14291
crafting_item_id = 36626
RepairAmount = 20
ReasignRetainers = true
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

do_scrips = true
scrip_overcap_limit = 3900
min_scrip_for_exchange = 2500

-- collectible_to_turnin_row, item_id, job_for_turnin, turnin_scrip_type
collectible_item_table =
{
    -- CUL
    -- purple scrips -- 38 for purple scrips
    { 6, 36626, 7, 38 }  -- Rarefied Sykon Bavarois
}

-- scrip_exchange_category,scrip_exchange_subcategory,scrip_exchange_item_to_buy_row, collectible_scrip_price
exchange_item_table = {
    { 2, 1, 2, 250 }  -- Craftman's Commanding Materia XI
}

--------------------------------- Constant --------------------------------

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    casting=27,
    occupied=39,
    betweenAreas=45,
    occupiedSummoningBell=50
}

---------------------
--    Plugins    --
---------------------

RequiredPlugins = {
    "Artisan",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "YesAlready",
    "PandorasBox"
}

if ReasignRetainers then
    table.insert(RequiredPlugins, "AutoRetainer")
end

-------------------------------- Functions --------------------------------

--------------------
--    Warnings    --
--------------------

function Warning()
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

----------------
--    Wait    --
----------------

function PlayerTest()
    repeat
        yield("/wait "..interval_rate)
    until IsPlayerAvailable()
end

function WaitForLifeStream()
    repeat
        yield("/wait "..interval_rate)
    until not LifestreamIsBusy()
    PlayerTest()
end

function WaitForTp()
    yield("/wait "..interval_rate)
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait "..interval_rate)
    end
    yield("/wait "..interval_rate)
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait "..interval_rate)
    end
    PlayerTest()
    yield("/wait "..interval_rate)
end

function WaitForAR()
    if ARRetainersWaitingToBeProcessed() and ReasignRetainers then
        yield("/echo [Artisan] Waiting for AutoRetainers to complete")
        yield("/wait "..interval_rate)
        while GetCharacterCondition(CharacterCondition.occupiedSummoningBell) do
            PlayerTest()
        end
    end
    yield("/wait "..interval_rate)
end

function WaitForArtisan()
    while IsNotCrafting() and GetItemCount(crafting_item_id) < 1 do
        repeat
            yield("/wait "..interval_rate)
        until IsCrafting()
    end
    yield("/echo [Artisan] Ready for crafting")
    PlayerTest()
    yield("/wait "..interval_rate)
end

----------------
--    Move    --
----------------

function MeshCheck()
    local function Truncate1Dp(num)
        return truncate and ("%.1f"):format(num) or num
    end
    local was_ready = NavIsReady()
    if not NavIsReady() then
        while not NavIsReady() do
            LogInfo("[Debug]Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() - 100) .. "%")
            yield("/wait "..interval_rate)
            local was_ready = NavIsReady()
            if was_ready then
                LogInfo("[Debug] Navmesh ready!")
            end
        end
    else
    LogInfo("[Debug]Navmesh ready!")
    end
end

function WalkTo(valuex, valuey, valuez, stopdistance)
    MeshCheck()
    PathfindAndMoveTo(valuex, valuey, valuez, false)
    while ((PathIsRunning() or PathfindInProgress()) and GetDistanceToPoint(valuex, valuey, valuez) > stopdistance) do
        yield("/wait "..interval_rate)
    end
    PathStop()
    LogInfo("[WalkTo] Completed")
end

function MoveToInn()
    local WhereAmI = GetZoneID()
    if (WhereAmI ~= 177) and (WhereAmI ~= 178) and (WhereAmI ~= 179) then
        yield("/li Inn")
        yield("/echo [Artisan] Moving to Inn")
        WaitForLifeStream()
    end
end

function MoveToSNine()
    local WhereAmI = GetZoneID()
    if not (WhereAmI == 1186) then
        yield("/tp Solution Nine")
        yield("/echo [Artisan] Moving to Collectable Appraiser")
        WaitForTp()
        yield("/li Nexus Arcade")
        WaitForTp()
        WalkTo(-158.019,0.922,-37.884,1)
        PlayerTest()
    end
end

----------------
--    Misc    --
----------------

function Repair()
    if NeedsRepair(RepairAmount) then
        yield("/echo [Artisan] Repairing Gear")
        while not IsAddonVisible("Repair") do
            yield("/generalaction repair")
            yield("/wait "..interval_rate)
        end
        yield("/callback Repair true 0")
        yield("/wait "..interval_rate)
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            yield("/wait "..interval_rate)
        end
        while GetCharacterCondition(CharacterCondition.occupied) do
            yield("/wait "..interval_rate)
        end
        yield("/wait "..interval_rate)
        yield("/callback Repair true -1")
    end
    PlayerTest()
    yield("/wait "..interval_rate)
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
                yield("/pcall Materialize true 2")
                yield("/wait "..interval_rate)
                if IsAddonVisible("MaterializeDialog") then
                    yield("/pcall MaterializeDialog true 0")
                    yield("/wait "..interval_rate)
                end
                while GetCharacterCondition(CharacterCondition.occupied) do
                    yield("/wait "..interval_rate)
                end
            end
            yield("/wait "..interval_rate)
            yield("/pcall Materialize true -1")
            yield("/wait "..interval_rate)
        end
    end
    PlayerTest()
    yield("/wait "..interval_rate)
end

function GetOUT()
    repeat
        yield("/wait "..interval_rate)
        if IsAddonVisible("SelectIconString") then
            yield("/pcall SelectIconString true -1")
        end
        if IsAddonVisible("SelectString") then
            yield("/pcall SelectString true -1")
        end
        if IsAddonVisible("ShopExchangeItem") then
            yield("/pcall ShopExchangeItem true -1")
        end
        if IsAddonVisible("RetainerList") then
            yield("/pcall RetainerList true -1")
        end
        if IsAddonVisible("InventoryRetainer") then
            yield("/pcall InventoryRetainer true -1")
        end
    until IsPlayerAvailable()
end

function CleanCollectables()
    if GetItemCount(crafting_item_id) >= min_items_before_turnins then
        MoveToSNine()
        CollectableAppraiserScripExchange()
    end
end

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

---------------------
--    Retainers    --
---------------------

function DoAR()
    if ARRetainersWaitingToBeProcessed() and ReasignRetainers then
        yield("/echo [Artisan] Processing Retainers")
        yield("/target Summoning Bell")
        yield("/wait "..interval_rate)
        if GetTargetName() == "Summoning Bell" and GetDistanceToTarget() <= 4.5 then
            yield("/interact")
            while ARRetainersWaitingToBeProcessed() do
                yield("/wait "..interval_rate)
            end
            GetOUT()
        else
            yield("No Summoning Bell")
        end
    end
    if GetTargetName() ~= "" then
        ClearTarget()
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
        yield("/wait "..interval_rate)
    end
    yield("/wait "..interval_rate)

    local orange_scrips_raw = GetNodeText("CollectablesShop", 39, 1):gsub(",", ""):match("^([%d,]+)/")
    local purple_scrips_raw = GetNodeText("CollectablesShop", 38, 1):gsub(",", ""):match("^([%d,]+)/")

    local orange_scrips = tonumber(orange_scrips_raw)
    local purple_scrips = tonumber(purple_scrips_raw)

    if (orange_scrips < scrip_overcap_limit) and (purple_scrips < scrip_overcap_limit) then
        for i, item in ipairs(collectible_item_table) do
            local collectible_to_turnin_row = item[1]
            local collectible_item_id = item[2]
            local job_for_turnin = item[3]
            local turnins_scrip_type = item[4]
            if GetItemCount(collectible_item_id) > 0 then
                yield("/callback CollectablesShop true 14 " .. job_for_turnin)
                yield("/wait "..interval_rate)
                yield("/callback CollectablesShop true 12 " .. collectible_to_turnin_row)
                yield("/wait "..interval_rate)
                scrips_owned = tonumber(GetNodeText("CollectablesShop", turnins_scrip_type, 1):gsub(",", ""):match("^([%d,]+)/"))
                while (scrips_owned <= scrip_overcap_limit) and (not IsAddonVisible("SelectYesno")) and (GetItemCount(collectible_item_id) > 0) do
                    yield("/callback CollectablesShop true 15 0")
                    yield("/wait "..interval_rate)
                    scrips_owned = tonumber(GetNodeText("CollectablesShop", turnins_scrip_type, 1):gsub(",", ""):match("^([%d,]+)/"))
                end
                yield("/wait "..interval_rate)
            end
            yield("/wait "..interval_rate)
            if IsAddonVisible("Selectyesno") then
                yield("/callback Selectyesno true 1")
                break
            end
        end
    end
    yield("/wait "..interval_rate)
    yield("/callback CollectablesShop true -1")

    if GetTargetName() ~= "" then
        ClearTarget()
        yield("/wait "..interval_rate)
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
        yield("/wait "..interval_rate)
    end
    yield("/wait "..interval_rate)

    --EXCHANGE CATEGORY--
    for i, reward in ipairs(exchange_item_table) do
        local scrip_exchange_category = reward[1]
        local scrip_exchange_subcategory = reward[2]
        local scrip_exchange_item_to_buy_row = reward[3]
        local collectible_scrip_price = reward[4]
        yield("/wait "..interval_rate)
        yield("/callback InclusionShop true 12 " .. scrip_exchange_category)
        yield("/wait "..interval_rate)
        yield("/callback InclusionShop true 13 " .. scrip_exchange_subcategory)
        yield("/wait "..interval_rate)

    --EXCHANGE PURCHASE--
        scrips_owned_str = GetNodeText("InclusionShop", 21):gsub(",", "")
        scrips_owned = tonumber(scrips_owned_str)
        if scrips_owned >= min_scrip_for_exchange then
            scrip_shop_item_row = scrip_exchange_item_to_buy_row + 21
            scrip_item_number_to_buy = scrips_owned // collectible_scrip_price
            local scrip_item_number_to_buy_final = math.min(scrip_item_number_to_buy,99)
            yield("/callback InclusionShop true 14 " .. scrip_exchange_item_to_buy_row .. " " .. scrip_item_number_to_buy_final)
            yield("/wait "..interval_rate * 5)
            if IsAddonVisible("ShopExchangeItemDialog") then
                yield("/callback ShopExchangeItemDialog true 0")
                yield("/wait "..interval_rate)
            end
        end
    end

    --EXCHANGE CLOSE--
    yield("/wait "..interval_rate)
    yield("/callback InclusionShop true -1")

    if GetTargetName() ~= "" then
        ClearTarget()
        yield("/wait "..interval_rate)
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
        while CanTurnin() do
            CollectableAppraiser()
            yield("/wait "..interval_rate)
            ScripExchange()
            yield("/wait "..interval_rate)
        end
    else yield("/wait "..interval_rate)
        ScripExchange()
    end
end

-------------------------------- Execution --------------------------------

Warning()
Loop()
while LoopAmount == true or loop <= LoopAmount do
    yield("[Artisan] Loop Count: " .. loop)
    CleanCollectables()
    MoveToInn()
    DoAR()
    WaitForAR()
    yield("/artisan lists "..craftingList.." start")
    WaitForArtisan()
    Repair()
    ExtractMateria()
    MoveToSNine()
    CollectableAppraiserScripExchange()
    LoopCount()
end

----------------------------------- End -----------------------------------