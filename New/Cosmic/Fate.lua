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

function CharacterStates.firstStep()
    MoveToTarget("Mini Rover")
    Interact("Mini Rover")
    WaitForPlayer()
    State = CharacterStates.secondStep
    LogInfo(string.format("%s State changed to: SecondStep", LogPrefix))
end

function CharacterStates.secondStep()
    MoveToTarget("Charging Module")
    Interact("Charging Module")
    WaitForPlayer()
    State = CharacterStates.thirdStep
    LogInfo(string.format("%s State changed to: ThirdStep", LogPrefix))
end

function CharacterStates.thirdStep()
    MoveToTarget("Depleted Mini Rover")
    Interact("Depleted Mini Rover")
    WaitForPlayer()
    State = CharacterStates.firstStep
    LogInfo(string.format("%s State changed to: FirstStep", LogPrefix))
end

--=========================== EXECUTION ==========================--

State = CharacterStates.firstStep

while State do
    State()
end

Echo(string.format("Cosmic Fate script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Cosmic Fate script completed successfully..!!", LogPrefix))

--============================== END =============================--