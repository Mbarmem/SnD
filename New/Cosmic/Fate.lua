--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Auto Fate
plugin_dependencies:
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  FirstTarget:
    description: Name of the first interactable target.
    default: "Mini Rover"
  SecondTarget:
    description: Name of the second interactable target.
    default: "Charging Module"
  ThirdTarget:
    description: Name of the third interactable target.
    default: "Depleted Mini Rover"
  Move:
    description: Move to the configured coordinates before interacting.
    default: false
  Move Coordinates:
    description: Coordinates to move to in x, y, z format.
    default: "0, 0, 0"

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

FirstTarget  = Config.Get("FirstTarget")
SecondTarget = Config.Get("SecondTarget")
ThirdTarget  = Config.Get("ThirdTarget")
Move         = Config.Get("Move")
MoveCoords   = Config.Get("Move Coordinates")
LogPrefix    = "[CosmicFate]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

--=========================== FUNCTIONS ==========================--

function GetMoveCoordinates()
    local sanitizedCoords = tostring(MoveCoords or "")
    sanitizedCoords = string.gsub(sanitizedCoords, "^%s*", "")
    sanitizedCoords = string.gsub(sanitizedCoords, "%s*$", "")
    sanitizedCoords = string.gsub(sanitizedCoords, "([%-]?%d+),(%d+)", "%1.%2")

    local x, y, z = string.match(sanitizedCoords, "^%s*([%-]?%d+%.?%d*)%s*,%s*([%-]?%d+%.?%d*)%s*,%s*([%-]?%d+%.?%d*)%s*$")

    if not x or not y or not z then
        LogInfo(string.format("%s Invalid Move Coordinates config: %s", LogPrefix, tostring(MoveCoords)))
        return nil
    end

    return tonumber(x), tonumber(y), tonumber(z)
end

function MoveIfConfigured()
    if not Move then
        return
    end

    local x, y, z = GetMoveCoordinates()
    if x and y and z then
        MoveTo(x, y, z, 1, false)
    end
end

function CharacterState.firstStep()
    MoveIfConfigured()
    MoveToTarget(FirstTarget)
    Interact(FirstTarget)
    WaitForPlayer()
    State = CharacterState.secondStep
    LogInfo(string.format("%s State changed to: SecondStep", LogPrefix))
end

function CharacterState.secondStep()
    MoveToTarget(SecondTarget)
    Interact(SecondTarget)
    Wait(8)
    State = CharacterState.thirdStep
    LogInfo(string.format("%s State changed to: ThirdStep", LogPrefix))
end

function CharacterState.thirdStep()
    MoveIfConfigured()
    MoveToTarget(ThirdTarget)
    While not IsPlayerAvailable() do
        Interact(ThirdTarget)
        Wait(1)
    end
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
