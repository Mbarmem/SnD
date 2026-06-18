--[=====[
[[SND Metadata]]
author: Mo
version: 1.0.0
description: Forager - BigFish - Automates catching newly-tracked Dawntrail/Endwalker Big Fish
plugin_dependencies:
- AutoHook
- Lifestream
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  RetryCooldownSeconds:
    description: Seconds to wait before retrying the same fish after an unsuccessful attempt.
    default: 60
    min: 10
    max: 600

[[End Metadata]]
--]=====]

--------------------------------------------------------------------
-- BACKGROUND / DATA PROVENANCE
--------------------------------------------------------------------
-- This script automates catching the Big Fish that were missing from Mo's
-- "Big Fish Sorted" Google Sheet (tabs: "Read Me", "Sorted by Bait",
-- "Sorted by Location"; sheet id 1WP7ZRuXrEm68yNS_mug7k1wTp4rahI1QLsGnaAWo_24).
--
-- How the missing-fish list (FishData below) was built, step by step:
--   1. Exported the Google Sheet as .xlsx (export?format=xlsx) and parsed it with
--      openpyxl to get every fish name currently listed in "Sorted by Bait".
--   2. Pulled the FULL list of Big Fish from the data source that actually
--      powers https://ff14fish.carbuncleplushy.com/ (that site itself is a JS app
--      with no scrapable API). The data lives in the app's GitHub repo:
--          https://github.com/icykoneko/ff14-fish-tracker-app
--      specifically js/app/data.js (FISH / FISHING_SPOTS / ITEMS / ZONES /
--      REGIONS / WEATHER_RATES / WEATHER_TYPES tables). That file is a JS object
--      literal (not strict JSON) - it was downloaded raw and the handful of
--      unquoted top-level keys were quoted before json.loads'ing it.
--   3. Filtered FISH entries where bigFish == true (329 total at the time this
--      was built) and diffed their names (case/whitespace-normalized) against
--      the sheet's existing list. Result: 34 fish were completely absent from
--      the sheet - 32 Dawntrail (7.1-7.5) + 2 Endwalker stragglers (Sidereal
--      Whale, Snowy Parexus) that had apparently just been overlooked.
--   4. For each missing fish, resolved via the same dataset:
--        - name            <- ITEMS[fishId].name_en
--        - zone / zoneId   <- FISH.location -> FISHING_SPOTS[location].territory_id
--                             (zoneId here IS the Territory ID, i.e. what
--                             GetAetheryteName()/IsInZone() in MoLib expect)
--        - x, y            <- FISHING_SPOTS[location].map_coords (normal in-game
--                             map-coordinate units, kept for reference/display)
--        - worldX, worldZ  <- x/y converted to raw world coordinates via FFXIV's
--                             standard map<->world formula (using each zone's map
--                             scale, e.g. Tuliyollal = 180, everything else here =
--                             100), since SetMapFlag turned out not to exist as a
--                             real global in this SnD build despite being listed
--                             in .stubs/snd-stubs.lua (discovered at runtime: see
--                             "Known gaps" below). worldX/worldZ are what actually
--                             get used for movement, via PathfindAndMoveTo.
--        - time             <- FISH.startHour/endHour (Eorzea hours; "Always" if
--                             0-24 with no weather restriction at all)
--        - weather/previousWeather <- FISH.weatherSet/previousWeatherSet, resolved
--                             to names via WEATHER_TYPES
--        - bait/additionalBait    <- FISH.bestCatchPath item chain, resolved via
--                             ITEMS (first item = primary bait, rest = additional)
--      Two spots (Cabinkeep Permit, Purse of Riches - both in Tuliyollal) had a
--      corrupted Y value in the *upstream* data.js itself (~47 million instead of
--      a normal map coordinate) - confirmed by grepping the raw file, not a
--      parsing bug on our end. Both have since been fixed by hand:
--        - Cabinkeep Permit: recovered by standing at the spot in-game and
--          converting the reported world position (X=-152.01, Z=259.63) to map
--          coordinates using FFXIV's standard formula with Tuliyollal's map scale
--          (180): x = 10.7, y = 15.3 (x lines up almost exactly with the value
--          that was already there, confirming the conversion was correct).
--        - Purse of Riches: x = 16.9, y = 15.2, read directly off an in-game
--          gathering-helper overlay (already in map-coordinate units, no
--          conversion needed).
--   5. Cross-checked against the user's actual AutoHook preset list (screenshot
--      of the "(Big Fish) 7.x Dawntrail" preset folder) and confirmed preset
--      names match fish names exactly 1:1 - that's why CharacterState.fishing
--      just calls SetAutoHookPreset(SelectedFish.name) directly with no separate
--      preset-name field in FishData.
--   6. The Google Sheet itself was then updated (rows added to "Sorted by Bait",
--      grouped under bait headers; some pre-existing duplicate/cross-listed rows
--      for multi-bait fish were cleaned up; the TOTAL/CAUGHT header formulas were
--      rewritten to be self-maintaining COUNTA-based formulas instead of
--      hand-maintained cell ranges). None of that sheet bookkeeping matters to
--      this script - FishData below is the final, already-resolved result.
--
-- Weather/time prediction (no plugin reads needed):
--   FFXIV's Eorzea clock and per-zone weather are both deterministic functions of
--   the real-world Unix clock - no game-memory access or external polling is
--   required to know them in advance. This is implemented in MoLib.lua under the
--   "WEATHER" section - none of it existed in MoLib before this script; the
--   whole section (WeatherName, EorzeaWeatherRates, and every function below)
--   was written from scratch specifically to support BigFish.lua. If MoLib gets
--   refactored later and this script's still around, double-check these weren't
--   accidentally dropped as "unused":
--     - GetEorzeaTime(unixSeconds?)           -> current Eorzea hour/minute
--     - GetWeatherForecastTarget(unixSeconds)  -> 0-99 forecast roll for the
--                                                 current 8-Eorzea-hour weather
--                                                 period (same algorithm the game
--                                                 client itself uses)
--     - EorzeaWeatherRates[territoryId]        -> cumulative weather-rate table
--                                                 per zone, sourced from the same
--                                                 ff14-fish-tracker-app data.js
--                                                 (WEATHER_RATES). Currently only
--                                                 has entries for the 9 zones the
--                                                 34 fish above live in - extend
--                                                 this table (see MoLib.lua) if
--                                                 you add fish from other zones.
--     - GetCurrentWeatherId / GetCurrentWeatherName / GetPreviousWeatherName
--                                               -> wrap the above into a usable
--                                                  weather name lookup, including
--                                                  the *previous* 8-hour period
--                                                  (needed for fish that require a
--                                                  weather transition, e.g. "Rain
--                                                  after Clear Skies").
--   IsFishUp(fish, unixSeconds?) below combines all of this into a single
--   true/false check per fish entry.
--
-- Script architecture (mirrors FishingScrips.lua in this same folder):
--   CharacterState.selectFish    - scans FishData top-to-bottom for the first
--                                  entry where IsFishUp() is true and not on
--                                  cooldown (lastAttempt table, see
--                                  RetryCooldownSeconds). Sets SelectedFish and
--                                  advances to teleportToZone. If nothing is up,
--                                  logs once (loggedIdle) and just keeps idling -
--                                  the 0.1s main-loop tick re-evaluates constantly,
--                                  so no separate poll-interval config exists.
--   CharacterState.teleportToZone - re-checks IsFishUp() (window may have closed
--                                  while still travelling) before teleporting via
--                                  GetAetheryteName(zoneId) + Teleport(). Falls
--                                  back to selectFish if the window closed.
--   CharacterState.travelToSpot   - Mount() -> WaitForNavMesh() ->
--                                  QueryMeshPointOnFloor(worldX, 500, worldZ, ...)
--                                  to find a landable Y -> PathfindAndMoveTo(worldX,
--                                  Y, worldZ, true) -> WaitForPathRunning() ->
--                                  Dismount(). Same pattern FishingScrips.lua uses
--                                  in this same folder. (Originally tried
--                                  SetMapFlag + "/vnav flyflag" like
--                                  QoL/Alexandrite.lua, but SetMapFlag turned out
--                                  not to exist as a real global at runtime - see
--                                  "Known gaps" below.)
--   CharacterState.fishing        - on first entry (fishingStarted == false):
--                                  SetAutoHookPreset(SelectedFish.name) ->
--                                  SetAutoHookState(true) -> Execute("/ahstart").
--                                  Once IsFishing() goes true, fishingStarted
--                                  flips on and the state just waits each tick
--                                  while IsFishing() or IsGathering(). When fishing
--                                  stops (AutoHook caught the target OR gave up -
--                                  this script cannot currently tell which), the
--                                  fish goes on cooldown and we return to
--                                  selectFish.
--
-- Known gaps / things to revisit:
--   - First live test (2026-06-18) confirmed SelectFish/TeleportToZone work
--     correctly (correctly picked Deep Canopy when its window opened, correctly
--     teleported to Yak T'el), but TravelToSpot then crashed: it called
--     SetMapFlag(x, y, true), which is listed in .stubs/snd-stubs.lua but does
--     NOT actually exist as a global function in this SnD build at runtime
--     ("attempt to call a nil value (global 'SetMapFlag')"). The stub file is
--     apparently not a reliable guarantee of what's actually registered - verify
--     against real behavior, not just the stub, before trusting an unfamiliar
--     global again. Fixed by switching to worldX/worldZ + QueryMeshPointOnFloor +
--     PathfindAndMoveTo (FishingScrips.lua's proven pattern) instead. Movement
--     itself (navmesh behavior at these exact spots) still hasn't been verified
--     end-to-end - that's the next thing to confirm on a live run.
--   - No success/failure detection for a fishing attempt beyond "IsFishing()
--     turned false" - can't currently distinguish "caught it" from "AutoHook gave
--     up" from "got interrupted". Might be worth hooking chat messages (see
--     FishingScrips.lua's OnChatMessage / fishSense pattern) to detect an actual
--     catch and permanently remove that fish from FishData/mark it caught.
--   - AutoHook preset stop-on-catch behavior and the weather/time math itself
--     still need real-world verification.
--   - If you add fish in a zone not already in MoLib's EorzeaWeatherRates, weather
--     gating will silently fail (GetCurrentWeatherName returns nil) - add the
--     zone's territory ID + cumulative rate table there first.
--------------------------------------------------------------------

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RetryCooldownSeconds  = Config.Get("RetryCooldownSeconds")
LogPrefix             = "[BigFish]"

local lastAttempt     = {}
local loggedIdle      = false
local fishingStarted  = false

--============================ CONSTANT ===========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

-------------------
--    Big Fish    --
-------------------

--- One entry per newly-tracked Big Fish (Dawntrail 7.x + the Endwalker stragglers).
--- x/y are map coordinates (same numbers you'd see in-game), kept for reference.
--- worldX/worldZ are the converted raw world coordinates actually used for movement.
--- time is an Eorzea hour window ("HH:00-HH:00") or "Always". weather/previousWeather are
--- comma-separated lists of acceptable weather names, or "" if unrestricted.
FishData = {
    {
        name = "Autarch's Supper",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Sapsweet Cenote",
        x = 35.0, y = 32.7, radius = 1000,
        worldX = 674.34, worldZ = 559.45,
        time = "16:00-18:00",
        weather = "Fog",
        previousWeather = "Rain",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Awaksbane Apoda",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Yak Awak Tsoly",
        x = 19.1, y = 8.8, radius = 800,
        worldX = -119.88, worldZ = -634.38,
        time = "0:00-24:00",
        weather = "Clouds, Fog",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Azure Diver",
        zone = "Shaaloani",
        zoneId = 1190,
        spotName = "Eastbound Zorgor",
        x = 33.1, y = 38.2, radius = 1000,
        worldX = 579.43, worldZ = 834.19,
        time = "18:00-24:00",
        weather = "Gales",
        previousWeather = "Clear Skies, Fair Skies",
        bait = "Dragonfly",
        additionalBait = "",
    },
    {
        name = "Bitterbark Caiman",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Bitterbark Cenote",
        x = 25.5, y = 39.0, radius = 800,
        worldX = 199.8, worldZ = 874.15,
        time = "16:00-18:00",
        weather = "Clear Skies",
        previousWeather = "Fog",
        bait = "Red Maggots",
        additionalBait = "Blind Brotula",
    },
    {
        name = "Cabinkeep Permit",
        zone = "Tuliyollal",
        zoneId = 1185,
        spotName = "The For'ard Cabins",
        x = 10.7, y = 15.3, radius = 1000,
        worldX = -151.85, worldZ = 261.74,
        time = "5:00-7:00",
        weather = "",
        previousWeather = "",
        bait = "Ghost Nipper",
        additionalBait = "",
    },
    {
        name = "Crenicichla Miyaka",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "The Dewspun Bank",
        x = 37.9, y = 33.3, radius = 600,
        worldX = 819.2, worldZ = 589.42,
        time = "6:00-8:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Datnioides Aeroplanos",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "Leynode Aero",
        x = 16.2, y = 13.2, radius = 600,
        worldX = -264.74, worldZ = -414.6,
        time = "2:00-4:00",
        weather = "Rain",
        previousWeather = "Fog",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Deep Canopy",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Iq Br'aax Reservoir",
        x = 13.7, y = 12.7, radius = 500,
        worldX = -389.62, worldZ = -439.57,
        time = "10:00-12:00",
        weather = "",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Esperance Carp",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "Proto Alexandria",
        x = 38.5, y = 31.6, radius = 500,
        worldX = 849.17, worldZ = 504.51,
        time = "22:00-24:00",
        weather = "Clouds",
        previousWeather = "Rain",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Excavator Catfish",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Marsh Ligaka",
        x = 25.8, y = 31.6, radius = 800,
        worldX = 214.79, worldZ = 504.51,
        time = "4:00-6:00",
        weather = "Clouds",
        previousWeather = "Rain",
        bait = "Popper Lure",
        additionalBait = "",
    },
    {
        name = "Gigagiant Snakehead",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "Mu Springs Eternal",
        x = 12.6, y = 11.5, radius = 300,
        worldX = -444.57, worldZ = -499.51,
        time = "4:00-6:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Gondola Louvar",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "Canal Town South",
        x = 14.3, y = 34.8, radius = 1050,
        worldX = -359.65, worldZ = 664.35,
        time = "8:00-12:00",
        weather = "Fair Skies",
        previousWeather = "Rain",
        bait = "Ghost Nipper",
        additionalBait = "",
    },
    {
        name = "Harlequin Queen",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "The Knowable",
        x = 7.2, y = 14.3, radius = 400,
        worldX = -714.3, worldZ = -359.65,
        time = "16:00-18:00",
        weather = "Fair Skies",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Heirloom Goldgrouper",
        zone = "Heritage Found",
        zoneId = 1191,
        spotName = "Alexandrian Ruins",
        x = 6.8, y = 34.0, radius = 1000,
        worldX = -734.28, worldZ = 624.39,
        time = "12:00-16:00",
        weather = "Fair Skies",
        previousWeather = "Fog",
        bait = "Popper Lure",
        additionalBait = "",
    },
    {
        name = "Iron Oxydoras",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Miyakabek'zoma",
        x = 14.5, y = 28.6, radius = 2000,
        worldX = -349.66, worldZ = 354.65,
        time = "13:00-15:00",
        weather = "Fog",
        previousWeather = "Clouds",
        bait = "Golden Stonefly Nymph",
        additionalBait = "Dumplingfish",
    },
    {
        name = "Iron Shadowtongue",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Iq Rrax Tsoly",
        x = 31.8, y = 6.8, radius = 1800,
        worldX = 514.5, worldZ = -734.28,
        time = "16:00-18:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Lotl-in-waiting",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Xobr'it Tsoly",
        x = 33.3, y = 16.6, radius = 800,
        worldX = 589.42, worldZ = -244.76,
        time = "0:00-4:00",
        weather = "Clouds",
        previousWeather = "Fair Skies",
        bait = "Cloud-eye Carp",
        additionalBait = "",
    },
    {
        name = "Moonmarking Saucer",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Cenote Jayunja",
        x = 19.7, y = 32.0, radius = 1800,
        worldX = -89.91, worldZ = 524.49,
        time = "16:00-21:00",
        weather = "Rain",
        previousWeather = "Clear Skies",
        bait = "Red Maggots",
        additionalBait = "Flawless Saucer",
    },
    {
        name = "Moxutural Greatgar",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Cenote Moxutural",
        x = 21.7, y = 20.3, radius = 800,
        worldX = 9.99, worldZ = -59.94,
        time = "20:00-22:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Popper Lure",
        additionalBait = "Checkered Cichlid",
    },
    {
        name = "Muttering Matamata",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Bopo'uihih",
        x = 10.6, y = 12.4, radius = 1500,
        worldX = -544.47, worldZ = -454.56,
        time = "12:00-14:00",
        weather = "Clear Skies",
        previousWeather = "",
        bait = "Poison Dyefrog",
        additionalBait = "",
    },
    {
        name = "Ole Ole Ole",
        zone = "Urqopacha",
        zoneId = 1187,
        spotName = "Chirwagur Lake",
        x = 20.0, y = 37.0, radius = 600,
        worldX = -74.93, worldZ = 774.24,
        time = "0:00-2:00",
        weather = "Snow",
        previousWeather = "Clouds",
        bait = "White Worm",
        additionalBait = "",
    },
    {
        name = "Prime Adjudicator",
        zone = "Urqopacha",
        zoneId = 1187,
        spotName = "Karvarhur the First",
        x = 6.3, y = 20.3, radius = 1000,
        worldX = -759.26, worldZ = -59.94,
        time = "12:00-16:00",
        weather = "Fog",
        previousWeather = "Fair Skies",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Punutiy Pain",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Peaks Poga",
        x = 40.0, y = 15.1, radius = 600,
        worldX = 924.1, worldZ = -319.69,
        time = "8:00-12:00",
        weather = "Rain",
        previousWeather = "Clouds",
        bait = "Hunu Peacock Bass",
        additionalBait = "",
    },
    {
        name = "Purse of Riches",
        zone = "Tuliyollal",
        zoneId = 1185,
        spotName = "High Tide Harbor",
        x = 16.9, y = 15.2, radius = 1800,
        worldX = 405.6, worldZ = 252.75,
        time = "16:00-18:00",
        weather = "Rain",
        previousWeather = "Clouds",
        bait = "Ghost Nipper",
        additionalBait = "",
    },
    {
        name = "Riverlong Candiru",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Miyakabek'zu",
        x = 29.2, y = 12.0, radius = 600,
        worldX = 384.62, worldZ = -474.54,
        time = "0:00-4:00",
        weather = "Clouds",
        previousWeather = "Fair Skies",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Shin Snuffler",
        zone = "Yak T'el",
        zoneId = 1189,
        spotName = "Ankledeep",
        x = 8.0, y = 27.2, radius = 400,
        worldX = -674.34, worldZ = 284.72,
        time = "0:00-2:00",
        weather = "Fog",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Shined Copper Shark",
        zone = "Living Memory",
        zoneId = 1192,
        spotName = "Canal Town North",
        x = 9.5, y = 28.1, radius = 1050,
        worldX = -599.41, worldZ = 329.68,
        time = "8:00-13:00",
        weather = "Fog",
        previousWeather = "Clouds",
        bait = "Ghost Nipper",
        additionalBait = "",
    },
    {
        name = "Shuckfin Dace",
        zone = "Kozama'uka",
        zoneId = 1188,
        spotName = "Ku'uxage",
        x = 22.7, y = 21.1, radius = 800,
        worldX = 59.94, worldZ = -19.98,
        time = "4:00-6:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Sidereal Whale",
        zone = "Ultima Thule",
        zoneId = 960,
        spotName = "Limne 3-β",
        x = 25.1, y = 17.2, radius = 600,
        worldX = 179.82, worldZ = -214.79,
        time = "0:00-8:00",
        weather = "Astromagnetic Storms",
        previousWeather = "Umbral Wind",
        bait = "Horizon Event",
        additionalBait = "",
    },
    {
        name = "Snowy Parexus",
        zone = "Garlemald",
        zoneId = 958,
        spotName = "The Eblan Thaw",
        x = 11.1, y = 30.7, radius = 600,
        worldX = -519.49, worldZ = 459.55,
        time = "16:00-24:00",
        weather = "Snow",
        previousWeather = "Fair Skies",
        bait = "Mayfly",
        additionalBait = "",
    },
    {
        name = "Sprouting Perch",
        zone = "Heritage Found",
        zoneId = 1191,
        spotName = "Outskirts Shallows",
        x = 19.8, y = 8.9, radius = 1400,
        worldX = -84.92, worldZ = -629.39,
        time = "20:00-24:00",
        weather = "Thunderstorms",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Thunderous Flounder",
        zone = "Heritage Found",
        zoneId = 1191,
        spotName = "Crackling Canyons",
        x = 21.5, y = 32.3, radius = 1800,
        worldX = 0.0, worldZ = 539.47,
        time = "0:00-24:00",
        weather = "Rain",
        previousWeather = "",
        bait = "Red Maggots",
        additionalBait = "",
    },
    {
        name = "Ttokatoa",
        zone = "Shaaloani",
        zoneId = 1190,
        spotName = "Lake Toari",
        x = 31.5, y = 13.8, radius = 1000,
        worldX = 499.51, worldZ = -384.62,
        time = "20:00-24:00",
        weather = "Dust Storms",
        previousWeather = "Fair Skies",
        bait = "Popper Lure",
        additionalBait = "Niikwerepi Trout",
    },
    {
        name = "Vagrant Keeper",
        zone = "Shaaloani",
        zoneId = 1190,
        spotName = "Westbound Zorgor",
        x = 16.1, y = 38.2, radius = 1000,
        worldX = -269.74, worldZ = 834.19,
        time = "6:00-8:00",
        weather = "Clouds",
        previousWeather = "Gales",
        bait = "Dragonfly",
        additionalBait = "",
    },
}

--=========================== FUNCTIONS ===========================--

-------------------
--    Utility    --
-------------------

function IsFishUp(fish, unixSeconds)
    unixSeconds = unixSeconds or os.time()

    if fish.time ~= "Always" then
        local hour, minute = GetEorzeaTime(unixSeconds)
        local hourDecimal = hour + minute / 60

        local startHour, endHour = fish.time:match("^(%d+):%d+%-(%d+):%d+$")
        startHour, endHour = tonumber(startHour), tonumber(endHour)

        if endHour > startHour then
            if hourDecimal < startHour or hourDecimal >= endHour then
                return false
            end
        else
            -- window wraps past midnight (e.g. 20:00-2:00)
            if hourDecimal < startHour and hourDecimal >= endHour then
                return false
            end
        end
    end

    if fish.weather and fish.weather ~= "" then
        local currentWeather = GetCurrentWeatherName(fish.zoneId, unixSeconds)
        if not currentWeather or not string.find(fish.weather, currentWeather, 1, true) then
            return false
        end
    end

    if fish.previousWeather and fish.previousWeather ~= "" then
        local priorWeather = GetPreviousWeatherName(fish.zoneId, unixSeconds)
        if not priorWeather or not string.find(fish.previousWeather, priorWeather, 1, true) then
            return false
        end
    end

    return true
end

-------------------
--    Fishing    --
-------------------

function SelectNextFish()
    for _, fish in ipairs(FishData) do
        if fish.x and fish.y then
            local cooldownUntil = lastAttempt[fish.name]
            if (not cooldownUntil or os.clock() >= cooldownUntil) and IsFishUp(fish) then
                return fish
            end
        end
    end
    return nil
end

function CharacterState.selectFish()
    local fish = SelectNextFish()

    if not fish then
        if not loggedIdle then
            LogInfo(string.format("%s No fish window currently open. Waiting...", LogPrefix))
            loggedIdle = true
        end
        return
    end

    loggedIdle = false
    SelectedFish = fish
    LogInfo(string.format("%s Selected fish: %s (%s, bait: %s)", LogPrefix, SelectedFish.name, SelectedFish.spotName, SelectedFish.bait))
    State = CharacterState.teleportToZone
    LogInfo(string.format("%s State Changed → TeleportToZone", LogPrefix))
end

function CharacterState.teleportToZone()
    if not IsFishUp(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed → SelectFish", LogPrefix))
        return
    end

    if not IsInZone(SelectedFish.zoneId) then
        local aetheryteName = GetAetheryteName(SelectedFish.zoneId)
        if aetheryteName then
            Teleport(aetheryteName)
        end
        return
    end

    if not IsPlayerAvailable() then
        return
    end

    State = CharacterState.travelToSpot
    LogInfo(string.format("%s State Changed → TravelToSpot", LogPrefix))
end

function CharacterState.travelToSpot()
    if not IsFishUp(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed → SelectFish", LogPrefix))
        return
    end

    if not IsInZone(SelectedFish.zoneId) then
        State = CharacterState.teleportToZone
        LogInfo(string.format("%s State Changed → TeleportToZone", LogPrefix))
        return
    end

    LogInfo(string.format("%s Flying to %s (%.1f, %.1f)", LogPrefix, SelectedFish.spotName, SelectedFish.worldX, SelectedFish.worldZ))
    Mount()
    WaitForNavMesh()

    local point = QueryMeshPointOnFloor(SelectedFish.worldX, 500, SelectedFish.worldZ, false, 50)
    local targetY = (point and point.Y) or 0

    PathfindAndMoveTo(SelectedFish.worldX, targetY, SelectedFish.worldZ, true)
    WaitForPathRunning()
    Dismount()

    State = CharacterState.fishing
    LogInfo(string.format("%s State Changed → Fishing", LogPrefix))
end

function CharacterState.fishing()
    if not fishingStarted then
        if not IsFishUp(SelectedFish) then
            LogInfo(string.format("%s %s's window closed before fishing started.", LogPrefix, SelectedFish.name))
            State = CharacterState.selectFish
            LogInfo(string.format("%s State Changed → SelectFish", LogPrefix))
            return
        end

        if not IsPlayerAvailable() then
            return
        end

        LogInfo(string.format("%s Starting AutoHook preset: %s", LogPrefix, SelectedFish.name))
        SetAutoHookPreset(SelectedFish.name)
        SetAutoHookState(true)
        Wait(1)
        Execute("/ahstart")
        Wait(3)

        if IsFishing() then
            fishingStarted = true
        end
        return
    end

    if IsFishing() or IsGathering() then
        Wait(1)
        return
    end

    -- Fishing stopped: either AutoHook caught the target or gave up.
    LogInfo(string.format("%s Finished attempt on %s.", LogPrefix, SelectedFish.name))
    lastAttempt[SelectedFish.name] = os.clock() + RetryCooldownSeconds
    fishingStarted = false
    State = CharacterState.selectFish
    LogInfo(string.format("%s State Changed → SelectFish", LogPrefix))
end

--=========================== EXECUTION ===========================--

for _, fish in ipairs(FishData) do
    if not fish.y then
        LogInfo(string.format("%s WARNING: %s has no valid coordinates (source data error) - skipping until fixed.", LogPrefix, fish.name))
    end
end

if not GetClassJobId(18) then
    LogInfo(string.format("%s Switching to Fisher.", LogPrefix))
    Execute("/gs change Fisher")
    Wait(1)
end

State = CharacterState.selectFish
LogInfo(string.format("%s State Changed → SelectFish", LogPrefix))

while true do
    State()
    Wait(0.1)
end

--============================== END ==============================--
