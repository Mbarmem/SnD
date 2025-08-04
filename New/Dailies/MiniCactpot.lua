--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Mini Cactpot - Script for Daily Mini Cactpot
plugin_dependencies:
- Lifestream
- Saucy
- TextAdvance
- vnavmesh
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

Aetheryte  = { X = -1, Y = 3, Z = -1 }
Npc        = { Name = "Mini Cactpot Broker", Position = { X = -50, Y = 1, Z = 22 } }
LogPrefix  = "[MiniCactpot]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

local StopFlag  = false
local State     = nil
local Tickets   = false

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function CharacterState.ready()
    if not IsInZone(144) then
        Teleport("Gold Saucer")
    else
        State = CharacterState.goToCashier
        LogInfo(string.format("%s State changed to: GoToCashier", LogPrefix))
    end
end

function CharacterState.goToCashier()
    if GetDistanceToPoint(Aetheryte.X, Aetheryte.Y, Aetheryte.Z) <= 8 and PathIsRunning() then
        ExecuteGeneralAction(CharacterAction.GeneralActions.jump)  -- Prevents stuck pathing near aetheryte
        Wait(3)
        return
    end

    if GetDistanceToPoint(Npc.Position.X, Npc.Position.Y, Npc.Position.Z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z, 5)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
    end

    State = CharacterState.playMiniCactpot
    LogInfo(string.format("%s State changed to: PlayMiniCactpot", LogPrefix))
end

function CharacterState.playMiniCactpot()
    if IsAddonReady("LotteryDaily") then
        Wait(1)

    elseif IsAddonReady("SelectIconString") then
        yield("/callback SelectIconString true 0")

    elseif IsAddonReady("Talk") then
        yield("/click Talk Click")

    elseif IsAddonReady("SelectYesno") then
        yield("/callback SelectYesno true 0")

    elseif GetDistanceToPoint(Npc.Position.X, Npc.Position.Y, Npc.Position.Z) > 5 then
        MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z, 5)

    elseif PathfindInProgress() or PathIsRunning() then
        PathStop()

    elseif Tickets and IsPlayerAvailable() then
        State = CharacterState.endState
        LogInfo(string.format("%s State changed to: EndState", LogPrefix))

    else
        Interact(Npc.Name)
        Tickets = true
    end
end

function CharacterState.endState()
    CloseAddons()
    StopFlag = true
end

--=========================== EXECUTION ==========================--

yield("/at y")
State = CharacterState.ready
LogInfo(string.format("%s State changed to: Ready", LogPrefix))

while not StopFlag do
    State()
    Wait(1)
end

Echo(string.format("Mini Cactpot script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Mini Cactpot script completed successfully..!!", LogPrefix))

--============================== END =============================--