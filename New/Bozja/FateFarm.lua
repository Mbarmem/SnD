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
  FateBlacklist:
    description: Comma-separated FATE names or IDs to skip (e.g. "A Relic Unleashed, 1638").
    is_input: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LastAdjustTime  = 0
StopFlag        = false
ZoneToFarm      = Config.Get("ZoneToFarm")
DisabledFates   = Config.Get("FateBlacklist")
LogPrefix       = "[FateFarm]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    Gangos = { Id = 915, Name = "Gangos",               Teleport = "Gangos"      },
    Bozja  = { Id = 920, Name = "Bozja Southern Front", Teleport = "EnterBozja"  },
    Zadnor = { Id = 975, Name = "Zadnor",               Teleport = "EnterZadnor" },
}

---------------------
--    Blacklist    --
---------------------

BlacklistNames  = {}
BlacklistIds    = {}

--=========================== FUNCTIONS ==========================--

-------------------
--    Helpers    --
-------------------

function BuildFateBlacklist(raw)
    local names, ids = {}, {}

    for token in string.gmatch(raw or "", "[^,]+") do
        token = (token and token:gsub("^%s+",""):gsub("%s+$","")) or token
        if token and #token > 0 then
            local id = tonumber(token)
            if id then
                ids[id] = true
            else
                names[(token and token:lower():gsub("%s+"," ")) or token] = true
            end
        end
    end

    BlacklistNames = names
    BlacklistIds   = ids

    return names, ids
end

function IsBlacklisted(fate)
    if not fate then
        return false
    end

    if BlacklistIds[fate.Id] then
        return true
    end

    local name = (fate.Name and fate.Name:lower():gsub("^%s+",""):gsub("%s+$",""):gsub("%s+"," ")) or fate.Name
    return name and BlacklistNames[name] or false
end

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

function PickBestFate(block)
    if block ~= false then
        WaitForPlayer()
    end

    local list  = Fates.GetActiveFates()
    local count = (list and list.Count) or 0
    if count == 0 then
        return nil
    end

    local anyViable = false
    local myPosition = Player and Player.Entity and Player.Entity.Position
    local best, bestDist, bestProg = nil, 1e12, -1

    for i = 0, count - 1 do
        local fate = list[i]
        if fate and fate.Exists and IsActiveState(fate.State) and not IsBlacklisted(fate) then
            anyViable = true

            local distance = FateDistance(fate, myPosition)
            local progress = FateProgress(fate)

            if (distance + 10) < bestDist or (math.abs(distance - bestDist) <= 10 and progress > bestProg) then
                best, bestDist, bestProg = fate, distance, progress
            end
        end
    end

    if not anyViable then
        LogInfo(string.format("%s All active FATEs are blacklisted. Idling...", LogPrefix))
        return nil
    end

    if block ~= false and best then
        local nearNote = (bestDist <= 500) and " [+near]" or ""
        LogInfo(string.format("%s Picked: %s (id=%s, dist=%.0fm, prog=%d%%%s)", LogPrefix, best.Name or "?", tostring(best.Id or "?"), bestDist or -1, bestProg or -1, nearNote))
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
    local lastSwitchAt = 0

    local fate = Fates.GetFateById(fateId)
    if not (fate and fate.Exists) then
        return "gone"
    end

    Mount()
    LogInfo(string.format("%s Heading to %s (%.0fm, %d%%)...", LogPrefix, fate.Name, fate.DistanceToPlayer or 0, fate.Progress or 0))
    MoveToStart(fate.Location.X, fate.Location.Y, fate.Location.Z)

    while true do
        local myPosition    = Player and Player.Entity and Player.Entity.Position
        local selectedFate  = Fates.GetFateById(fateId)

        if not (selectedFate and selectedFate.Exists) then
            if FateQuickDespawned(fateId) then
                PathStop()
                return "despawned"
            end
        else
            if (not IsActiveState(selectedFate.State)) or (FateProgress(selectedFate) >= 100) then
                PathStop()
                return "ended"
            end

            local dist = (myPosition and selectedFate.Location) and GetDistance(myPosition, selectedFate.Location) or (selectedFate.DistanceToPlayer or 99999)
            if selectedFate.InFate and (dist and dist <= 1) then
                PathStop()
                StanceOff()
                RotationON()
                AiON()
                Dismount()
                break
            end

            local now = os.time()
            if (now - lastSwitchAt) >= 5 then
                local best = PickBestFate(false)

                if best and best.Exists and IsActiveState(best.State) and best.Location and best.Id ~= fateId and not IsBlacklisted(best) then
                    local curDist  = (myPosition and selectedFate and selectedFate.Location) and GetDistance(myPosition, selectedFate.Location) or (selectedFate and selectedFate.DistanceToPlayer) or 1e9
                    local bestDist = FateDistance(best, myPosition)

                    if curDist and bestDist and (bestDist < curDist - 100) and (curDist > 50) then
                        LogInfo(string.format("%s Switching target: '%s' → '%s' (%.0fm → %.0fm)", LogPrefix, selectedFate.Name or "?", best.Name or "?", curDist, bestDist))
                        PathStop()
                        fateId       = best.Id
                        fate         = best
                        lastSwitchAt = now
                        MoveToStart(fate.Location.X, fate.Location.Y, fate.Location.Z)
                    end
                end
            end
        end

        Wait(1)
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

    if not IsInZone(HubZone.Id) then
        Wait(1)
        Teleport(HubZone.Teleport)
        LogInfo(string.format("%s Teleporting to %s...", LogPrefix, HubZone.Name))
        WaitForPlayer()
        return
    end

    Wait(1)
    LogInfo(string.format("%s Entering %s...", LogPrefix, TargetZoneName))
    Teleport(TargetTeleport)
    WaitForPlayer()
end

function MoveToStart(x, y, z, fly)
    fly = fly or false
    PathStop()
    local destination = Vector3(x, y, z)
    local ok = IPC.vnavmesh.PathfindAndMoveTo(destination, fly)

    if not ok then
        return false
    end
    return true
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

function ResolveZone()
    local chosen   = Zones[ZoneToFarm] or Zones.Bozja
    TargetZoneID   = chosen.Id
    TargetZoneName = chosen.Name
    TargetTeleport = chosen.Teleport
    HubZone        = Zones.Gangos

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

BuildFateBlacklist(DisabledFates)
while not StopFlag do
    ResolveZone()
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