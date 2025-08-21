--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Alexandrite - ARR Relic Helper
plugin_dependencies:
- Globetrotter
- Lifestream
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  Alexandrite:
    description: Initial Count of Alexandrtie in the Inventory.
    default: 0
  DesiredCount:
    description: Desired Count of Alexandrtie required.
    default: 75

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
        ExecuteGeneralAction(CharacterAction.GeneralActions.sprint)
        WaitForPlayer()

        Interact("Auriana")
        Wait(1)
        repeat

            if IsAddonReady("SelectIconString") then
                Execute("/callback SelectIconString true 5")
            end

            if IsAddonReady("Talk") then
                Execute("/callback Talk true 0")
            end

            if IsAddonReady("SelectYesno") then
                Execute("/callback SelectYesno true 0")
            end

            Wait(1)
        until IsPlayerAvailable()
    end

    -- Decipher the map
    LogInfo(string.format("%s Deciphering the map.", LogPrefix))
    ExecuteGeneralAction(CharacterAction.GeneralActions.decipher)
    WaitForAddon("SelectIconString")
    Execute("/callback SelectIconString true 0")
    Wait(1)

    WaitForAddon("SelectYesno")
    Execute("/callback SelectYesno true 0")
    Wait(4)

    -- Open treasure map
    repeat
        Execute("/tmap")
    until IsAddonReady("AreaMap")
    WaitForPlayer()

    -- Travel to flagged zone
    TeleportFlagZone()

    -- Mount up and fly to flag
    Mount()
    WaitForNavMesh()

    Execute("/vnav flyflag")
    Wait(3)
    WaitForPathRunning()

    -- Dig at flag and approach chest
    LogInfo(string.format("%s Digging at flag.", LogPrefix))
    ExecuteGeneralAction(CharacterAction.GeneralActions.dig)
    Wait(5)
    WaitForPlayer()

    Target("Treasure Coffer")
    Execute("/vnav flytarget")
    WaitForPathRunning()

    -- Dismount and open chest
    Dismount()
    Wait(2)
    Interact("Treasure Coffer")
    WaitForAddon("SelectYesno")
    Execute("/callback SelectYesno true 0")

    -- Fight if necessary
    repeat
        Execute("/rotation auto")
        Wait(1)
    until not IsInCombat()
    Execute("/rotation off")

    -- Loot
    Interact("Treasure Coffer")
    Wait(1)
    if IsInCombat() then
        repeat
            Execute("/rotation auto")
            Wait(1)
        until not IsInCombat()
        Execute("/rotation off")
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