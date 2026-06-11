--[=====[
[[SND Metadata]]
author: Mo
version: 2.2.2
description: Red Alert Hunter
plugin_dependencies:
- Artisan
- AutoHook
- ICE
- Lifestream
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  Sinus Enabled:
    description: Enable Sinus in the zone rotation.
    default: true
  Phaenna Enabled:
    description: Enable Phaenna in the zone rotation.
    default: true
  Oizys Enabled:
    description: Enable Oizys in the zone rotation.
    default: true
  Auxesia Enabled:
    description: Enable Auxesia in the zone rotation.
    default: true
  Zone Wait:
    description: Seconds to wait in each enabled zone before swapping to the next enabled zone.
    default: 180
    min: 10
    max: 3600
[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

SinusEnabledConfig      = Config.Get("Sinus Enabled")
PhaennaEnabledConfig    = Config.Get("Phaenna Enabled")
OizysEnabledConfig      = Config.Get("Oizys Enabled")
AuxesiaEnabledConfig    = Config.Get("Auxesia Enabled")
ZoneWaitConfig          = Config.Get("Zone Wait")
LogPrefix               = "[RAHunter]"

--============================ CONSTANT ==========================--

-------------------
--    General    --
-------------------

UseICE                  = true
UseStellarReturn        = true
UseCruisingwayCoords    = true
RunScript               = true
TravelOption            = 0
CallbackDelay           = 1.5       -- delay after UI callbacks to reduce addon/client instability
TalkAdvanceDelay        = 1.0       -- delay between Talk callbacks
PostInteractDelay       = 2.0       -- allow menu addons time to settle after interacting
AddonPollInterval       = 0.5       -- polling interval for addon readiness/state checks
NodePollInterval        = 1.0       -- polling interval for UI text reads
StartupDelay            = 3.0       -- grace period after pressing Start before doing anything

----------------
--    Zone    --
----------------

SinusTerritory   = 1237
PhaennaTerritory = 1291
OizysTerritory   = 1310
AuxesiaTerritory = 1319

ZoneCycle = {
    {
        display     = "Sinus",
        enabled     = SinusEnabledConfig,
        territory   = SinusTerritory,
        cruisingway = {-40.92, 11.89, -97.29},
        planet      = {0, 1}
    },
    {
        display     = "Phaenna",
        enabled     = PhaennaEnabledConfig,
        territory   = PhaennaTerritory,
        cruisingway = {278.09, 52.02, -378.46},
        planet      = {1, 1}
    },
    {
        display     = "Oizys",
        enabled     = OizysEnabledConfig,
        territory   = OizysTerritory,
        cruisingway = {-202.93, 0.49, 67.31},
        planet      = {2, 1}
    },
    {
        display     = "Auxesia",
        enabled     = AuxesiaEnabledConfig,
        territory   = AuxesiaTerritory,
        cruisingway = {364.68, 204.13, 394.90},
        planet      = {3, 1}
    },
}

--=========================== FUNCTIONS ==========================--

local function WaitUntil(predicate, timeout, interval)
    timeout  = timeout or 30
    interval = interval or AddonPollInterval

    local startTime = os.time()

    while (os.time() - startTime) < timeout do
        if predicate() then
            return true
        end
        Wait(interval)
    end

    return false
end

function ZoneByTerritory(tt)
    for _, z in ipairs(ZoneCycle) do
        if z.territory == tt then
            return z
        end
    end
    return nil
end

local function CallbackWhenReady(addonName, callback, timeout)
    if not WaitForAddon(addonName, timeout or 10) then
        LogInfo("%s %s did not appear.", LogPrefix, addonName)
        return false
    end

    Execute(callback)
    Wait(CallbackDelay)
    return true
end

local function WaitForAddonStateChange(addonName, timeout)
    return WaitUntil(function()
        return not IsAddonReady(addonName)
    end, timeout or 5, AddonPollInterval)
end

local function ConfirmYesNo(timeout)
    return CallbackWhenReady("SelectYesno", "/callback SelectYesno true 0", timeout)
end

local function ParseCountdown(text)
    if not text or text == "" then
        return nil
    end

    local normalized = tostring(text)
    normalized = normalized:gsub("[%z\1-\31]", "")
    normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")
    normalized = normalized:lower()

    if normalized:find("less than 1m", 1, true) then
        return 59
    end

    local minsOnly = normalized:match("(%d+)%s*m")
    if minsOnly and not normalized:find(":") then
        return tonumber(minsOnly) * 60
    end

    local m, s = normalized:match("(%d+):(%d%d)")
    if not m then
        return nil
    end

    local secs = tonumber(m) * 60 + tonumber(s)

    if secs < 0 then
        return nil
    end

    return secs
end

local function GetFirstNodeText(addonName, paths)
    for _, path in ipairs(paths) do
        local text = GetNodeText(addonName, table.unpack(path))
        if text and text ~= "" then
            return tostring(text)
        end
    end

    return nil
end

local function RedAlertTitleVisible()
    local title = GetFirstNodeText("WKSAnnounce", {
        {1, 9, 11},
        {1, 2, 4},
    })
    return title and tostring(title):find("RED ALERT", 1, true) ~= nil
end

function RedAlertCountdown()
    if not RedAlertTitleVisible() then
        return nil
    end

    return ParseCountdown(GetFirstNodeText("WKSAnnounce", {
        {1, 9, 19},
    }))
end

function RedAlertAnnouncementCountdown()
    if not RedAlertTitleVisible() then
        return nil
    end

    return ParseCountdown(GetFirstNodeText("WKSAnnounce", {
        {1, 2, 6},
    }))
end

local function MoveToCruisingway(zone)
    if UseCruisingwayCoords and zone.cruisingway then
        local p = zone.cruisingway
        local x, y, z = p[1], p[2], p[3]

        -- If coordinates are still TODO / 0,0,0, fallback to target pathing.
        if x and y and z and not (x == 0 and y == 0 and z == 0) then
            if GetDistanceToPoint(x, y, z) > 4 then
                LogInfo("%s Moving to Cruisingway coords in %s.", LogPrefix, zone.display)
                return MoveTo(x, y, z, 3, false)
            end

            return true
        end
    end

    -- Fallback: path to nearest object named Cruisingway.
    LogInfo("%s Cruisingway coordinates missing; using MoveToTarget fallback.", LogPrefix)
    return MoveToTarget("Cruisingway", 4)
end

local function OpenCruisingwayMenu()
    if not Interact("Cruisingway", 20, 0.2) then
        LogInfo("%s Failed to interact with Cruisingway.", LogPrefix)
        return false
    end

    Wait(PostInteractDelay)

    WaitUntil(function()
        return IsAddonReady("Talk")
            or IsAddonReady("SelectString")
            or IsAddonReady("WKSPlanetSelect")
    end, 10, AddonPollInterval)

    local talkStart = os.time()
    while IsAddonReady("Talk") and (os.time() - talkStart) < 10 do
        Execute("/callback Talk true 0")
        Wait(TalkAdvanceDelay)

        if WaitUntil(function()
            return not IsAddonReady("Talk")
                or IsAddonReady("SelectString")
                or IsAddonReady("WKSPlanetSelect")
        end, 3, AddonPollInterval) and not IsAddonReady("Talk") then
            break
        end
    end

    if IsAddonReady("WKSPlanetSelect") then
        return true
    end

    -- Select travel option.
    if not WaitUntil(function()
        return IsAddonReady("SelectString") or IsAddonReady("WKSPlanetSelect")
    end, 10, AddonPollInterval) then
        LogInfo("%s SelectString did not appear.", LogPrefix)
        return false
    end

    if IsAddonReady("WKSPlanetSelect") then
        return true
    end

    Execute("/callback SelectString true " .. tostring(TravelOption))
    Wait(CallbackDelay)

    WaitUntil(function()
        return IsAddonReady("WKSPlanetSelect")
            or IsAddonReady("SelectYesno")
            or not IsAddonReady("SelectString")
    end, 5, AddonPollInterval)

    return true
end

local function SelectDestinationPlanet(target)
    if not CallbackWhenReady("WKSPlanetSelect", string.format("/callback WKSPlanetSelect true 11 %d %d", target.planet[1], target.planet[2]), 10) then
        return false
    end

    if not ConfirmYesNo(10) then
        LogInfo("%s SelectYesno did not appear after destination selection.", LogPrefix)
        return false
    end

    WaitForAddonStateChange("SelectYesno", 5)
    Wait(CallbackDelay)

    return true
end

function TravelToZone(target)
    if IsInZone(target.territory) then
        return true
    end

    local here = ZoneByTerritory(GetZoneID())

    if not here then
        LogInfo("%s Not in a known cosmic zone. Current zone: %s", LogPrefix, tostring(GetZoneID()))
        return false
    end

    LogInfo("%s Travelling from %s to %s.", LogPrefix, here.display, target.display)
    WaitForPlayer()

    if not MoveToCruisingway(here) then
        LogInfo("%s Could not move to Cruisingway.", LogPrefix)
        return false
    end

    WaitForPlayer()

    if not OpenCruisingwayMenu() then
        CloseAddons()
        return false
    end

    if not SelectDestinationPlanet(target) then
        CloseAddons()
        return false
    end

    local startedZoning = WaitUntil(function()
        return IsBetweenAreas() or IsPlayerCasting() or IsInZone(target.territory)
    end, 20, AddonPollInterval)

    if startedZoning then
        WaitForPlayer()
    else
        LogInfo("%s Travel confirmation sent, but zoning did not start within timeout.", LogPrefix)
    end

    local arrived = WaitUntil(function()
        return IsInZone(target.territory)
    end, 120, 1)

    CloseAddons()
    LogInfo("%s Travel to %s: %s", LogPrefix, target.display, arrived and "Arrived" or "Failed")
    return arrived
end

function StartICE()
    if not UseICE then
        return false
    end

    Execute("/ice start")
    Wait(1)

    return true
end

function StopICE()
    if not UseICE then
        return
    end

    Execute("/ice stop")
    Wait(1)
end

function StellarReturn()
    if not UseStellarReturn then
        return
    end

    LogInfo("%s Stellar Return.", LogPrefix)
    ExecuteAction(CharacterAction.Actions.stellarReturn)
    Wait(1)

    WaitUntil(function()
        return not IsBetweenAreas()
            and not IsPlayerCasting()
            and IsPlayerAvailable()
    end, 60, 0.5)
end

function HandleRedAlert(zone, secs)
    local mss = string.format("%d:%02d", math.floor(secs / 60), secs % 60)

    LogInfo("%s RED ALERT active in %s - %s remaining. Starting ICE.", LogPrefix, zone.display, mss)

    local iceStarted = StartICE()
    local deadline = os.time() + secs + 120

    while RunScript do
        local remaining = RedAlertCountdown()

        if remaining == nil then
            Wait(5 + NodePollInterval)
            remaining = RedAlertCountdown()

            if remaining == nil then
                Wait(5 + NodePollInterval)
                remaining = RedAlertCountdown()
            end

            if not (remaining and remaining > 0) then
                break
            end
        end

        if os.time() >= deadline then
            Wait(5 + NodePollInterval)
            remaining = RedAlertCountdown()

            if not remaining or remaining <= 0 then
                Wait(5 + NodePollInterval)
                remaining = RedAlertCountdown()
            end

            if remaining and remaining > 0 then
                deadline = os.time() + remaining + 120
            else
                LogInfo("%s Red Alert grace window ended in %s and timer is %s. Stopping ICE.", LogPrefix, zone.display, remaining == 0 and "0:00" or "gone")
                break
            end
        end

        if remaining and remaining <= 0 then
            Wait(10 + NodePollInterval)
        else
            Wait(5 + NodePollInterval)
        end
    end

    if iceStarted then
        StopICE()
    end

    LogInfo("%s %s alert ended - ICE stopped.", LogPrefix, zone.display)

    if RunScript then
        StellarReturn()
    end
end

function HandleRedAlertAnnouncement(zone, secs)
    local mss = string.format("%d:%02d", math.floor(secs / 60), secs % 60)
    local waitSecs = secs + 60

    LogInfo("%s RED ALERT announcement in %s - %s remaining. Waiting %ds before rechecking active timer.", LogPrefix, zone.display, mss, waitSecs)
    Wait(waitSecs)
end

--=========================== EXECUTION ==========================--

LogInfo("%s Red Alert hunter started.", LogPrefix)
Wait(StartupDelay)

while RunScript do
    for _, zone in ipairs(ZoneCycle) do
        if not RunScript then
            break
        end

        if zone.enabled then
            if TravelToZone(zone) then
                local zoneWait = ZoneWaitConfig or 180

                local dwellEnd = os.time() + zoneWait

                while os.time() < dwellEnd and RunScript do
                    local secs = RedAlertCountdown()

                    if secs and secs > 0 then
                        HandleRedAlert(zone, secs)
                        break
                    end

                    local announcementSecs = RedAlertAnnouncementCountdown()
                    if announcementSecs and announcementSecs > 0 then
                        HandleRedAlertAnnouncement(zone, announcementSecs)

                        local activeSecs = RedAlertCountdown()
                        if activeSecs and activeSecs > 0 then
                            HandleRedAlert(zone, activeSecs)
                            break
                        end
                    end

                    Wait(10 + NodePollInterval)
                end
            else
                LogInfo("%s Could not reach %s, skipping.", LogPrefix, zone.display)
            end
        end
    end
end

StopICE()
CloseAddons()
LogInfo("%s Red Alert hunter stopped.", LogPrefix)

--============================== END =============================--
