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
  MaxFailuresAllowed:
    default: 5
    description: The maximum number of allowed failures before stopping the script.
    type: int


[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

MaxFailuresAllowed = Config.Get("MaxFailuresAllowed")
EchoPrefix         = "[MGP]"

--=========================== FUNCTIONS ==========================--

------------------
--    Helper    --
------------------

function StartScript()
    PlayManservant()
end

function StopScript()
    yield("/echo Stopping script, thanks for using")
    yield("/pcraft stop")
end

function PlayTTUntilNeeded()
    while not IsPlayerAvailable() do
        Wait(0.5)
        LogInfo(string.format("%s Waiting for game UI", EchoPrefix))
    end

    yield("/saucy tt go")
    Wait(1)

    while not ARRetainersWaitingToBeProcessed() do
        Wait(1)
    end

    if IsPlayingMiniGame() then
        yield("/saucy tt play 1")
    end

    while IsPlayingMiniGame() do
        Wait(1)
    end

    Wait(1)
    LogInfo(string.format("%s Done Playing... Heading to bell", EchoPrefix))
end

function PlayManservant()
    if IsInZone(433) then
        goto HouseFortemps
    end
    Teleport("Foundation")
    WaitForTeleport()
    MoveToTarget("Aetheryte", 7)
    Lifestream("Last")
    WaitForLifeStream()
    ::LastVigil::
    MoveToTarget("House Fortemps Guard", 3)
    Interact("House Fortemps Guard")
    WaitForZoneChange()
    ::HouseFortemps::
    MoveToTarget("House Fortemps Manservant", 3)
    Interact("House Fortemps Manservant")
    ::PlayTT::
    PlayTTUntilNeeded()
    if DoAutoRetainers then
        MoveToTarget("Manor Exit")
        Interact("Manor Exit")
        WaitForZoneChange()
        MoveToTarget("Aethernet Shard", 7)
        Lifestream("Jeweled")
        WaitForLifeStream()
        MoveToTarget("Summoning Bell")
        Interact("Summoning Bell")
        DoAR(DoAutoRetainers)
        MoveToTarget("Aethernet Shard")
        Lifestream("Last")
        WaitForLifeStream()
        goto LastVigil
    else
        goto PlayTT
    end
end

--[[ START ]]

StartScript()
StopScript()