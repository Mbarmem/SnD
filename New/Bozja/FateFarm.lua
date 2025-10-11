--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Bozja - Automates fate farming in Bozja Southern Front
plugin_dependencies:
- BossModReborn
- Lifestream
- RotationSolver
- vnavmesh
- YesAlready
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

LogPrefix            = "[FateFarm]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    Gangos = 915,
    Bozja  = 920
}

--=========================== FUNCTIONS ==========================--

----------------
--    Move    --
----------------

function MoveToBozja()
    WaitForPlayer()

    local command = ""
    if IsInZone(Zones.Gangos) then
        command = "EnterBozja"
        Wait(1)
        Teleport(command)
        LogInfo(string.format("%s Teleporting to Bozja Southern Front...", LogPrefix))
        return
    end

    Wait(1)
    StopFlag = true
    LogInfo(string.format("%s Not in Gangos. Stopping script...", LogPrefix))
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
        ExecuteAction(CharacterAction.Actions.defiance)
        Wait(1)
    end
end

function RotationON()
    LogInfo(string.format("%s Setting rotation to LowHP mode...", LogPrefix))
    Execute("/rotation auto LowHP")
    Wait(1)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    Execute("/bmrai on")
    Wait(1)
end

----------------
--    Main    --
----------------

function NearestActiveFate()
    local fates = Fates.GetActiveFates() or {}
    local best, bestD = nil, 9e9
    local me = Player.Position
    for _, f in ipairs(fates) do
        if f.Exists and f.State == FateState.Active then
            local d = f.DistanceToPlayer or DistanceBetween(me, f.Location)
            if d < bestD then best, bestD = f, d end
        end
    end
    return best
end

function RunToAndWaitFate(fateId)
    local f = Fates.GetFateById(fateId)
    if not (f and f.Exists) then
        return "gone"
    end

    Mount()
    LogInfo(string.format("%s Heading to %s (%.0fm, %d%%)...", LogPrefix, f.Name, f.DistanceToPlayer or 0, f.Progress or 0))
    MoveTo(f.Location.X, f.Location.Y, f.Location.Z, 1, true)

    if f.InFate or DistanceBetween(Player.Position, f.Location) <= 3 then
        StanceOff()
        RotationON()
        AiON()
        Dismount()
    end

    local lastSeen = os.clock()
    while true do
        local cur = Fates.GetFateById(fateId)
        if not (cur and cur.Exists) then
            if (os.clock() - lastSeen) > 300 then
                return "ended"
            end
        else
            lastSeen = os.clock()
            if cur.State ~= FateState.Active then
                return "ended"
            end
        end
        Wait(30)
    end
end

function StartFarm()
    if not IsInZone(Zones.Bozja) then
        return
    end

    LogInfo(string.format("%s Starting Fates farm...", LogPrefix))

    StanceOff()
    RotationON()
    AiON()

    local timeout = os.time() + 7200  -- default 2 hours in seconds

    while IsInZone(Zones.Bozja) do
        if os.time() >= timeout then
            LogInfo(string.format("%s Timeout reached. Exiting loop...", LogPrefix))
            WaitForPlayer()
            break
        end

        local fate = NearestActiveFate()
        if not fate then
            LogInfo(string.format("%s No active FATEs. Idling...", LogPrefix))
            Wait(10)
        else
            local result = RunToAndWaitFate(fate.Id)
            LogInfo(string.format("%s FATE %s: %s.", LogPrefix, fate.Name, result))
            Wait(10)
        end

        StanceOff()
        LogInfo(string.format("%s Looping FateFarm... TimeLeft=%d", LogPrefix, timeout - os.time()))
        Wait(5)
    end

    WaitForPlayer()
    Execute("/rotation off")
    Execute("/bmrai off")
    WaitForPlayer()

    if IsInZone(Zones.Bozja) then
        LeaveInstance()
    end
end

--=========================== EXECUTION ==========================--

local StopFlag = false

while not StopFlag do
    if IsInZone(Zones.Bozja) then
        LogInfo(string.format("%s In Bozja zone. Beginning Fate farm cycle.", LogPrefix))
        StartFarm()
        WaitForPlayer()
    else
        LogInfo(string.format("%s Not in Bozja. Moving to Bozja Southern Front...", LogPrefix))
        MoveToBozja()
        WaitForPlayer()
    end
    Wait(10)
end

--============================== END =============================--