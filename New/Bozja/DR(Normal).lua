--[=====[
[[SND Metadata]]
author: Mo
version: 0.6.1
description: Delubrum Reginae Multi-Account - all accounts run the same recorded route, sync at bosses via combat, recover from trap deaths via raise. Role (register vs accept) via PrimaryPlayer.
plugin_dependencies:
- BossModReborn
- Lifestream
- RotationSolver
- SkipCutscene
- vnavmesh
- YesAlready
- AntiAfkKick-Dalamud
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  Accounts:
    description: |
      Expected party character names used for synchronization and stranger detection.
      Enter the exact character name and press enter. One account per line.
    default: []
  PrimaryPlayer:
    description: TRUE on the ONE account that registers at Sjeros. Others accept the Duty Ready pop.
    default: false
  MaxRuns:
    description: Number of clears (primary only; secondaries cycle until you stop them). 0 = infinite.
    default: 0
    min: 0
    max: 100
  RequiredPartySize:
    description: Party size required before registering / accepting entry.
    default: 5
    min: 1
    max: 8
  RepairThreshold:
    description: Gear % at which to repair (between runs). 0 to disable.
    default: 40
    min: 0
    max: 100
  DeathWait:
    description: Seconds to wait for a raise after a confirmed boss kill before returning alone.
    default: 180
  LootWait:
    description: Seconds to wait at the final chests before leaving.
    default: 5
  AbortOnStranger:
    description: Leave the duty if a non-whitelisted player is detected.
    default: true
  StrangerCooldown:
    description: Seconds to wait before requeueing after leaving because of a stranger.
    default: 3600
    min: 60
    max: 7200

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

AccountsConfig     = Config.Get("Accounts")
PrimaryPlayer      = Config.Get("PrimaryPlayer")
MaxRuns            = tonumber(Config.Get("MaxRuns")) or 0
RequiredPartySize  = tonumber(Config.Get("RequiredPartySize")) or 5
RepairThreshold    = tonumber(Config.Get("RepairThreshold")) or 40
DeathWait          = tonumber(Config.Get("DeathWait")) or 180
LootWait           = tonumber(Config.Get("LootWait")) or 5
AbortOnStranger    = Config.Get("AbortOnStranger")
StrangerCooldown   = tonumber(Config.Get("StrangerCooldown")) or 3600
LogPrefix          = "[DR(Normal)]"

StopFlag           = false -- Abort the current route pass.
StopScript         = false -- Hard-stop the whole script.
Wiped              = false -- Restart the route after returning to the entrance.
WipeLatched        = false -- Preserve a confirmed wipe while other accounts respawn.
WipeSeenAt         = nil   -- Start of the continuous full-wipe confirmation window.
WipeLatchedAt      = nil   -- Start of the synchronized return grace period.
SoloReturnAllowed  = false -- The current boss was confirmed dead while this account was down.

BossKilled         = {}    -- Cleared boss segments retained during route replay.
LootCollected      = {}    -- Collected coffers retained during route replay.
LastClearedSegment = nil   -- Rendezvous checkpoint for returning accounts.
ReplayingRoute     = false -- This account is catching up from the DR entrance.
RetryCount         = 0

StrangerCooldownUntil  = nil -- Requeue time after leaving because of a stranger.
UpcomingBossIndex      = nil -- Next boss segment reachable from the current route position.
ArenaJoinBossIndex     = nil -- Boss route requested by a sealed-area or crystal teleport.
ArenaJoinSource        = nil -- Source of the current route jump for accurate logging.
AiState                = nil
RotationState          = nil
WaypointsMoved         = 0
InTrapPassage          = false -- Enable the no-one-left-behind leash.

--------------------
--    Accounts    --
--------------------

-- SnD list configs are normally zero-indexed .NET collections. Accept plain
-- Lua tables and newline/comma-separated text as fallbacks for portability.
Accounts = {}
Whitelist = {}

local function AddConfiguredAccount(name)
    if name == nil then return end
    name = tostring(name):gsub("^%s+", ""):gsub("%s+$", "")
    local key = name:lower()
    if name ~= "" and not Whitelist[key] then
        Accounts[#Accounts + 1] = name
        Whitelist[key] = true
    end
end

local okCount, accountCount = pcall(function() return AccountsConfig and AccountsConfig.Count end)
if okCount and type(accountCount) == "number" then
    for i = 0, accountCount - 1 do
        AddConfiguredAccount(AccountsConfig[i])
    end
elseif type(AccountsConfig) == "table" then
    for _, name in ipairs(AccountsConfig) do
        AddConfiguredAccount(name)
    end
elseif type(AccountsConfig) == "string" then
    for name in AccountsConfig:gmatch("[^\r\n,]+") do
        AddConfiguredAccount(name)
    end
end

--============================ CONSTANT ==========================--

--------------------
--    Delubrum    --
--------------------

-- Delubrum Reginae fixed values (never change).
ZoneID          = 936
Gangos          = 915
HubAetheryte    = "Gangos"
EntryNpcId      = 1032080
EntryNpcX       = -29.862
EntryNpcY       = -0.4095392
EntryNpcZ       = -34.3786
MenuPath        = { 1, 0 }   -- Sjeros: "Delubrum Reginae." -> "Enter Delubrum Reginae."

------------------
--    Tuning    --
------------------

BoundTimeout           = 900 -- Wait through DR's approximately 10-minute muster.
EntryWait              = 20  -- Settle after loading before the first movement.
SlowStartCount         = 3   -- Number of opening waypoints with an extra regroup pause.
SlowStartWait          = 5   -- Pause after each slow-start waypoint.
StopDistance           = 3
WaypointTimeout        = 90  -- Maximum time to reach one waypoint.
BossTimeout            = 600 -- Interval between combat-helper watchdog restarts.
BossSettleTime         = 4   -- Out-of-combat time required to confirm a boss clear.

PartyCheckDelay        = 2
PartyGatherDist        = 20  -- Required proximity for party synchronization.
EntranceConfirmDist    = 80  -- Maximum distance from route start after a wipe return.
PostBossGatherTimeout  = 300 -- Maximum post-boss wait for a missing account.
PostBossStableTime     = 10  -- Continuous all-ready time before release.
PostBossReleaseGrace   = 3   -- Allow every account to latch stability before movement.
CatchUpGatherTimeout   = 30  -- Short checkpoint timeout for a late route replayer.

PadLandingDist         = 20  -- Landing-radius fallback when transition flags are missed.

-- "No one left behind" leash (trap passages): keep a rezzer in range of anyone who dies.
RaiseRange              = 28 -- Hold when a downed teammate is within RSR range.
RaiseHoldTimeout        = 90 -- Maximum hold for a nearby raise.
ConvoyDist              = 25 -- Distance at which a living teammate counts as a straggler.
ConvoyMargin            = 2  -- Route-distance tolerance for the behind-me check.
ConvoyTimeout           = 45 -- Maximum straggler wait at one waypoint.

-- Wipe detection (return-to-entrance retry): the whole party must read dead continuously for this
-- long before a wipe latches.
WipeConfirmWindow       = 30
WipeClickDelay          = 5  -- Let every account latch before the first one respawns.
SealedAreaPrompt        = "Move immediately to sealed area?"
TeleportCrystalName     = "Teleportation Crystal"
TeleportCrystalPrompt   = "Use the crystal to teleport?"
TeleportCrystalApproach = { 0.05, 0.00, 345.51 }
TeleportCrystalPosition = { -9.38, 0.11, 336.69 }
TeleportCrystalTimeout  = 30
TeleportCrystalMoveDist = 80 -- A large displacement confirms transport if zoning flags are missed.
ArenaTeleportSettleTime = 15 -- Never let Player.IsBusy block sealed-area route control for a whole fight.

--------------------------------------------------------------------
-- ROUTE (recorded). Each entry: Waypoints, optional TransitionDir (PathMoveDir
-- into a portal after the waypoints), optional Boss (nil = walk-in, gate on
-- combat-settle), optional WalkIn, optional Loot (Personal Spoils coords),
-- optional Exit (leave the duty).
--------------------------------------------------------------------
Route = {
    {
        Name      = "Trinity Seeker (to launch pad)",
        Waypoints = {
            {-2.84, 38.00, 471.59},
            {-4.62, 30.00, 438.68},
            {-1.81, 30.00, 424.05},
        },
        PadStart = { -0.95, 30.00, 422.36 },
        PadDir   = { 0, 0, -1 },
        PadLanding = { 0.29, 8.00, 312.97 },
    },
    {
        Name      = "Trinity Seeker",
        Boss      = "Trinity Seeker",
        Waypoints = {
            {0.29, 8.00, 312.97},
        },
        Loot      = { {0.02, 7.98, 258.38} },
    },
    {
        Name      = "Dahu",
        Boss      = "Dahu",
        TrapPause = true,   -- passage 1->2 has traps
        Waypoints = {
            {0.01, 8.00, 258.54},
            {0.48, 8.00, 227.62},
            {7.20, 8.00, 215.30},
            {78.68, 12.00, 210.47},
            {82.32, 12.00, 175.77},
        },
        Loot      = { {82.14, 11.98, 114.43} },
    },
    {
        Name          = "Queen's Guard (to lift)",
        Waypoints     = {
            {82.45, 12.00, 115.08},
            {79.00, 12.00, 107.00},   -- bridge the wp1->wp2 diagonal in short hops: vnav otherwise
            {73.00, 12.00, 93.00},    -- wanders north into the wall here and stalls ~10-30s
            {70.47, 12.02, 85.80},
            {70.18, 12.00, 44.62},
            {90.54, 12.00, 43.56},
        },
        PadStart = { 91.57, 12.00, 43.15 },   -- last on-mesh point; vnav can't path onto the pad itself
        PadDir   = { 1, 0, 0 },               -- push +X onto the lift; it launches you (Jumping) and warps down
        PadLanding = { 202.47, -72.00, -20.34 },
    },
    {
        Name      = "Queen's Guard",
        Boss      = "Queen's Knight",   -- 4 enemies; gate on combat-settle
        CombatSettleOnly = true,
        Waypoints = {
            {202.47, -72.00, -20.34},   -- first move off the pad after the lift lands
            {237.20, -80.00, -58.15},
            {243.73, -80.00, -76.56},
            {243.85, -86.78, -129.29},
        },
        Loot      = { {244.01, -86.02, -183.73} },
    },
    {
        Name      = "Bozjan Phantom",
        Boss      = "Bozjan Phantom",
        Waypoints = {
            {244.05, -86.00, -183.58},
            {244.06, -88.00, -247.17},
            {202.36, -96.00, -288.53},
            {201.88, -97.00, -338.27},
        },
        Loot      = { {201.98, -97.00, -396.72} },
    },
    {
        Name            = "Descend -> portal",
        TrapPause       = true,   -- passage 4->5 has traps
        Waypoints       = {
            {202.03, -97.00, -396.89},
            {213.68, -95.95, -429.00},
            {214.35, -100.00, -463.77},
            {208.07, -100.00, -463.57},
            {177.50, -100.00, -464.32},
            {175.65, -101.44, -448.88},
            {159.40, -105.59, -447.28},
        },
        TransitionStart = { 155.35, -106.89, -449.63 },   -- pathfind tightly onto the portal edge first
        TransitionDir   = { -0.90, 0, -0.44 },
    },
    {
        Name      = "Trinity Avowed",
        Boss      = "Trinity Avowed",
        TrapPause = true,   -- passage 4->5 has traps
        Waypoints = {
            {-229.70, -171.24, 33.05},
            {-237.44, -174.00, 18.09},
            {-271.78, -174.00, 17.23},
            {-272.17, -182.11, -46.47},
        },
        Loot      = { {-272.11, -182.02, -98.59} },
    },
    {
        Name      = "Descend to Queen (to lift)",
        Waypoints = {
            {-271.91, -182.00, -97.03},
            {-272.05, -182.00, -136.80},
        },
        PadStart = { -271.49, -182.00, -137.71 },   -- last on-mesh point before the jump
        PadDir   = { 0, 0, -1 },                     -- push -Z onto the lift; it launches you (Jumping) and warps down
        PadLanding = { -295.12, -182.00, -236.44 },
    },
    {
        Name      = "The Queen",
        Boss      = "The Queen",
        WalkIn    = true,
        Waypoints = {
            {-295.12, -182.00, -236.44},   -- first move off the pad after the lift lands
            {-294.86, -182.00, -261.05},
            {-272.96, -182.00, -272.06},
            {-272.52, -175.00, -355.80},
            {-272.53, -175.00, -372.27},
            {-272.21, -175.00, -406.66},
        },
        Loot      = {
            {-274.25, -175.01, -437.22},
            {-269.67, -175.01, -437.34},
        },
        Exit      = true,
    },
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Toggles    --
-------------------

function AiON()
    if AiState == true then return end
    AiState = true
    Execute("/bmrai on")
    Wait(0.3)
end

function AiOFF()
    if AiState == false then return end
    AiState = false
    Execute("/bmrai off")
    Wait(0.3)
end

function RotationON()
    if RotationState == "on" then return end
    RotationState = "on"
    Execute("/rotation auto")
    Wait(0.3)
end

function RotationOFF()
    if RotationState == "off" then return end
    RotationState = "off"
    Execute("/rotation off")
    Wait(0.3)
end

--- Enable the plugins the run depends on: YesAlready (dialogs/raise), RotationSolver, BMR AI.
function Setup()
    local myName = GetCharacterName()
    if not myName or myName == "" or not Whitelist[myName:lower()] then
        LogInfo(string.format("%s CONFIG ERROR: Accounts must include this character's exact name.", LogPrefix))
        return false
    end

    LogInfo(string.format("%s Enabling YesAlready + RotationSolver + BMR AI.", LogPrefix))
    SetYesAlready(true)
    RotationON()
    AiON()
    return true
end

------------------
--    Safety    --
------------------

--- Best-effort stranger detection (no ObjectKind): party roster + nearest other char.
function FindStranger()
    if not AbortOnStranger or next(Whitelist) == nil then return nil end
    local okLen, len = pcall(function() return Svc.Party.Length end)
    if okLen and len then
        for i = 0, len - 1 do
            local okN, nm = pcall(function()
                local m = Svc.Party[i]; return m and m.Name and m.Name.TextValue
            end)
            if okN and nm and nm ~= "" and not Whitelist[nm:lower()] then return nm end
        end
    end
    local okO, other = pcall(function() return Entity.NearestOtherCharacter end)
    if okO and other then
        local okNm, nm = pcall(function() return (other.Name and other.Name.TextValue) or other.Name end)
        if okNm and type(nm) == "string" and nm ~= "" and not Whitelist[nm:lower()] then return nm end
    end
    return nil
end

--- Settle after leaving DR without requiring us to observe the brief BetweenAreas transition.
function WaitForDutyExit(timeout)
    local deadline = os.time() + (timeout or 60)
    while GetZoneID() == ZoneID and os.time() < deadline do Wait(0.2) end
    WaitForPlayer()
end

function CheckStrangerAbort()
    if StrangerCooldownUntil and os.time() < StrangerCooldownUntil then return true end

    local stranger = FindStranger()
    if stranger then
        LogInfo(string.format("%s Stranger detected: %s -- leaving and cooling down for %d minute(s).", LogPrefix, stranger, math.ceil(StrangerCooldown / 60)))
        RotationOFF(); AiOFF(); PathStop()
        local leaveAttempts = 0
        while IsBoundByDuty() and not StopScript do
            leaveAttempts = leaveAttempts + 1
            LeaveInstance()
            Wait(2)
            if leaveAttempts % 10 == 0 and IsBoundByDuty() then
                LogInfo(string.format("%s Still bound after %d leave attempts -- continuing.", LogPrefix, leaveAttempts))
            end
        end
        if not IsBoundByDuty() then
            StrangerCooldownUntil = os.time() + StrangerCooldown
            WaitForDutyExit(60)
        end
        StopFlag = true
        return true
    end
    return false
end

function WaitForStrangerCooldown()
    if not StrangerCooldownUntil then return end

    RotationOFF()
    AiOFF()
    PathStop()
    local nextLogAt = 0
    while os.time() < StrangerCooldownUntil and not StopScript do
        if os.time() >= nextLogAt then
            local remaining = StrangerCooldownUntil - os.time()
            LogInfo(string.format("%s Stranger cooldown: %d minute(s) remaining.", LogPrefix, math.max(1, math.ceil(remaining / 60))))
            nextLogAt = os.time() + 300
        end
        Wait(10)
    end

    if not StopScript then
        StrangerCooldownUntil = nil
        StopFlag = false
        RotationON()
        AiON()
        LogInfo(string.format("%s Stranger cooldown complete -- resuming queue loop.", LogPrefix))
    end
end

local function ResetWipeState()
    WipeLatched = false
    WipeSeenAt = nil
    WipeLatchedAt = nil
end

local function PartyMemberName(member)
    local ok, name = pcall(function()
        if not member or not member.Name then return nil end
        return member.Name.TextValue or tostring(member.Name)
    end)
    return ok and name or nil
end

local function PartyMemberHp(member)
    local ok, hp = pcall(function()
        if member.CurrentHP ~= nil then return member.CurrentHP end
        return member.CurrentHp
    end)
    return ok and tonumber(hp) or nil
end

--- Are all configured accounts confirmed at 0 HP in the party roster? Missing or unreadable
--- members make this false; distance-based object visibility is never used to declare a wipe.
function IsFullWipe()
    local okLen, len = pcall(function() return Svc.Party.Length end)
    if not okLen or not len or len < 1 then return false end

    local expected = {}
    for _, accountName in ipairs(Accounts) do
        expected[string.lower(accountName)] = true
    end

    local seen = {}
    for i = 0, len - 1 do
        local member = Svc.Party[i]
        local name = PartyMemberName(member)
        local lname = name and string.lower(name) or nil
        if lname and expected[lname] then
            local hp = PartyMemberHp(member)
            if hp == nil or hp > 0 then return false end
            seen[lname] = true
        end
    end

    -- Some party-list implementations omit the local player; use the authoritative local state
    -- only for that one expected member.
    local myName = string.lower(GetCharacterName() or "")
    if expected[myName] and not seen[myName] then
        if not IsDead() then return false end
        seen[myName] = true
    end

    for lname in pairs(expected) do
        if not seen[lname] then return false end
    end
    return true
end

--- Latch a continuously observed full wipe, then wait an additional grace period before clicking.
--- The sticky latch prevents the first respawn from cancelling recovery on the other accounts.
function DetectWipe()
    if WipeLatched then
        return WipeLatchedAt ~= nil and (os.time() - WipeLatchedAt) >= WipeClickDelay
    end
    if IsFullWipe() then
        WipeSeenAt = WipeSeenAt or os.time()
        if (os.time() - WipeSeenAt) >= WipeConfirmWindow then
            WipeLatched = true
            WipeLatchedAt = os.time()
            LogInfo(string.format("%s Party wipe confirmed -- return begins in %ds.", LogPrefix, WipeClickDelay))
        end
    else
        WipeSeenAt = nil   -- not (yet) a full wipe -- reset the confirmation window
    end
    return false
end

--- Take DR's return-to-entrance prompt, then flag a route restart only after the callback actually
--- produces a living player. `allowSolo` is reserved for a boss confirmed dead while we were down.
function RecoverFromWipe(reason, allowSolo)
    if not IsDead() then return false end
    if not allowSolo and not WipeLatched then return false end

    LogInfo(string.format("%s Wipe recovery: %s -- returning to the entrance.", LogPrefix, reason))
    PathStop()
    local returnRequested = false
    local nextLogAt = os.time() + 15
    while IsDead() and IsBoundByDuty() and not StopScript do
        if IsAddonReady("SelectYesno") then
            Execute("/callback SelectYesno true 0")
            returnRequested = true
        elseif os.time() >= nextLogAt then
            LogInfo(string.format("%s Waiting for the return-to-entrance prompt.", LogPrefix))
            nextLogAt = os.time() + 15
        end
        Wait(0.5)
    end

    if IsDead() or not returnRequested then
        if not IsDead() then ResetWipeState() end
        return false
    end

    WaitForPlayer()
    Wait(2)

    local firstWaypoint = Route[1] and Route[1].Waypoints and Route[1].Waypoints[1]
    local entranceDistance = firstWaypoint and GetDistanceToPoint(firstWaypoint[1], firstWaypoint[2], firstWaypoint[3]) or nil
    if not entranceDistance or entranceDistance > EntranceConfirmDist then
        LogInfo(string.format("%s Revived away from the entrance -- treating it as a raise, not a route retry.", LogPrefix))
        SoloReturnAllowed = false
        ResetWipeState()
        RotationON()
        return false
    end

    RotationON()
    Wiped = true      -- only now, after a confirmed respawn
    StopFlag = true   -- unwind the current pass; RunInstance restarts the route
    ReplayingRoute = true
    SoloReturnAllowed = false
    ResetWipeState()
    return true
end

--- If dead outside a boss loop, prefer a raise. Return alone only after a confirmed boss kill;
--- a full-party wipe uses the independently latched recovery path immediately.
--- Returns true if we were dead (caller should re-issue movement afterwards).
function HandleDeath()
    if not IsDead() then return false end
    LogInfo(string.format("%s Died -- waiting for raise.", LogPrefix))
    PathStop()
    local deadSince = os.time()
    while IsDead() and not StopFlag and not StopScript and IsBoundByDuty() do
        if DetectWipe() then
            if RecoverFromWipe("full party wipe", false) then return true end
        elseif SoloReturnAllowed and (os.time() - deadSince) >= DeathWait then
            if RecoverFromWipe("boss cleared while down", true) then return true end
        end
        Wait(1)
    end

    if not IsDead() then
        LogInfo(string.format("%s Raised -- resuming.", LogPrefix))
        SoloReturnAllowed = false
        ResetWipeState()
        WaitForPlayer()
        Wait(2)               -- ride out the transition / weakness
        RotationON()
    end
    return true
end

--- Accept only the sealed-boss-arena teleport. RunInstance consumes ArenaJoinBossIndex
--- and discards every obsolete navigation or transition step before that boss.
function TryJoinSealedArea()
    if StopFlag or IsDead() or not UpcomingBossIndex or ArenaJoinBossIndex then return false end
    if not IsAddonReady("SelectYesno") then return false end

    local prompt = GetNodeText("SelectYesno", 1, 2)
    if type(prompt) ~= "string" or not string.find(prompt, SealedAreaPrompt, 1, true) then
        return false
    end

    local bossSegment = Route[UpcomingBossIndex]
    if not bossSegment or not (bossSegment.Boss or bossSegment.WalkIn) then return false end

    LogInfo(string.format("%s Sealed-area teleport offered -- joining %s and discarding stale navigation.", LogPrefix, bossSegment.Name))
    PathStop()

    local deadline = os.time() + 5
    while os.time() < deadline do
        if not IsAddonReady("SelectYesno") then break end
        local currentPrompt = GetNodeText("SelectYesno", 1, 2)
        if type(currentPrompt) ~= "string" or not string.find(currentPrompt, SealedAreaPrompt, 1, true) then
            break
        end
        Execute("/callback SelectYesno true 0")
        Wait(0.3)
    end

    if IsAddonReady("SelectYesno") then
        local currentPrompt = GetNodeText("SelectYesno", 1, 2)
        if type(currentPrompt) == "string" and string.find(currentPrompt, SealedAreaPrompt, 1, true) then
            LogInfo(string.format("%s Sealed-area callback did not close the prompt -- keeping the current route.", LogPrefix))
            return false
        end
    end

    ArenaJoinBossIndex = UpcomingBossIndex
    ArenaJoinSource = "sealed-area teleport"
    InTrapPassage = false
    PathStop()
    local settleDeadline = os.time() + ArenaTeleportSettleTime
    while os.time() < settleDeadline and (IsBetweenAreas() or not IsPlayerAvailable()) do Wait(0.2) end
    if not IsPlayerAvailable() then LogInfo(string.format("%s Sealed-area teleport still reports busy after %ds -- resuming route control anyway.", LogPrefix, ArenaTeleportSettleTime)) end
    Wait(1)
    return true
end

--- On a wipe replay, use DR's checkpoint crystal after the opening launch pad. A failed
--- interaction is non-fatal: RunInstance simply continues along the full recorded route.
function UseTeleportationCrystal()
    LogInfo(string.format("%s Wipe replay: attempting the Teleportation Crystal checkpoint.", LogPrefix))
    MoveToWaypoint(TeleportCrystalApproach[1], TeleportCrystalApproach[2], TeleportCrystalApproach[3])
    if StopFlag then return false end
    if ArenaJoinBossIndex then return true end

    if not MoveToTarget(TeleportCrystalName, 3) then
        LogInfo(string.format("%s Teleportation Crystal could not be reached -- continuing the full route.", LogPrefix))
        return false
    end
    PathStop()
    if not Interact(TeleportCrystalName) then
        LogInfo(string.format("%s Teleportation Crystal interaction failed -- continuing the full route.", LogPrefix))
        return false
    end

    local deadline = os.time() + TeleportCrystalTimeout
    while os.time() < deadline and not StopFlag and IsBoundByDuty() do
        if TryJoinSealedArea() then return true end
        if IsBetweenAreas() then
            WaitForPlayer()
            Wait(2)
            LogInfo(string.format("%s Teleportation Crystal transport confirmed.", LogPrefix))
            return true
        end

        local distance = GetDistanceToPoint(TeleportCrystalPosition[1], TeleportCrystalPosition[2], TeleportCrystalPosition[3])
        if distance and distance >= TeleportCrystalMoveDist then
            WaitForPlayer()
            Wait(2)
            LogInfo(string.format("%s Teleportation Crystal transport confirmed by displacement.", LogPrefix))
            return true
        end

        if IsAddonReady("SelectYesno") then
            local prompt = GetNodeText("SelectYesno", 1, 2)
            if type(prompt) == "string" and string.find(prompt, TeleportCrystalPrompt, 1, true) then
                Execute("/callback SelectYesno true 0")
            end
        end
        if CheckStrangerAbort() then return false end
        Wait(0.3)
    end

    PathStop()
    LogInfo(string.format("%s Teleportation Crystal did not transport within %ds -- continuing the full route.", LogPrefix, TeleportCrystalTimeout))
    return false
end

----------------------
--   Party Leash    --
----------------------

--- 3D distance between two points.
local function Dist3(ax, ay, az, bx, by, bz)
    local dx, dy, dz = ax - bx, ay - by, az - bz
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Look up a nearby whitelisted teammate by name. Returns hp, obj, dist (nil if not in the object table).
local function TeammateInfo(lname)
    local obj, dist = FindNearestObjectByName(lname)
    if not obj then return nil end
    local ok, hp = pcall(function() return obj.CurrentHp end)
    return (ok and hp) or nil, obj, dist
end

--- Is any whitelisted teammate (not us) dead within `range`?
function DeadTeammateNearby(range)
    local me = string.lower(GetCharacterName() or "")
    for lname in pairs(Whitelist) do
        if lname ~= me then
            local hp, _, dist = TeammateInfo(lname)
            if hp ~= nil and hp <= 0 and dist and dist <= range then return true end
        end
    end
    return false
end

--- Any LIVING teammate lagging behind me on the route (farther from nextWp) and not yet within `gap`?
--- The "behind" test excludes the tank, which runs ahead (closer to nextWp than we are).
function StragglerBehind(nextWp, gap)
    local me = string.lower(GetCharacterName() or "")
    local myToNext = GetDistanceToPoint(nextWp[1], nextWp[2], nextWp[3]) or 0
    for lname in pairs(Whitelist) do
        if lname ~= me then
            local hp, obj, distToMe = TeammateInfo(lname)
            if hp ~= nil and hp > 0 and obj and distToMe and distToMe > gap then
                local ok, tx, ty, tz = pcall(function() local p = obj.Position; return p.X, p.Y, p.Z end)
                if ok and tx and Dist3(tx, ty, tz, nextWp[1], nextWp[2], nextWp[3]) > myToNext + ConvoyMargin then
                    return true   -- behind me on the route AND still too far back
                end
            end
        end
    end
    return false
end

--- Freeze while a teammate is down nearby, so the rezzer (also held here) stays in raise range.
--- Loop exits the instant nobody is down; the timeout is only the give-up bound for an impossible rez.
function WaitForDownedTeammates(range, timeout)
    if not DeadTeammateNearby(range) then return end
    LogInfo(string.format("%s Teammate down within %dy -- holding for raise.", LogPrefix, range))
    PathStop(); RotationON()
    local deadline = os.time() + timeout
    while not StopFlag and not ArenaJoinBossIndex and DeadTeammateNearby(range) do
        if TryJoinSealedArea() then return end
        if IsDead() then HandleDeath(); if StopFlag then return end end
        if CheckStrangerAbort() then return end
        if os.time() >= deadline then
            LogInfo(string.format("%s Raise wait timed out (%ds) -- proceeding short-handed.", LogPrefix, timeout)); return
        end
        Wait(1)
    end
    LogInfo(string.format("%s Teammate(s) back up -- resuming.", LogPrefix))
end

--- Don't outrun the tail: hold at a waypoint until stragglers behind me close up (rez any down meanwhile).
function WaitForConvoy(nextWp, gap, timeout)
    if not nextWp then return end
    local deadline = os.time() + timeout
    while not StopFlag and not ArenaJoinBossIndex and StragglerBehind(nextWp, gap) do
        if TryJoinSealedArea() then return end
        if IsDead() then HandleDeath(); if StopFlag then return end end
        if CheckStrangerAbort() then return end
        WaitForDownedTeammates(RaiseRange, RaiseHoldTimeout)   -- a straggler may be dead, not just slow
        if ArenaJoinBossIndex then return end
        if os.time() >= deadline then
            LogInfo(string.format("%s Convoy wait timed out -- advancing.", LogPrefix)); return
        end
        Wait(1)
    end
end

----------------------
--    Navigation    --
----------------------

--- Death-aware move to a single point: interrupts on death, waits for raise, resumes.
function MoveToWaypoint(x, y, z)
    PathfindAndMoveTo(x, y, z, false)
    local t0 = os.time()
    while not StopFlag and not ArenaJoinBossIndex do
        if TryJoinSealedArea() then return end
        if CheckStrangerAbort() then return end
        if IsDead() then
            HandleDeath()
            if StopFlag then return end
            PathfindAndMoveTo(x, y, z, false)   -- resume after raise
            t0 = os.time()
        end

        -- Trap-passage leash: freeze the instant a teammate drops so a rezzer stays in range.
        if InTrapPassage and not PrimaryPlayer and DeadTeammateNearby(RaiseRange) then
            WaitForDownedTeammates(RaiseRange, RaiseHoldTimeout)
            if StopFlag or ArenaJoinBossIndex then return end
            PathfindAndMoveTo(x, y, z, false)   -- resume toward the waypoint after the hold
            t0 = os.time()
        end

        local d = GetDistanceToPoint(x, y, z)
        if d and d <= StopDistance then PathStop(); return end

        if not PathIsRunning() and not PathfindInProgress() then
            if d and d <= StopDistance + 2 then PathStop(); return end
            PathfindAndMoveTo(x, y, z, false)   -- path ended short; re-issue
        end
        if (os.time() - t0) >= WaypointTimeout then
            LogInfo(string.format("%s Waypoint timeout (%.1f,%.1f,%.1f) -- skipping.", LogPrefix, x, y, z))
            PathStop(); return
        end
        Wait(0.2)
    end
end

function WalkWaypoints(waypoints, trapPause)
    RotationON()
    InTrapPassage = trapPause and true or false
    for i, wp in ipairs(waypoints) do
        if StopFlag or ArenaJoinBossIndex then break end
        LogInfo(string.format("%s Waypoint %d/%d -> %.1f, %.1f, %.1f", LogPrefix, i, #waypoints, wp[1], wp[2], wp[3]))
        MoveToWaypoint(wp[1], wp[2], wp[3])
        if StopFlag or ArenaJoinBossIndex then break end
        WaypointsMoved = WaypointsMoved + 1
        if WaypointsMoved <= SlowStartCount then
            LogInfo(string.format("%s Slow-start pause (%d/%d).", LogPrefix, WaypointsMoved, SlowStartCount))
            Wait(SlowStartWait)
        end
        -- Trap passage: the primary (tank) runs blind and soaks the traps; the followers hold
        -- for any downed teammate (keeping a rezzer in range) and wait for stragglers to close up,
        -- so nobody gets left dead behind while the group walks on to the boss.
        if trapPause and not PrimaryPlayer then
            RotationON()
            WaitForDownedTeammates(RaiseRange, RaiseHoldTimeout)
            if ArenaJoinBossIndex then break end
            WaitForConvoy(waypoints[i + 1], ConvoyDist, ConvoyTimeout)
            if ArenaJoinBossIndex then break end
        end
    end
    InTrapPassage = false
    PathStop()
end

--- Reach the portal edge precisely (waypoints stop short), then push (PathMoveDir) into the
--- portal until the sub-area loads. `start` = tight approach point; `dir` = push direction.
function DoTransition(dir, start)
    -- 1) Pathfind right onto the portal edge (vnav handles the stairs; PathMoveDir can't).
    if start then
        LogInfo(string.format("%s Transition: approaching edge (%.1f, %.1f, %.1f).", LogPrefix, start[1], start[2], start[3]))
        PathfindAndMoveTo(start[1], start[2], start[3], false)
        local by = os.time() + 15
        while not StopFlag and not IsBetweenAreas() do
            if TryJoinSealedArea() then return end
            if IsDead() then
                HandleDeath(); if StopFlag then return end
                PathfindAndMoveTo(start[1], start[2], start[3], false); by = os.time() + 15
            end
            local d = GetDistanceToPoint(start[1], start[2], start[3])
            if d and d <= 1.5 then PathStop(); break end
            if os.time() >= by then break end
            if not PathIsRunning() and not PathfindInProgress() then
                PathfindAndMoveTo(start[1], start[2], start[3], false)
            end
            Wait(0.3)
        end
    end

    -- 2) Push through until IsBetweenAreas (the transition fires).
    LogInfo(string.format("%s Transition: PathMoveDir(%.2f, %.2f, %.2f).", LogPrefix, dir[1], dir[2], dir[3]))
    PathStop()
    local deadline = os.time() + 20
    while not StopFlag and not IsBetweenAreas() do
        if TryJoinSealedArea() then return end
        if IsDead() then
            HandleDeath()
            if StopFlag then return end
            deadline = os.time() + 20            -- fresh push window after the raise
        elseif os.time() >= deadline then
            break
        elseif IsPlayerAvailable() then
            PathMoveDir(dir[1], dir[2], dir[3])
        end
        Wait(0.5)
    end
    PathStop()
    WaitForPlayer()
    Wait(2)
end

--- Reach the last on-mesh point before an aetherial lift, then push straight onto the pad
--- (PathMoveDir, no pathfinding, so vnav can't wander) until it launches us. `Jumping` fires on
--- pad contact, `BetweenAreas` on the load. Mirrors DoTransition; used where vnav can't path the pad.
function DoPadTransition(start, dir, landing)
    local function HasLanded()
        if not landing then return false end
        local distance = GetDistanceToPoint(landing[1], landing[2], landing[3])
        return distance ~= nil and distance <= PadLandingDist
    end

    local function FinishLaunch(attempt)
        PathStop()
        WaitForPlayer()
        Wait(2)
        LogInfo(string.format("%s Lift succeeded on attempt %d.", LogPrefix, attempt))
        return true
    end

    local attempt = 0
    while not StopFlag and IsBoundByDuty() do
        if TryJoinSealedArea() then return true end
        attempt = attempt + 1

        -- Return to the recorded edge before every attempt. This is also the fallback after
        -- a failed push, preventing repeated pushes from an unknown position on or beside the pad.
        LogInfo(string.format("%s Lift attempt %d: approaching edge (%.1f, %.1f, %.1f).", LogPrefix, attempt, start[1], start[2], start[3]))
        PathfindAndMoveTo(start[1], start[2], start[3], false)
        local approachDeadline = os.time() + 20
        while not StopFlag and IsBoundByDuty() and not IsBetweenAreas() and not IsJumping() do
            if TryJoinSealedArea() then return true end
            if HasLanded() then break end
            if IsDead() then
                HandleDeath()
                if StopFlag then return false end
                PathfindAndMoveTo(start[1], start[2], start[3], false)
                approachDeadline = os.time() + 20
            end

            local distance = GetDistanceToPoint(start[1], start[2], start[3])
            if distance and distance <= 1.5 then PathStop(); break end
            if os.time() >= approachDeadline then break end
            if not PathIsRunning() and not PathfindInProgress() then
                PathfindAndMoveTo(start[1], start[2], start[3], false)
            end
            Wait(0.3)
        end

        if StopFlag or not IsBoundByDuty() then PathStop(); return false end
        if IsBetweenAreas() or IsJumping() or HasLanded() then
            return FinishLaunch(attempt)
        end

        local edgeDistance = GetDistanceToPoint(start[1], start[2], start[3])
        if not edgeDistance or edgeDistance > 2 then
            PathStop()
            LogInfo(string.format("%s Lift attempt %d could not reach the edge (distance=%s) -- retrying approach.", LogPrefix, attempt, tostring(edgeDistance)))
            Wait(1)
        else
        LogInfo(string.format("%s Lift attempt %d: PathMoveDir(%.2f, %.2f, %.2f) onto the pad.", LogPrefix, attempt, dir[1], dir[2], dir[3]))
        PathStop()
        local launchDeadline = os.time() + 15
        while not StopFlag and IsBoundByDuty() and not IsBetweenAreas() and not IsJumping() do
            if TryJoinSealedArea() then return true end
            if HasLanded() then break end
            if IsDead() then
                HandleDeath()
                if StopFlag then return false end
                break
            elseif os.time() >= launchDeadline then
                break
            elseif IsPlayerAvailable() then
                PathMoveDir(dir[1], dir[2], dir[3])
            end
            Wait(0.3)
        end
        PathStop()

        if IsBetweenAreas() or IsJumping() or HasLanded() then
            return FinishLaunch(attempt)
        end

        LogInfo(string.format("%s Lift attempt %d did not launch within 15s -- returning to the edge and retrying.", LogPrefix, attempt))
        Wait(1)
        end
    end
    PathStop()
    return false
end

------------------
--    Combat    --
------------------

--- Wait until the rest of the party is gathered within maxDist. Used before a trap-passage
--- boss so the tank (which runs the traps blind, ahead of the group) doesn't pull solo.
--- Timeout returns false so a dead/stuck straggler can't stall the pull forever.
function WaitForParty(maxDist, timeout)
    timeout = timeout or 60
    local need = RequiredPartySize - 1
    if need < 1 then return true end
    local myName = string.lower(GetCharacterName() or "")
    local deadline = os.time() + timeout

    while not StopFlag do
        if TryJoinSealedArea() then return true end
        if CheckStrangerAbort() then return false end
        if IsDead() then HandleDeath() end
        WaitForDownedTeammates(RaiseRange, RaiseHoldTimeout)   -- rez anyone down before we count / pull
        local near = 0
        for lname in pairs(Whitelist) do
            if lname ~= myName then
                local hp, _, dist = TeammateInfo(lname)
                if hp ~= nil and hp > 0 and dist and dist <= maxDist then near = near + 1 end   -- living only
            end
        end
        if near >= need then return true end
        if os.time() >= deadline then
            LogInfo(string.format("%s Party gather timeout: %d/%d within %dy -- pulling anyway.", LogPrefix, near, need, maxDist))
            return false
        end
        Wait(1)
    end
    return false
end

local function MissingNearbyAccounts(maxDist)
    local myName = string.lower(GetCharacterName() or "")
    local missing = {}
    local unsafeNearby = false

    for _, accountName in ipairs(Accounts) do
        local lname = string.lower(accountName)
        if lname ~= myName then
            local hp, obj, dist = TeammateInfo(lname)
            local targetable = false
            if obj then
                local ok, value = pcall(function() return obj.IsTargetable end)
                targetable = ok and value == true
            end

            if hp == nil or hp <= 0 or not dist or dist > maxDist or not targetable then
                table.insert(missing, accountName)
                if obj and dist and dist <= maxDist and (hp == nil or hp <= 0 or not targetable) then
                    unsafeNearby = true
                end
            end
        end
    end
    return missing, unsafeNearby
end

--- After a wipe, hold at the entrance until every configured account has fully respawned nearby.
--- This barrier deliberately has no timeout because route replay must begin in sync.
function WaitForRetryParty(maxDist)
    local lastMissing = ""
    local nextLogAt = 0
    while IsBoundByDuty() and not StopScript do
        if CheckStrangerAbort() then return false end

        if IsDead() then
            HandleDeath()
            if StopScript then return false end
        end

        local missing = MissingNearbyAccounts(maxDist)
        if #missing == 0 then
            LogInfo(string.format("%s All configured accounts assembled at the entrance.", LogPrefix))
            return true
        end

        local missingText = table.concat(missing, ", ")
        if missingText ~= lastMissing or os.time() >= nextLogAt then
            LogInfo(string.format("%s Waiting at entrance for: %s", LogPrefix, missingText))
            lastMissing = missingText
            nextLogAt = os.time() + 15
        end
        Wait(1)
    end
    return false
end

--- Hold after a boss so a revived/returning account can catch up. Unlike the entrance barrier,
--- this checkpoint eventually releases the available group so one missing box cannot stop the run.
function WaitForPostBossParty(maxDist, timeout)
    local deadline = os.time() + timeout
    local lastMissing = ""
    local nextLogAt = 0
    local stableSince = nil
    local releaseAt = nil

    while IsBoundByDuty() and not StopScript and not StopFlag do
        if TryJoinSealedArea() then return true end
        if CheckStrangerAbort() then return false end
        if IsDead() then
            stableSince = nil
            releaseAt = nil
            HandleDeath()
            if StopFlag or StopScript then return false end
        end

        local missing, unsafeNearby = MissingNearbyAccounts(maxDist)
        if #missing == 0 then
            if not stableSince then
                stableSince = os.time()
                LogInfo(string.format("%s Party assembled -- holding %ds to confirm stability.", LogPrefix, PostBossStableTime))
            elseif not releaseAt and (os.time() - stableSince) >= PostBossStableTime then
                releaseAt = os.time() + PostBossReleaseGrace
                LogInfo(string.format("%s Party stable -- releasing in %ds.", LogPrefix, PostBossReleaseGrace))
            elseif releaseAt and os.time() >= releaseAt then
                LogInfo(string.format("%s Post-boss checkpoint released.", LogPrefix))
                return true
            end
        else
            -- Once this account has confirmed stability, another healthy account leaving range
            -- means the group has begun moving. Follow it instead of resetting into a solo wait.
            if releaseAt and not unsafeNearby then
                LogInfo(string.format("%s Group started moving -- releasing this account to follow.", LogPrefix))
                return true
            end
            stableSince = nil
            releaseAt = nil
        end

        local missingText = table.concat(missing, ", ")
        if os.time() >= deadline then
            if missingText == "" then missingText = "stability confirmation" end
            LogInfo(string.format("%s Post-boss gather timed out after %ds; continuing without: %s", LogPrefix, timeout, missingText))
            return false
        end
        if missingText ~= "" and (missingText ~= lastMissing or os.time() >= nextLogAt) then
            LogInfo(string.format("%s Post-boss checkpoint waiting for: %s", LogPrefix, missingText))
            lastMissing = missingText
            nextLogAt = os.time() + 15
        end
        Wait(1)
    end
    return false
end

--- Engage a boss and wait for the kill. Death-aware so a trap/mechanic death doesn't
--- false-trigger the "combat ended" gate.
function FightBoss(seg)
    local name = seg.Boss
    LogInfo(string.format("%s Engaging: %s", LogPrefix, tostring(name or "(walk-in)")))
    RotationON()

    if not seg.WalkIn and name then
        local engageBy = os.time() + 30
        while not IsInCombat() and os.time() < engageBy and not StopFlag do
            if IsDead() then HandleDeath() else MoveToTarget(name, 5) end
            Wait(1)
        end
    else
        local engageBy = os.time() + 20
        while not IsInCombat() and os.time() < engageBy and not StopFlag do
            if IsDead() then HandleDeath() end
            Wait(1)
        end
    end

    local deadline      = os.time() + BossTimeout
    local combatStarted = false
    local endedAt       = nil
    local watchdogCount = 0
    while not StopFlag and IsBoundByDuty() do
        if os.time() >= deadline then
            watchdogCount = watchdogCount + 1
            LogInfo(string.format("%s Boss watchdog %d: restarting combat helpers for %s.", LogPrefix, watchdogCount, tostring(name)))
            PathStop()
            RotationOFF()
            AiOFF()
            Wait(1)
            RotationON()
            AiON()
            if not IsDead() and name and not seg.WalkIn then MoveToTarget(name, 5) end
            deadline = os.time() + BossTimeout
        end
        if CheckStrangerAbort() then break end

        local boss        = name and Entity.GetEntityByName(name) or nil
        local bossKilled  = not seg.CombatSettleOnly and name and boss and boss.CurrentHp and boss.CurrentHp <= 0
        local bossPresent = boss ~= nil and not bossKilled

        -- Check the kill first: a successful party kill while we are down must win over
        -- the wipe timer. Loot/movement will then wait for a raise or recover at the entrance.
        if bossKilled then
            LogInfo(string.format("%s Boss down: %s (HP 0).", LogPrefix, tostring(name)))
            if IsDead() then SoloReturnAllowed = true end
            return "cleared"
        elseif IsDead() then
            endedAt = nil
            if DetectWipe() and RecoverFromWipe("full party wipe during " .. tostring(name), false) then
                return "retry"
            end
        elseif IsInCombat() then
            ResetWipeState()
            SoloReturnAllowed = false
            combatStarted = true
            endedAt = nil
        elseif combatStarted then
            endedAt = endedAt or os.time()
            if (os.time() - endedAt) >= BossSettleTime then
                LogInfo(string.format("%s Boss down: %s (combat ended).", LogPrefix, tostring(name or "(walk-in)")))
                return "cleared"
            end
        elseif bossPresent then
            endedAt = nil                           -- alive but not engaged -> pull it
            if name and not seg.WalkIn then MoveToTarget(name, 5) end
        else
            -- Never engaged and boss not on the field. For a targetable boss that means it's
            -- already dead (a straggler arriving late) -> advance. For a walk-in boss, nil is
            -- normal before aggro, so wait longer for combat to start.
            endedAt = endedAt or os.time()
            local grace = seg.WalkIn and 20 or BossSettleTime
            if (os.time() - endedAt) >= grace then
                LogInfo(string.format("%s %s not on field -- advancing.", LogPrefix, tostring(name)))
                return "cleared"
            end
        end
        Wait(1)
    end
    return Wiped and "retry" or "abort"
end

----------------
--    Loot    --
----------------

--- Loot each Personal Spoils coffer.
function LootSpoils(coffers)
    RotationON()
    for _, c in ipairs(coffers) do
        if StopFlag then return false end
        MoveToWaypoint(c[1], c[2], c[3])
        if StopFlag then return false end
        Interact("Personal Spoils")
        Wait(1.5)
    end
    return not StopFlag
end

function ExitDuty()
    Wait(LootWait)
    local leaveAttempts = 0
    while IsBoundByDuty() and not StopScript do
        leaveAttempts = leaveAttempts + 1
        LeaveInstance()
        Wait(2)
        if leaveAttempts % 10 == 0 and IsBoundByDuty() then
            LogInfo(string.format("%s Still bound after %d completed-duty leave attempts -- continuing.", LogPrefix, leaveAttempts))
        end
    end
    if IsBoundByDuty() then
        return false
    end
    WaitForDutyExit(60)
    return true
end

-----------------
--    Entry    --
-----------------

function SelectTalkOption(index, timeout)
    timeout = timeout or 5
    local deadline = os.time() + timeout
    while os.time() < deadline do
        local cbAddon
        if IsAddonReady("SelectString") then cbAddon = "SelectString"
        elseif IsAddonReady("SelectIconString") then cbAddon = "SelectIconString" end
        if cbAddon then
            LogInfo(string.format("%s Menu: /callback %s true %d", LogPrefix, cbAddon, index))
            Execute(string.format("/callback %s true %d", cbAddon, index)); Wait(1)
            return true
        end
        Wait(0.3)
    end
    LogInfo(string.format("%s No talk menu for index %d.", LogPrefix, index))
    return false
end

function AcceptEntryConfirms()
    if IsAddonReady("ContentsFinderConfirm") then
        Execute("/callback ContentsFinderConfirm Commence"); Wait(1)
    elseif IsAddonReady("SelectYesno") then
        Execute("/callback SelectYesno true 0"); Wait(1)
    end
end

function RegisterForDelubrum()
    if not IsInZone(Gangos) then
        LogInfo(string.format("%s Teleporting to '%s'...", LogPrefix, HubAetheryte))
        Teleport(HubAetheryte); WaitForPlayer()
    end
    MoveTo(EntryNpcX, EntryNpcY, EntryNpcZ, 3)
    WaitForPlayer()
    local npcName = GetNPCName(EntryNpcId)
    if not npcName or npcName == "" then
        LogInfo(string.format("%s Could not resolve NPC %d.", LogPrefix, EntryNpcId)); return
    end
    LogInfo(string.format("%s Interacting with '%s'...", LogPrefix, npcName))
    MoveToTarget(npcName, 3); Interact(npcName); Wait(1)
    for _, idx in ipairs(MenuPath) do
        if not SelectTalkOption(idx, 5) then return end
    end
end

function WaitForRequiredParty()
    local last = -1
    while not HasPartySize(RequiredPartySize) and not StopFlag do
        local c = GetPartyCount()
        if c ~= last then LogInfo(string.format("%s Waiting for party: %d/%d.", LogPrefix, c, RequiredPartySize)); last = c end
        Wait(PartyCheckDelay)
    end
end

--- Wait to be bound. While actively queued we wait indefinitely; the timeout only
--- counts once we've LEFT the queue without binding (i.e. something dropped).
function WaitUntilBound(timeout)
    local idle = os.time()
    while not IsBoundByDuty() do
        AcceptEntryConfirms()
        if not HasPartySize(RequiredPartySize) then return false end
        if IsInDutyQueue() then
            idle = os.time()                       -- still queued -- keep waiting
        elseif (os.time() - idle) >= timeout then
            return false                           -- not queued and not bound -> give up
        end
        Wait(1)
    end
    return true
end

--- Primary registers; everyone accepts the Duty Ready pop.
function EnterDuty()
    if PrimaryPlayer then
        RegisterForDelubrum()
        -- Confirm the registration actually put us in the queue; if not, retry (re-register).
        local queued = false
        for _ = 1, 15 do
            if IsInDutyQueue() or IsBoundByDuty() then queued = true; break end
            Wait(1)
        end
        if not queued then
            LogInfo(string.format("%s Registration didn't queue -- will retry.", LogPrefix))
            return false
        end
        LogInfo(string.format("%s Registered (in duty queue).", LogPrefix))
        if not IsBoundByDuty() then
            LogInfo(string.format("%s Primary returning to the inn while queued.", LogPrefix))
            Lifestream("Inn")
        end
    end
    -- Secondaries don't need to be in Gangos -- the Duty Ready pop reaches them anywhere.
    LogInfo(string.format("%s Waiting to be bound...", LogPrefix))
    return WaitUntilBound(BoundTimeout)
end

--------------------
--    Instance    --
--------------------

local function FindUpcomingBossIndex(startIndex)
    for i = startIndex, #Route do
        if (Route[i].Boss or Route[i].WalkIn) and not BossKilled[Route[i].Name] then return i end
    end
    return nil
end

--- Run the recorded route. A recovered wipe starts a fresh pass from the entrance;
--- cleared bosses and collected coffers are skipped while their travel segments are replayed.
function RunInstance()
    LogInfo(string.format("%s Inside -- settling %ds before first move.", LogPrefix, EntryWait))
    Wait(EntryWait)

    BossKilled = {}
    LootCollected = {}
    LastClearedSegment = nil
    ReplayingRoute = false
    RetryCount = 0
    SoloReturnAllowed = false
    UpcomingBossIndex = nil
    ArenaJoinBossIndex = nil
    ArenaJoinSource = nil
    ResetWipeState()

    while IsBoundByDuty() and not StopScript do
        StopFlag = false
        Wiped = false
        WaypointsMoved = 0

        local routeIndex = 1
        while routeIndex <= #Route do
            if StopFlag then break end

            local joinedBoss = false
            local joinSource = nil
            if ArenaJoinBossIndex then
                routeIndex = ArenaJoinBossIndex
                ArenaJoinBossIndex = nil
                joinedBoss = true
                joinSource = ArenaJoinSource
            end

            local seg = Route[routeIndex]
            UpcomingBossIndex = FindUpcomingBossIndex(routeIndex)

            if joinedBoss then
                LogInfo(string.format("%s Joined %s via %s -- skipping obsolete route waypoints.", LogPrefix, seg.Name, joinSource or "route teleport"))
                ArenaJoinSource = nil
                if joinSource == "Teleportation Crystal" and seg.Waypoints and #seg.Waypoints > 0 then
                    local finalWaypoint = seg.Waypoints[#seg.Waypoints]
                    LogInfo(string.format("%s Crystal arrival: moving to %s's final approach waypoint.", LogPrefix, seg.Name))
                    MoveToWaypoint(finalWaypoint[1], finalWaypoint[2], finalWaypoint[3])
                end
            else
                LogInfo(string.format("%s Segment: %s", LogPrefix, seg.Name))
                WalkWaypoints(seg.Waypoints, seg.TrapPause)
                if not StopFlag and not ArenaJoinBossIndex and seg.TransitionDir then
                    DoTransition(seg.TransitionDir, seg.TransitionStart)
                end
                if not StopFlag and not ArenaJoinBossIndex and seg.PadStart then
                    DoPadTransition(seg.PadStart, seg.PadDir, seg.PadLanding)
                end
                if ReplayingRoute and routeIndex == 1 and not StopFlag and not ArenaJoinBossIndex then
                    local crystalBossIndex = FindUpcomingBossIndex(routeIndex + 1)
                    if crystalBossIndex and crystalBossIndex > 2 and UseTeleportationCrystal() and not ArenaJoinBossIndex then
                        ArenaJoinBossIndex = crystalBossIndex
                        ArenaJoinSource = "Teleportation Crystal"
                    end
                end
            end

            if not StopFlag and not ArenaJoinBossIndex and (seg.Boss or seg.WalkIn) then
                if BossKilled[seg.Name] then
                    LogInfo(string.format("%s Already cleared: %s -- skipping fight.", LogPrefix, seg.Name))
                else
                    if seg.TrapPause and not joinedBoss then WaitForParty(PartyGatherDist) end

                    -- WaitForParty may itself accept the prompt for this boss.
                    if ArenaJoinBossIndex == routeIndex then
                        ArenaJoinBossIndex = nil
                        ArenaJoinSource = nil
                        joinedBoss = true
                    end

                    if not ArenaJoinBossIndex then
                        local result = FightBoss(seg)
                        if result == "cleared" then
                            BossKilled[seg.Name] = true
                            LastClearedSegment = seg.Name
                        elseif result == "retry" then
                            break
                        else
                            return false
                        end
                    end
                end
            end

            -- Once this segment's fight is resolved, any sealed-area prompt belongs to the
            -- following boss, including prompts that appear during loot or checkpoint waits.
            UpcomingBossIndex = FindUpcomingBossIndex(routeIndex + 1)
            if not StopFlag and not ArenaJoinBossIndex and seg.Loot and not LootCollected[seg.Name] then
                if LootSpoils(seg.Loot) then LootCollected[seg.Name] = true end
            end

            if not StopFlag and not ArenaJoinBossIndex and LastClearedSegment == seg.Name then
                if ReplayingRoute then
                    LogInfo(string.format("%s Reached catch-up checkpoint: %s.", LogPrefix, seg.Name))
                    WaitForPostBossParty(PartyGatherDist, CatchUpGatherTimeout)
                    if not StopFlag then ReplayingRoute = false end
                else
                    WaitForPostBossParty(PartyGatherDist, PostBossGatherTimeout)
                end
            end

            if not StopFlag and not ArenaJoinBossIndex and seg.Exit then
                return ExitDuty()
            end

            if ArenaJoinBossIndex then
                routeIndex = ArenaJoinBossIndex
            else
                routeIndex = routeIndex + 1
            end
        end

        UpcomingBossIndex = nil
        ArenaJoinBossIndex = nil
        ArenaJoinSource = nil
        if Wiped and IsBoundByDuty() and not StopScript then
            RetryCount = RetryCount + 1
            LogInfo(string.format("%s Retry %d -- replaying the route from the DR entrance.", LogPrefix, RetryCount))
            WaitForPlayer()
            StopFlag = false
            LogInfo(string.format("%s Regrouping at the entrance before retry %d.", LogPrefix, RetryCount))
            if not WaitForRetryParty(PartyGatherDist) then return false end
            Wait(3)
        else
            return not StopFlag
        end
    end
    return false
end

--=========================== EXECUTION ==========================--

if #Accounts ~= RequiredPartySize then
    LogInfo(string.format("%s CONFIG ERROR: Accounts contains %d name(s), but RequiredPartySize is %d.", LogPrefix, #Accounts, RequiredPartySize))
    return
end

if not Setup() then return end

local runCount = 0
while not StopScript do
    WaitForStrangerCooldown()
    if StopScript then break end

    -- MaxRuns caps the primary only; secondaries cycle until the primary stops registering.
    if PrimaryPlayer and MaxRuns > 0 and runCount >= MaxRuns then break end

    WaitForRequiredParty()
    if StopScript then break end

    if not IsBoundByDuty() and RepairThreshold > 0 and NeedsRepair(RepairThreshold) then
        Repair(RepairThreshold); Wait(1)
    end

    local entered = IsBoundByDuty()
    if not entered then
        entered = EnterDuty()
        if not entered then LogInfo(string.format("%s Entry failed. Retrying.", LogPrefix)); Wait(5) end
    end

    if entered then
        WaitForPlayer()
        LogInfo(string.format("%s Inside zone %d (expected %d).", LogPrefix, GetZoneID(), ZoneID))
        local cleared = RunInstance()
        if IsBoundByDuty() and not StopScript then
            local leaveAttempts = 0
            while IsBoundByDuty() and not StopScript do
                leaveAttempts = leaveAttempts + 1
                LeaveInstance()
                Wait(2)
                if leaveAttempts % 10 == 0 and IsBoundByDuty() then
                    LogInfo(string.format("%s Still bound after %d fallback leave attempts -- continuing.", LogPrefix, leaveAttempts))
                end
            end
            if not IsBoundByDuty() then
                WaitForDutyExit(60)
            end
        end
        if cleared and not StopScript then
            runCount = runCount + 1
            LogInfo(string.format("%s Run finished: %d.", LogPrefix, runCount))
        elseif not StopScript then
            LogInfo(string.format("%s Run ended without a clear -- not counted.", LogPrefix))
        end
    end
    Wait(1)
end

RotationOFF(); AiOFF()
LogInfo(string.format("%s Stopped after %d run(s).", LogPrefix, runCount))

--============================== END =============================--
