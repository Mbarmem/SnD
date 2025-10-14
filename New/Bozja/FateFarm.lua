--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Bozja/Zadnor - Automates FATE farming in Save the Queen areas
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
configs:
  ZoneToFarm:
    description: Choose the zone to farm FATEs in (Bozja or Zadnor).
    is_choice: true
    choices:
        - "Bozja"
        - "Zadnor"

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LastAdjustTime  = 0
StopFlag        = false
ZoneToFarm      = Config.Get("ZoneToFarm")
LogPrefix       = "[FateFarm]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    Gangos = 915,
    Bozja  = 920,
    Zadnor = 975
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Helpers    --
-------------------

function IsActiveState(state)
    if state == nil then
        return false
    end

    local ok, number = pcall(function()
        return state:GetHashCode()
    end)

    if ok and type(number) == "number" then
        return number == 4
    end

    local text = tostring(state) or ""
    local num = tonumber(text:match("(%d+)$"))
    if num ~= nil then
        return num == 4
    end

    return text == "Running" or text == "Active"
end

function StayNearFateCenter(target)
    if not (target and target.Location) then
        return "ok"
    end

    local myPosition = Player and Player.Entity and Player.Entity.Position
    if not myPosition then
        return "ok"
    end

    local distance = GetDistance(myPosition, target.Location) or 1e9
    local now = os.time()

    if distance > 50 then
        MoveTo(target.Location.X, target.Location.Y, target.Location.Z, 3)
        LastAdjustTime = now
        return "reapproach"
    end

    if (now - LastAdjustTime) < 60 then
        return "cooldown"
    end

    if distance > (20 + 1.0) then
        MoveTo(target.Location.X, target.Location.Y, target.Location.Z, 3)
        LastAdjustTime = now
        return "adjust"
    end

    return "ok"
end

function FateDistance(fate, myPosition)
    local distance = tonumber(fate and fate.DistanceToPlayer)
    if not distance or distance ~= distance or distance == 0 then
        if fate and fate.Location and myPosition then
            distance = GetDistance(myPosition, fate.Location)
        end
    end
    return distance or 99999
end

function FateProgress(fate)
    local progress = tonumber(fate and fate.Progress)
    if not progress or progress ~= progress then
        return 0
    end

    if progress < 0 then
        progress = 0
    elseif progress > 100
        then progress = 100
    end
    return progress
end

function PickBestFate()
    WaitForPlayer()
    local list  = Fates.GetActiveFates()
    local count = (list and list.Count) or 0

    if count == 0 then
        return nil
    end

    local myPosition = Player and Player.Entity and Player.Entity.Position
    local best, bestDist, bestProg = nil, 1e12, -1

    for i = 0, count - 1 do
        local fate = list[i]
        if fate and fate.Exists and IsActiveState(fate.State) then
            local distance = FateDistance(fate, myPosition)
            local progress = FateProgress(fate)

            if (distance + 10) < bestDist or (math.abs(distance - bestDist) <= 10 and progress > bestProg) then
                best, bestDist, bestProg = fate, distance, progress
            end
        end
    end

    if best then
        local nearNote = (bestDist <= 500) and " [+near]" or ""
        LogInfo(string.format("%s Picked: %s (dist=%.0fm, prog=%d%%%s)", LogPrefix, best.Name or "?", bestDist, bestProg, nearNote))
    end

    return best
end

function FateQuickDespawned(fateId)
    local misses = 0
    while misses < 6 do
        local fate = Fates.GetFateById(fateId)
        if fate and fate.Exists then
            return false
        end
        misses = misses + 1
        Wait(1)
    end
    return true
end

function WaitForCombat(maxWaitSeconds)
    local deadline = os.time() + (maxWaitSeconds or 120)
    if IsInCombat() then
        LogInfo(string.format("%s FATE ended. Waiting to leave combat before disabling rotation...", LogPrefix))
    end

    while IsInCombat() and os.time() < deadline do
        Wait(1)
    end
    RotationOFF()
    AiOFF()
end

function RunToAndWaitFate(fateId)
    LastAdjustTime = 0
    local fate = Fates.GetFateById(fateId)
    if not (fate and fate.Exists) then
        return "gone"
    end

    Mount()
    LogInfo(string.format("%s Heading to %s (%.0fm, %d%%)...", LogPrefix, fate.Name, fate.DistanceToPlayer or 0, fate.Progress or 0))
    MoveTo(fate.Location.X, fate.Location.Y, fate.Location.Z, 3)

    if fate.InFate or GetDistance(Player.Entity.Position, fate.Location) <= 3 then
        StanceOff()
        RotationON()
        AiON()
        Dismount()
    end

    while true do
        local target = Fates.GetFateById(fateId)
        if target and target.Exists then
            if not IsActiveState(target.State) or FateProgress(target) >= 100 then
                return "ended"
            end

            local stick = StayNearFateCenter(target)
            if stick ~= "ok" and stick ~= "cooldown" then
                LogInfo(string.format("%s Adjust: %s", LogPrefix, stick))
            end

        else
            if FateQuickDespawned(fateId) then
                return "despawned"
            end
        end
        Wait(1)
    end
end

----------------
--    Move    --
----------------

function MoveToZone()
    WaitForPlayer()

    if IsInZone(TargetZoneID) then
        LogInfo(string.format("%s Already in %s. Continuing...", LogPrefix, TargetZoneName))
        return
    end

    if not IsInZone(Zones.Gangos) then
        Wait(1)
        Teleport("Gangos")
        LogInfo(string.format("%s Teleporting to Gangos...", LogPrefix))
        WaitForPlayer()
        return
    end

    Wait(1)
    LogInfo(string.format("%s Entering %s...", LogPrefix, TargetZoneName))
    Teleport(EnterCommand)
    WaitForPlayer()
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

function RotationOFF()
    LogInfo(string.format("%s Turning rotation OFF...", LogPrefix))
    Execute("/rotation off")
    Wait(1)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    Execute("/bmrai on")
    Wait(1)
end

function AiOFF()
    LogInfo(string.format("%s Turning BattleMod AI OFF...", LogPrefix))
    Execute("/bmrai off")
    Wait(1)
end

----------------
--    Main    --
----------------

function ZoneSelection()
    if ZoneToFarm == "Zadnor" then
        TargetZoneID   = Zones.Zadnor
        TargetZoneName = "Zadnor"
        EnterCommand   = "EnterZadnor"
    elseif ZoneToFarm == "Bozja" then
        TargetZoneID   = Zones.Bozja
        TargetZoneName = "Bozja Southern Front"
        EnterCommand   = "EnterBozja"
    else
        LogInfo(string.format("%s Invalid ZoneToFarm '%s', defaulting to Bozja.", LogPrefix, tostring(ZoneToFarm)))
        TargetZoneID   = Zones.Bozja
        TargetZoneName = "Bozja Southern Front"
        EnterCommand   = "EnterBozja"
    end

    LogInfo(string.format("%s Zone selected: %s (ID=%d)", LogPrefix, TargetZoneName, TargetZoneID))
end

function StartFarm(zoneId)
    if not IsInZone(zoneId) then
        return
    end

    LogInfo(string.format("%s Starting FateFarm...", LogPrefix))

    local timeout = os.time() + 7200  -- default 2 hours in seconds

    while IsInZone(zoneId) do
        if os.time() >= timeout then
            LogInfo(string.format("%s Timeout reached. Exiting loop...", LogPrefix))
            WaitForPlayer()
            break
        end

        local fate = PickBestFate()
        if not fate then
            RotationOFF()
            AiOFF()
            LogInfo(string.format("%s No active FATEs. Idling...", LogPrefix))
            Wait(2)
        else
            local result = RunToAndWaitFate(fate.Id)

            if result == "ended" then
                WaitForCombat(120)
            else
                RotationOFF()
                AiOFF()
                LogInfo(string.format("%s FATE %s: %s.", LogPrefix, fate.Name, result))
                Wait(2)
            end
        end

        StanceOff()
        LogInfo(string.format("%s Looping FateFarm... TimeLeft=%d", LogPrefix, timeout - os.time()))
        Wait(1)
    end

    WaitForPlayer()
    RotationOFF()
    AiOFF()
    WaitForPlayer()

    if IsInZone(zoneId) then
        LeaveInstance()
    end
end

--=========================== EXECUTION ==========================--

while not StopFlag do
    ZoneSelection()
    if IsInZone(TargetZoneID) then
        LogInfo(string.format("%s In %s. Beginning Fate farm cycle.", LogPrefix, TargetZoneName))
        StartFarm(TargetZoneID)
        WaitForPlayer()
    else
        RotationOFF()
        AiOFF()
        LogInfo(string.format("%s Not in %s. Moving...", LogPrefix, TargetZoneName))
        MoveToZone()
        WaitForPlayer()
    end
    Wait(5)
end

--============================== END =============================--