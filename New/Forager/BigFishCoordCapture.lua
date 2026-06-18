--[=====[
[[SND Metadata]]
author: Mo
version: 1.0.0
description: Forager - BigFishCoordCapture - One-off tool that visits every BigFish.lua spot and records a manually-corrected, walkable worldX/worldZ.
plugin_dependencies:
- Lifestream
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  LandingWaitSeconds:
    description: Seconds to pause after dismounting, before the landing coordinate is recorded - move the character onto safe ground in this window.
    default: 15
    min: 5
    max: 120
  CastWaitSeconds:
    description: Seconds to pause after the landing coordinate is recorded, before the fishing coordinate is recorded - move the character to the actual casting spot, facing the water, in this window.
    default: 5
    min: 5
    max: 120

[[End Metadata]]
--]=====]

--------------------------------------------------------------------
-- Some worldX/worldZ values in BigFish.lua's FishData were converted from
-- map coordinates and land in water, where casting isn't allowed - and even
-- where it lands on shore, you also need to be facing the water to cast.
-- Walking the character there automatically isn't safe either: it can walk
-- straight into deep water, where casting also isn't allowed. So both
-- coordinates here are entirely human-positioned - this script just flies
-- to the spot and gives you two timed windows to move the character before
-- each capture:
--   1. Landing coordinate - dismount, then LandingWaitSeconds to move the
--      character onto safe ground, then captured via GetPlayerPosition().
--   2. Fishing coordinate - CastWaitSeconds more to move the character to
--      the actual casting spot facing the water, then captured the same way.
-- It does not edit BigFish.lua - copy the logged coordinates back into
-- FishData by hand once the run finishes.
--
-- Locations are visited grouped by zone (not the FishData order) purely to
-- avoid redundant teleports.
--------------------------------------------------------------------

LogPrefix          = "[BigFishCoordCapture]"
LandingWaitSeconds = Config.Get("LandingWaitSeconds")
CastWaitSeconds    = Config.Get("CastWaitSeconds")

Locations = {
    { name = "Moongripper", zone = "Urqopacha", zoneId = 1187, aetheryte = "Worlar's Echo", spotName = "Sunken Stars", worldX = -57.21, worldZ = 304.67 },
    { name = "Sprouting Perch", zone = "Heritage Found", zoneId = 1191, aetheryte = "The Outskirts", spotName = "Outskirts Shallows", worldX = -144.75, worldZ = -770.15 },
    { name = "Shin Snuffler", zone = "Yak T'el", zoneId = 1189, aetheryte = "Iq Br'aax", spotName = "Ankledeep", worldX = -669.03, worldZ = 289.21 },
    { name = "Hwittayoanaan Cichlid", zone = "Shaaloani", zoneId = 1190, aetheryte = "Mehwahhetsoan", spotName = "Niikwerepi", worldX = 420.92, worldZ = -708.28 },
}

--=========================== FUNCTIONS ===========================--

--- Travels to the spot. loc.noMount zones (e.g. Tuliyollal) re-teleport to
--- the aetheryte first, then walk - vnavmesh failed to path there from an
--- arbitrary spot 280y away (confirmed: PathfindAndMoveTo starts but never
--- reaches "Running" state), so a short, consistent approach distance from
--- the aetheryte is required instead of walking from wherever you are. Any
--- entry with an explicit loc.aetheryte always re-teleports there first
--- (even when already in the zone, and even when mounting works fine) for
--- the shortest approach to that specific spot; otherwise it only teleports
--- in via the zone's default aetheryte when not already in the zone.
function FlyToSpot(loc)
    if loc.aetheryte and loc.aetheryte ~= "" then
        LogInfo(string.format("%s Teleporting to %s for the shortest approach.", LogPrefix, loc.aetheryte))
        Teleport(loc.aetheryte)
        Wait(0.3)
    elseif not IsInZone(loc.zoneId) then
        local aetheryteName = GetAetheryteName(loc.zoneId)
        if aetheryteName then
            Teleport(aetheryteName)
            Wait(0.3)
        end
    end

    while not IsPlayerAvailable() do
        Wait(0.5)
    end

    WaitForNavMesh()

    local point = QueryMeshPointOnFloor(loc.worldX, 500, loc.worldZ, false, 50)
    local targetY = (point and point.Y) or 0

    if loc.noMount then
        LogInfo(string.format("%s Walking to %s (%s) at (%.2f, %.2f)", LogPrefix, loc.name, loc.spotName, loc.worldX, loc.worldZ))
        MoveTo(loc.worldX, targetY, loc.worldZ)
        Wait(0.3)
        return
    end

    LogInfo(string.format("%s Flying to %s (%s) at (%.2f, %.2f)", LogPrefix, loc.name, loc.spotName, loc.worldX, loc.worldZ))
    Mount()
    Wait(0.3)
    MoveTo(loc.worldX, targetY, loc.worldZ, 0, true)
    Dismount()
    Wait(0.3)
end

function CapturePosition()
    local pos = GetPlayerPosition()
    if not pos then
        return nil
    end
    return { x = pos.X, y = pos.Y, z = pos.Z }
end

--=========================== EXECUTION ===========================--

local results = {}

for _, loc in ipairs(Locations) do
    FlyToSpot(loc)

    LogInfo(string.format("%s Dismounted at %s. %.0f second window - move onto safe ground.", LogPrefix, loc.name, LandingWaitSeconds))
    Wait(LandingWaitSeconds)

    local landing = CapturePosition()
    if landing then
        LogInfo(string.format("%s Landing coordinate for %s: worldX = %.2f, worldZ = %.2f (worldY = %.2f)", LogPrefix, loc.name, landing.x, landing.z, landing.y))
    else
        LogInfo(string.format("%s WARNING: could not read landing position for %s.", LogPrefix, loc.name))
    end

    LogInfo(string.format("%s %.0f second window - move to the casting spot, facing the water.", LogPrefix, CastWaitSeconds))
    Wait(CastWaitSeconds)

    local fishing = CapturePosition()
    if fishing then
        LogInfo(string.format("%s Fishing coordinate for %s: worldX = %.2f, worldZ = %.2f (worldY = %.2f)", LogPrefix, loc.name, fishing.x, fishing.z, fishing.y))
    else
        LogInfo(string.format("%s WARNING: could not read fishing position for %s.", LogPrefix, loc.name))
    end

    table.insert(results, { name = loc.name, landing = landing, fishing = fishing })
end

LogInfo(string.format("%s Done. Captured %d/%d locations:", LogPrefix, #results, #Locations))
for _, r in ipairs(results) do
    if r.landing then
        LogInfo(string.format('%s ["%s"] worldX = %.2f, worldZ = %.2f, worldY = %.2f', LogPrefix, r.name, r.landing.x, r.landing.z, r.landing.y))
    end
    if r.fishing then
        LogInfo(string.format('%s ["%s"] fishX = %.2f, fishZ = %.2f (fishY = %.2f)', LogPrefix, r.name, r.fishing.x, r.fishing.z, r.fishing.y))
    end
end

--============================== END ==============================--
