--[[

******************************************
*             Jumbo Cactpot              *
*           A barebones script.          *
******************************************

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
    -> Lifestream : https://github.com/NightmareXIV/Lifestream/blob/main/Lifestream/Lifestream.json
    -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat
    -> TextAdvance
    -> Vnavmesh

]]

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "TextAdvance"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    casting=27,
    occupiedInQuestEvent=32,
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
            yield("/echo [JumboCactpot] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [JumboCactpot] Stopping the script..!!")
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
end

----------------
--    Move    --
----------------

function Teleport(aetheryteName)
    yield("/tp "..aetheryteName)
    WaitForTp()
end

function Target(destination)
    attemptsCount = 0
    yield("/target "..destination)
    yield("/wait 0.5")
    while GetTargetName():lower() ~= destination:lower() do
        yield("/target "..destination)
        attemptsCount = attemptsCount + 1
        if attemptsCount > 5 then
            yield("/e Unable to Target "..destination.." Stopping")
            return
        end
        yield("/wait 0.5")
    end
end

function PathFinding()
    yield("/wait 0.2")
    while PathfindInProgress() do
        yield("/wait 0.5")
    end
end

function moveToTarget(minDistanceOverride)
    minDistance = minDistanceOverride or 7
    targetX = GetTargetRawXPos()
    targetY = GetTargetRawYPos()
    targetZ = GetTargetRawZPos()
    PathfindAndMoveTo(targetX, targetY, targetZ, false)
    PathFinding()
    while GetDistanceToPoint(targetX, targetY, targetZ) > minDistance do
        yield("/wait 0.1")
    end
    PathStop()
end

----------------
--    Misc    --
----------------

function GetOUT()
    repeat
        yield("/wait 1")
        if IsAddonVisible("SelectIconString") then
            yield("/callback SelectIconString true -1")
        end
        if IsAddonVisible("SelectString") then
            yield("/callback SelectString true -1")
        end
    until IsPlayerAvailable()
end

----------------
--    Main    --
----------------

function Start()
    PlayerTest()
    Teleport("Gold Saucer")
    WaitForTp()
    Target("Aetheryte")
    moveToTarget()
    yield("/li Cactpot Board")
    WaitForTp()
end

function MoveToPrizeClaim()
    Target("Cactpot Cashier")
    moveToTarget()
    yield("/wait 1")
end

RewardClaimed = false
purchaseNewTickets = false
function ClaimPrize()
    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/callback LotteryWeeklyRewardList true -1")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif RewardClaimed and not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        purchaseNewTickets = true
    elseif HasTarget() then
        yield("/interact")
        yield("/echo [JumboCactpot] Claiming Prize..!!")
        RewardClaimed = true
        yield("/wait 1")
    end
end

function MoveToPurchaseNewTickets()
    Target("Jumbo Cactpot Broker")
    moveToTarget()
    yield("/wait 1")
end

TicketsPurchased = false
endState = false
function PurchaseNewTickets()
    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/echo [JumboCactpot] You have already purchased tickets this week!")
        yield("/callback LotteryWeeklyRewardList true -1")
        endState = true
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("LotteryWeeklyInput") then
        yield("/wait 1")
        yield("/callback LotteryWeeklyInput true "..math.random(9999))
    elseif TicketsPurchased and not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        yield("/echo [JumboCactpot] Purchased New Tickets..!!")
        endState = true
    elseif not HasTarget() or GetTargetName() ~= "Jumbo Cactpot Broker" or GetDistanceToTarget() > 7 then
        PathfindAndMoveTo(120.26, 13.00, -10.9)
    elseif GetDistanceToTarget() <= 7 then
        yield("/interact")
        TicketsPurchased = true
        yield("/wait 1")
    end
end

function End()
    GetOUT()
    yield("/echo [JumboCactpot] Script Ended..!!")
    StopFlag = true
end

-------------------------------- Execution --------------------------------

StopFlag = false
yield("/at y")
Plugins()
Start()
MoveToPrizeClaim()
while not endState do
    repeat
        ClaimPrize()
    until purchaseNewTickets
    MoveToPurchaseNewTickets()
    repeat
        PurchaseNewTickets()
    until endState
end
End()

----------------------------------- End -----------------------------------