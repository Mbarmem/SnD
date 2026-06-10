--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
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

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

TravelOption            = 0         -- SelectString index for the travel option
UseICE                  = true
UseStellarReturn        = true
Run_script              = true
UseCruisingwayCoords    = true
ZONE_WAIT               = 180       -- dwell per zone, 3 minutes
LogPrefix               = "[RAHunter]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

SinusTerritory   = 1237
PhaennaTerritory = 1291
OizysTerritory   = 1504
AuxesiaTerritory = 1319

ZoneCycle = {
    {
        display     = "Sinus",
        territory   = SinusTerritory,
        cruisingway = {-40.92, 11.89, -97.29},
        planet      = {0, 1}
    },
    {
        display     = "Phaenna",
        territory   = PhaennaTerritory,
        cruisingway = {278.09, 52.02, -378.46},
        planet      = {1, 1}
    },
    {
        display     = "Oizys",
        territory   = OizysTerritory,
        cruisingway = {-202.93, 0.49, 67.31},
        planet      = {2, 1}
    },
    {
        display     = "Auxesia",
        territory   = AuxesiaTerritory,
        cruisingway = {364.68, 204.13, 394.90},
        planet      = {3, 1}
    },
}

--=========================== FUNCTIONS ==========================--

local function WaitUntil(predicate, timeout, interval)
    timeout  = timeout or 30
    interval = interval or 0.1

    local startTime = os.clock()

    while (os.clock() - startTime) < timeout do
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
    Wait(0.5)
    return true
end

local function ConfirmYesNo(timeout)
    return CallbackWhenReady("SelectYesno", "/callback SelectYesno true 0", timeout)
end

local function ParseCountdown(text)
    if not text or text == "" then
        return nil
    end

    local m, s = tostring(text):match("(%d+):(%d%d)")
    if not m then
        return nil
    end

    local secs = tonumber(m) * 60 + tonumber(s)

    if secs < 0 then
        return nil
    end

    return secs
end

function RedAlertCountdown()
    local title = GetNodeText("WKSAnnounce", 1, 9, 11)
    if not title or not tostring(title):find("RED ALERT", 1, true) then
        return nil
    end

    return ParseCountdown(GetNodeText("WKSAnnounce", 1, 9, 19))
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

    WaitUntil(function()
        return IsAddonReady("Talk")
            or IsAddonReady("SelectString")
            or IsAddonReady("WKSPlanetSelect")
    end, 10, 0.2)

    local talkStart = os.clock()
    while IsAddonReady("Talk") and (os.clock() - talkStart) < 10 do
        Execute("/callback Talk true 0")
        Wait(0.3)
    end

    if IsAddonReady("WKSPlanetSelect") then
        return true
    end

    -- Select travel option.
    if not WaitUntil(function()
        return IsAddonReady("SelectString") or IsAddonReady("WKSPlanetSelect")
    end, 10, 0.2) then
        LogInfo("%s SelectString did not appear.", LogPrefix)
        return false
    end

    if IsAddonReady("WKSPlanetSelect") then
        return true
    end

    Execute("/callback SelectString true " .. tostring(TravelOption))
    Wait(0.5)

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

    CloseAddons()
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
    end, 20, 0.2)

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
    local deadline = os.clock() + secs + 120

    while Run_script do
        local remaining = RedAlertCountdown()

        if remaining == nil then
            Wait(5)
            remaining = RedAlertCountdown()

            if remaining == nil then
                Wait(5)
                remaining = RedAlertCountdown()
            end

            if remaining and remaining > 0 then
                LogInfo("%s Red Alert timer refreshed in %s. Continuing ICE.", LogPrefix, zone.display)
            else
                break
            end
        end

        if os.clock() >= deadline then
            Wait(5)
            remaining = RedAlertCountdown()

            if not remaining or remaining <= 0 then
                Wait(5)
                remaining = RedAlertCountdown()
            end

            if remaining and remaining > 0 then
                local mssRemaining = string.format("%d:%02d", math.floor(remaining / 60), remaining % 60)
                LogInfo("%s Red Alert still active in %s after grace window - %s remaining. Continuing ICE.", LogPrefix, zone.display, mssRemaining)
                deadline = os.clock() + remaining + 120
            else
                LogInfo("%s Red Alert grace window ended in %s and timer is %s. Stopping ICE.", LogPrefix, zone.display, remaining == 0 and "0:00" or "gone")
                break
            end
        end

        if remaining and remaining <= 0 then
            Wait(10)
        else
            Wait(5)
        end
    end

    if iceStarted then
        StopICE()
    end

    LogInfo("%s %s alert ended - ICE stopped.", LogPrefix, zone.display)

    if Run_script then
        StellarReturn()
    end
end

--=========================== EXECUTION ==========================--

LogInfo("%s Red Alert hunter started.", LogPrefix)

while Run_script do
    for _, zone in ipairs(ZoneCycle) do
        if not Run_script then
            break
        end

        if TravelToZone(zone) then
            LogInfo("%s Watching %s for %ds.", LogPrefix, zone.display, ZONE_WAIT)

            local dwellEnd = os.clock() + ZONE_WAIT

            while os.clock() < dwellEnd and Run_script do
                local secs = RedAlertCountdown()

                if secs and secs > 0 then
                    HandleRedAlert(zone, secs)
                    break
                end

                Wait(10)
            end
        else
            LogInfo("%s Could not reach %s, skipping.", LogPrefix, zone.display)
        end
    end
end

StopICE()
CloseAddons()
LogInfo("%s Red Alert hunter stopped.", LogPrefix)

--============================== END =============================--
