--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Alexandrite - ARR Relic Helper
plugin_dependencies:
- Globetrotter
- TeleporterPlugin
- Lifestream
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  Alexandrite:
    default: 0
    description: Initial Count of Alexandrtie in the Inventory.
    type: int
    required: true
  DesiredCount:
    default: 75
    description: Desired Count of Alexandrtie required.
    type: int
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

Alexandrite     = Config.Get("Alexandrite")
DesiredCount    = Config.Get("DesiredCount")
LogPrefix       = "[Alexandrite]"

--=========================== FUNCTIONS ==========================--

function Main()
    LogInfo(string.format("%s Starting cycle. Alexandrite so far: %s", LogPrefix, Alexandrite))

    if GetItemCount(7884) < 1 then
        LogInfo(string.format("%s No map found, teleporting to Revenant's Toll.", LogPrefix))
        Teleport("Revenant's Toll")

        LogInfo(string.format("%s Traveling to Auriana to purchase map.", LogPrefix))
        MoveTo(63.3, 31.15, -736.3)
        WaitForNavMesh()
        yield("/ac Sprint")
        WaitForPathRunning()
        PlayerTest()

        Interact("Auriana")
        Wait(1)
        repeat

            if IsAddonReady("SelectIconString") then
                yield("/callback SelectIconString true 5")
            end

            if IsAddonReady("Talk") then
                yield("/callback Talk true 0")
            end

            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end

            Wait(1)
        until IsPlayerAvailable()
    end

    -- Decipher the map
    LogInfo(string.format("%s Deciphering the map.", LogPrefix))
    yield("/ac Decipher")
    WaitForAddon("SelectIconString")
    yield("/callback SelectIconString true 0")
    Wait(1)

    WaitForAddon("SelectYesno")
    yield("/callback SelectYesno true 0")
    Wait(4)

    -- Open treasure map
    repeat
        yield("/tmap")
    until IsAddonReady("AreaMap")
    PlayerTest()

    -- Travel to flagged zone
    TeleportFlagZone()

    -- Mount up and fly to flag
    if not IsMounted() then
        UseMount()
    end
    WaitForNavMesh()

    yield("/vnav flyflag")
    Wait(3)
    WaitForPathRunning()

    -- Dig at flag and approach chest
    LogInfo(string.format("%s Digging at flag.", LogPrefix))
    yield("/generalaction Dig")
    Wait(5)
    PlayerTest()

    Target("Treasure Coffer")
    yield("/vnav flytarget")
    WaitForPathRunning()

    -- Dismount and open chest
    yield("/ac dismount")
    Wait(2)
    Interact("Treasure Coffer")
    WaitForAddon("SelectYesno")
    yield("/callback SelectYesno true 0")

    -- Fight if necessary
    repeat
        yield("/rotation auto")
        Wait(1)
    until not IsInCombat()
    yield("/rotation off")

    -- Loot
    Interact("Treasure Coffer")
    Wait(1)
    if IsInCombat() then
        repeat
            yield("/rotation auto")
            Wait(1)
        until not IsInCombat()
        yield("/rotation off")
    end

    LogInfo(string.format("%s Cycle completed.", LogPrefix))
end

--=========================== EXECUTION ==========================--

while Alexandrite < DesiredCount do
    Main()
    Alexandrite = Alexandrite + 5
    LogInfo(string.format("%s Alexandrite Count: %d / %d", LogPrefix, Alexandrite, DesiredCount))
end

Echo(string.format("Farming complete..!! Total Alexandrite: %d", Alexandrite), LogPrefix)
LogInfo(string.format("%s Farming complete..!! Total Alexandrite: %d", LogPrefix, Alexandrite))

--============================== END =============================--