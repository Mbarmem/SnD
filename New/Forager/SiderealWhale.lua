--[=====[
[[SND Metadata]]
author: Mo
version: 1.0.0
description: Forager - SiderealWhale - Unattended Sidereal Whale campaign (Ultima Thule, Limne 3-b)
plugin_dependencies:
- AutoHook
- Lifestream
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  LeadHours:
    description: Hours before the whale window to arrive and start pre-farming Phallaina. 3h = 2 attempts, 4h = 3, 5h = 4.
    default: 5
    min: 1
    max: 12
  PrepLeadSeconds:
    description: Seconds before a window opens to move to the spot and start the preset.
    default: 1200
    min: 300
    max: 3600
  ForceQuitDelaySeconds:
    description: Seconds to keep fishing after a window closes before forcing a quit.
    default: 15
    min: 0
    max: 120
  ScanHorizonDays:
    description: Days ahead to scan for the next whale window.
    default: 7
    min: 1
    max: 30
  MinInventoryFreeSlots:
    description: Warn on arrival if fewer than this many inventory slots are free.
    default: 5
    min: 1
    max: 30
  UseIdleTeleport:
    description: Teleport to the Lifestream auto destination while waiting and when finished.
    default: true
  TestModeOneCycle:
    description: Test run. Skips the whale forecast, does one Phallaina cycle at the next ET 0:00, then stops.
    default: false

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LeadHours             = Config.Get("LeadHours")
PrepLeadSeconds       = Config.Get("PrepLeadSeconds")
ForceQuitDelaySeconds = Config.Get("ForceQuitDelaySeconds")
ScanHorizonDays       = Config.Get("ScanHorizonDays")
MinInventoryFreeSlots = Config.Get("MinInventoryFreeSlots")
UseIdleTeleport       = Config.Get("UseIdleTeleport")
TestModeOneCycle      = Config.Get("TestModeOneCycle")
LogPrefix             = "[SiderealWhale]"

--------------------
--    Campaign    --
--------------------

local whaleWindowStart     = nil
local phallainaWindowStart = nil
local nextSpotIndex        = 1
local idleTeleported       = false
local testCycleDone        = false
local finished             = false

-------------------
--    Catches    --
-------------------

local chatCatches      = {}
local baselineItems    = {}
local baselineCaptured = false

--------------------
--    Intuition   --
--------------------

local intuitionActive   = false
local intuitionGainedAt = nil
local intuitionCycles   = 0
local intuitionSeconds  = 0

-------------------
--    Session    --
-------------------

local sessionActive    = false
local sessionEndsAt    = nil
local sessionLabel     = nil
local quitRequestedAt  = nil
local lastStartAttempt = 0

-------------------
--    Logging    --
-------------------

local loggedFirstChat   = false
local loggedFirstLand   = false
local lastWaitKey       = nil
local lastWaitAt        = 0
local lastSkippedWindow = nil
local loggedDivergence  = {}

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

-----------------
--    Timing   --
-----------------

EorzeaDaySeconds       = 4200
WeatherPeriodSeconds   = 1400
PhallainaWindowLength  = 700
MinWindowSeconds       = 120
StartRetrySeconds      = 10
WaitHeartbeatSeconds   = 300
ArrivalTolerance       = 3.0
MountDistanceThreshold = 150

-----------------
--    Target   --
-----------------

ZoneId               = 960
ZoneName             = "Ultima Thule"
Aetheryte            = "Abode of the Ea"
SpotName             = "Limne 3-b"

WeatherAstromagnetic = 149
WeatherUmbralWind    = 49

BaitItemId           = 36597
CordialItemId        = 12669

PresetPrepJail       = "Sidereal Whale - 1 - Prep Whale Jail"
PresetPerfectJail    = "Sidereal Whale - 4a - Perfect Jail prepped HE + Stacks"

FishPhallaina        = "Phallaina"
FishUnbegotten       = "Unbegotten"
FishEBE              = "E.B.E.-9318"
FishSiderealWhale    = "Sidereal Whale"

StatusIntuition      = 568

TrackedFishItemIds = {
    [FishPhallaina]     = 36521,
    [FishUnbegotten]    = 36520,
    [FishEBE]           = 36519,
    [FishSiderealWhale] = 41412,
}

CatchMarkers         = { "You land", "You catch", "ilms" }
ChatterMarkers       = { "AutoHook", "preset", "Preset", "[SiderealWhale]" }

--------------------
--    Positions   --
--------------------

BaseSpot = {
    name = "Base (island centre)",
    x = 177.90, y = 235.00, z = -218.64,
}

PhallainaSpots = {
    { name = "Phallaina 1 (west)",      x = 116.71, y = 231.36, z = -184.94 },
    { name = "Phallaina 2 (east)",      x = 241.63, y = 234.05, z = -197.32 },
    { name = "Phallaina 3 (northwest)", x = 132.88, y = 233.42, z = -263.78 },
    { name = "Phallaina 4 (south)",     x = 191.09, y = 231.84, z = -138.05 },
}

WhaleSpot = {
    name = "Whale window",
    x = 212.21, y = 233.85, z = -268.79,
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Utility    --
-------------------

function LogWait(key, message, ...)
    local now = os.time()
    if lastWaitKey == key and (now - lastWaitAt) < WaitHeartbeatSeconds then
        return
    end
    lastWaitKey = key
    lastWaitAt  = now
    LogInfo(message, ...)
end

function ChangeState(newState, label)
    lastWaitKey = nil
    lastWaitAt  = 0
    State = newState
    LogInfo("%s State Changed -> %s", LogPrefix, label)
end

function FormatDuration(seconds)
    if not seconds then
        return "unknown"
    end
    seconds = math.max(0, math.floor(seconds))
    return string.format("%dh%02dm%02ds", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
end

function FormatEorzeaClock(unixSeconds)
    local hour, minute = GetEorzeaTime(unixSeconds)
    return string.format("ET %02d:%02d", hour, minute)
end

---------------------------
--    Catch counting     --
---------------------------

function GetTotalItemCount(itemId)
    local normal = Inventory.GetItemCount(itemId) or 0
    local hq     = Inventory.GetHqItemCount(itemId) or 0
    return normal + hq
end

function CaptureCatchBaseline()
    if baselineCaptured then
        return
    end
    baselineCaptured = true

    for name, itemId in pairs(TrackedFishItemIds) do
        chatCatches[name]   = 0
        baselineItems[name] = GetTotalItemCount(itemId)
        LogInfo("%s Catch baseline: %s x%d in inventory.", LogPrefix, name, baselineItems[name])
    end
end

function GetCatchTotal(name)
    local chat   = chatCatches[name] or 0
    local itemId = TrackedFishItemIds[name]
    local base   = baselineItems[name]

    if not itemId or not base then
        return chat
    end

    local delta = math.max(0, GetTotalItemCount(itemId) - base)
    return math.max(chat, delta)
end

function IsWhaleCaught()
    return GetCatchTotal(FishSiderealWhale) >= 1
end

function ReportCatchSignalDivergence()
    for name, itemId in pairs(TrackedFishItemIds) do
        local base = baselineItems[name]
        if base and not loggedDivergence[name] then
            local chat  = chatCatches[name] or 0
            local delta = math.max(0, GetTotalItemCount(itemId) - base)
            if chat ~= delta then
                loggedDivergence[name] = true
                LogInfo("%s NOTE: %s catch signals disagree - chat saw %d, inventory saw %d. Using the higher.", LogPrefix, name, chat, delta)
            end
        end
    end
end

function TrackIntuition()
    local active = HasStatusId(StatusIntuition) == true

    if active == intuitionActive then
        return
    end

    intuitionActive = active

    if active then
        intuitionGainedAt = os.time()
        intuitionCycles   = intuitionCycles + 1
        LogInfo("%s Fisher's Intuition GAINED (cycle %d). E.B.E.-9318 caught so far: %d.", LogPrefix, intuitionCycles, GetCatchTotal(FishEBE))
    else
        local held = intuitionGainedAt and (os.time() - intuitionGainedAt) or 0
        intuitionSeconds  = intuitionSeconds + held
        intuitionGainedAt = nil
        LogInfo("%s Fisher's Intuition EXPIRED after %s.", LogPrefix, FormatDuration(held))
    end
end

function DescribeIntuition()
    if intuitionCycles == 0 then
        return "Intuition never procced"
    end

    local total = intuitionSeconds
    if intuitionGainedAt then
        total = total + (os.time() - intuitionGainedAt)
    end

    return string.format("Intuition %d cycle(s), %s total", intuitionCycles, FormatDuration(total))
end

function IsPhallainaBanked()
    return GetCatchTotal(FishPhallaina) >= 1
end

function IsFodderComplete()
    return GetCatchTotal(FishPhallaina) >= 1 and GetCatchTotal(FishUnbegotten) >= 2
end

-----------------------
--    Forecasting    --
-----------------------

function GetEorzeaDayStart(unixSeconds)
    return math.floor(unixSeconds / EorzeaDaySeconds) * EorzeaDaySeconds
end

function GetNextPhallainaWindowStart(fromUnix, minRemaining)
    minRemaining = minRemaining or 0
    local dayStart = GetEorzeaDayStart(fromUnix)
    if fromUnix + minRemaining < dayStart + PhallainaWindowLength then
        return dayStart
    end
    return dayStart + EorzeaDaySeconds
end

function IsWhaleWindowStart(periodStart)
    local current  = GetCurrentWeatherId(ZoneId, periodStart + 60)
    local previous = GetCurrentWeatherId(ZoneId, periodStart - 60)
    return current == WeatherAstromagnetic and previous == WeatherUmbralWind
end

function FindNextWhaleWindow(fromUnix)
    local horizon    = ScanHorizonDays * 86400
    local period     = math.floor(fromUnix / WeatherPeriodSeconds)
    local lastPeriod = math.floor((fromUnix + horizon) / WeatherPeriodSeconds)

    while period <= lastPeriod do
        if period % 3 == 0 then
            local periodStart = period * WeatherPeriodSeconds
            if periodStart + WeatherPeriodSeconds > fromUnix and IsWhaleWindowStart(periodStart) then
                return periodStart
            end
        end
        period = period + 1
    end

    return nil
end

function GetPlannedAttemptCount()
    local usable = math.floor(((LeadHours * 3600) - PrepLeadSeconds) / EorzeaDaySeconds)
    return math.max(0, math.min(usable, #PhallainaSpots))
end

--------------------
--    Movement    --
--------------------

function HasCoordinates(spot)
    return spot ~= nil
        and type(spot.x) == "number"
        and type(spot.y) == "number"
        and type(spot.z) == "number"
end

function MoveToBase()
    if not HasCoordinates(BaseSpot) then
        LogInfo("%s WARNING: base has no coordinates.", LogPrefix)
        return false
    end

    WaitForNavMesh()

    local playerPos = GetPlayerPosition()
    local target    = Vector3(BaseSpot.x, BaseSpot.y, BaseSpot.z)
    local distance  = playerPos and GetDistance(playerPos, target) or math.huge

    if distance <= ArrivalTolerance then
        return true
    end

    if distance > MountDistanceThreshold and CanMount() then
        Mount()
        Wait(0.3)
        local fly = CanFly()
        LogInfo("%s %s to %s (%.1f, %.1f), %.0fy away.", LogPrefix, fly and "Flying" or "Riding", BaseSpot.name, BaseSpot.x, BaseSpot.z, distance)
        MoveTo(BaseSpot.x, BaseSpot.y, BaseSpot.z, 0, fly)
        while IsMounted() do
            Dismount()
            Wait(1)
        end
    else
        LogInfo("%s Walking to %s (%.1f, %.1f), %.0fy away.", LogPrefix, BaseSpot.name, BaseSpot.x, BaseSpot.z, distance)
        MoveTo(BaseSpot.x, BaseSpot.y, BaseSpot.z)
    end

    Wait(0.3)

    local landedPos = GetPlayerPosition()
    if not landedPos or GetDistance(landedPos, target) > ArrivalTolerance then
        LogInfo("%s Failed to reach %s.", LogPrefix, BaseSpot.name)
        return false
    end

    return true
end

function MoveToCastingSpot(spot)
    if not HasCoordinates(spot) then
        LogInfo("%s WARNING: %s has no coordinates - cannot move there.", LogPrefix, tostring(spot and spot.name))
        return false
    end

    WaitForNavMesh()

    local target = Vector3(spot.x, spot.y, spot.z)
    LogInfo("%s Walking out to %s (%.1f, %.1f).", LogPrefix, spot.name, spot.x, spot.z)

    while IsMounted() do
        Dismount()
        Wait(1)
    end

    MoveTo(spot.x, spot.y, spot.z)
    Wait(0.3)

    local arrivedPos = GetPlayerPosition()
    if not arrivedPos or GetDistance(arrivedPos, target) > ArrivalTolerance then
        LogInfo("%s Failed to reach %s.", LogPrefix, spot.name)
        return false
    end

    return true
end

---------------------
--    Prechecks    --
---------------------

function ValidateSpots()
    local problems = {}

    if not HasCoordinates(BaseSpot) then
        table.insert(problems, "BaseSpot")
    end
    for index, spot in ipairs(PhallainaSpots) do
        if not HasCoordinates(spot) then
            table.insert(problems, string.format("PhallainaSpots[%d]", index))
        end
    end
    if not HasCoordinates(WhaleSpot) then
        table.insert(problems, "WhaleSpot")
    end

    if #problems > 0 then
        LogInfo("%s Cannot run: missing coordinates for %s.", LogPrefix, table.concat(problems, ", "))
        LogInfo("%s Capture them with BigFishCoordCapture.lua at %s and fill in the tables at the top of this script.", LogPrefix, SpotName)
        return false
    end

    return true
end

function ReportConsumables()
    local baitCount    = GetItemCount(BaitItemId)
    local cordialCount = GetItemCount(CordialItemId)
    local freeSlots    = GetInventoryFreeSlotCount()

    LogInfo("%s Supplies: Stardust x%d, Hi-Cordial x%d, %d free inventory slots.", LogPrefix, baitCount, cordialCount, freeSlots)

    if baitCount <= 0 then
        LogInfo("%s WARNING: no Stardust - every preset in the chain force-swaps to it.", LogPrefix)
    end
    if cordialCount <= 0 then
        LogInfo("%s WARNING: no Hi-Cordial - Patience and Chum will stall on GP.", LogPrefix)
    end
    if freeSlots < MinInventoryFreeSlots then
        LogInfo("%s WARNING: only %d free inventory slots (want %d) - catches may not register.", LogPrefix, freeSlots, MinInventoryFreeSlots)
    end
end

-------------------
--    Fishing    --
-------------------

function StartSession(presetName, label, endsAt)
    if not IsPlayerAvailable() then
        return false
    end

    LogInfo("%s Selecting AutoHook preset '%s' (%s), running until %s.", LogPrefix, presetName, label, FormatEorzeaClock(endsAt))
    ClearAutoHookAnonymousPresets()
    SetAutoHookPreset(presetName)
    SetAutoHookState(true)
    Wait(1)

    sessionActive    = true
    sessionLabel     = label
    sessionEndsAt    = endsAt
    quitRequestedAt  = nil
    lastStartAttempt = 0

    KeepSessionFishing()
    return true
end

function KeepSessionFishing()
    if not sessionActive or quitRequestedAt then
        return
    end
    if IsFishing() or IsGathering() or not IsPlayerAvailable() then
        return
    end

    local now = os.time()
    if (now - lastStartAttempt) < StartRetrySeconds then
        return
    end

    lastStartAttempt = now
    Execute("/ahstart")
end

function StopSession(reason)
    if not sessionActive then
        return
    end

    LogInfo("%s Ending session (%s): %s", LogPrefix, tostring(sessionLabel), reason)
    ReportCatchSignalDivergence()
    SetAutoHookState(false)

    if IsFishing() or IsGathering() then
        ExecuteAction(CharacterAction.Actions.quitFishing)
        Wait(0.3)
    end

    sessionActive   = false
    sessionLabel    = nil
    sessionEndsAt   = nil
    quitRequestedAt = nil
end

function IsSessionComplete()
    if not sessionActive then
        return true
    end

    if not sessionEndsAt or os.time() < sessionEndsAt then
        return false
    end

    if IsFishing() or IsGathering() then
        if not quitRequestedAt then
            quitRequestedAt = os.time()
            LogInfo("%s Window closed for %s - forcing quit in %ds.", LogPrefix, tostring(sessionLabel), ForceQuitDelaySeconds)
        end
        if os.time() - quitRequestedAt >= ForceQuitDelaySeconds then
            ExecuteAction(CharacterAction.Actions.quitFishing)
            Wait(0.3)
        end
        return false
    end

    return true
end

function ContainsAny(message, markers)
    for _, marker in ipairs(markers) do
        if message:find(marker, 1, true) then
            return true
        end
    end
    return false
end

function GetCatchCount(message, fishName)
    if ContainsAny(message, ChatterMarkers) then
        return 0
    end
    if not message:find(fishName, 1, true) then
        return 0
    end
    if not ContainsAny(message, CatchMarkers) then
        return 0
    end

    return tonumber(message:match("[Yy]ou land (%d+)")) or 1
end

function OnChatMessage()
    if not loggedFirstChat then
        loggedFirstChat = true
        LogInfo("%s CHAT PROBE: handler is live. type=%s sender=%s messageType=%s message=%s", LogPrefix, tostring(TriggerData and TriggerData.type), tostring(TriggerData and TriggerData.sender), type(TriggerData and TriggerData.message), tostring(TriggerData and TriggerData.message))
    end

    local message = TriggerData and TriggerData.message

    if type(message) ~= "string" then
        return
    end

    if not loggedFirstLand and message:find("land", 1, true) then
        loggedFirstLand = true
        LogInfo("%s CHAT PROBE: first 'land' message seen verbatim: [%s]", LogPrefix, message)
    end

    local whale = GetCatchCount(message, FishSiderealWhale)
    if whale > 0 then
        chatCatches[FishSiderealWhale] = (chatCatches[FishSiderealWhale] or 0) + whale
        LogInfo("%s CAUGHT SIDEREAL WHALE: %s", LogPrefix, message)
        return
    end

    local phallaina = GetCatchCount(message, FishPhallaina)
    if phallaina > 0 then
        chatCatches[FishPhallaina] = (chatCatches[FishPhallaina] or 0) + phallaina
        LogInfo("%s Phallaina banked (%d total): %s", LogPrefix, GetCatchTotal(FishPhallaina), message)
        return
    end

    local unbegotten = GetCatchCount(message, FishUnbegotten)
    if unbegotten > 0 then
        chatCatches[FishUnbegotten] = (chatCatches[FishUnbegotten] or 0) + unbegotten
        LogInfo("%s Unbegotten caught (%d total).", LogPrefix, GetCatchTotal(FishUnbegotten))
        return
    end

    local ebe = GetCatchCount(message, FishEBE)
    if ebe > 0 then
        chatCatches[FishEBE] = (chatCatches[FishEBE] or 0) + ebe
        LogInfo("%s E.B.E.-9318 caught (%d total).", LogPrefix, GetCatchTotal(FishEBE))
    end
end

--============================ STATES ============================--

function CharacterState.awaitingCampaign()
    if TestModeOneCycle then
        LogInfo("%s TEST MODE: ignoring the whale forecast, running one Phallaina cycle.", LogPrefix)
        baselineCaptured = false
        ChangeState(CharacterState.travelToZone, "TravelToZone")
        return
    end

    whaleWindowStart = FindNextWhaleWindow(os.time())

    if not whaleWindowStart then
        LogWait("nowindow", "%s No Sidereal Whale window found within %d days. Waiting.", LogPrefix, ScanHorizonDays)
        Wait(60)
        return
    end

    if os.time() >= whaleWindowStart - PrepLeadSeconds then
        local skipped   = whaleWindowStart
        local nextStart = FindNextWhaleWindow(skipped + WeatherPeriodSeconds)

        if not nextStart then
            LogWait("nowindow", "%s No Sidereal Whale window found within %d days. Waiting.", LogPrefix, ScanHorizonDays)
            Wait(60)
            return
        end

        if lastSkippedWindow ~= skipped then
            lastSkippedWindow = skipped
            LogInfo("%s A whale window is already open or inside its prep lead - targeting the next one instead.", LogPrefix)
        end

        whaleWindowStart = nextStart
    end

    local campaignStart  = whaleWindowStart - (LeadHours * 3600)
    local secondsToStart = campaignStart - os.time()

    if secondsToStart > 0 then
        LogWait("waiting", "%s Next window in %s (%s). Campaign starts in %s, %d Phallaina attempt(s) planned.", LogPrefix, FormatDuration(whaleWindowStart - os.time()), FormatEorzeaClock(whaleWindowStart), FormatDuration(secondsToStart), GetPlannedAttemptCount())

        if UseIdleTeleport and not idleTeleported and IsPlayerAvailable()
            and not IsFishing() and not IsGathering() and not LifestreamIsBusy() then
            idleTeleported = true
            LogInfo("%s Parking at the Lifestream idle destination until the campaign starts.", LogPrefix)
            Teleport("auto")
        end

        Wait(10)
        return
    end

    idleTeleported   = false
    baselineCaptured = false
    LogInfo("%s Campaign starting. Window opens in %s.", LogPrefix, FormatDuration(whaleWindowStart - os.time()))
    ChangeState(CharacterState.travelToZone, "TravelToZone")
end

function CharacterState.travelToZone()
    if not IsInZone(ZoneId) then
        Teleport(Aetheryte)
        Wait(0.3)
        return
    end

    if not IsPlayerAvailable() then
        return
    end

    ReportConsumables()
    CaptureCatchBaseline()
    ChangeState(CharacterState.returnToBase, "ReturnToBase")
end

function CharacterState.returnToBase()
    if not IsInZone(ZoneId) then
        ChangeState(CharacterState.travelToZone, "TravelToZone")
        return
    end

    if not IsPlayerAvailable() then
        return
    end

    if not MoveToBase() then
        Wait(5)
        return
    end

    ChangeState(CharacterState.planning, "Planning")
end

function CharacterState.planning()
    local now = os.time()

    if TestModeOneCycle then
        if testCycleDone then
            LogInfo("%s TEST MODE: cycle complete.", LogPrefix)
            ChangeState(CharacterState.finish, "Finish")
            return
        end

        local windowStart = GetNextPhallainaWindowStart(now, MinWindowSeconds)
        local prepAt      = windowStart - PrepLeadSeconds

        if now >= prepAt then
            phallainaWindowStart = windowStart
            ChangeState(CharacterState.moveToPhallainaSpot, "MoveToPhallainaSpot")
            return
        end

        LogWait("testnext", "%s TEST MODE: now %s. Phallaina window at %s (in %s); moving out in %s.", LogPrefix, FormatEorzeaClock(now), FormatEorzeaClock(windowStart), FormatDuration(windowStart - now), FormatDuration(prepAt - now))
        Wait(10)
        return
    end

    whaleWindowStart = FindNextWhaleWindow(now)
    if not whaleWindowStart then
        LogInfo("%s Lost track of the whale window. Aborting.", LogPrefix)
        ChangeState(CharacterState.abort, "Abort")
        return
    end

    if now >= whaleWindowStart - PrepLeadSeconds then
        if IsPhallainaBanked() then
            if GetCatchTotal(FishUnbegotten) < 2 then
                LogInfo("%s WARNING: only %d Unbegotten seen and Intuition needs 2. Proceeding anyway - AutoHook's own counters decide.", LogPrefix, GetCatchTotal(FishUnbegotten))
            end
            LogInfo("%s Phallaina banked. Heading to the whale spot.", LogPrefix)
            ChangeState(CharacterState.moveToWhaleSpot, "MoveToWhaleSpot")
        else
            LogInfo("%s Whale window opens in %s but Phallaina was never caught - not attempting both in the last window.", LogPrefix, FormatDuration(whaleWindowStart - now))
            ChangeState(CharacterState.abort, "Abort")
        end
        return
    end

    if IsPhallainaBanked() then
        LogWait("banked", "%s Phallaina banked. Holding at base for %s until whale prep.", LogPrefix, FormatDuration((whaleWindowStart - PrepLeadSeconds) - now))
        Wait(10)
        return
    end

    if nextSpotIndex > #PhallainaSpots then
        LogWait("exhausted", "%s Phallaina spot rotation exhausted (%d used). Holding at base until whale prep.", LogPrefix, #PhallainaSpots)
        Wait(10)
        return
    end

    local windowStart = GetNextPhallainaWindowStart(now, MinWindowSeconds)
    local prepAt      = windowStart - PrepLeadSeconds

    if windowStart + PhallainaWindowLength > whaleWindowStart - PrepLeadSeconds then
        LogWait("nofit", "%s No further Phallaina window fits before whale prep. Holding at base.", LogPrefix)
        Wait(10)
        return
    end

    if now >= prepAt then
        phallainaWindowStart = windowStart
        ChangeState(CharacterState.moveToPhallainaSpot, "MoveToPhallainaSpot")
        return
    end

    LogWait("next", "%s Next Phallaina window at %s (in %s); moving out in %s. Spot %d/%d.", LogPrefix, FormatEorzeaClock(windowStart), FormatDuration(windowStart - now), FormatDuration(prepAt - now), nextSpotIndex, #PhallainaSpots)

    Wait(10)
end

function CharacterState.moveToPhallainaSpot()
    local spot = PhallainaSpots[nextSpotIndex]

    if not MoveToCastingSpot(spot) then
        LogInfo("%s Skipping %s and moving on.", LogPrefix, spot.name)
        nextSpotIndex = nextSpotIndex + 1
        ChangeState(CharacterState.returnToBase, "ReturnToBase")
        return
    end

    LogInfo("%s At %s (spot %d/%d).", LogPrefix, spot.name, nextSpotIndex, #PhallainaSpots)
    nextSpotIndex = nextSpotIndex + 1
    ChangeState(CharacterState.prefarm, "Prefarm")
end

function CharacterState.prefarm()
    if not sessionActive then
        local windowEnd = phallainaWindowStart + PhallainaWindowLength
        if os.time() >= windowEnd then
            LogInfo("%s Could not start a session before the Phallaina window closed.", LogPrefix)
            ChangeState(CharacterState.returnToBase, "ReturnToBase")
            return
        end
        if not StartSession(PresetPrepJail, "prefarm", windowEnd) then
            Wait(5)
        end
        return
    end

    if IsFodderComplete() then
        StopSession("fodder complete")
        testCycleDone = true
        LogInfo("%s Banked: Phallaina %d, Unbegotten %d.", LogPrefix, GetCatchTotal(FishPhallaina), GetCatchTotal(FishUnbegotten))
        ChangeState(CharacterState.returnToBase, "ReturnToBase")
        return
    end

    if IsSessionComplete() then
        StopSession("Phallaina window closed")
        testCycleDone = true
        LogInfo("%s Window over: Phallaina %d, Unbegotten %d.", LogPrefix, GetCatchTotal(FishPhallaina), GetCatchTotal(FishUnbegotten))
        ChangeState(CharacterState.returnToBase, "ReturnToBase")
        return
    end

    TrackIntuition()
    KeepSessionFishing()
    Wait(1)
end

function CharacterState.moveToWhaleSpot()
    if not MoveToCastingSpot(WhaleSpot) then
        LogInfo("%s Could not reach the whale spot - retrying.", LogPrefix)
        Wait(5)
        return
    end

    LogInfo("%s At %s. Whale window opens in %s.", LogPrefix, WhaleSpot.name, FormatDuration(whaleWindowStart - os.time()))
    ChangeState(CharacterState.whaleWindow, "WhaleWindow")
end

function CharacterState.whaleWindow()
    if not sessionActive then
        local windowEnd = whaleWindowStart + WeatherPeriodSeconds
        if os.time() >= windowEnd then
            LogInfo("%s Could not start a session before the whale window closed.", LogPrefix)
            ChangeState(CharacterState.finish, "Finish")
            return
        end
        if not StartSession(PresetPerfectJail, "whale window", windowEnd) then
            Wait(5)
        end
        return
    end

    if IsWhaleCaught() then
        StopSession("Sidereal Whale caught")
        ChangeState(CharacterState.finish, "Finish")
        return
    end

    if IsSessionComplete() then
        StopSession("whale window closed")
        ChangeState(CharacterState.finish, "Finish")
        return
    end

    TrackIntuition()
    KeepSessionFishing()
    Wait(1)
end

function CharacterState.abort()
    StopSession("aborting")

    if IsInZone(ZoneId) and IsPlayerAvailable() then
        MoveToBase()
    end

    LogInfo("%s Campaign aborted. Phallaina %d, Unbegotten %d, E.B.E. %d, %s, spots used %d/%d.", LogPrefix, GetCatchTotal(FishPhallaina), GetCatchTotal(FishUnbegotten), GetCatchTotal(FishEBE), DescribeIntuition(), nextSpotIndex - 1, #PhallainaSpots)
    ChangeState(CharacterState.finish, "Finish")
end

function CharacterState.finish()
    StopSession("finished")

    local outcome = IsWhaleCaught() and "SIDEREAL WHALE CAUGHT" or "Finished without the whale"
    LogInfo("%s %s. Phallaina %d, Unbegotten %d, E.B.E. %d, %s, spots used %d/%d.", LogPrefix, outcome, GetCatchTotal(FishPhallaina), GetCatchTotal(FishUnbegotten), GetCatchTotal(FishEBE), DescribeIntuition(), nextSpotIndex - 1, #PhallainaSpots)

    if UseIdleTeleport and IsPlayerAvailable() and not IsFishing() and not IsGathering() and not LifestreamIsBusy() then
        LogInfo("%s Returning to the Lifestream idle destination.", LogPrefix)
        Teleport("auto")
        Wait(3)
    end

    finished = true
end

--=========================== EXECUTION ==========================--

LogInfo("%s Target: %s at %s, %s.", LogPrefix, FishSiderealWhale, SpotName, ZoneName)
LogInfo("%s Lead time %dh, prep lead %ds, %d Phallaina attempt(s) planned across %d spot(s).", LogPrefix, LeadHours, PrepLeadSeconds, GetPlannedAttemptCount(), #PhallainaSpots)

if GetPlannedAttemptCount() < 1 then
    LogInfo("%s WARNING: LeadHours=%d leaves no room for a Phallaina window before whale prep. Raise it to at least 2.", LogPrefix, LeadHours)
end

if not ValidateSpots() then
    return
end

if not GetClassJobId(18) then
    LogInfo("%s Switching to Fisher.", LogPrefix)
    Execute("/gs change Fisher")
    Wait(1)
end

ChangeState(CharacterState.awaitingCampaign, "AwaitingCampaign")

while not finished do
    State()
    Wait(1)
end

LogInfo("%s Script finished.", LogPrefix)

--============================== END =============================--
