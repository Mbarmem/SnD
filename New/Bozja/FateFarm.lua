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

LastAdjustTime  = 0
StopFlag        = false
LogPrefix       = "[FateFarm]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    Gangos = 915,
    Bozja  = 920
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Helpers    --
-------------------

function IsActiveState(state)
    if state == nil then
        return false
    end

    local ok, n = pcall(function() return state:GetHashCode() end)
    if ok and type(n) == "number" then
        return n == 4
    end

    local t = tostring(state) or ""
    local num = tonumber(t:match("(%d+)$"))
    if num ~= nil then
        return num == 4
    end

    return t == "Running" or t == "Active"
end

function StayNearFateCenter(cur)
    if not (cur and cur.Location) then
        return "ok"
    end

    local me = Player and Player.Entity and Player.Entity.Position
    if not me then
        return "ok"
    end

    local d = GetDistance(me, cur.Location) or 1e9
    local now = os.time()

    if d > 50 then
        MoveTo(cur.Location.X, cur.Location.Y, cur.Location.Z, 3)
        LastAdjustTime = now
        return "reapproach"
    end

    if (now - LastAdjustTime) < 60 then
        return "cooldown"
    end

    if d > (20 + 1.0) then
        MoveTo(cur.Location.X, cur.Location.Y, cur.Location.Z, 3)
        LastAdjustTime = now
        return "adjust"
    end

    return "ok"
end

function FateDistance(f, me)
    local distance = tonumber(f and f.DistanceToPlayer)
    if not distance or distance ~= distance or distance == 0 then
        if f and f.Location and me then
            distance = GetDistance(me, f.Location)
        end
    end
    return distance or 99999
end

function FateProgress(f)
    local progress = tonumber(f and f.Progress)
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

    local me = Player and Player.Entity and Player.Entity.Position

    local best, bestScore = nil, -1e9

    for i = 0, count - 1 do
        local f = list[i]
        if f and f.Exists and IsActiveState(f.State) then
            local distance = FateDistance(f, me)
            local progress = FateProgress(f)

            local score = (progress * 2) - (distance * 0.02)
            if distance <= 20 then
                score = score + 15
            end

            if score > bestScore then
                best, bestScore = f, score
            end
        end
    end

    if best then
        LogInfo(string.format("%s Picked: %s (score=%.2f)", LogPrefix, best.Name or "?", bestScore))
    end

    return best
end


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
    WaitForPlayer()
    local fates = Fates.GetActiveFates()
    if not (fates and fates.Count and fates.Count > 0) then
        return nil
    end

    local best, bestD = nil, 9e9
    local me = Player.Entity.Position

    for i = 0, fates.Count - 1 do
        local f = fates[i]
        if f and f.Exists and IsActiveState(f.State) then
            local d = tonumber(f.DistanceToPlayer)
            if not d or d ~= d or d == 0 then  -- nil/NaN/zero
                d = GetDistance(me, f.Location)
            end

            if d < bestD then
                best, bestD = f, d
            end
        end
    end

    return best
end

function RunToAndWaitFate(fateId)
    LastAdjustTime = 0
    local f = Fates.GetFateById(fateId)
    if not (f and f.Exists) then
        return "gone"
    end

    Mount()
    LogInfo(string.format("%s Heading to %s (%.0fm, %d%%)...", LogPrefix, f.Name, f.DistanceToPlayer or 0, f.Progress or 0))
    MoveTo(f.Location.X, f.Location.Y, f.Location.Z, 3)

    if f.InFate or GetDistance(Player.Entity.Position, f.Location) <= 3 then
        StanceOff()
        RotationON()
        AiON()
        Dismount()
    end

    local lastSeen = os.clock()
    while true do
        local cur = Fates.GetFateById(fateId)
        if cur and cur.Exists then
            lastSeen = os.clock()
            if not IsActiveState(cur.State) then
                return "ended"
            end

            local stick = StayNearFateCenter(cur)
            if stick ~= "ok" and stick ~= "cooldown" then
                LogInfo(string.format("%s Adjust: %s", LogPrefix, stick))
            end

        elseif (os.clock() - lastSeen) > 30 then
            return "despawned"
        end
        Wait(5)
    end
end

function StartFarm()
    if not IsInZone(Zones.Bozja) then
        return
    end

    LogInfo(string.format("%s Starting FateFarm...", LogPrefix))

    local timeout = os.time() + 7200  -- default 2 hours in seconds

    while IsInZone(Zones.Bozja) do
        if os.time() >= timeout then
            LogInfo(string.format("%s Timeout reached. Exiting loop...", LogPrefix))
            WaitForPlayer()
            break
        end

        local fate = PickBestFate()
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