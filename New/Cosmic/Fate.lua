--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Auto Fate
plugin_dependencies:
- vnavmesh
dependencies:
- source: ''
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LogPrefix  = "[CosmicFate]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterStates = {}

--=========================== FUNCTIONS ==========================--

function CharacterStates.Start()
    MoveToTarget("Mini Rover")
    Interact("Mini Rover")
    WaitForPlayer()
    State = "Charge"
    LogInfo(string.format("%s State changed to: Charge", LogPrefix))
end

function CharacterStates.Charge()
    MoveToTarget("Charging Module")
    Interact("Charging Module")
    WaitForPlayer()
    State = "End"
    LogInfo(string.format("%s State changed to: End", LogPrefix))
end

function CharacterStates.End()
    MoveToTarget("Depleted Mini Rover")
    Interact("Depleted Mini Rover")
    WaitForPlayer()
    State = "Start"
    LogInfo(string.format("%s State changed to: Start", LogPrefix))
end

--=========================== EXECUTION ==========================--

State = CharacterStates.Start

while State do
    State()
end

--============================== END =============================--