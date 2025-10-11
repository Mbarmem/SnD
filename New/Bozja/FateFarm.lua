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
    local best, bestScore = nil, -1e9

    for i = 0, count - 1 do
        local fate = list[i]
        if fate and fate.Exists and IsActiveState(fate.State) then
            local distance = FateDistance(fate, myPosition)
            local progress = FateProgress(fate)

            local score = (progress * 2) - (distance * 0.02)
            if distance <= 20 then
                score = score + 15
            end

            if score > bestScore then
                best, bestScore = fate, score
            end
        end
    end

    if best then
        LogInfo(string.format("%s Picked: %s (score=%.2f)", LogPrefix, best.Name or "?", bestScore))
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
        RotationOFF()
        AiOFF()
        LogInfo(string.format("%s Not in Bozja. Moving to Bozja Southern Front...", LogPrefix))
        MoveToBozja()
        WaitForPlayer()
    end
    Wait(5)
end

--============================== END =============================--