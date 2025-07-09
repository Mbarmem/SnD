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

--=========================== FUNCTIONS ==========================--

local state = "start"
function Fate()
    if state == "end" then
        MoveToTarget("Depleted Mini Rover")
        Interact("Depleted Mini Rover")
        WaitForPlayer()
        state = "start"
    elseif state == "charge" then
        MoveToTarget("Charging Module")
        Interact("Charging Module")
        WaitForPlayer()
        state = "end"
    elseif state == "start" then
        MoveToTarget("Mini Rover")
        Interact("Mini Rover")
        WaitForPlayer()
        state = "charge"
    end
end

--=========================== EXECUTION ==========================--

while state do
    Fate()
end

--============================== END =============================--