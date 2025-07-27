--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Crescent - Automates CE farming in South Horn
plugin_dependencies:
- BOCCHI
- RotationSolver
- BossModReborn
- Lifestream
- vnavmesh
- visland
- YesAlready
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  RunBuffs:
    default: true
    description: Whether to apply buffs before beginning of each run.
    type: boolean
  BuffMacro:
    default: JobBuffs
    description: The name of the macro used to apply job-specific buffs.
    type: string
  RunChestsRoute:
    default: true
    description: If `true`, the script will farm chests.
    type: boolean
  VislandChestRoute:
    default: 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
    description: Route or path used to farm chests.
    type: string
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunBuffs             = Config.Get("RunBuffs")
BuffMacro            = Config.Get("BuffMacro")
RunChestsRoute       = Config.Get("RunChestsRoute")
VislandChestRoute    = Config.Get("VislandChestRoute")
LogPrefix            = "[CEFarm]"

--============================ CONSTANT ==========================--

-------------------
--    Actions    --
-------------------

ActionsOC = {
    OccultReturn = 41343
}

----------------
--    Zone    --
----------------

Zones = {
    SouthHorn      = 1252,
    PhantomVillage = 1278
}

--=========================== FUNCTIONS ==========================--

----------------
--    Move    --
----------------

function MoveToOC()
    WaitForPlayer()

    local command = "Occult"
    Wait(1)

    if IsInZone(Zones.PhantomVillage) then
        command = "EnterOC"
    end

    Wait(1)
    Teleport(command)
    LogInfo(string.format("%s Teleporting to Occult Crescent...", LogPrefix))
end

-----------------
--    Mount    --
-----------------

function Dismount()
    if not IsMounted() then
        return
    end

    LogInfo(string.format("%s Dismounting...", LogPrefix))

    while IsMounted() do
        yield("/gaction Dismount")
        Wait(1)
    end

    LogInfo(string.format("%s Dismounted successfully.", LogPrefix))
end

----------------
--    Misc    --
----------------

function StanceOff()
    if not IsPlayerAvailable() then
        return
    end

    if HasStatusId(91) then
        LogInfo(string.format("%s Turning off Defiance stance...", LogPrefix))
        yield("/action Defiance")
        Wait(1)
    end
end

function RotationON()
    LogInfo(string.format("%s Setting rotation to LowHP mode...", LogPrefix))
    yield("/rotation auto LowHP")
    Wait(1)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    yield("/bmrai on")
    Wait(1)
end

function UseBuffs()
    if not RunBuffs or not IsInZone(Zones.SouthHorn) then
        return
    end

    LogInfo(string.format("%s Applying support buffs...", LogPrefix))

    MoveTo(836.92, 73.12, -707.14, 0.2)
    Dismount()

    yield("/snd run " .. BuffMacro)
    WaitForPlayer()
    Wait(1)
end

function RunVislandRoute(routeName, timeoutSeconds)
    if not RunChestsRoute or not IsInZone(Zones.SouthHorn) then
        return
    end

    WaitForPlayer()
    VislandRouteStart(routeName)
    Wait(1)

    if not IsVislandRouteRunning() then
        LogInfo(string.format("%s Failed to start Visland route: %s", LogPrefix, routeName))
        return false
    end

    LogInfo(string.format("%s Visland Route started: %s", LogPrefix, routeName))

    local timeout = os.time() + (timeoutSeconds or 1200)  -- default 20 minutes if not specified

    while IsVislandRouteRunning() do
        if os.time() >= timeout then
            LogInfo(string.format("%s Timeout waiting for Visland route to finish.", LogPrefix))
            VislandRouteStop()
            return false
        end

        LogDebug(string.format("%s Looping: IsVislandRouteRunning=%s, TimeLeft=%d", LogPrefix, tostring(IsVislandRouteRunning()), timeout - os.time()))
        Wait(3)
    end

    LogInfo(string.format("%s Visland Route completed successfully.", LogPrefix))
    Wait(1)

    return true
end

----------------
--    Main    --
----------------

function StartFarm()
    if not IsInZone(Zones.SouthHorn) then
        return
    end

    LogInfo(string.format("%s Starting CE farm...", LogPrefix))

    StanceOff()
    RotationON()
    AiON()
    UseBuffs()
    yield("/ochillegal on")

    local timeout = os.time() + 7200  -- default 2 hours in seconds

    while IsInZone(Zones.SouthHorn) do
        if os.time() >= timeout then
            LogInfo(string.format("%s Timeout reached. Exiting loop...", LogPrefix))
            WaitForPlayer()
            yield("/ochillegal off")
            Wait(5)
            WaitForPlayer()
            break
        end

        StanceOff()
        LogInfo(string.format("%s Looping: CEFarm, TimeLeft=%d", LogPrefix, timeout - os.time()))
        Wait(5)
    end

    WaitForPlayer()
    yield("/rotation off")
    yield("/bmrai off")
    WaitForPlayer()

    Actions.ExecuteAction(ActionsOC.OccultReturn)
    WaitForPlayer()

    RunVislandRoute(VislandRoute, 1200)
    if IsInZone(Zones.SouthHorn) then
        LeaveInstance()
    end
end

--=========================== EXECUTION ==========================--

while true do
    if IsInZone(Zones.SouthHorn) then
        LogInfo(string.format("%s In SouthHorn zone. Beginning CE farm cycle.", LogPrefix))
        StartFarm()
        WaitForPlayer()
    else
        LogInfo(string.format("%s Not in SouthHorn. Moving to Occult Crescent zone...", LogPrefix))
        MoveToOC()
        WaitForPlayer()
    end
    Wait(1)
end

--============================== END =============================--