--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Mini Cactpot - Script for Daily Mini Cactpot
plugin_dependencies:
- Saucy
- vnavmesh
- Lifestream
- TeleporterPlugin
- TextAdvance
dependencies:
- source: https://raw.githubusercontent.com/Mbarmem/SnD/refs/heads/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

Aetheryte  = { X = -1, Y = 3, Z = -1 }
Npc        = { name = "Mini Cactpot Broker", position = { X = -50, Y = 1, Z = 22 } }
EchoPrefix = "[Mini Cactpot]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterStates = {}

local StopFlag = false
local State    = nil

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function CharacterStates.ready()
    if not IsInZone(144) then
        Teleport("Gold Saucer")
    else
        State = CharacterStates.goToCashier
    end
end

function CharacterStates.goToCashier()
    if GetDistanceToPoint(Aetheryte.X, Aetheryte.Y, Aetheryte.Z) <= 8 and PathIsRunning() then
        yield("/gaction jump")  -- Prevents stuck pathing near aetheryte
        Wait(3)
        return
    end

    if GetDistanceToPoint(Npc.position.X, Npc.position.Y, Npc.position.Z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            MoveTo(Npc.position.X, Npc.position.Y, Npc.position.Z, false, 5)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
    end

    State = CharacterStates.playMiniCactpot
end

local TicketsPurchased = false

function CharacterStates.playMiniCactpot()
    if IsAddonReady("LotteryDaily") then
        Wait(1)
    elseif IsAddonReady("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonReady("Talk") then
        yield("/click Talk Click")
    elseif IsAddonReady("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif GetDistanceToPoint(Npc.position.X, Npc.position.Y, Npc.position.Z) > 5 then
        MoveTo(Npc.position.X, Npc.position.Y, Npc.position.Z, false, 5)
    elseif PathfindInProgress() or PathIsRunning() then
        PathStop()
    elseif TicketsPurchased and IsPlayerAvailable() then
        State = CharacterStates.endState
    elseif GetTargetName() ~= Npc.name then
        Target(Npc.name)
    else
        Interact(Npc.name)
        TicketsPurchased = true
    end
end

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

LogInfo(string.format("%s Mini Cactpot script completed successfully!", EchoPrefix))

----------------------------------- End -----------------------------------