--[[

***********************************************
*             Triple Triad Seller             *
*  Sells your acumulated Triple Triad cards!  *
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

Max_Distance = 100

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

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [TT Seller] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [TT Seller] Stopping the script..!!")
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

function TargetedInteract(target)
    yield("/target "..target.."")
    repeat
        yield("/wait 0.1")
    until GetDistanceToTarget() < 7
    yield("/interact")
    repeat
        yield("/wait 0.1")
    until IsAddonReady("SelectIconString")
end

function TripleSeller()
    yield("/callback SelectIconString false 1")
    repeat
        yield("/wait 0.1")
    until IsAddonReady("TripleTriadCoinExchange")
    while not IsNodeVisible("TripleTriadCoinExchange",{1,11}) do
        nodenumber = GetNodeText("TripleTriadCoinExchange",3 ,1 ,5)
        a = tonumber(nodenumber)
        repeat
            yield("/wait 0.1")
        until IsNodeVisible("TripleTriadCoinExchange",{1,10,5})
        yield("/callback TripleTriadCoinExchange true 0")
        repeat
            yield("/wait 0.1")
        until IsAddonReady("ShopCardDialog")
        yield(string.format("/callback ShopCardDialog true 0 %d", a))
        yield("/wait 1")
    end
    yield("/callback TripleTriadCoinExchange true -1")
end

-------------------------------- Execution --------------------------------

Plugins()
if IsInZone(144) then
    DistanceToSeller()
    if Distance_Test > 0 and Distance_Test < Max_Distance then
        WalkTo(-55,1,16)
        TargetedInteract("Triple Triad Trader")
        TripleSeller()
    else
        yield("/tp The Gold Saucer")
        WaitForTp()
        WalkTo(-55,1,16)
        TargetedInteract("Triple Triad Trader")
        TripleSeller()
    end
else
    yield("/tp The Gold Saucer")
    WaitForTp()
    WalkTo(-55,1,16)
    TargetedInteract("Triple Triad Trader")
    TripleSeller()
end

----------------------------------- End -----------------------------------