--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Triple Triad + Auto Retainer - Play TT and process AR when needed
plugin_dependencies:
- Saucy
- TeleporterPlugin
- Lifestream
- vnavmesh
- YesAlready
dependencies:
- source: ''
  name: SnD
  type: git
configs:
  DoAutoRetainers:
    default: true
    description: Automatically interact with retainers for ventures.
    type: boolean

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

DoAutoRetainers = Config.Get("DoAutoRetainers")
EchoPrefix      = "[MGP]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterStates = {}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function PlayTTUntilNeeded()
    while not IsPlayingMiniGame() do
        Wait(1)
    end

    LogInfo(string.format("%s Starting Triple Triad...", EchoPrefix))
    yield("/saucy tt go")
    Wait(1)

    while not ARRetainersWaitingToBeProcessed() do
        Wait(1)
    end

    if IsPlayingMiniGame() then
        yield("/saucy tt play 1")
        Wait(1)
    end

    while IsPlayingMiniGame() do
        Wait(1)
    end

    Wait(1)
    LogInfo(string.format("%s Done Playing... Heading to Summoning Bell", EchoPrefix))
end

function CharacterStates.goToFoundation()
    if IsInZone(418) then
        MoveToTarget("Aetheryte", 7)
        Lifestream("The Last Vigil")
        WaitForLifeStream()

        State = CharacterStates.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", EchoPrefix))
    else
        Teleport("Foundation")
        WaitForTeleport()

        State = CharacterStates.goToFoundation
        LogInfo(string.format("%s State changed to: GoToFoundation", EchoPrefix))
    end
end

function CharacterStates.goToLastVigil()
    if not IsInZone(419) then
        State = CharacterStates.goToFoundation
        LogInfo(string.format("%s State changed to: GoToFoundation", EchoPrefix))
        return
    end

    MoveToTarget("House Fortemps Guard", 3)
    Interact("House Fortemps Guard")
    WaitForZoneChange()

    State = CharacterStates.playTTandAR
    LogInfo(string.format("%s State changed to: PlayTTandAR", EchoPrefix))
end

function CharacterStates.playTTandAR()
    if not IsInZone(433) then
        State = CharacterStates.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", EchoPrefix))
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
        Lifestream("The Jeweled Crozier")
        WaitForLifeStream()

        DoAR(DoAutoRetainers)

        MoveToTarget("Aethernet Shard", 5)
        Lifestream("The Last Vigil")
        WaitForLifeStream()

        State = CharacterStates.goToLastVigil
        LogInfo(string.format("%s State changed to: GoToLastVigil", EchoPrefix))
    else
        State = CharacterStates.playTTandAR
        LogInfo(string.format("%s State changed to: PlayTTandAR", EchoPrefix))
    end
end

--=========================== EXECUTION ==========================--

State = CharacterStates.playTTandAR

while State do
    State()
    Wait(1)
end

--============================== END =============================--