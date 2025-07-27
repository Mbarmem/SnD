--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Jumbo Cactpot - A barebones script for weeklies
plugin_dependencies:
- Lifestream
- vnavmesh
- TextAdvance
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LogPrefix = "[JumboCactpot]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

local RewardClaimed = false
local TicketsPurchased = false
local StopFlag = false

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function CharacterState.startJumboCactpot()
    WaitForPlayer()
    LogInfo(string.format("%s Teleporting to Gold Saucer...", LogPrefix))
    Teleport("Gold Saucer")

    MoveToTarget("Aetheryte", 6)
    Teleport("Cactpot Board")

    MoveToTarget("Cactpot Cashier", 5)
    Wait(1)

    State = CharacterState.claimPrize
    LogInfo(string.format("%s State changed to: ClaimPrize", LogPrefix))
end

function CharacterState.claimPrize()
    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/callback LotteryWeeklyRewardList true -1")

    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")

    elseif RewardClaimed and not IsOccupiedInQuestEvent() then
        State = CharacterState.purchaseNewTickets
        LogInfo(string.format("%s State changed to: PurchaseNewTickets", LogPrefix))

    else
        Interact("Cactpot Cashier")
        LogInfo(string.format("%s Interacting with Cactpot Cashier to claim prize...", LogPrefix))
        RewardClaimed = true
        Wait(1)
    end
end

function CharacterState.purchaseNewTickets()
    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/callback LotteryWeeklyRewardList true -1")
        State = CharacterState.endJumboCactpot
        LogInfo(string.format("%s State changed to: EndJumboCactpot", LogPrefix))

    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")

    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")

    elseif IsAddonVisible("LotteryWeeklyInput") then
        Wait(1)
        local number = math.random(9999)
        yield(string.format("/callback LotteryWeeklyInput true %d", number))

    elseif TicketsPurchased and not IsOccupiedInQuestEvent() then
        State = CharacterState.endJumboCactpot
        LogInfo(string.format("%s State changed to: EndJumboCactpot", LogPrefix))

    elseif GetTargetName() ~= "Jumbo Cactpot Broker" or GetDistanceToTarget() > 7 then
        MoveToTarget("Jumbo Cactpot Broker", 4)

    else
        Interact("Jumbo Cactpot Broker")
        TicketsPurchased = true
        Wait(1)
    end
end

function CharacterState.endJumboCactpot()
    CloseAddons()
    StopFlag = true
end

--=========================== EXECUTION ==========================--

yield("/at y")
State = CharacterState.startJumboCactpot
LogInfo(string.format("%s State changed to: StartJumboCactpot", LogPrefix))

while not StopFlag do
    if State then
        State()
    end
    Wait(1)
end

Echo(string.format("Jumbo Cactpot script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Jumbo Cactpot script completed successfully..!!", LogPrefix))

--============================== END =============================--