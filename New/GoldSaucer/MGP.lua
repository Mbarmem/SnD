--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Triple Triad + Auto Retainer - Play TT and process AR when needed
plugin_dependencies:
- Lifestream
- Saucy
- vnavmesh
- YesAlready
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  DoAutoRetainers:
    description: Automatically interact with retainers for ventures.
    default: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

DoAutoRetainers = Config.Get("DoAutoRetainers")
LogPrefix       = "[MGP]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function PlayTTUntilNeeded()
    while not IsPlayingMiniGame() do
        Wait(1)
    end

    LogInfo(string.format("%s Starting Triple Triad...", LogPrefix))
    Execute("/saucy tt go")
    Wait(1)

    while not ARRetainersWaitingToBeProcessed() do
        Wait(1)
    end

    if IsPlayingMiniGame() then
        Execute("/saucy tt play 1")
        Wait(1)
    end

    while IsPlayingMiniGame() do
        Wait(1)
    end

    Wait(1)
    LogInfo(string.format("%s Done Playing... Heading to Summoning Bell", LogPrefix))
end

function CharacterState.goToFoundation()
    if IsInZone(418) then
        MoveToTarget("Aetheryte", 7)
        Teleport("The Last Vigil")

        State = CharacterState.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", LogPrefix))
    else
        Teleport("Foundation")

        State = CharacterState.goToFoundation
        LogInfo(string.format("%s State changed to: GoToFoundation", LogPrefix))
    end
end

function CharacterState.goToLastVigil()
    if not IsInZone(419) then
        State = CharacterState.goToFoundation
        LogInfo(string.format("%s State changed to: GoToFoundation", LogPrefix))
        return
    end

    MoveToTarget("House Fortemps Guard", 3)
    Interact("House Fortemps Guard")
    WaitForZoneChange()

    State = CharacterState.playTTandAR
    LogInfo(string.format("%s State changed to: PlayTTandAR", LogPrefix))
end

function CharacterState.playTTandAR()
    if not IsInZone(433) then
        State = CharacterState.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", LogPrefix))
        return
    end

    MoveToTarget("House Fortemps Manservant", 3)
    Interact("House Fortemps Manservant")

    PlayTTUntilNeeded()

    if DoAutoRetainers then
        MoveToTarget("Manor Exit")
        Interact("Manor Exit")
        WaitForZoneChange()

        MoveToTarget("Aethernet Shard", 5)
        Teleport("The Jeweled Crozier")

        DoAR(DoAutoRetainers)

        MoveToTarget("Aethernet Shard", 5)
        Teleport("The Last Vigil")

        State = CharacterState.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", LogPrefix))
    else
        State = CharacterState.playTTandAR
        LogInfo(string.format("%s State changed to: PlayTTandAR", LogPrefix))
    end
end

--=========================== EXECUTION ==========================--

State = CharacterState.playTTandAR
LogInfo(string.format("%s State changed to: PlayTTandAR", LogPrefix))

while State do
    State()
    Wait(1)
end

Echo(string.format("Triple Triad MGP script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Triple Triad MGP script completed successfully..!!", LogPrefix))

--============================== END =============================--