--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Auto Fate
plugin_dependencies:
- vnavmesh
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

State = "Start"

--=========================== FUNCTIONS ==========================--

function Fate()
    if State == "End" then
        MoveToTarget("Depleted Mini Rover")
        Interact("Depleted Mini Rover")
        WaitForPlayer()
        State = "Start"
    elseif State == "Charge" then
        MoveToTarget("Charging Module")
        Interact("Charging Module")
        WaitForPlayer()
        State = "End"
    elseif state == "Start" then
        MoveToTarget("Mini Rover")
        Interact("Mini Rover")
        WaitForPlayer()
        State = "Charge"
    end
end

--=========================== EXECUTION ==========================--

while State do
    Fate()
end

--============================== END =============================--