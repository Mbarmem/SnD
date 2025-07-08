--[[

***********************************************
*                Mini Cactpot                 *
*        Script for Daily Mini Cactpot        *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  2.0.0  *
            **********************

]]

---------------------------------- Import ---------------------------------

require("MoLib")

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

local Npc = {
    name     = "Mini Cactpot Broker",
    position = Vector3(-50, 1, 22)
}

local Aetheryte   = Vector3(-1, 3, -1)
local EchoPrefix  = "[Mini Cactpot] "

--------------------------------- Constants -------------------------------

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    casting       = 27,
    occupied      = 32,
    betweenAreas  = 45
}

----------------------------
--    State Management    --
----------------------------

CharacterStates = {}

local StopFlag = false
local State    = nil

-------------------------------- Functions --------------------------------

----------------
--    Main    --
----------------

--- Checks if player is in Gold Saucer. If not, teleports there.
function CharacterStates.ready()
    if not IsInZone(144) then
        Teleport("Gold Saucer")
    else
        State = CharacterStates.goToCashier
    end
end

--- Navigates to the Mini Cactpot Broker.
function CharacterStates.goToCashier()
    if GetDistanceToPoint(Aetheryte) <= 8 and IPC.vnavmesh.IsRunning() then
        yield("/gaction jump")  -- Prevents stuck pathing near aetheryte
        Wait(3)
        return
    end

    if GetDistanceToPoint(Npc.position) > 5 then
        if not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
            IPC.vnavmesh.PathfindAndMoveTo(Npc.position, false)
        end
        return
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    end

    State = CharacterStates.playMiniCactpot
end

local TicketsPurchased = false

--- Handles Mini Cactpot purchase and interaction flow.
function CharacterStates.playMiniCactpot()
    if IsAddonReady("LotteryDaily") then
        Wait(1)
    elseif IsAddonReady("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonReady("Talk") then
        yield("/click Talk Click")
    elseif IsAddonReady("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif GetDistanceToPoint(Npc.position) > 5 then
        IPC.vnavmesh.PathfindAndMoveTo(Npc.position)
    elseif IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    elseif TicketsPurchased and not GetCharacterCondition(CharacterCondition.occupied) then
        State = CharacterStates.endState
    elseif not Entity or not Entity.Target or Entity.Target.Name ~= Npc.name then
        Target(Npc.name)
    else
        yield("/interact")
        TicketsPurchased = true
    end
end

--- Closes any open dialogue window and ends script.
function CharacterStates.endState()
    if IsAddonReady("SelectString") then
        yield("/callback SelectString true -1")
    else
        StopFlag = true
    end
end

------------------------------- Execution ----------------------------------

State = CharacterStates.ready
yield("/at y")

while not StopFlag do
    State()
    Wait(0.1)
end

Echo("Mini Cactpot script completed successfully!", EchoPrefix)

----------------------------------- End -----------------------------------