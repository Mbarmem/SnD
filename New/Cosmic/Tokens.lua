--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Script for Auto Fate
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

--========================= DEPENDENCIES =========================--

import("System.Numerics")

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LoopDelay  = .1           -- Controls how fast the script runs
CycleLoops = 100          -- How many loop iterations to run before cycling to the next job
SpotRadius = 3            -- Movement radius around chosen anchor
MinRadius  = .5           -- Minimum random offset distance

--=========================== FUNCTIONS ==========================--

function ToNumber(s)
    if type(s) ~= "string" then return ToNumber(s) end
    s = s:match("^%s*(.-)%s*$")
    s = s:gsub(",", "")
    return ToNumber(s)
end

function DistanceBetweenPositions(pos1, pos2)
    return Vector3.Distance(pos1, pos2)
end

function getEorzeaHour()
    local et = os.time() * 1440 / 70
    return math.floor((et % 86400) / 3600)
end

-- Resolve an ENpcResident name directly by DataId
function GetENpcResidentName(dataId)
    local sheet = Excel.GetSheet("ENpcResident")
    if not sheet then return nil, "ENpcResident sheet not available" end
    local row = sheet:GetRow(dataId)
    if not row then return nil, "no row for id "..tostring(dataId) end
    local name = row.Singular or row.Name
    return name, "ENpcResident"
end

--TerritoryType ID -> localized PlaceName (string or nil)
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

-- Object name helper
local function ObjName(o)
    if not o then return nil end
    local ok, name = pcall(function()
        if o.Name and o.Name.GetText then return o.Name:GetText() end
        if o.Name then return tostring(o.Name) end
        return nil
    end)
    if ok then return name end
    return nil
end

-- Find nearest object by display name
local function FindNearestByName(wantName, maxDist)
    maxDist = maxDist or 80
    local me = Svc.ClientState.LocalPlayer
    if not me then return nil end
    local best, bestD = nil, 999999
    for o in luanet.each(Svc.Objects) do
        local n = ObjName(o)
        if n and n == wantName and o.Position then
            local d = DistanceBetweenPositions(me.Position, o.Position)
            if d < bestD and d <= maxDist then
                best, bestD = o, d
            end
        end
    end
    return best
end

-- Random spot around pre-filled SpotPos
function GetRandomSpotAround(radius, minDist)
    minDist = minDist or 0
    if not SpotPos or #SpotPos == 0 then return nil end
    if #SpotPos == 1 then
        lastSpotIndex = 1
        return SpotPos[1]
    end
    local spotIndex
    repeat
        spotIndex = math.random(1, #SpotPos)
    until spotIndex ~= lastSpotIndex
    lastSpotIndex = spotIndex
    local center = SpotPos[spotIndex]
    local u = math.random()
    local distance = math.sqrt(u) * (radius - minDist) + minDist
    local angle = math.random() * 2 * math.pi
    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance
    return Vector3(center.X + offsetX, center.Y, center.Z + offsetZ)
end

-- Timed mission helpers
function currentexJobs2H()
    local h = getEorzeaHour()
    local slot = math.floor(h / 2) * 2
    local jobs = exJobs2H[slot]
    return jobs and jobs[1] or nil
end

function currentexJobs4H()
    local h = getEorzeaHour()
    local slot = math.floor(h / 4) * 4
    local jobs = exJobs4H[slot]
    return jobs and jobs[1] or nil
end

-- DoH-only swap guard
local function IsDoLAbbr(abbr)
  return abbr == "MIN" or abbr == "BTN" or abbr == "FSH"
end

local function IsDoHAbbr(abbr)
  return abbr == "CRP" or abbr == "BSM" or abbr == "ARM" or abbr == "GSM"
      or abbr == "LTW" or abbr == "WVR" or abbr == "ALC" or abbr == "CUL"
end

--[[ =========================================================
     Class Score (fix shadowing bug)
========================================================= ]]
function RetrieveClassScore()
    classScoreAll = {}
    if not IsAddonExists("WKSScoreList") then
        yield("/callback WKSHud true 18")
        Wait(.5)
    end
    local scoreAddon = Addons.GetAddon("WKSScoreList")
    local dohRowIds = {2, 21001, 21002, 21003, 21004, 21005, 21006, 21007}
    for _, rowId in ipairs(dohRowIds) do
        local nameNode  = scoreAddon:GetNode(1, 2, 7, rowId, 4)
        local scoreNode = scoreAddon:GetNode(1, 2, 7, rowId, 5)
        if nameNode and scoreNode then
            table.insert(classScoreAll, {
                className  = string.lower(nameNode.Text),
                classScore = scoreNode.Text
            })
        end
    end
    local dolRowIds = {2, 21001, 21002}
    for _, rowId in ipairs(dolRowIds) do
        local nameNode  = scoreAddon:GetNode(1, 8, 13, rowId, 4)
        local scoreNode = scoreAddon:GetNode(1, 8, 13, rowId, 5)
        if nameNode and scoreNode then
            table.insert(classScoreAll, {
                className  = string.lower(nameNode.Text),
                classScore = scoreNode.Text
            })
        end
    end
    for _, entry in ipairs(classScoreAll) do
        if Player.Job.Name == entry.className then
            return entry.classScore
        end
    end
    return nil
end

--[[ =========================================================
     Zone / Oizys Support
========================================================= ]]
SinusTerritory   = 1237
PhaennaTerritory = 1291

SinusGateHub   = Vector3(0,0,0)
PhaennaGateHub = Vector3(340.721, 52.864, -418.183)

-- NPC information (Sinus/Phaenna hardcoded like original)
SinusCreditNpc   = {name = GetENpcResidentName(1052612), position = Vector3(18.845, 2.243, -18.906)}
PhaennaCreditNpc = {name = GetENpcResidentName(1052642), position = Vector3(358.816, 53.193, -438.865)}

-- Spot anchors (Sinus/Phaenna)
SinusSpots = {
    Vector3(9.521,1.705,14.300),
    Vector3(8.870, 1.642, -13.272),
    Vector3(-9.551, 1.705, -13.721),
    Vector3(-12.039, 1.612, 16.360),
    Vector3(7.002, 1.674, -7.293),
    Vector3(5.471, 1.660, 5.257),
    Vector3(-6.257, 1.660, 6.100),
    Vector3(-5.919, 1.660, -5.678),
}

PhaennaSpots = {
    Vector3(355.522, 52.625, -409.623),
    Vector3(353.649, 52.625, -403.039),
    Vector3(356.086, 52.625, -434.961),
    Vector3(330.380, 52.625, -436.684),
    Vector3(319.037, 52.625, -417.655),
}

Zones = {
    sinus = { gateHub = SinusGateHub,   creditNpc = SinusCreditNpc,   spots = SinusSpots,   isOizys = false },
    phaenna = { gateHub = PhaennaGateHub, creditNpc = PhaennaCreditNpc, spots = PhaennaSpots, isOizys = false },
    oizys = {
        gateHub = nil, -- unknown, optional
        creditNpc = { name = "Orbitingway", position = nil },
        spots = {},
        discovered = false,
        isOizys = true
    }
}

function GetActiveZone()
    local tt = Svc.ClientState.TerritoryType
    if tt == SinusTerritory then return Zones.sinus end
    if tt == PhaennaTerritory then return Zones.phaenna end

    local place = PlaceNameByTerritory(tt)
    if place and string.find(string.lower(place), "oizys", 1, true) then
        return Zones.oizys
    end
    return nil
end

function DiscoverOizysHub(zone)
    if zone.discovered then return end

    local bell      = FindNearestByName("Summoning Bell", 80)
    local orbit     = FindNearestByName(zone.creditNpc.name, 80)
    local standings = FindNearestByName("Scanningway", 80)
    local kaede     = FindNearestByName("Kaede", 80)

    if orbit and orbit.Position then zone.creditNpc.position = orbit.Position end

    zone.spots = {}
    if bell and bell.Position then table.insert(zone.spots, bell.Position) end
    if orbit and orbit.Position then table.insert(zone.spots, orbit.Position) end
    if standings and standings.Position then table.insert(zone.spots, standings.Position) end
    if kaede and kaede.Position then table.insert(zone.spots, kaede.Position) end

    if #zone.spots >= 2 and zone.creditNpc.position then
        zone.discovered = true
        yield("/echo [Cosmic Helper] Oizys detected (dynamic hub ready).")
    end
end

--[[ =========================================================
     Worker Functions
========================================================= ]]

function ShouldCredit()
    if not ActiveZone or not ActiveZone.creditNpc then return end
    local npc = ActiveZone.creditNpc
    if not npc.position then return end

    if lunarCredits >= LimitConfig and Svc.Condition[CharacterCondition.normalConditions] and not Player.IsBusy then
        if not IPC.TextAdvance.IsEnabled() then
            yield("/at enable")
            EnabledAutoText = true
        end

        Dalamud.Log("[Cosmic Helper] Credits: " .. tostring(lunarCredits) .. "/" .. LimitConfig .. " Going to Gamba!")
        yield("/echo Credits: " .. tostring(lunarCredits) .. "/" .. LimitConfig .. " Going to Gamba!")

        curPos = Svc.ClientState.LocalPlayer.Position

        -- Stellar Return for Sinus/Phaenna only (Oizys gateHub unknown)
        if ActiveZone.gateHub and DistanceBetweenPositions(curPos, ActiveZone.gateHub) > 75 then
            Dalamud.Log("[Cosmic Helper] Stellar Return")
            yield('/gaction "Duty Action"')
            Wait(5)
        end

        while Svc.Condition[CharacterCondition.betweenAreas] or Svc.Condition[CharacterCondition.casting] do
            Wait(.5)
        end

        IPC.vnavmesh.PathfindAndMoveTo(npc.position, false)
        Dalamud.Log("[Cosmic Helper] Moving to Gamba NPC: " .. tostring(npc.name))
        Wait(1)

        while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
            Wait(.02)
            curPos = Svc.ClientState.LocalPlayer.Position
            if DistanceBetweenPositions(curPos, npc.position) < 5 then
                IPC.vnavmesh.Stop()
                break
            end
        end

        local e = Entity.GetEntityByName(npc.name)
        if e then
            Dalamud.Log("[Cosmic Helper] Targetting: " .. tostring(npc.name))
            e:SetAsTarget()
        end

        if Entity.Target and Entity.Target.Name == npc.name then
            Dalamud.Log("[Cosmic Helper] Interacting: " .. tostring(npc.name))
            Entity.Target:Interact()
            Wait(1)
        end

        while not IsAddonReady("SelectString") do Wait(1) end
        if IsAddonReady("SelectString") then yield("/callback SelectString true 0"); Wait(1) end
        while not IsAddonReady("SelectString") do Wait(1) end
        if IsAddonReady("SelectString") then yield("/callback SelectString true 0"); Wait(1) end

        while Svc.Condition[CharacterCondition.occupiedInQuestEvent] do
            Wait(1)
        end

        -- Move to a random nearby spot after Gamba (purely cosmetic / de-idle)
        local job = Player.Job
        if job.IsCrafter then
            aroundSpot = GetRandomSpotAround(SpotRadius, MinRadius)
            if aroundSpot then
                IPC.vnavmesh.PathfindAndMoveTo(aroundSpot, false)
                Wait(1)
                while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
                    Wait(.2)
                    curPos = Svc.ClientState.LocalPlayer.Position
                    if DistanceBetweenPositions(curPos, aroundSpot) < 3 then
                        IPC.vnavmesh.Stop()
                        break
                    end
                end
            end
        end

        if EnabledAutoText then
            yield("/at disable")
            EnabledAutoText = false
        end

        Wait(1)
        yield("/ice start")
    end
end

function ShouldCycle()
    if LimitConfig > 0 and lunarCredits >= LimitConfig then return end

    if Svc.Condition[CharacterCondition.normalConditions] then
        if (IsAddonExists("WKSMission")
        or IsAddonExists("WKSMissionInfomation")
        or IsAddonExists("WKSReward")
        or Player.IsBusy) then
            cycleCount = 0
            return
        else
            cycleCount = cycleCount + 1
        end
    end

    if cycleCount > 0 and cycleCount % 20 == 0 then
        yield("/echo [Cosmic Helper] Job Cycle ticks: " .. cycleCount .. "/" .. CycleLoops)
    end

    if cycleCount >= CycleLoops then
        if jobCount == totalJobs then
            yield("/echo [Cosmic Helper] End of job list reached. Exiting script.")
            Run_script = false
            return
        end
        yield("/echo [Cosmic Helper] Swapping to -> " .. JobsConfig[jobCount])
        yield("/equipjob " .. JobsConfig[jobCount])
        Wait(2)
        yield("/ice start")
        jobCount = jobCount + 1
        cycleCount = 0
    end
end

-- DoH-only EX timed swap
function ShouldExTime()
    local CurJob = Player.Job.Abbreviation

    if Ex4TimeConfig then
        local Cur4ExJob = currentexJobs4H()

        -- DoH-only: ignore DoL targets and unknown
        if Cur4ExJob and (IsDoLAbbr(Cur4ExJob) or not IsDoHAbbr(Cur4ExJob)) then
            return
        end

        if Cur4ExJob and CurJob ~= Cur4ExJob then
            local waitcount = 0
            while IsAddonExists("WKSMissionInfomation") do
                Wait(.1)
                waitcount = waitcount + 1
                if waitcount >= 50 then
                    yield("/echo [Cosmic Helper] Waiting for mission to end to swap to EX+ job.")
                    waitcount = 0
                end
            end
            yield("/ice stop")
            Wait(1)
            yield("/echo Current EX+ time: " .. getEorzeaHour() .. " swapping to " .. Cur4ExJob)
            yield("/equipjob " .. Cur4ExJob)
            Wait(1)
            yield("/ice start")
        end

    elseif Ex2TimeConfig then
        local Cur2ExJob = currentexJobs2H()

        -- DoH-only: ignore DoL targets and unknown
        if Cur2ExJob and (IsDoLAbbr(Cur2ExJob) or not IsDoHAbbr(Cur2ExJob)) then
            return
        end

        if Cur2ExJob and CurJob ~= Cur2ExJob then
            local waitcount = 0
            while IsAddonExists("WKSMissionInfomation") do
                Wait(.1)
                waitcount = waitcount + 1
                if waitcount >= 50 then
                    yield("/echo [Cosmic Helper] Waiting for mission to end to swap to EX+ job.")
                    waitcount = 0
                end
            end
            yield("/ice stop")
            Wait(1)
            yield("/echo Current EX+ time: " .. getEorzeaHour() .. " swapping to " .. Cur2ExJob)
            yield("/equipjob " .. Cur2ExJob)
            Wait(1)
            yield("/ice start")
        end
    end
end

function ShouldReport()
    local curJob = Player.Job
    while IsAddonExists("WKSMissionInfomation") and curJob.IsCrafter do
        while IsAddonExists("WKSRecipeNotebook") and Svc.Condition[CharacterCondition.normalConditions] do
            Wait(.1)
            reportCount = reportCount + 1
            if reportCount >= 50 then
                yield("/callback WKSMissionInfomation true 11")
                yield("/echo [Cosmic Helper] Reporting failed mission.")
                reportCount = 0
            end
        end
        reportCount = 0
        Wait(.1)
    end
end

--[[ =========================================================
     Script Settings
========================================================= ]]
JobsConfig      = Config.Get("Jobs")
LimitConfig     = Config.Get("Lunar Credits Limit")
FailedConfig    = Config.Get("Report Failed Missions")
Ex4TimeConfig   = Config.Get("EX+ 4hr Timed Missions")
Ex2TimeConfig   = Config.Get("EX+ 2hr Timed Missions")

Run_script      = true
reportCount     = 0
cycleCount      = 0
jobCount        = 0
lunarCredits    = 0
lastSpotIndex   = nil
EnabledAutoText = false
classScoreAll   = {}
ActiveZone      = nil
SpotPos         = {}

CharacterCondition = {
    normalConditions                   = 1,
    mounted                            = 4,
    crafting                           = 5,
    gathering                          = 6,
    casting                            = 27,
    occupiedInQuestEvent               = 32,
    occupied33                         = 33,
    occupiedMateriaExtractionAndRepair = 39,
    executingCraftingAction            = 40,
    preparingToCraft                   = 41,
    executingGatheringAction           = 42,
    betweenAreas                       = 45,
    jumping48                          = 48,
    occupiedSummoningBell              = 50,
    mounting57                         = 57,
    unknown85                          = 85,
}

-- Read Excel sheets for jobs
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

-- Timed mission jobs (Sinus/Phaenna default tables)
exJobs4H_Default = {
  [0]  = {Jobs[10].abbr}, -- ARM
  [4]  = {Jobs[11].abbr}, -- GSM
  [8]  = {Jobs[12].abbr}, -- LTW
  [12] = {Jobs[13].abbr}, -- WVR
  [16] = {Jobs[8].abbr},  -- CRP
  [20] = {Jobs[9].abbr},  -- BSM
}

exJobs2H_Default = {
  [0]  = {Jobs[12].abbr}, -- LTW
  [4]  = {Jobs[13].abbr}, -- WVR
  [8]  = {Jobs[14].abbr}, -- ALC
  [12] = {Jobs[15].abbr}, -- CUL
  [16] = {Jobs[10].abbr}, -- ARM
  [20] = {Jobs[11].abbr}, -- GSM
}

-- Oizys timed mission jobs (DoH-only; DoL windows omitted => nil)
exJobs4H_Oizys = {
  [0]  = {Jobs[10].abbr}, -- ARM
  [4]  = {Jobs[11].abbr}, -- GSM
  [8]  = {Jobs[12].abbr}, -- LTW
  [12] = {Jobs[13].abbr}, -- WVR
  [16] = {Jobs[8].abbr},  -- CRP
  [20] = {Jobs[9].abbr},  -- BSM
}

exJobs2H_Oizys = {
  [0]  = {Jobs[8].abbr},  -- CRP
  [2]  = {Jobs[15].abbr}, -- CUL
  [4]  = {Jobs[9].abbr},  -- BSM
  [6]  = {Jobs[14].abbr}, -- ALC
  [8]  = {Jobs[10].abbr}, -- ARM
  [12] = {Jobs[11].abbr}, -- GSM
  [16] = {Jobs[12].abbr}, -- LTW
  [20] = {Jobs[13].abbr}, -- WVR
}

-- Active tables (set in loop)
exJobs4H = exJobs4H_Default
exJobs2H = exJobs2H_Default

--[[ =========================================================
     Start of script loop
========================================================= ]]
yield("/echo Cosmic Helper started!")

-- Plugin checks (jump/move/relic/autoretainer removed)
if JobsConfig.Count > 0 and not HasPlugin("SimpleTweaksPlugin") then
    yield("/echo [Cosmic Helper] Cycling jobs requires SimpleTweaks plugin. Script will continue without changing jobs.")
    JobsConfig = nil
end
if LimitConfig > 0 and not HasPlugin("TextAdvance") then
    yield("/echo [Cosmic Helper] Credit spending for Gamba requires TextAdvance plugin. Script will continue without playing Gamba.")
    LimitConfig = 0
end
if Ex4TimeConfig and Ex2TimeConfig then
    yield("/echo [Cosmic Helper] Both EX+ modes not supported. Using EX+ 4HR only.")
    Ex2TimeConfig = false
end

-- Enable plugin options
yield("/tweaks enable EquipJobCommand true")

-- Initialize job counts safely
totalJobs = (JobsConfig and JobsConfig.Count) or 0

-- Main Loop
while Run_script do
    -- Zone detection + Oizys discovery
    ActiveZone = GetActiveZone()
    if ActiveZone == Zones.oizys then
        DiscoverOizysHub(ActiveZone)
        exJobs4H = exJobs4H_Oizys
        exJobs2H = exJobs2H_Oizys
    else
        exJobs4H = exJobs4H_Default
        exJobs2H = exJobs2H_Default
    end

    -- Bind SpotPos for random movement (used after Gamba only)
    SpotPos = (ActiveZone and ActiveZone.spots) or {}

    -- Credits from HUD
    if IsAddonExists("WKSHud") then
        lunarCredits = Addons.GetAddon("WKSHud"):GetNode(1, 15, 17, 3).Text:gsub("[^%d]", "")
        lunarCredits = ToNumber(lunarCredits)
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
    if totalJobs > 0 then
        ShouldCycle()
    end

    Wait(LoopDelay)
end