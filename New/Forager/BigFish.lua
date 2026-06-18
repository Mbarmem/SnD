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
  DisabledFish:
    description: |
      A list of fish names to skip entirely.
      Enter the exact fish name and press enter. One fish per line.
      Use this to manually remove fish from rotation after you catch them.
    default: []

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
--      names match fish names exactly 1:1. The script originally relied only on
--      that and selected named presets directly; it now also supports an
--      optional per-fish exported preset string (autoHookPreset) for anonymous
--      IPC-based preset selection when provided.
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
--                                  entry where IsFishUp() is true, the primary
--                                  bait is available (if bait checks are active),
--                                  and the fish is not disabled or on cooldown
--                                  (lastAttempt table, see
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
--                                  SelectAutoHookPreset(SelectedFish) ->
--                                  SetAutoHookState(true) -> Execute("/ahstart").
--                                  SelectAutoHookPreset uses
--                                  SetAutoHookAnonymousPreset(autoHookPreset)
--                                  when a fish entry provides an exported preset
--                                  string, otherwise it falls back to the named
--                                  preset path SetAutoHookPreset(SelectedFish.name).
--                                  Once IsFishing() goes true, fishingStarted
--                                  flips on and the state just waits each tick
--                                  while IsFishing() or IsGathering(). In practice,
--                                  AutoHook keeps the character in the gathering
--                                  state until the target fish is actually caught
--                                  (or something external interrupts fishing), so
--                                  this script does NOT naturally advance on a miss.
--                                  It only cools the fish down and returns to
--                                  selectFish once gathering ends.
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
--   - No success/failure detection for a fishing attempt beyond "gathering ended" -
--     can't currently distinguish "caught it" from "got interrupted", and with the
--     current AutoHook behavior it generally will not end gathering on an ordinary
--     miss anyway. Might be worth hooking chat messages (see
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
DisabledFishConfig    = Config.Get("DisabledFish")
LogPrefix             = "[BigFish]"

local lastAttempt     = {}
local loggedIdle      = false
local fishingStarted  = false
local catchDetected   = false
local catchMessage    = nil
local forcedQuit      = false
local disabledFish    = {}
local baitItemIds     = {}
local missingBaitLog  = {}
local baitChecksReady = false

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
--- autoHookPreset is an optional exported AutoHook preset string for anonymous IPC preset
--- selection; leave it blank to use the named preset path with fish.name instead.
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
        autoHookPreset = "",
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
        autoHookPreset = "AH6_H4sIAAAAAAAACu1cW2/bOhL+KwGxwL5Ihe4Xv7lO2w2QNEHsoFgUAZaSRjY3suhDUUmzQf77grrYliylTuImdg7f7CFFcciP8w01HD6gYc7pCGc8G8VTNHhAX1IcJDBMEjTgLAcFHdOUj3AaQnJGaTirxZcQ4owPUzLHnNC0rFEXTnKWjmiSQMjP4xgNYpxkoKDRLJ9vPFGVNR/5QfiM5kXzrXqir6ckBdHXk2lKGTS6VXY/qv+eRGhgeL6Cvi0mMwbZjCYRGmi9Wl0wQhnh92igK+gk+/IrTPIIopW4rLbW2jCgt1DLRzSNiFBuDFx0cF68a4oGP4vfuoLC4jdHAzTmmOfZMOTkFkbHSEEL8cQ/+P0CROl9xmH+qRoRQtPs0zdIgZHw0zEpBJjd/8f4+bOqOOaMpFPlqPp7wcgt5vBpRBmckuBaqeudB/+FkPfWu+4rQQoiUYYGP3VPM68VRNLbUulHBVXqPyqlYj8A8xmwlU7lg9b11lXN9arXCsKrn4AGaZ4kj48lEqrJe0DFD2MF4GgJmAICjteCgK5tBYIdoKDortLdLd99CTK1PwBNrYTmk4Mtlm9jhFdrzNI1qz3C9iuWWTVIz1BG31Tm8NdZ9zJQtlVy2xX7bXEQA3OLEzQwNW1b41D1vc8oWLqmv2D5GTszCaKP4xRPpySdPtFJ7QWdNHfayRFlERGD/4BO0ltgtWBjvZaEPCFz+EHSiN4tCzpMhm44zvbEfH4LLMSL11ix9fGxdmV2nmtDv5Js9uUesg33pT1QTQzYrYGytzKuzg60XIPBGb6B8YzE/DMmhf5CkNWCMcfhTYYGdg/XOd6mFlvo4L/XTF1gTiANC0fzEmLxli+YJfcC3UULPVPltJV0tuJB4930ZOR/MMK89KP6pq6tlbGd/2S+l1aTGU4Ivsm+4lvKRBsNQY1VU2nKLyGkt8Aq56VvLNqezlYj4bzXSHwm029YQPYBDdNpAiyrtTe6VTRdzdqY7m1U9HZsbvKEkxmlN73caGj2S7Z2O/Cfq26umK7b5//FGW7sq5cMeAkZ8BHNUw7sgok/4zu8WKr3lbIQCqtaSMtnCmEkpIX2pmd7SrF/Pw8BpwWztEapUThMkjGni6y7dLygRbNaSy5U7JK/joknjEynwIR7eq2gq5T8lRdvQRrYmo0dUN1IA9VyAkcNDCtSQ8vCMQSxiw0HPSrolGT8PBZjIdrYGF5RIHpZ0OxqsE5zBmeQZXgqXFykoO/FykCXEB2d4emU8gyVD08KL1i4mt8pm+PkXxUOL+GvnDCISoe70LMmih+Aiyqiaga8PRfl/6pwfVorUflGS3d9BV1lUKB/UT4girLPBfOwZXtXGay6Jmq0KzRLz0iKBtonbUOOf1XyqwwuGIQkIzTta3OjwqrZzaJGy/QOWJz3drZdvtZuu2S92TGHJMGsr9VW8arRdsGyze1gffg7y+79YN9yrcdp08q14dRVYwMZnZVa09xVpzVrnTa3Xo1jzmi5rWqvx/UPhb9fjpopl6NcjoewHJ/LwXu6cE9hCmmE2b1cu38HKv0AlHOVwTHNKzZZDtgplB97shAvuspLUZ/T2EtS1dMNljLEhzTpM0qg/2Ggl5B9gWclQbvn1rnEwMFB8WW+gkTjnqPxY/sKE1Z/1+n2FTrKS9FufAXXNuSWVkL9z0O9BO2uvAUJ232y0AfnL5Rg3KG/IPG4T3j8wB6DGCia8zXNZ/l8Q3iVwSjPOJ2XQYmG91Acmc1ZeehE/FgLf5eB0iHnMF/wlT+SM5hgNhXdMDpP75iu7W+c+Huj4Ouzw+DVaHXNwNpgdo7+ScrzQtgXALTF0dLfhQCfZVpkCHCfLMvBMd0rAmDdaJQRMInGd4rqSEDu+6eagzOPMlgjD/gcMHxlCOajnjU7UCjKEIxE4z6gUQZW5NHdgzanMlzycc+RHygYZbhE4nFP8PjOQZCebMD3jII0R+YlsQ2RDTaMObBVMtqaxaMLcSSFpNMxh0Vxv8L4jswDTHhpq8Q4CstZCVcD3fmqqtYynPKsp79TTuL783SchyFkxQxuZFeFMzqaYb7M7lpeOYP5BH6JdB2koGOSLRJ8L/IhJxRnq9cuJRt1C2nRARIW99Ys77hpVv+a4Gw2wdlNgNlJKKpVTX8WaT2i/a+UwZTRPF31+jPAYk2tQlpNTNeEruXJ6X5oRLZpqeCavmqJX74Z6qoTGJ4bxq6reyYSYbAyUa6C4c+loEyO20ycayTNub5v9CfNDe/wTRbgFI6GCxrhRuKc/ht4nUSQchLiRCzL3vxO22/noZpb5b3vIhH12UHGcc5iHMI4ER+uexWyX5ZHbe8utVZemfNGUefxAjMQ3IfFin/ozbW2n3E1kVieJ9GEjmYQ3ogMaN/yHdcQsFq7oUR7D/wfQLp2YZ9oGVoqTZyq99u37zSFhlEzCyLDCyHpsGllGnfdPlJFS3ALrHnBxyaxaoa4jaS4C+S1CV39NFmF2D4CS1ZJcpsk+XS2bpG0jvPprJy2VcJuca2QLtLxKsrbIgOvhkGnP3uHFyUWfsPhVoA1zzN0NcShrVqGr6lY133VdQJd03Rd80BD4o6mpzjadI0nMCyZ+QlmXru+TBLz4d5lVy/JN6DbcrEdJNPqkmn1P0+z77AbrVNE3n47uhMS1FzDxbrlqlro66rlOKB6EJhqZIVOGPmuH4K/DQk+sVE9I4xRdjTCbPHBNqm16ZMEJy9rfeOdZ7nkdkyF9ScKSXAv20pKgts/goss0zEjR1ct3Q5UKzQNNYhNTTUjzXNc0H3LhibB1XfANRlOfAPsY7jxjMznIBQ/Gs+wuHj1b8Vz8hPrx7iV/O12cnUIU7LXHn0Iley1f+wFHvjYDjzVsjGoVhS5amD7nqr7nuYYZgw2DrdiL6cfX1f8n3Q2z4+O8V0ai8ckecn4oCQvSV6HFMWT5LV/5IVDTQOwddULrUC1dB+rnhY5qmmC4cZBEBvbkJdlmk9svf6Nb47ESZgjca+nZC7JXJK5JHNJ5pJRsdFrmCsAOw5iB9Q41i3VAjtQA9My1TjwLM/WoyiyjeJ450n2LaGBOMHS8F96j2iuv8MzvdjBnupGnqlarmaqnhtEqh7qsa85lq9ZIXr8PzsUJS8icgAA",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "",
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
        autoHookPreset = "",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_H4sIAAAAAAAACu1d72+jPBL+V1bWfQwVP5MQ3Z3UpttepW5blVT7YbXSOTAkvhLMa0y7eav+7ycbSAKBbpqmu8nW35KxMTPm8czA8OAndJxxOsQpT4fhBA2e0OcYjyM4jiI04CyDDjqlMR/i2IfoC6X+tBTfgo9TfhyTGeaExnmPsnGUsXhIowh8fh2GpXQ4zWZrB4Q4SteO+Er4lGZy9Fo/oeoliUGoejGJKYOKVrn2Qfn3IkADs+920HkymjJIpzQK0EBvNeqGEcoIn6OB0UEX6ecffpQFECzFebeV0Y7H9AEWBtI4IMI4DzgaxFkUPecaFyd5QvKHuZznYGGYVLXbr6lq6BspuzttG9Vye9vMoP52pZ7QTJ5sggbfyt8+Gnz73kE4P+L5ewdBoX0x2QJmlRleYsE2dLtmSm+jGe4321JM0nsak6+JNsTYhm5scW3MnaLbi/FkQuLJC0rqWyhp7VTJIWUBwZH0G/EDsFKwdjFzrzIiM/hK4oA+Lhoa8GSY3e7m3uX6AZiPk7egYgMX9SpMrkzQGUmnn+eQrnnWuvnVK+vUzHecNwBwW92/4HvwpiTkJ5jIORWCtBR4HPv3KRo4zfGh2183Ynt4bmvCDeYEYl8GtlsIxbGfMYvmAogSFM3urFvXvLvJ9Nu/y53dMPI3DDHPo2FLDFwzytzIRzu7vSCjKY4Ivk/P8ANlQtuKoMSU1anKb8GnD8DQwBDroM3AehDaxLzubs07IZNzLKD1hI7jSQQsLU0ym/W2erq9dmE20Lu346WeRZxMKb1vjTam7myT8e0gXSnUXMaO5hTrB2e4km0vFvUtpMCHNIs5sBsm/niPOFmYd0aZD9KjSWl+jBQGQiqtt/q225FZ/bUPOJZevTZLlcbjKPI4TdLmVi+hcli9JhcmNsnXDe6gESOTCbA09w13Mfkrk8ciwL2xafdtzQlcU7ND6Gpjxw60XuA7bs/Qx7Zlo+cOuiQpvw6FhWKMtUkTDeLcMnAtp+AyY/AF0hRPAA0Q6qArCXd0TqMA4k8epzGE0fzT1XyWTFE+zGieCGf73EFXlM1w9J8CZ7fwV0YYBB7HPEul2aW//gpYdhFdU+A13fK/RdvqVStE+Qlto+d20F0KEtxJfoBoSk+k/2eLi3OXwlIz0aPeodr6hcRooB/pa3L8o5DfpXDDwCcpoXHbmGsdlsOuN1VGpo/AwqxV2Xr7yrj1ltVhPQ5RhFnbqLXm5aD1hsWYb8vIyvGasF+d9qYeazPY2Kk2HU19atY1up4StB5nNM/X67CtJHs/x61uKdwq3P4y3F7CBOIAs7mCrnK5h+Fy71I4pVnhTBf+9RLy++3Ux0lTey56dW5RHF1x0qZ4QqFyi/3ILXLcHFDGkAOxPV9QUDzUNPdAofhiCqDQqND46+L6iJX36s1xvaE9F+0mrvccU919KXe6LYBzKO4qsiswqtj+ZjDuMLYrPCo8vgWPZAY04yu58zSbrQnvUhhmKaezvC5QifTyRaWM5fV08WOlYpjXoY45h1nCl7lDxmCE2USo0VzvtXqOWy9VG7+otvXqcm8xW01XYGUyG2f/IuaZFLbVXxzxotTWFZgmh6FKMMpfvGth5ZVoVIUVldq/b7lEAVI9LFFFEPWChXryrIogH/ZdH1UEUdVhhUZVBFGvTn5Md6qKICq27xkYVRFE5Zp7gsc9KoJUiEiOa/+mKkh1ZrapbQiyzXHIgS25Pit3MzQRr4+QeOJxSCTF03skszEmPA+cYh7FXVEhXE5046mKXotyyquOvqKchPPr2Mt8H1J5BddYAv6UDqeYL2g25XhTzEfwg+e8m1OSJhGeC7bZiOJ0edqFZK2vlEoFiC+/FrD4sEC1+1mE0+kIp/djzC580a0Y+oSRWPLbziiDCaNZvNT6BCBZMUtKiwvTdEFXCEt+13THY8PRrGBsaHaohxp2bay5Y+iHlu8Eoe4jUQbLGUsFDDdhLPXMfjtjaRjRLNBgDp+GmCUVqpKxC6rSKzkfiquk7hgVA0kx544+eqFMMeL2/OnuH8zkVLQiRVk+YMeraEXqKcdeQVHRilR9dx/QqGhF6mMkB31LpSpqqqK2Z2BUFTVVUdsTPKqK2u4raoot9ME/2HZwOZJiCyk07h8aFVtIuce9AKSqbajaxgFHd1XbUInmXkFR1TbUbc8+oFHVNlRt46Dv21VtQz1E2jMwqtqGumvfEzyq2sbes4Ve82G3JyRINuWx8tTDU9RBiTjkH1ySQZA3TznMjopdCgmN06NziIER/+iUSAFm8/+a374VHT0uiDmdT8XfG0YeMIejIWVwScbfO2W/6/H/wOet/b63taAOehB2Gx1EEzRA//4X6iBSUmye5cu+5Xu/zZ+tU6SpHZOm+m4YBn63q/m2JXZ5ciwN28FYC00LfNe2At/BK6SpnBe1zpmq8KW6hmu286UuKY80EmuPmHCxLWWdMPXSoroIIObEx5GgLrZuMea49Z3QLGdvtxH1MhZiH7xIcBZaDXK22nPPcH6HRWo73V/0DU8vwQxEboCFK3hq3Rdw/aOk7eARC/kiGNHhFPz7xVpe2RpUf0dIHXRQs4qg9s8ypomp2ySmHcCeidJD05xXlTt5zWj38Fc0hopbt2TkxomQNHj1fC/FcnykiZHgAVh1h9v1hEo3xU6pcjPctzGLXiJTF/yyP5tL/fKClFtH4mwyPaAluViBZcr505W4hGjjPdYjTnKc/iSh6uJu1/B9XfNxYGm23Qs0d2w5muGaPcs0dacbBOi583IG9SbG+WEnUOW1+FBpUWW/61dE6xWbjJ05+yat3N4W8cf4U5OifHmqpGiLpGjTG32VFG2ZFL1/RvSRPi/j7SIlcIO+pYfga+MeuJqtu67mulZf0y2nC6Hf84PQks9YLtLziI7Fuqlkxq0PTlbOYYJt233oa0bfxprt9rpa37dB69omdg3LtoO+g57/D51NuRxRiAAA",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_H4sIAAAAAAAACu1c60/jOBD/V1bWfUxQXn1+K2XhkGBBtGg/IKRzkknqI417tlOWQ/zvJzvpI2kCpWT3Wjbf2rHjzIx/80gm42c0SAQdYi74MAhR/xl9jbEbwSCKUF+wBDR0QmMxxLEH0SWl3mRBvgEPczGIyRQLQuN0xmJwnLB4SKMIPHEVBAvqcJJMNy4IcMQ3rvhOxIQmavXCPMnqBYlBsnoexpRBjquUe3/x99xHfavb09DZbDxhwCc08lHfqBTqmhHKiHhCfVND5/zrDy9KfPBX5HTa2moDl85hKSCNfSKFG4GQDE7VvULUv1O/TQ156rdAfTQSWCR84Akyh+EJ0tBMXvGHeJqBHH3iAqZHmUYIjfnRGcTAiHd0QhQBs6e/rLu7bOJIMBKH2pfs7zUjcyzgaEgZXBD3XlvMu3L/Bk9UzruvGkEaIj5H/Tuza9j3GiLxPBX6RUOZ+C9aKtiYTOE7iX36uBRrbdK9hvDqJ6B+nETRy0u6sdlePCP1w1rB0V/uv9rRdrewo6ax1Z7WsKmKXa2crV5nF6AZtTElVShtLKe3lSE4puEUGHS201s5h5no7zAGc80YjM9iDOXg1qqEHAnsPfDDELLayM9mByHBHEeobxvGtg4o473K8TimYe5g4latFj6KcRiSOHyFSWMHJu163RBlPpHKf0bn8RzYgrDhPdIYvooZy4ESB2Za7fb2sfxqDszDszdicmah5ahY149TgxNcU9Ap4ZOvT8A38pii+PmdbRXEb7W22dt2vbxf4gcYTUggjjFROpUEviCkDg71WxVRst3dlGILGXr1ynCNBYHYU3nkDQTy2q+YRU8SiQoVFRvQLrLe3iqCWjVzz8i/MMQizZaq1Fzk1dou2tv18jqe4IjgB36K55RJdnOEBVpsLU+/AY/OgaG+KRFeJWExn9lKvjqs4X1+JNPEMQnPsITXMxrEYQQsSwZUhCgT0e4YzsYmbiNit2aDTyJBJpQ+VMYcy2jt8pRVX+679tRRmq//EAznnnCXkeUGOIghTWIB7JrJP6NHPFuKd0qZB8qvKWp6jSL6kqqkt7utrqaepK88wLHy7QUt5QYHUTQSdMbLR0czqpY1CnQpYhl9U2ANjRkJQ2AySb3X0G1M/knUtShwLc93DdBtDzu647YMvRt0Hd32set3rZ7bcW30oqELwsVVICWUa2woTQ7Ie6vwtVLBRcLgEjjHoUwIkYa+KbyjG/C/XOIwpIKj9OKxyhllYvaNsimO/szQdQP/JISBnybLStiFq/4OWE2RUzmIoobT/9ng+mZlpPSOjtnpaeiWg8L0LL1ADvFj5fvZcr1bDivW5IzihPzoJYlR3zgyNuj4R0a/5XDNwCOc0LhqzY0Jq2U3h3Ir00dgQVLJbHF8bd3iyPqyIwFRhFnVqoXh1aLFgeWa27nRw38qLH96qkozF3oqM+U8nMpmbCCjdFJhm8vmFHat1JMurHEkGE0fQor2uP4m7m1zNOzGHBtzbMzxg+Z4ASHEPmZPjUX+DgHyEwSSWw4nNMlixFJhF5C+GuEenpWNp6SqVLAy9GRX52KPJV8mNZlgA/SfDPQUsjvkSw1o99w7pxg4OCjulis0aNxzNH7uXGHMFm9rynOFkvGUVE+u0GlZzYNqA/WfD/UUtHVlCw1s98lDH1y+kIKxxnyhweM+4fETZwxSUTQRa5JPkukG8ZbDMOGCTtNSQy57UF+aJiz9REP+WCtVp0XNgRAwnYlVPpIwGGMWSjaM0i9Y7E6rV6xZm7+oUPruknWmrbIdWFNmqfbPY5EoYlVZryU/4XyrsPcu19IU9vbJsxxcpPtAWascjU1dq0Hjh9FYX+bVALJxj02xpvls5/eM7k0J5rN+QXagUGxKMA0a9wGNTWGl+SD3oN1pUy75vF+HHygYm3JJg8c9weMeFUFybW3/XxUkr5ldahuyc2sQCGCrxrE1j0dn8pMUEocjATN14sHokUxdTETqq6QepefMiCtFl94qm7Usp7zr6m9UkODpKh4lngdc7eBGz5Q3ocMJFsuercV6EyzG8EM24SANnRA+i/CT7F0cU8xXt11SNuYqqmKAeOq4l+XJMPnppxHmkzHmDy5m556cli19LJt15PqnlEHIaBKvuD4GmK2JpajZxpRt6Hr3W89zArfb1m3PtnXHAUd32722brWDtuf3TLACE8kyWNr+lsHwbklIW9422+FyrXBtU544U9UKd83IFL4M/L8TX6qGslxDnPkGwM59iAXxcCQNs7Ibs9Urdo3aW/WJ19E2+u4y4yhhAfZgFMlX15UCtXbrZW7V1wjbHE7zIY87mmEGMqZhacnPlf3OrXcc7SPN7twf0+EEvIdVhF2eu2HUuPv73wKtvAhNS0CpK9LNaj/0jcaQcz22Cjh4JiklnidtjV6sj3S5EsyB5Y+t2AyAhiVPzlAnXHzs45PXwllWCvvc0ez1ZlnVCY6TcJLu24H0yy7DpTqpx9yiVXYB0dKc+BHPUpy+kQd0sd1xLA90G/td3cFdX8eOaeiWHdhg99qO0ZJd8K/Hebvd7VTb1yVlHKIvY0YT8clC/GInKgL32olj28btpY+pNXC/OxVpQvwv+rTsFyQDmXnWnA28H1JN3rBb3vDzk4bf6Rl4VEfUxF0MVsfu6abhge6YnqFj3+3pPb/rm21se74dqKfnc34WUVdG9Fzy+MoTcO4u0OpYnq1ju2vqTtsHvRf4gW7b2HV7pue2zBZ6+Q+ZjSu6uVYAAA==",
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
        autoHookPreset = "",
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
        autoHookPreset = "AH6_H4sIAAAAAAAACu1cWW/jOBL+KwGxj1JD8i1jX9LOsQHSSRA76IcgwNBUyeZEFj0k5e5MkP++ICnZso604zg9dkZvdvEQWfzqIIvFZ3QcSzbAQopBMEH9Z3Qa4XEIx2GI+pLHYKETFskBjgiE3xgj05R8CwQLeRzRGZaURaZGWjiKeTRgYQhEXgcB6gc4FGChwTSeFVokZetNvlM5ZbHuPldPjfWSRqDGejGJGIe1YZnh++nfCx/1Gz3PQufz0ZSDmLLQR32nclY3nDJO5RPquxa6EKc/SRj74K/Iplqmt+MxW0BKH7DIp2pyQ5BqgDP9rQnq3+vfroWI/i1RHw0llrE4JpIuYHCCLDRXLf4jn+agSp+EhNmXhCOUReLLOUTAKflyQjUB86c/Gvf3ScWh5DSaWEfJ3xtOF1jClwHjcEnHD1Za73r8JxBZWe+hqgRZiPoC9e/dntN8sBCNFmbSLxZKpv9imYmN6Ay+08hnP1bTEhJzifpex7EQRD7qu07PKTY1PBlKTB7FqrH5cKPb7T1YaEYjU676sBCboz76L8p09WAhvPoJqB/FYfjyYpCTLPYz0j8aK8D7S4BpyHR6Oci4zkag2QFq9HCt8mF53W2Q7HwAlB0D5VeZrcR9jcMrmWy5Tms7DpfPJWHSGybjFiezPXxfZ4OR4SqstVzH3WJVGztDmhrjMMKTCY0mrwzS2WKQzZ0OcsC4T3GoNX+0AJ4SCjAwdmG1kMuCEiS6jU5nc/twvQBO8Pw9wpHlT2sHaM4w6IyK6ekTiIJtzE9/fWXbuem325usbWe3Y/+GH2E4pYH8iqnmqSKIlJCq/HaFYuz0irPYYA7ebudwgyWFiGjf5BYC1fYU8/BJIVGjolwTdvIj72ykCRu7UoXOFqqw20hVoedsrAlvOP0bBlgaE1y1kHl2NDYzDM0PZMersxpNcUjxozjDC8ZVH2uEFLlNa51+C4QtgKO+q6StzG3t9Ao2ciNGdA7PRH6lk3OsZOQZHUeTEHjiA2ozV4aTZtdpFXCyCXN6O9ZacSjplLHHSsPZcNrbbD924LMlw8wsVqmf+VNyvLb3W6LwFgTIAYsjCfyGqz/DH3i+nN4Z4wS0ctZU00YTfUXVs2/21OzVHvOaAI60gcpxaa3wOAyHks1FeelwznS3To6uplhGf5+ZHnE6mQBXe48Ca3akRZWMpOLS2ECPWkjx2qzFkkXm74iZZUA2MrWMHU3qqD9pjWcNTNu10GXM4RsIgSdqy4ksdKWFEF2xCFDSSG9Hm+rLks3VbpVFWtRuQbBwAYlzq5gjcs5WSQ2Njiu2rDJUbFArpV3PZTs/JqCoGdKMLcDsDrONZSxGzBRqpl8xSYOn62gYEwJC+0F5uJ2SKRtMsVzOe3k2geUIfqoFQxY6oWIe4iellEYMixUjl5RCXU3VA6BEH3CsjjbW65+FWExHWDyOMb8gmXpf1RZefeCMcZhwFitcpGUA88y8NPVFQeMuon/FGv3I9V0/IKRrt4jn2C2/g+0xcbFNoNNr+U3SbHc7aqd8SYW8DtTqlmJbFRjuG6QkQlwFlvMpE/Lois7nwNdAo+B8xfgMh/9LFOQt/BVTDn66kI6FUpfpO2BdRVUVIHNDMn+Tsqy6SUjmgy2361noToDWynPTQBWJr9oF40tu3glYjUzVyFdYL/1GI9R3vjgFOv6Z0O8E3HAgVFAWVfVZqLDqtli01jP7ATyIKwebL8/0my/JdjuUEIaYV/WaK151mi9Y9vkWpfhpT78+7gjLoF2xvGjI88gsq1EAWWmlHGLK6uQAUOpWpHI9lJyZY4X3SbbTrCV7ryTb/fdIdkYcrXdshn7Z+aHL+iVMIPIxf6rF/d9gyN+G3Lf2smcYvxNwwuLEVC1ZewnmzFUQPC8rN6Q3+7ZJ6zUT2FCn1LVv+5lEYi+VuYHsFm5bDdo91+MGAwcHxe28ihqNe47GT6xC7wSMeHr+VO4rlJQb0m58hW67Ue+Xa6h/PNQNaHflLdSw3ScNfXD+ggHjDv2FGo/7hMdP7DEoRrFYZmY+jWcF4p2AQSwkm5kj1jXvQV+Ljrm5+6V+ZO6dmIsGx1LCbL6KZKpKI8wnahhO1S2Ltle8pvl7bi+8+SpOwq6yJchws5T9F5GMNbEqUNlW94G3DlWW6ZY6VrlPquXgTN07wmvlaKzjazUa/6EAUA3IfT+rOTj1WEdr6ptIBwzfOgbzWS/FHSgU6xhMjcZ9QGMdWanvGB+0Oq3jJZ/3wvuBgrGOl9R43BM81lGQV3I4t4xt6LS9QAJfZXNmNB6bJ9l3Qwlzfal/+IPOxphKo6vUQZ7SnAlxFW4q/VRSaxlOeVPrPcvdSx4y+qjUPcP8sgXNJPR1my1oY6drEzIO7Fan5dvY81w7cL1uw3McIJ6HVBjMZPQlwbj7JcFk8RUz/Nay+7yuivFVZffdxFzAEQuObimZglhL8HN/Aa8LHyJJCQ5VcLIyQbrt5RO5mxu9P7GLTO43BxmHMQ8wgWFoEmkrJtTe7gWD9u5y0+t3jn5T1Hk4xxyU7cNK4p8rHytov+G1IyWeF/6IDaZAHpcSmnn6x/knoH8ATx3sIss9yZwvUWclefZXsAC+/sZO0aY6DfXMj36O570pMdUWMomufQYDmSTIFe3j6xnF+sEHHE+mZtlWyXgL5ca4Ks8vkaUNn1lQMCh1ZZdPMPzCfHdIt+cG4Nu+57fsVs/HtgdB224F4LWa4DVwo4dUSuFr5rnZ6b5ins9Z6Ac0OhrgBQ5D+snMc7oYFUY384hSbXMP923BdJV/gyU1wrRjS5q6XNvYR7e2j+7HG8dP+PSLVbl/3InpGnt+MHbaju2Ar3aepGF70GzagQvQbpNWL3C7eud5Ic5DNlYWds1Lqtw9Zs2jEwSB77l2r4Gbdstz2vbYdQIbd4Kg2e24nucCevk/1rNUQqJYAAA=",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_H4sIAAAAAAAACu1dW2/bOhL+KwWxwL5Iha62ZexL6l5OgDQJYgfFoiiwtDSyuZFFH4pymw3y3xek5ItuieOoreXyTSYpemY4w/nI4YgP6CzldIQTnozCGRo+oA8xnkZwFkVoyFkKGnpPYz7CsQ/RZ0r9+br4Bnyc8LOYLDAnNM5arCsnKYtHNIrA51dhuC4dzdNF5YUQR0nljS+Ez2kqey+1E6RekBgEqeezmDIoUJVRH6x/ngdoaA08DX1aTuYMkjmNAjQ0Gpm6ZoQywu/R0NTQefLhhx+lAQTb4qzZTm9nU7qCDYM0DohgbgxcELiQ/zVDw6/y2dSQL585GqIxxzxNznxOVjB6jzS0FG/8g98vQdTeJxwWb3OJEBonbz9BDIz4b98TWYDZ/X+sr1/zhmPOSDzT3uQ/rxlZYQ5vR5TBBZl+09btrqb/BZ83tvvWVIM0RIIEDb+aA8P5piESrzKmHzWUs/+oZYxNyAK+kDig3zvBVsIx42hoOrarIYgDNDQtY4erbxrC20dAwziNosfHTBNz5XlA8sHa2k+wUVipgr1BSQVNYy8lbEELJblaPVle/xDLMFojSohQTAoFuW0t1zEN5zC51VOYs/4C6zV3rNfYtd7zmKeybcmA6xVHq3aQmf+YY/8u6YSdPGHxn5ad4GCFIzS0jb2NO6e9yagd0zAPMB+rVesZx3g2I/HsCSKNA4i02zVxygIihP+AzuMVsHVBxTIzh751IJuKmsnBtHq9/R371QqYj5fPOOjcQuu1Ylc+TgsTzI6APpJk/uEekgqoKbNfHFm3xL7r7jO2vXZp/4zvYDwnIX+HiZSpKEjWBdkEh4ZugwfqDapc7MGD1y4P15gTiH0JKm8gFO9+wCy6F5ootaJhAHpl0nt7eSerZeoZ+R+MMM+QSJOYy7Ra+3lSu11aJ3McEXyXfMQrygS5hYK1tthasfwGfLoChoam0PAmDstYYS/+WraGd2T2CQuleUBn8SwClrt4Oe/XEW73DacyNPsQPmjZjNOIkzmld42exDLcQxZS7aHFnYVFLcL9wRkuLGI3/uIGEuAjmsYc2DUTP8bf8XLD3kfKfJCzlSzN3pGFgSiV3NsD19LkYvnKBxzLGbskpULlWRSNOV0m9bXjJZXdGqVywWJd+ev81oSR2QyYWL5VRLNfz4eA3gIJQrKZ5DcCyX5OaCZ0pKOsVeZGMuLE87rBQ6aF9sAdaOgiZfAZkgTPBNZEGrqURoduIHjzGc9mlCcof13CUYH5xHAIwmks2bqBhEYryEGekElSAh01LaRSXNJNk7FYPIoBkhBs816Q+iBKd4oWdAUZ5t99mafJhGaVkqhLykl4fxWPU9+HROKBspZ98Od0NMd8w/56Y2SO+QR+iHFCGnpPkmWE78VcNKE42Up9U1JpK0slAcSXOzSbzZxi848RTuYTnNxNMTv3RbO863cCwYv+P1IGM0ZTsZhe1wEsd9iSpY9i/fAT1LFrq6hfYTNWs838RWO4nwIogzl1g+nozpxl5BtzlmP8BLNZC7xiN7rZbDSXNC4ajF3yMJbyMMdgMN80dBuTv1OJqpBtBP1BHwa6ZQyw7oCFdc/xAz10XMsJYRoOQg89auiCJPwqFINbi5lERebeXw1KLilb4OivHHffwN8pYRCsgYKhofXS9Atg2UQ0TYBXUIH8nVfuwti8KPtHx+x7GrpNQKL9ZfaCqEreybUu2/R3m8CWNNGi3KBY+5kIUPXWqJTjH3n5bQLXDHySEBo39VlpsO22WlXomX4HFqaNxJbrd/ot1+x2O+YQRZg19Vqq3nZartj0+ZLJurvxIbshPtQ0Ya/lVF3VldWprkVFM2oblYa5rk1p1GrXmGtrHHNGs03XV9qjYSt7VPao7PGV9ngBM4gDzO7rTHL3ZICyyFPwkCfgSW4TeE/TXCM3AruALBaU+HhZV58VNWHBRkXP3y74HktEzxQUPA5Fz/SmQ+qbKWIzDFKq2NVVSUdV8TAEoCZGpY2t+/UJW2+t1Pv1mvqsqB2/3ncttahU0+mhCpypYlueXSmj8u2vVsYWfbvSx2PSxxNe3wtB0ZTvcD5PF5XC2wRGacLpItvtL2ACmemSsuxUqHjYOR2Xnbg64xwWy20IUzSaYDYTZBi1h2btvutVj9T/mlNcLxvsrQjrRmBHmLXS3xwNaYqsuSIj47nY2oumFhVbO6aZpXOr2OcjSy/URhVZUtr4am1sD3kphVTTowqXqJMzf6Z3V+GSUz3E1VFVVOESpY3HoI0qXKLOxHZ6OlXhktM9oN1RZVThEqWPR6KPRxQEKeTc/74oSFEyh8Q2ZJZZyIFts9p3Zjy6zNORxxyW8gNG4+9kMcWEZ3OVkKOYOfPCraBr/ypvtQmnvOjtPyuZORN+3YDuJKA50LdC7GI99HqG7vRdU5/2XEc3sN8zHQemht9HNVmedRlnh6T0qnQzlW52gsH2VwTPVFbWkYPwEz4jsleUTSUUqvWjSkpS+elq+0NF2f7YTyV0bidORdmUNh6PNqoom4qydXo6VVE25duPTBlVlE1hzSPRxyOKsh13qlH3v6xWvXzj9O4RUglh6mOLagdBJYQpzHs8mFclhKkN1qPaEVDfz1OfUu7whpZKCFPbB0eliiohTAVOj0EbVahKhapUqEp9r0wdQ1GhqurhJTU5dnxyPKJQlUoIUwlhvz0hbNobeH0wfB1bTk93QtPQpy54umla7nQwsHoBhEhExLIryfKQ6ddNQZYUVr2irJAs5vW9fnOy2HhO4jfjOA3DCFghY8x8JtvwPICYEx9Hwigb7w12vfL9xvZe95S3ccHxi785OU5ZiH0YR9k1gA0MuYfdpe3+Do5yYh6yB+uJK8Irwfq9mDJby4mtJUto7stv9W4vUXe8xAyE58PC3h8a7/B2XyA9YZznwYSO5uDfiZu1Pcfr9S2hVltaxa2XP01b8qMDeRqvtOpOnB1YiQRmW0NUXOP5L3mYIJ/f9jk/0IE7ztu4hTS/2bRmwq65B/USVsBythqTyA3L0dD5LKYMXpec91RKeJ6iedoZ4U8bpLzqHaezeYdMcmOBuXWae17RK1S0dhmxub73GegUOP3QNQ1Td00wdAdbnj4IBp5ugWs4ngdBaIZ1ufTFPPq+7Tbb11l8F0EAsHwzwjwU77UDj7an5I4SHf0J16s/gfUKo3OEUO/p4dnLESpM+Gs+Yf8r0GM2hSngeABwFKJTwPEnAsefjxr/pA8JtQKbMPYMsG1Ld3wMuuOITxBZvq2HDoA19d1p6OJ9YJPTDJv+je/eTP4JUcuo6eQ2lQ4AGht7VJtKalPpOVjgtA4L8glZbaQof3gq/rBne6EdYkO3Qm+gO5bYRjDMQHfB6VsDA4eel0VgzpNPEZ0KHFkARQ1RlJ1/8LHjYN+xdM9yA90xbEvHPR901zAcFyAIbKOHHv8PFcIQVoqfAAA=",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
    },
    {
        name = "Sidereal Whale",
        zone = "Ultima Thule",
        zoneId = 960,
        spotName = "Limne 3-Î²",
        x = 25.1, y = 17.2, radius = 600,
        worldX = 179.82, worldZ = -214.79,
        time = "0:00-8:00",
        weather = "Astromagnetic Storms",
        previousWeather = "Umbral Wind",
        bait = "Horizon Event",
        additionalBait = "",
        autoHookPreset = "",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
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
        autoHookPreset = "AH6_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",
    },
}

--=========================== FUNCTIONS ===========================--

-------------------
--    Utility    --
-------------------

function OnChatMessage()
    local message = TriggerData.message

    if not message or not SelectedFish or not fishingStarted then
        return
    end

    if message:find(SelectedFish.name, 1, true) then
        catchDetected = true
        catchMessage = message
        LogInfo(string.format("%s Detected chat match for %s: %s", LogPrefix, SelectedFish.name, message))
    end
end

function BuildDisabledFishSet()
    disabledFish = {}

    if type(DisabledFishConfig) == "table" then
        for _, fishName in ipairs(DisabledFishConfig) do
            if fishName and fishName ~= "" then
                disabledFish[fishName] = true
            end
        end
    elseif type(DisabledFishConfig) == "string" and DisabledFishConfig ~= "" then
        for fishName in DisabledFishConfig:gmatch("[^\r\n,]+") do
            local trimmed = fishName:gsub("^%s+", ""):gsub("%s+$", "")
            if trimmed ~= "" then
                disabledFish[trimmed] = true
            end
        end
    end
end

function BuildBaitItemIdMap()
    baitItemIds = {}
    baitChecksReady = false

    local itemSheet = Excel.GetSheet("Item")
    if not itemSheet then
        LogInfo(string.format("%s WARNING: Failed to load Item sheet. Bait availability checks disabled.", LogPrefix))
        return
    end

    local index = 0
    local row = itemSheet:GetRow(index)

    while row do
        if row.Name and row.RowId then
            baitItemIds[tostring(row.Name)] = row.RowId
        end
        index = index + 1
        row = itemSheet:GetRow(index)
    end

    baitChecksReady = true
end

function HasRequiredBait(fish)
    if not baitChecksReady then
        return true
    end

    if not fish.bait or fish.bait == "" then
        return true
    end

    local baitItemId = baitItemIds[fish.bait]
    if not baitItemId then
        if not missingBaitLog[fish.name] then
            LogInfo(string.format("%s Skipping %s: could not resolve bait item ID for '%s'.", LogPrefix, fish.name, fish.bait))
            missingBaitLog[fish.name] = true
        end
        return false
    end

    if GetItemCount(baitItemId) <= 0 then
        if not missingBaitLog[fish.name] then
            LogInfo(string.format("%s Skipping %s: no bait '%s' in inventory.", LogPrefix, fish.name, fish.bait))
            missingBaitLog[fish.name] = true
        end
        return false
    end

    missingBaitLog[fish.name] = nil
    return true
end

function SelectAutoHookPreset(fish)
    if fish.autoHookPreset and fish.autoHookPreset ~= "" then
        SetAutoHookAnonymousPreset(fish.autoHookPreset)
        LogInfo(string.format("%s Selected anonymous AutoHook preset for %s.", LogPrefix, fish.name))
    else
        SetAutoHookPreset(fish.name)
        LogInfo(string.format("%s Selected named AutoHook preset for %s.", LogPrefix, fish.name))
    end
end

function CleanupAutoHookPreset(fish)
    if fish and fish.autoHookPreset and fish.autoHookPreset ~= "" then
        ClearAutoHookAnonymousPresets()
    end
end

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
            if not disabledFish[fish.name] and HasRequiredBait(fish) and (not cooldownUntil or os.clock() >= cooldownUntil) and IsFishUp(fish) then
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
    LogInfo(string.format("%s State Changed â†’ TeleportToZone", LogPrefix))
end

function CharacterState.teleportToZone()
    if not IsFishUp(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed â†’ SelectFish", LogPrefix))
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
    LogInfo(string.format("%s State Changed â†’ TravelToSpot", LogPrefix))
end

function CharacterState.travelToSpot()
    if not IsFishUp(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed â†’ SelectFish", LogPrefix))
        return
    end

    if not IsInZone(SelectedFish.zoneId) then
        State = CharacterState.teleportToZone
        LogInfo(string.format("%s State Changed â†’ TeleportToZone", LogPrefix))
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
    LogInfo(string.format("%s State Changed â†’ Fishing", LogPrefix))
end

function CharacterState.fishing()
    if not fishingStarted then
        if not IsFishUp(SelectedFish) then
            LogInfo(string.format("%s %s's window closed before fishing started.", LogPrefix, SelectedFish.name))
            CleanupAutoHookPreset(SelectedFish)
            State = CharacterState.selectFish
            LogInfo(string.format("%s State Changed â†’ SelectFish", LogPrefix))
            return
        end

        if not IsPlayerAvailable() then
            return
        end

        LogInfo(string.format("%s Starting AutoHook preset: %s", LogPrefix, SelectedFish.name))
        catchDetected = false
        catchMessage = nil
        forcedQuit = false
        SelectAutoHookPreset(SelectedFish)
        SetAutoHookState(true)
        Wait(1)
        Execute("/ahstart")
        Wait(3)

        if IsFishing() then
            fishingStarted = true
        else
            CleanupAutoHookPreset(SelectedFish)
        end
        return
    end

    if not IsFishUp(SelectedFish) then
        if IsFishing() or IsGathering() then
            if not forcedQuit then
                LogInfo(string.format("%s %s's window closed while fishing. Forcing quit.", LogPrefix, SelectedFish.name))
                forcedQuit = true
            end
            ExecuteAction(CharacterAction.Actions.quitFishing)
            Wait(0.1)
            return
        end
    end

    if IsFishing() or IsGathering() then
        Wait(1)
        return
    end

    -- Gathering ended: either we saw a catch message, forced a quit when the
    -- window closed, or something external interrupted the attempt.
    if catchDetected then
        LogInfo(string.format("%s Confirmed catch for %s.", LogPrefix, SelectedFish.name))
        if catchMessage then
            LogInfo(string.format("%s Catch message: %s", LogPrefix, catchMessage))
        end
    elseif forcedQuit then
        LogInfo(string.format("%s Ended attempt on %s after the window closed.", LogPrefix, SelectedFish.name))
    else
        LogInfo(string.format("%s Finished attempt on %s without a confirmed catch.", LogPrefix, SelectedFish.name))
    end

    lastAttempt[SelectedFish.name] = os.clock() + RetryCooldownSeconds
    CleanupAutoHookPreset(SelectedFish)
    fishingStarted = false
    catchDetected = false
    catchMessage = nil
    forcedQuit = false
    State = CharacterState.selectFish
    LogInfo(string.format("%s State Changed â†’ SelectFish", LogPrefix))
end

--=========================== EXECUTION ===========================--

for _, fish in ipairs(FishData) do
    if not fish.y then
        LogInfo(string.format("%s WARNING: %s has no valid coordinates (source data error) - skipping until fixed.", LogPrefix, fish.name))
    end
end

BuildDisabledFishSet()
BuildBaitItemIdMap()

if not GetClassJobId(18) then
    LogInfo(string.format("%s Switching to Fisher.", LogPrefix))
    Execute("/gs change Fisher")
    Wait(1)
end

State = CharacterState.selectFish
LogInfo(string.format("%s State Changed â†’ SelectFish", LogPrefix))

while true do
    State()
    Wait(0.1)
end

--============================== END ==============================--
