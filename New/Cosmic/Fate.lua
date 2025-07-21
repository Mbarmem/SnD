--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Auto Fate
plugin_dependencies:
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

LogPrefix  = "[CosmicFate]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

--=========================== FUNCTIONS ==========================--

function CharacterState.firstStep()
    MoveToTarget("Mini Rover")
    Interact("Mini Rover")
    WaitForPlayer()
    State = CharacterState.secondStep
    LogInfo(string.format("%s State changed to: SecondStep", LogPrefix))
end

function CharacterState.secondStep()
    MoveToTarget("Charging Module")
    Interact("Charging Module")
    WaitForPlayer()
    State = CharacterState.thirdStep
    LogInfo(string.format("%s State changed to: ThirdStep", LogPrefix))
end

function CharacterState.thirdStep()
    MoveToTarget("Depleted Mini Rover")
    Interact("Depleted Mini Rover")
    WaitForPlayer()
    State = CharacterState.firstStep
    LogInfo(string.format("%s State changed to: FirstStep", LogPrefix))
end

--=========================== EXECUTION ==========================--

State = CharacterState.firstStep
LogInfo(string.format("%s State changed to: FirstStep", LogPrefix))

while State do
    State()
end

Echo(string.format("Cosmic Fate script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Cosmic Fate script completed successfully..!!", LogPrefix))

--============================== END =============================--