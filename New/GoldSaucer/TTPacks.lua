--[[

***********************************************
*           TT Packs Buying Script            *
*    Buy Triple Triad Packs and opens them    *
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
    -> Teleporter
    -> vnavmesh : https://puni.sh/api/repository/veyn
    -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat

]]

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

PackToBuy = "Dream Triad Card" -- Bronze, Silver, Gold, Mythril, Imperial, Dream
Max_Distance = 100 -- this is max distance to Triple Triad Seller
CardsToLookFor = {
    27972
}

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh"
}

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
--    Packs    --
-----------------

TTPacks = {
    {
        packName = "Bronze Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 36,
        packId = 10128
    },
    {
        packName = "Silver Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 37,
        packId = 10129
    },
    {
        packName = "Gold Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 38,
        packId = 10130
    },
    {
        packName = "Mythril Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 39,
        packId = 13380
    },
    {
        packName = "Imperial Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 40,
        packId = 17702
    },
    {
        packName = "Dream Triad Card",
        categoryMenu = 1,
        subcategoryMenu = 41,
        packId = 28652
    }
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [TT Packs] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [TT Packs] Stopping the script..!!")
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

function WalkTo(x, y, z)
    PathfindAndMoveTo(x, y, z, false)
    while (PathIsRunning() or PathfindInProgress()) do
        yield("/wait 0.5")
    end
end

----------------
--    Misc    --
----------------

function DistanceToSeller()
    if IsInZone(144) then -- The Gold Saucer
        Distance_Test = GetDistanceToPoint(-55,1,16)
    end
end

function Main()
    for _, packs in ipairs(TTPacks) do
        if packs.packName == PackToBuy then
            SelectedPackToBuy = packs
        end
    end
    if GetItemCount(SelectedPackToBuy.packId) > 0 then
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
        else
            yield("/item "..SelectedPackToBuy.packName)
            for i, card in ipairs(CardsToLookFor) do
                if GetItemCount(card) > 0 then
                    table.remove(CardsToLookFor, i)
                end
            end
            if #CardsToLookFor == 0 then
                Stop = true
            end
        end
        return
    end

    if not HasTarget() or GetTargetName() ~= "Triple Triad Trader" then
        yield("/target Triple Triad Trader")
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("ShopExchangeCurrency") then
        yield("/callback ShopExchangeCurrency true 0 "..SelectedPackToBuy.subcategoryMenu.." 10")
        return
    end

    yield("/interact")
end

-------------------------------- Execution --------------------------------

if IsInZone(144) then
    DistanceToSeller()
    if Distance_Test > 0 and Distance_Test < Max_Distance then
        WalkTo(-55,1,16)
    else
        yield("/tp The Gold Saucer")
        WaitForTp()
        WalkTo(-55,1,16)
    end
else
    yield("/tp The Gold Saucer")
    WaitForTp()
    WalkTo(-55,1,16)
end

Stop = false
while not Stop do
    Main()
    yield("/wait 0.5")
end

----------------------------------- End -----------------------------------