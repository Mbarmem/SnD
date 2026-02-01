--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Token Farming with ICE integration.
plugin_dependencies:
- ICE
- vnavmesh
- TextAdvance
- SimpleTweaksPlugin
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  Jobs:
    description: |
      A list of jobs to cycle through when EXP or class score thresholds are reached,
      depending on the settings configured in ICE.
      Enter short or full job name and press enter. One job per line.
      -- Enable equip job command in Simple Tweaks and leave it as the default. --
      Leave blank to disable job cycling.
    default: []
  Lunar Credits Limit:
    description: |
      Maximum number of Credits before missions will pause for Gamba.
      Match this with "Stop at Lunar Credits" in ICE to synchronize behavior.
      -- Enable Gamba under Gamble Wheel in ICE settings. --
      Set to 0 to disable the limit.
    default: 0
    min: 0
    max: 10000
  Report Failed Missions:
    description: |
      Enable to report missions that failed to reach scoreing tier.
    default: false
  EX+ 4hr Timed Missions:
    description: |
      Enable to swap crafting jobs to the current EX+ 4hr long timed mission job.
    default: false
  EX+ 2hr Timed Missions:
    description: |
      Enable to swap crafting jobs to the current EX+ 2hr long timed mission job.
    default: false

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

JobsConfig      = Config.Get("Jobs")
LimitConfig     = Config.Get("Lunar Credits Limit")
FailedConfig    = Config.Get("Report Failed Missions")
Ex4TimeConfig   = Config.Get("EX+ 4hr Timed Missions")
Ex2TimeConfig   = Config.Get("EX+ 2hr Timed Missions")
LogPrefix       = "[CosmicTokens]"

--========================= INITIALIZATION ========================--

local sheet = Excel.GetSheet("ClassJob")
assert(sheet, "ClassJob sheet not found")
Jobs = {}
for id = 8, 18 do
    local row = sheet:GetRow(id)
    if row then
        local name = row.Name or row["Name"]
        local abbr = row.Abbreviation or row["Abbreviation"]
        if name and abbr then
            Jobs[id] = { name = name, abbr = abbr }
        end
    end
end

--============================ CONSTANT ==========================--

-------------------
--    General    --
-------------------

Run_script      = true
ReportCount     = 0
CycleCount      = 0
JobCount        = 0
LunarCredits    = 0
LastSpotIndex   = nil
EnabledAutoText = false
ClassScoreAll   = {}
ActiveZone      = nil
SpotPos         = {}
LoopDelay       = 0.1
CycleLoops      = 100
SpotRadius      = 3
MinRadius       = 0.5
DiscoveredZone  = false

--------------------
--    Missions    --
--------------------

ExJobs4H_Default = {
    [0]  = {Jobs[10].abbr}, -- ARM
    [4]  = {Jobs[11].abbr}, -- GSM
    [8]  = {Jobs[12].abbr}, -- LTW
    [12] = {Jobs[13].abbr}, -- WVR
    [16] = {Jobs[8].abbr},  -- CRP
    [20] = {Jobs[9].abbr},  -- BSM
}

ExJobs2H_Default = {
    [0]  = {Jobs[12].abbr}, -- LTW
    [4]  = {Jobs[13].abbr}, -- WVR
    [8]  = {Jobs[14].abbr}, -- ALC
    [12] = {Jobs[15].abbr}, -- CUL
    [16] = {Jobs[10].abbr}, -- ARM
    [20] = {Jobs[11].abbr}, -- GSM
}

ExJobs4H_Oizys = {
    [0]  = {Jobs[10].abbr}, -- ARM
    [4]  = {Jobs[11].abbr}, -- GSM
    [8]  = {Jobs[12].abbr}, -- LTW
    [12] = {Jobs[13].abbr}, -- WVR
    [16] = {Jobs[8].abbr},  -- CRP
    [20] = {Jobs[9].abbr},  -- BSM
}

ExJobs2H_Oizys = {
    [0]  = {Jobs[8].abbr},  -- CRP
    [2]  = {Jobs[15].abbr}, -- CUL
    [4]  = {Jobs[9].abbr},  -- BSM
    [6]  = {Jobs[14].abbr}, -- ALC
    [8]  = {Jobs[10].abbr}, -- ARM
    [12] = {Jobs[11].abbr}, -- GSM
    [16] = {Jobs[12].abbr}, -- LTW
    [20] = {Jobs[13].abbr}, -- WVR
}

ExJobs4H = ExJobs4H_Default
ExJobs2H = ExJobs2H_Default

----------------
--    Zone    --
----------------

SinusTerritory   = 1237
PhaennaTerritory = 1291
OizysTerritory   = 1504

Zones = {
    sinus = {
        key        = "sinus",
        match      = {"sinus"},
        gateHub    = nil,
        creditNpc  = { id = 1052612, name = nil, position = nil }, -- resolved on discovery
        spots      = {},
        discovered = false,
        isOizys    = false,
    },
    phaenna = {
        key        = "phaenna",
        match      = {"phaenna"},
        gateHub    = nil,
        creditNpc  = { id = 1052642, name = nil, position = nil }, -- resolved on discovery
        spots      = {},
        discovered = false,
        isOizys    = false,
    },
    oizys = {
        key        = "oizys",
        match      = {"oizys"},
        gateHub    = nil,
        creditNpc  = { id = nil, name = "Orbitingway", position = nil },
        spots      = {},
        discovered = false,
        isOizys    = true,
    }
}

--=========================== FUNCTIONS ==========================--

function ToNumber(s)
    if type(s) ~= "string" then return tonumber(s) end
    s = s:match("^%s*(.-)%s*$")
    s = s:gsub(",", "")
    return tonumber(s)
end

function GetEorzeaHour()
    local et = os.time() * 1440 / 70
    return math.floor((et % 86400) / 3600)
end

function GetENpcResidentName(dataId)
    local sheet = Excel.GetSheet("ENpcResident")
    if not sheet then return nil, "ENpcResident sheet not available" end
    local row = sheet:GetRow(dataId)
    if not row then return nil, "no row for id "..tostring(dataId) end
    local name = row.Singular or row.Name
    return name, "ENpcResident"
end

function Pos(x, y, z)
    return { X = x, Y = y, Z = z }
end

function PosFrom(p)
    if not p then return nil end
    return Pos(p.X, p.Y, p.Z)
end

function PlaceNameByTerritory(id)
    local terr = Excel.GetSheet("TerritoryType"); if not terr then return nil end
    local row  = terr:GetRow(id);                  if not row  then return nil end
    local pn   = row.PlaceName;                    if not pn   then return nil end

    if type(pn) == "string" and #pn > 0 then return pn end

    if type(pn) == "userdata" then
        local ok,val = pcall(function() return pn.Value end)
        if ok and val then
            local ok2,name = pcall(function() return val.Singular or val.Name or val:ToString() end)
            if ok2 and name and name ~= "" then return name end
        end
        local okId,rid = pcall(function() return pn.RowId end)
        if okId and type(rid) == "number" then
            local place = Excel.GetSheet("PlaceName"); if not place then return nil end
            local prow  = place:GetRow(rid);           if not prow  then return nil end
            local ok3,name = pcall(function() return prow.Singular or prow.Name or prow:ToString() end)
            if ok3 and name and name ~= "" then return name end
        end
        return nil
    end

    if type(pn) == "number" then
        local place = Excel.GetSheet("PlaceName"); if not place then return nil end
        local prow  = place:GetRow(pn);            if not prow  then return nil end
        local ok,name = pcall(function() return prow.Singular or prow.Name or prow:ToString() end)
        if ok and name and name ~= "" then return name end
    end

    return nil
end

function ObjName(o)
    if not o then return nil end
    local ok, name = pcall(function()
        if o.Name and o.Name.GetText then return o.Name:GetText() end
        if o.Name then return tostring(o.Name) end
        return nil
    end)
    if ok then return name end
    return nil
end

function FindNearestByName(wantName, maxDist)
    maxDist = maxDist or 80
    local me = Svc.ClientState.LocalPlayer
    if not me then return nil end
    local best, bestD = nil, 999999
    for o in luanet.each(Svc.Objects) do
        local n = ObjName(o)
        if n and n == wantName and o.Position then
            local d = GetDistance(me.Position, o.Position)
            if d < bestD and d <= maxDist then
                best, bestD = o, d
            end
        end
    end
    return best
end

function GetRandomSpotAround(radius, minDist)
    minDist = minDist or 0
    if not SpotPos or #SpotPos == 0 then return nil end
    if #SpotPos == 1 then
        LastSpotIndex = 1
        return SpotPos[1]
    end

    local spotIndex
    repeat
        spotIndex = math.random(1, #SpotPos)
    until spotIndex ~= LastSpotIndex
    LastSpotIndex = spotIndex

    local center = SpotPos[spotIndex]
    local u = math.random()
    local distance = math.sqrt(u) * (radius - minDist) + minDist
    local angle = math.random() * 2 * math.pi

    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance

    return Pos(center.X + offsetX, center.Y, center.Z + offsetZ)
end

function PrePositionAtBell()
    while IsBetweenAreas() or IsPlayerCasting() do
        Wait(0.5)
    end

    if not DiscoveredZone then
        ActiveZone = GetActiveZone()
        if ActiveZone then
            DiscoverZoneHub(ActiveZone)
            DiscoveredZone = true
        end
    end

    -- Prefer the actual bell object; fallback to zone.gateHub (usually bell pos)
    local bellObj = FindNearestByName("Summoning Bell", 120)
    local target = nil

    if bellObj and bellObj.Position then
        target = PosFrom(bellObj.Position)
    elseif ActiveZone.gateHub then
        target = ActiveZone.gateHub
    end

    if not target then
        LogInfo(string.format("%s PrePosition: Summoning Bell not found yet.", LogPrefix))
        return false
    end

    -- only move if not already close
    if GetDistanceToPoint(target.X, target.Y, target.Z) > 6 then
        LogInfo(string.format("%s PrePosition: Moving near Summoning Bell...", LogPrefix))
        MoveTo(target.X, target.Y, target.Z, 3, false)
        Wait(0.5)
    else
        LogInfo(string.format("%s PrePosition: Already near Summoning Bell.", LogPrefix))
    end

    DiscoveredZone = true
    return true
end

function CurrentexJobs2H()
    local h = GetEorzeaHour()
    local slot = math.floor(h / 2) * 2
    local jobs = ExJobs2H[slot]
    return jobs and jobs[1] or nil
end

function CurrentexJobs4H()
    local h = GetEorzeaHour()
    local slot = math.floor(h / 4) * 4
    local jobs = ExJobs4H[slot]
    return jobs and jobs[1] or nil
end

function IsDoLAbbr(abbr)
    return abbr == "MIN" or abbr == "BTN" or abbr == "FSH"
end

function IsDoHAbbr(abbr)
    return abbr == "CRP" or abbr == "BSM" or abbr == "ARM" or abbr == "GSM" or abbr == "LTW" or abbr == "WVR" or abbr == "ALC" or abbr == "CUL"
end

function RetrieveClassScore()
    ClassScoreAll = {}
    if not IsAddonReady("WKSScoreList") then
        Execute("/callback WKSHud true 18")
        Wait(0.5)
    end
    local scoreAddon = Addons.GetAddon("WKSScoreList")
    local dohRowIds = {2, 21001, 21002, 21003, 21004, 21005, 21006, 21007}
    for _, rowId in ipairs(dohRowIds) do
        local nameNode  = scoreAddon:GetNode(1, 2, 7, rowId, 4)
        local scoreNode = scoreAddon:GetNode(1, 2, 7, rowId, 5)
        if nameNode and scoreNode then
            table.insert(ClassScoreAll, { className = string.lower(nameNode.Text), classScore = scoreNode.Text })
        end
    end
    local dolRowIds = {2, 21001, 21002}
    for _, rowId in ipairs(dolRowIds) do
        local nameNode  = scoreAddon:GetNode(1, 8, 13, rowId, 4)
        local scoreNode = scoreAddon:GetNode(1, 8, 13, rowId, 5)
        if nameNode and scoreNode then
            table.insert(ClassScoreAll, { className = string.lower(nameNode.Text), classScore = scoreNode.Text })
        end
    end
    for _, entry in ipairs(ClassScoreAll) do
        if Player.Job.Name == entry.className then
            return entry.classScore
        end
    end
    return nil
end

function GetActiveZone()
    local tt = Svc.ClientState.TerritoryType

    if tt == SinusTerritory then return Zones.sinus end
    if tt == PhaennaTerritory then return Zones.phaenna end
    if tt == OizysTerritory then return Zones.oizys end

    local place = PlaceNameByTerritory(tt)
    if not place then return nil end

    local p = string.lower(place)

    for _, zone in pairs(Zones) do
        for _, token in ipairs(zone.match or {}) do
            if string.find(p, token, 1, true) then
                return zone
            end
        end
    end

    return nil
end

function DiscoverZoneHub(zone)
    if not zone or zone.discovered then return end

    if zone.creditNpc and zone.creditNpc.id and not zone.creditNpc.name then
        local name = GetENpcResidentName(zone.creditNpc.id)
        zone.creditNpc.name = name
    end

    local bell      = FindNearestByName("Summoning Bell", 80)
    local standings = FindNearestByName("Scanningway", 80)
    local kaede     = FindNearestByName("Kaede", 80)

    local creditObj = nil
    if zone.creditNpc and zone.creditNpc.name then
        creditObj = FindNearestByName(zone.creditNpc.name, 80)
        if creditObj and creditObj.Position then
            zone.creditNpc.position = PosFrom(creditObj.Position) -- table
        end
    end

    zone.spots = {}

    local function addSpot(obj)
        if obj and obj.Position then
            table.insert(zone.spots, PosFrom(obj.Position)) -- table
        end
    end

    addSpot(bell)
    addSpot(creditObj)
    addSpot(standings)
    addSpot(kaede)

    if bell and bell.Position then
        zone.gateHub = PosFrom(bell.Position) -- table
    else
        local me = Svc.ClientState.LocalPlayer
        zone.gateHub = (me and me.Position) and PosFrom(me.Position) or zone.gateHub -- table
    end

    if zone.creditNpc and zone.creditNpc.position then
        if #zone.spots == 0 then
            table.insert(zone.spots, zone.creditNpc.position)
        end
        zone.discovered = true
        LogInfo(string.format("%s %s hub detected (dynamic hub ready).", LogPrefix, tostring(zone.key)))
    end
end

function ShouldCredit()
    if not ActiveZone or not ActiveZone.creditNpc then return end
    local npc = ActiveZone.creditNpc
    if not npc.position then return end

    if LunarCredits >= LimitConfig and IsPlayerAvailable() then
        Execute("/at enable")
        EnabledAutoText = true

        LogInfo(string.format("%s Credits: %s/%s Going to Gamba!", LogPrefix, tostring(LunarCredits), tostring(LimitConfig)))

        if ActiveZone.gateHub and GetDistanceToPoint(ActiveZone.gateHub.X, ActiveZone.gateHub.Y, ActiveZone.gateHub.Z) > 75 then
            LogInfo(string.format("%s Stellar Return", LogPrefix))
            Execute('/gaction "Duty Action"')
            Wait(5)
        end

        while IsBetweenAreas() or IsPlayerCasting() do
            Wait(0.5)
        end

        MoveTo(npc.position.X, npc.position.Y, npc.position.Z, 5, false)
        LogInfo(string.format("%s Arrived near Gamba NPC: %s", LogPrefix, tostring(npc.name)))

        Interact(npc.name)
        Wait(1)

        WaitForAddon("SelectString", 60)
        if IsAddonReady("SelectString") then Execute("/callback SelectString true 0"); Wait(1) end

        WaitForAddon("SelectString", 60)
        if IsAddonReady("SelectString") then Execute("/callback SelectString true 0"); Wait(1) end

        while IsOccupiedInQuestEvent() do
            Wait(1)
        end

        local job = Player.Job
        if job.IsCrafter then
            AroundSpot = GetRandomSpotAround(SpotRadius, MinRadius)
            if AroundSpot then
                MoveTo(AroundSpot.X, AroundSpot.Y, AroundSpot.Z, 3, false)
            end
        end

        if EnabledAutoText then
            Execute("/at disable")
            EnabledAutoText = false
        end

        Wait(1)
        Execute("/ice start")
    end
end

function ShouldCycle()
    if LimitConfig > 0 and LunarCredits >= LimitConfig then return end

    if IsPlayerAvailable() then
        if (IsAddonReady("WKSMission")
        or IsAddonReady("WKSMissionInfomation")
        or IsAddonReady("WKSReward")
        or Player.IsBusy) then
            CycleCount = 0
            return
        else
            CycleCount = CycleCount + 1
        end
    end

    if CycleCount > 0 and CycleCount % 20 == 0 then
        LogInfo(string.format("%s Job Cycle ticks: %d/%d", LogPrefix, CycleCount, CycleLoops))
    end

    if CycleCount >= CycleLoops then
        if JobCount == TotalJobs then
            LogInfo(string.format("%s End of job list reached. Exiting script.", LogPrefix))
            Run_script = false
            return
        end
        LogInfo(string.format("%s Swapping to -> %s", LogPrefix, tostring(JobsConfig[JobCount])))
        Execute("/equipjob " .. JobsConfig[JobCount])
        Wait(2)
        Execute("/ice start")
        JobCount = JobCount + 1
        CycleCount = 0
    end
end

function ShouldExTime()
    local CurJob = Player.Job.Abbreviation

    if Ex4TimeConfig then
        local Cur4ExJob = CurrentexJobs4H()

        if Cur4ExJob and (IsDoLAbbr(Cur4ExJob) or not IsDoHAbbr(Cur4ExJob)) then
            return
        end

        if Cur4ExJob and CurJob ~= Cur4ExJob then
            local waitcount = 0
            while IsAddonReady("WKSMissionInfomation") do
                Wait(0.1)
                waitcount = waitcount + 1
                if waitcount >= 50 then
                    LogInfo(string.format("%s Waiting for mission to end to swap to EX+ job.", LogPrefix))
                    waitcount = 0
                end
            end
            Execute("/ice stop")
            Wait(1)
            LogInfo(string.format("%s Current EX+ time: %d swapping to %s", LogPrefix, GetEorzeaHour(), tostring(Cur4ExJob)))
            Execute("/equipjob " .. Cur4ExJob)
            Wait(1)
            Execute("/ice start")
        end

    elseif Ex2TimeConfig then
        local Cur2ExJob = CurrentexJobs2H()

        if Cur2ExJob and (IsDoLAbbr(Cur2ExJob) or not IsDoHAbbr(Cur2ExJob)) then
            return
        end

        if Cur2ExJob and CurJob ~= Cur2ExJob then
            local waitcount = 0
            while IsAddonReady("WKSMissionInfomation") do
                Wait(0.1)
                waitcount = waitcount + 1
                if waitcount >= 50 then
                    LogInfo(string.format("%s Waiting for mission to end to swap to EX+ job.", LogPrefix))
                    waitcount = 0
                end
            end
            Execute("/ice stop")
            Wait(1)
            LogInfo(string.format("%s Current EX+ time: %d swapping to %s", LogPrefix, GetEorzeaHour(), tostring(Cur2ExJob)))
            Execute("/equipjob " .. Cur2ExJob)
            Wait(1)
            Execute("/ice start")
        end
    end
end

function ShouldReport()
    local curJob = Player.Job
    while IsAddonReady("WKSMissionInfomation") and curJob.IsCrafter do
        while IsAddonReady("WKSRecipeNotebook") and IsPlayerAvailable() do
            Wait(0.1)
            ReportCount = ReportCount + 1
            if ReportCount >= 50 then
                Execute("/callback WKSMissionInfomation true 11")
                LogInfo(string.format("%s Reporting failed mission.", LogPrefix))
                ReportCount = 0
            end
        end
        ReportCount = 0
        Wait(0.1)
    end
end

--=========================== EXECUTION ==========================--

LogInfo(string.format("%s Cosmic Helper started!", LogPrefix))

if JobsConfig.Count > 0 and not HasPlugin("SimpleTweaksPlugin") then
    LogInfo(string.format("%s Cycling jobs requires SimpleTweaks plugin. Script will continue without changing jobs.", LogPrefix))
    JobsConfig = nil
end
if LimitConfig > 0 and not HasPlugin("TextAdvance") then
    LogInfo(string.format("%s Credit spending for Gamba requires TextAdvance plugin. Script will continue without playing Gamba.", LogPrefix))
    LimitConfig = 0
end
if Ex4TimeConfig and Ex2TimeConfig then
    LogInfo(string.format("%s Both EX+ modes not supported. Using EX+ 4HR only.", LogPrefix))
    Ex2TimeConfig = false
end

Execute("/tweaks enable EquipJobCommand true")

TotalJobs = (JobsConfig and JobsConfig.Count) or 0

while Run_script do
    ActiveZone = GetActiveZone()
    if ActiveZone then
        DiscoverZoneHub(ActiveZone)
    end

    PrePositionAtBell()
    Wait(0.2)

    if ActiveZone == Zones.oizys then
        ExJobs4H = ExJobs4H_Oizys
        ExJobs2H = ExJobs2H_Oizys
    else
        ExJobs4H = ExJobs4H_Default
        ExJobs2H = ExJobs2H_Default
    end

    if IsAddonReady("WKSHud") then
        local txt = Addons.GetAddon("WKSHud"):GetNode(1, 15, 17, 3).Text:gsub("[^%d]", "")
        LunarCredits = ToNumber(txt)
    end

    if LimitConfig > 0 then
        ShouldCredit()
    end
    if FailedConfig then
        ShouldReport()
    end
    if Ex2TimeConfig or Ex4TimeConfig then
        ShouldExTime()
    end
    if TotalJobs > 0 then
        ShouldCycle()
    end

    Wait(LoopDelay)
end

Echo(string.format("Tokens Farming script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Tokens Farming script completed successfully..!!", LogPrefix))

--============================== END =============================--