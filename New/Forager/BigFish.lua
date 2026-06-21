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
    default: 10
    min: 10
    max: 600
  CaughtCooldownSeconds:
    description: |
      Seconds to wait before retrying a fish you've already caught this window.
      Should comfortably outlast its time/weather window so it doesn't get
      reselected and refished while the window is still open.
    default: 1800
    min: 60
    max: 7200
  ForceQuitDelaySeconds:
    description: |
      Seconds to keep fishing/gathering after a fish's window closes before
      forcing a quit. Gives an active bite/catch time to finish instead of
      cutting it off the instant the window closes.
    default: 15
    min: 0
    max: 120
  SwimBaitPrepSeconds:
    description: |
      For fish with swimBait = true, how many seconds early to head to the
      spot once idle and begin fishing before the real window opens.
      This lets AutoHook work the prep period for swim bait automatically.
      Only kicks in when no other fish window is currently open.
    default: 300
    min: 0
    max: 1800
  RequireAutoHookPreset:
    description: |
      When enabled, fish with no exported AutoHook preset (autoHookPreset = "")
      are skipped during selection entirely, instead of falling back to a
      named AutoHook preset that matches the fish name.
    default: false
  EnabledFish:
    description: |
      A list of fish names to restrict the rotation to.
      Enter the exact fish name and press enter. One fish per line.
      When non-empty, this overrides DisabledFish and only these fish are attempted.
      Leave empty to run the full rotation.
    default: []
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
--        - bait             <- FISH.bestCatchPath item chain, resolved via
--                             ITEMS (first item only; mooch or intermediate fish are not stored here)
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
--                                  and the fish is allowed (IsFishAllowed: when
--                                  EnabledFish is non-empty it's an allowlist that
--                                  overrides DisabledFish entirely; otherwise
--                                  DisabledFish is a blocklist) and not on cooldown
--                                  (lastAttempt table, see
--                                  RetryCooldownSeconds). Sets SelectedFish and
--                                  advances to teleportToZone. If nothing is up,
--                                  logs once (loggedIdle) and just keeps idling -
--                                  the 0.1s main-loop tick re-evaluates constantly,
--                                  so no separate poll-interval config exists.
--                                  If nothing is open right now, it does a second
--                                  pass for fish marked swimBait = true whose
--                                  real window opens within SwimBaitPrepSeconds,
--                                  so travel/fishing can start early for bait prep.
--   CharacterState.teleportToZone - re-checks IsFishReady() rather than only
--                                  IsFishUp(), so early-selected swimBait fish
--                                  are not cancelled mid-travel just because the
--                                  actual fish window has not opened yet.
--                                  while still travelling) before teleporting via
--                                  SelectedFish.aetheryte if set, otherwise
--                                  GetAetheryteName(zoneId) + Teleport(). Falls
--                                  back to selectFish if the window closed. An
--                                  explicit per-fish aetheryte matters most for
--                                  CanMount()-false zones (no mounting at all,
--                                  e.g. Tuliyollal), where vnavmesh failed to
--                                  path there ground-walking
--                                  from an arbitrary spot 280y away (confirmed:
--                                  PathfindAndMoveTo starts but never reaches
--                                  "Running" state) - but it also shortens
--                                  flights to fish far from the zone's default
--                                  aetheryte.
--   CharacterState.travelToSpot   - WaitForNavMesh() -> uses SelectedFish.worldY
--                                  if set, otherwise QueryMeshPointOnFloor(worldX,
--                                  500, worldZ, ...) to guess a landable Y (the
--                                  guess can pick the wrong level in multi-level
--                                  zones, e.g. Living Memory - see worldY/fishY in
--                                  the FishData doc comment above) - then either
--                                  Mount() -> MoveTo(worldX, Y, worldZ, 0, CanFly())
--                                  -> Dismount() (rides if mountable but CanFly()
--                                  is false), or for CanMount()-false zones just
--                                  MoveTo(worldX, Y, worldZ) on foot. worldX/worldZ
--                                  is a landing spot, not
--                                  necessarily the cast spot itself (some are
--                                  in/over water). If the fish entry also has
--                                  fishX/fishZ (the actual casting position,
--                                  facing the water - see
--                                  BigFishCoordCapture.lua), it then walks there
--                                  on foot via MoveTo() before fishing (using
--                                  fishY if set, same fallback as worldY);
--                                  entries without fishX/fishZ skip that walk.
--                                  Same pattern FishingScrips.lua uses in this
--                                  same folder. (Originally tried SetMapFlag +
--                                  "/vnav flyflag" like QoL/Alexandrite.lua, but
--                                  SetMapFlag turned out not to exist as a real
--                                  global at runtime - see "Known gaps" below.)
--                                  Also uses IsFishReady(), so swimBait prep
--                                  travel survives until the early-prep window
--                                  actually expires.
--   CharacterState.fishing        - on first entry (fishingStarted == false):
--                                  SelectAutoHookPreset(SelectedFish) ->
--                                  SetAutoHookState(true) -> Execute("/ahstart").
--                                  SelectAutoHookPreset uses
--                                  SetAutoHookAnonymousPreset(autoHookPreset)
--                                  when a fish entry provides an exported preset
--                                  string, otherwise it falls back to the named
--                                  preset path SetAutoHookPreset(SelectedFish.name).
--                                  For fish marked swimBait = true, reaching the
--                                  spot during the SwimBaitPrepSeconds early
--                                  window does NOT wait for the real fish window
--                                  to open - it starts fishing immediately so
--                                  AutoHook can catch swim bait during prep.
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
--   - First live test (2026-06-18) found that TravelToSpot's original approach -
--     SetMapFlag(x, y, true), listed in .stubs/snd-stubs.lua - does NOT actually
--     exist as a global function in this SnD build at runtime ("attempt to call
--     a nil value (global 'SetMapFlag')"). The stub file is apparently not a
--     reliable guarantee of what's actually registered - verify against real
--     behavior, not just the stub, before trusting an unfamiliar global again.
--     Fixed by switching to worldX/worldZ + stored worldY/fishY + MoveTo()
--     (FishingScrips.lua's proven pattern) instead. Movement is now confirmed
--     working end-to-end on live runs across CanMount()-false (Cabinkeep
--     Permit: walked, cast, caught) and flying (Hwittayoanaan Cichlid) entries
--     alike.
--   - Catch detection is implemented via OnChatMessage matching the fish name in
--     chat, same as FishingScrips.lua's pattern - confirmed live: caught the
--     "Caught limit reached (Cabinkeep Permit: 1). Stopping fishing." message,
--     set catchDetected/catchMessage, and CharacterState.fishing correctly logged
--     "Confirmed catch" and advanced back to selectFish.
--   - AutoHook's own stop-on-catch behavior is also confirmed live (it ended
--     gathering by itself once the catch limit message fired, no forced quit
--     needed).
--   - The weather/time math had a real bug: GetWeatherForecastTarget's bitwise
--     steps need to be masked to 32 bits (uint32_t semantics) because Lua's
--     integers are 64-bit and << / ~ don't auto-truncate - without the mask, the
--     forecast silently diverged from the real game once calcBase grew past 32
--     bits (confirmed live: predicted "Gales" for Azure Diver when the real
--     weather, and every third-party tracker, said "Clouds"). Fixed in MoLib.lua;
--     reverified against a live tracker snapshot after the fix and the predicted
--     up/not-up status matched exactly.
--   - DisabledFish/EnabledFish edits made through the SnD config UI while the
--     script is already running used to be silently ignored, because the sets
--     were only built once at script start from a snapshot of Config.Get().
--     Fixed: BuildDisabledFishSet/BuildEnabledFishSet now re-read Config.Get()
--     and are rebuilt every CharacterState.selectFish tick, so edits apply live.
--   - If you add fish in a zone not already in MoLib's EorzeaWeatherRates, weather
--     gating will silently fail (GetCurrentWeatherName returns nil) - add the
--     zone's territory ID + cumulative rate table there first.
--   - A confirmed catch used to get the same short RetryCooldownSeconds as a
--     failed attempt, so a fish could be reselected and refished minutes after
--     being caught while its window was still open (confirmed live: Thunderswift
--     Trout was refished ~60s after a confirmed catch, then had to be force-quit
--     when the window closed mid-attempt). Fixed: confirmed catches now use the
--     longer CaughtCooldownSeconds instead.
--   - Forcing a quit used to fire the instant a fish's window closed, even if a
--     bite/catch was already in progress. Fixed: ForceQuitDelaySeconds now keeps
--     fishing/gathering for a grace period after the window closes before
--     actually quitting, so an in-progress catch isn't cut off.
--   - Deep Canopy (Iq Br'aax Reservoir, Yak T'el) failed to reach its spot by
--     flight almost instantly on live runs (~1.5s, too fast to be a real
--     pathing timeout) because worldX/Y/Z was too close to its aetheryte to
--     fly to. Fixed by pointing worldX/Y/Z directly at the real casting spot
--     (previously a separate fishX/Y/Z leg) so the flight covers a real
--     distance, same single-leg pattern as Hwittayoanaan Cichlid/Moongripper/
--     Shin Snuffler/Sprouting Perch.
--   - swimBait fish (e.g. Muttering Matamata) got stuck in a force-quit loop
--     on live runs: CharacterState.fishing's window-closed check used
--     IsFishUp directly, so starting to fish during legitimate swim-bait
--     prep (before the real window opens) was immediately read as "window
--     closed," triggering ForceQuitDelaySeconds and reselecting the same
--     fish to repeat the cycle. Fixed with an explicit windowOpenedAt flag:
--     it's only set once IsFishUp actually goes true, and the force-quit
--     countdown only starts after that - so prep fishing is never penalized
--     for the real window not being open yet, only for it closing again
--     after having been open.
--   - Despite the windowOpenedAt fix above, Muttering Matamata kept cycling
--     on live runs anyway. The actual cause was unrelated to the state
--     machine: its exported autoHookPreset string was stale/wrong, so
--     AutoHook never actually engaged and fishing never progressed past
--     the cast - read by the script as the window closing over and over.
--     Re-exported and replaced the preset; confirmed working live.
--------------------------------------------------------------------

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RetryCooldownSeconds   = Config.Get("RetryCooldownSeconds")
CaughtCooldownSeconds  = Config.Get("CaughtCooldownSeconds")
RequireAutoHookPreset  = Config.Get("RequireAutoHookPreset")
ForceQuitDelaySeconds  = Config.Get("ForceQuitDelaySeconds")
SwimBaitPrepSeconds    = Config.Get("SwimBaitPrepSeconds")
LogPrefix              = "[BigFish]"

local lastAttempt     = {}
local loggedIdle      = false
local fishingStarted  = false
local catchDetected   = false
local catchMessage    = nil
local forcedQuit      = false
local windowClosedAt  = nil
local windowOpenedAt  = false
local disabledFish    = {}
local enabledFish     = {}
local baitItemIds     = {}
local missingBaitLog  = {}
local baitChecksReady = false
local fishDataNames   = nil
local unknownFishLog  = {}

--============================ CONSTANT ===========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

-----------------
--    Baits    --
-----------------

BaitItemIds = {
    ["Horizon Event"]         = 36518,
    ["Mayfly"]                = 36591,
    ["Stardust"]              = 36597,
    ["Poison Dyefrog"]        = 43691,
    ["Hunu Peacock Bass"]     = 43701,
    ["Cloud-eye Carp"]        = 43728,
    ["Crimson Lugworm"]       = 43850,
    ["Golden Stonefly Nymph"] = 43849,
    ["Honeybee"]              = 43852,
    ["White Worm"]            = 43854,
    ["Popper Lure"]           = 43855,
    ["Dragonfly"]             = 43857,
    ["Red Maggots"]           = 43858,
    ["Ghost Nipper"]          = 43859,
}

--------------------
--    Big Fish    --
--------------------

--- One entry per newly-tracked Big Fish (Dawntrail 7.x + the Endwalker stragglers).
--- x/y are map coordinates (same numbers you'd see in-game), kept for reference.
--- worldX/worldZ are the converted raw world coordinates used as the flight/landing
--- target. worldY/fishY are optional human-verified heights from BigFishCoordCapture.lua
--- (logged as worldY/fishY there) - when present, travelToSpot passes them straight to
--- MoveTo() instead of guessing a height via QueryMeshPointOnFloor, which can pick the
--- wrong level in multi-level zones (confirmed on Esperance Carp: guessed Y landed the
--- flight ~13y below the real casting-spot height). fishX/fishZ are optional - when
--- present, they're the actual human-verified casting spot (on land, facing the water)
--- walked to on foot after dismounting; see BigFishCoordCapture.lua. Entries without
--- fishX/fishZ skip that walk and fish right where they land. Whether travelToSpot
--- walks, rides, or flies to worldX/worldZ is decided live via CanMount()/CanFly() -
--- CanMount() is false in zones with no mounting at all (e.g. Tuliyollal), and
--- CanFly() false rides a mount on the ground instead of flying; no per-fish flag
--- needed for either. aetheryte is optional (works regardless of mount/fly state)
--- - when set, teleportToZone
--- uses it instead of the zone's default aetheryte for the shortest/most reliable
--- approach to that specific spot; leave blank to use the zone's default aetheryte.
--- time is an Eorzea hour window ("HH:00-HH:00") or "Always". weather/previousWeather are
--- comma-separated lists of acceptable weather names, or "" if unrestricted.
--- expansion is the source expansion for the fish ("Dawntrail", "Endwalker", etc.).
--- swimBait is optional - set it true for fish that should start early during the
--- SwimBaitPrepSeconds prep window. When enabled, the script may select the fish
--- before the real window opens, travel there early, and begin fishing immediately
--- so AutoHook can work the swim-bait setup automatically.
--- autoHookPreset is an optional exported AutoHook preset string for anonymous IPC preset
--- selection; leave it blank to use the named preset path with fish.name instead - unless
--- the RequireAutoHookPreset config option is enabled, in which case fish left blank are
--- skipped during selection rather than falling back to the named preset path.
FishData = {
    {
        name            = "Autarch's Supper",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Mamook",
        spotName        = "Sapsweet Cenote",
        time            = "16:00-18:00",
        weather         = "Fog",
        previousWeather = "Rain",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 35.0, y = 32.7, radius = 1000,
        worldX = 653.68, worldY = -179.30, worldZ = 652.96,
        fishX = 663.30, fishY = -181.52, fishZ = 654.16,
    },
    {
        name            = "Awaksbane Apoda",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Yak Awak Tsoly",
        time            = "0:00-24:00",
        weather         = "Clouds, Fog",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 19.1, y = 8.8, radius = 800,
        worldX = -54.94, worldY = 7.92, worldZ = -545.20,
        fishX = -52.66, fishY = 8.06, fishZ = -558.52,
    },
    {
        name            = "Azure Diver",
        expansion       = "Dawntrail",
        zone            = "Shaaloani",
        zoneId          = 1190,
        aetheryte       = "Hhusatahwi",
        spotName        = "Eastbound Zorgor",
        time            = "18:00-24:00",
        weather         = "Gales",
        previousWeather = "Clear Skies, Fair Skies",
        bait            = "Dragonfly",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 33.1, y = 38.2, radius = 1000,
        worldX = 483.57, worldY = 16.83, worldZ = 648.66,
        fishX = 491.44, fishY = 13.32, fishZ = 663.55,
    },
    {
        name            = "Bitterbark Caiman",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Mamook",
        spotName        = "Bitterbark Cenote",
        time            = "16:00-18:00",
        weather         = "Clear Skies",
        previousWeather = "Fog",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 25.5, y = 39.0, radius = 800,
        worldX = 200.18, worldY = -149.74, worldZ = 823.89,
        fishX = 209.39, fishY = -151.05, fishZ = 842.45,
    },
    {
        name            = "Cabinkeep Permit",
        expansion       = "Dawntrail",
        zone            = "Tuliyollal",
        zoneId          = 1185,
        aetheryte       = "The For'ard Cabins",
        spotName        = "The For'ard Cabins",
        time            = "5:00-7:00",
        weather         = "",
        previousWeather = "",
        bait            = "Ghost Nipper",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 10.7, y = 15.3, radius = 1000,
        worldX = -157.30, worldY = -15.00, worldZ = 371.47,
        fishX = -152.05, fishY = -15.00, fishZ = 372.92,
    },
    {
        name            = "Cazuela Crab",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Ok'hanu",
        spotName        = "Waters Hanu",
        time            = "16:00-20:00",
        weather         = "Clouds, Fog",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1dbU/juhL+K8i60vmSoLw36Te27O5BFxZEi1ZXq5Wuk0xaX9I4x3HYZRH//cp5aZs0gQJdaFl/K2PH8Yxn5hlnPOYOHeWcjnDGs1E0RcM79DHBfgxHcYyGnOWgoGOa8BFOAojPKA1mNfkSApzxo4TMMSc0KXvUjZOcJSMaxxDw8yhCwwjHGShoNMvna09Ubc1HvhI+o3kxfKufmOspSUDM9WSaUAaNaZXTD+s/T0I0NFxPQZ/TyYxBNqNxiIZaL1cXjFBG+C0a6go6yT7+DOI8hHBJLrutjHbk0xuo6SOahEQwNwYuJjgv3jVFw2/Fb11BQfGboyEac8zz7Cjg5AZGx0hBqXjiX/w2BdF6m3GYH1YSITTJDj9DAowEh8ekIGB2+1/j27eq45gzkkyVg+rPC0ZuMIfDEWVwSvzvSt3v3P8fBLy33/e+FqQgEmZo+E13NfO7gkhyUzJ9r6CK/XulZGxC5vCVJCH9sWQr45hxNPQcTUGQhGioG5q28uh3BeHlT0DDJI/j+/tyuasVukPFD2OppeFCK4p1dtzWOuvaRiu9haUupqt0T8sbPEf9tN+gf1qpfw8KW9hoQ8JLQ7J0zWpL2H6BLVVCegIz+joz+29M3WagbMrkpmb5Od0LwdzgGA3NzZ1DNfc+p2Dpmv4M8zO25hLEHMcJnk5JMn1gktozJmludZIjykIihH+HTpIbYDVhzV5L1F16+UVDh8vQDcfZHH3Pb4AFOH2JF1uVj7UFt7MioE8km328hWwt8miz31xZu8W+vZHLdLY79zN8DeMZifgHTAqZCkJWE8YcB9cZGto9COa461xswIO3Lbf/VAy7wJxAEhQx4iVE4i0fMYtvhc4WI/QsldNm0tkI3Yw345ORXzDCvIyO+pauzZWxWVRkvhVXkxmOCb7OPuEbysQYDUKtq6bSpF9CQG+AVSFJnyza8ctGknDeShIfyPQzFip7h46SaQwsq7k3ulk0B5q1ttybsOhu2d3kMSczSq97Ec/Q7OfsyrYQFVfTXNmldEbyPznDjS3xAtcuIQM+onnCgV0w8cf4B04X7H2iLIDCqxbU8pmCGApqwb3p2q5SbL3PA8BJgSwtKTUaj+J4zGmadbeOU1oMq7XogsUu+svwdcLIdApMBJ3fFXSVkH/y4i3IDV0XsG2qthMGqgV2pPpg+qrtOI7va1YAuoHuFXRKMn4eCVmIMdbEKxrELAuYXQrrNGdwBlmGpyJwRQr6UlgGuoTw4AxPp5RnqHx4UsS2IoD8Qtkcx39XengJ/+SEQViG0QWfNVB8BVx0EV0z4O21KP+uGleXtSKVb7T0gaegqwwK7U/LB0RT9qFAHrYY7yqD5dREj3aHZusZSdBQO9TW6PhnRb/K4IJBQDJCk74x1zosh11vaoxMfwCL8t7JtttXxm23rA475hDHmPWN2mpeDtpuWIy5mVrv/36xe5fXZ661nF5m9E3FW/eYHTrU2amlEF19Wuvb6Z1rux1zRsttVdtyV78GPm64mikNVxquNNxXM9xTmEISYnYrbfdPAN0/CpyuMjimeYU7C9GeQvkBKQtw2tVekvoC0V44q55u4JkhPrnJOPQ9mUSpfTum6KXKPiMGk0q743681IG9U8XnRRVSG3dcG9+xC73KYMLqb0XdsUJHe0naTqwwsA25+ZWq/vtVvVTabUULUm13yUPvXbxQKuMW4wWpj7ukj+84YhCCojlf4XyWz9eIVxmM8ozTeZnoaEQPxQnanJUHWcSPlZR6mXw94hzmKV/GIzmDCWZTMQ2j85yPObC9tbOBr5TQfXJqvZJW1wqsCLNT+icJzwtiX1LRFodQH0srPsm1yLTiLnmWvUO6F6TKurVR5sqkNr5R/kcq5K5/qtk79yiTNfLQ0B6rr0zBvNfza3uqijIFI7VxF7RRJlbkceC9dqcyXfJ+z6bvqTLKdInUxx3RxzdOgvRUGL5lFqQpmefkNkSF2VHEgS0L3FY8Hk3FkRSSTMcc0uImhvEPMvcx4aWvEnIUnrMiLgXd+aqq1yKd8qSnv1BOotvzZJwHAWTFCq5VbAUzOpphvqgYW9xAg/kEfooSIKSgY5KlMb4VNZYTirPlaxeUtb4FtZgACYprbBZX3jS7f4pxNpvg7NrH7CQQ3aqhP4hSITH+J8pgymgubkOp2wDSFbYKarUwXQu6UntnYV03PdBV3zZBtQLLUf3ICVRNM10zGrjY0V0k0mBl8V2lht8WhLLgbr0Yr1GIZ5mW3l+IN8K/cojxwYhhv1GJpz+iWychJJwEOBY22VswanvtwlZzo0L6bVS2PjnDOM5ZhAMYx+KrdS9D9vMKs+3t1erKm3VeKeU8TjEDAXxYmPtdb/G2/YQbjIRtnoQTOppBcC1Kqj3LcwaGUKuVi0y0t9D/Paj/LvwTLfNKpX9TH3BuX2gCDadmFiiGU0Hp8GllXXg9PlLFSHADrHljyDqqaoa4tKS4XOSlNTH9GFnl194DRFZFsOsI+XD5b1EFj/PprFy2ZQVwcfuQLsptK7zboMK2VoPOYPYHTktdeATANc/UbFuz1QAPHNVyPVt13YGvhjrYLrihqwUmElc5PQTQpuNp/Tr8gab0r/xgHAOkwCREd0P0ynVnb4rQT/e58pa8l+DBayB0aZ97Cc66BGf99yPzG+xe65KS19++bgU3TeyDbxmRaoKNVcvUNdUD8FXf1nVLd3Bku34TN+trelrAafUD50WMOQeWzSCO3xls1s5P7lflTbCvvF+tPxtvFQzr7xoS4p63/5QQt4MQ55m+5gRYDf3AVq1IB9V1vED1TD2IwsixfT3aAOI87QGI+w+9Pvg7vz24iCGgEuPkN9n9u+389fZxErl28MupRK7dQy7DD30XooHqeH6oWrYRqa6lW6qp4YGuYW9gDgaPIpdtaOKG5d7NGeXwV36NJWhJ0JKgJUFrr9J9ErR2D7TAN8FxNazahu+qlmd5qqcbrjrAmoH9MLT8wNnki6L4r1N9+vVv+gvPsYCtg/E1Sd9fOk5+V/wj/sOU3HP90adVJHztHnzpPjZCA3RVDwagWj7YqoudSDUiI7QsLTCwoxcnQU+yzzH1xXmXhhZ0n+ZceYGjGbo18LGKbdtQLd0aqP7ACFXD13CE3YER+Sa6/z+PNh/wWXIAAA==",
        x = 22.9, y = 12.9, radius = 1200,
        worldX = 72.31, worldY = 0.47, worldZ = -428.35,
        fishX = 63.18, fishY = -0.40, fishZ = -428.09,
    },
    {
        name            = "Crenicichla Miyaka",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Ok'Hanu",
        spotName        = "The Dewspun Bank",
        time            = "6:00-8:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 37.9, y = 33.3, radius = 600,
        worldX = 793.78, worldY = 114.62, worldZ = 558.97,
        fishX = 802.58, fishY = 114.62, fishZ = 566.75,
    },
    {
        name            = "Datnioides Aeroplanos",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Aero",
        spotName        = "Leynode Aero",
        time            = "2:00-4:00",
        weather         = "Rain",
        previousWeather = "Fog",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1daW/jvBH+KynRj9JC92GgBbLO0aA5FrGD/RAEKCWNbDay6JeinE2D/PeCOmzJlhLHcTZ2Vt/i4SFy+Ayf4TV5Qocpp32c8KQfjlDvCR3H2IvgMIpQj7MUJHREY97HsQ/RBaX+uBRfg48TfhiTCeaExnmOMnGYsrhPowh8fhWGqBfiKAEJ9cfpZKVEkVYv8pPwMU2z6pfyibaekxhEW89GMWVQa1be/KD8eRagnua4EjqdDscMkjGNAtRTWnv1gxHKCH9EPVVCZ8nxLz9KAwgW4jxbpbZDj86glPdpHBDRuQFw0cBJVs8I9W6zvxUJ+ah3eychnJd4vpMQoF6cRtHzc963ojlPKPtDWwxJMFdB1inLWeqUqqzVrS30K2uu1Nws195E18qWlK28UdkCkDUNL1BjqIqxmYab+1Io6X3IeUIc9dCAY54mhz4nM+gfIQlNRYm/88cpiNTHhMPkW2FLhMbJt1OIgRH/2xHJBJg9/ke7vS0yDjgj8Ug6KH7+YGSGOXzrUwbnxLuTynxX3n/B56357tpSkIRIkKDereoo+t1zNgbZcEh5b06niz7McIR6hlAznaIe+ieqZK8MpLSuTioflhCJZ2X5l9qww3rM1KMrSrNWGuCdt71tDjFURd3AWrWtzSCijYMYj0YkHr3QSGWDRupbbWSfsoAI5T+hs3gGrBSsmHfOSEMygZ8kDujDPKFhhlE1y1qfma5mwHw8fc+kV9WPsa1Z6q1T7glJxsePkKzw97Ki6hgwlxRlmuugwPqsXl7gexiMSci/Y5LVIQRJKRhw7N8nqGe2kKjlrPZ3jd66n9XbH5gTiP3MJ7uGUHzlGLPoUdhBVkPLoFrLnbTWIljt0/rJyP+gj3nuoLUN3XKvtPXcBv2zejUc44jg++QEzygTddQEJVZ1qS6/Bp/OgKGeKiyxye22nBUPai1FfKTR5nQv3AQa9ymNAvoQV92F+aycOwHqK47IqjK/k9EpFqh/QofxKAKWlArUms1AtxVjBTHrqMnZgpoqFHeRRpyMKb1vJWJNMTdZSG3Bty+auaDV5vXIL85wbRU7x+M1JMD7NI05sB9M/Bg84Om8eyeU+ZBNzJk0L5MJAyHNeq87piNlq+UrH3Cc0diSlmqJh1E04HSaNKcOpjSrVlmSiy42yd9H+0NGRiNgwhdeUc1b7KYyAHObSThmXJiNIiGIBXiN1/1TCQlN5yMxV1D+c0jzQUAyynPlDFrkET/KHE8ZLGVVQucpgwtIEjwSjjuS0GVmguiSxoCKQpk96+LLnE7zCSDr3TUkNJpB4SoL1SRLrltDjgwbl3SeZSCUIMYpc2RLzAWpD0JYqWlCZ5AvVapleZoMaZ5Ytgmy6vo4HY1L4M5LXFJOwsereJD6PiSZJ7UMxWN/TPtjzOdame/AYD6EX2IwkYSOSDKN8KOYsIYUJws1zyUreTNp1gDiZ9s4iw2cev6TCCfjIU7uPczO/Eq+72KZJD5wQhmMGE0FaMo0gGmlX5n0WSzSfgNoX1wg5jaYxnxprVoSxD+yVa6YJmzHWi3+6up0byxG/RCLmZfrTGbHTUYzS5NZZx9iV1Crdajdh4n+TkI3MfkrzVwg5IGhq6FnySHWQtnARiB7nmPKjq4Z4Kp+YBqu8MvPScKvQjH4jQ6OSMhZOAdS4cm1YekagoMLPBpRntQgJcB+SdkER/8qnORr+CslDIKSzxUJlQvhn4CzLCJrAnyFnbPfRWLV5yxE+RcN1XYldJNA5ppP8wIiKfmerawXDsFNAoumiRzLGeqpF0S4Pt+UFTn+VchvEvjBwCcJoXFbnSsZFtWuJtVqpg/AwrS1scvplXqXU6rVDjhEEWZttS4lLypdTpjX+ZYZc5+35Jsdn7YJvdTT+1YkdeCtLucaMNSYaQkQTXmWxrdx6Vja7YAzmm9FL1tu9XTxdcNV9M5wO8PdB8PNbWRHzfEcRhAHmD12FvknUOkXQO5NAkc0LThirrDzfDfnOPHxtCk9F7U5ja3UU5SucY8mNq87n7ED+gcDPYfsBv5SB9odn51zDOwdFDfzFTo07jgav7avMGTlvk6zr9CQnou24yvYptYtVDuofzzUc9Buy1voYLtLM/Te+Qs5GLfoL3R43CU8fmGPQSiKprzS83E6WRHeJNBPE04n+aFEzXvIXs+kLL9+K/6oXO/Lb3Edcg6TKS9tQOQZYjYSrVAb7/nptumuvpT4PRfDNjmUecuti4XOm4asov3G4TqLeZoJ204MTfGI57UzwzfNRd2Z4S5NRXtHje84B2tGY3cQ1qHxk46BOkDu+t7O3k2P3elOdyNoj+Hbndl81ctpewrF7symQ+MuoLE7ienu+u71dNqdr3zdi+d7CsbufKXD4x94alLe4qgcm7TEv/jMc5O6ZjY528he14Uc2OJpfWXGo9PiaeeAwzQ7OBo8kImHCc/nKqFHMXMWwoWiGz9V5Jofp7yp9I49li7i433UE7pc+U0DWntYp9uO4buyqTqebASuJ7vY9OXQN8JA8W3NCGwkjsHyl3UFDG/ngvw13epLu9orO9cRYU/qr+wOD0Jg1Cc0TQ5CyiYHAWY8OSAxpwczAg9/WzzDO8I8JpQEkBwcAqPTCMe0/iBPfQWFZwHEnPg4EtbbGtTCdJeDb+hrRRZyPiNayyBlIfZhEOXPYls6ZG4Wf8bcXjyRLobhb4phOJhiBoIisZgYnloDzJhviGQorPgsGNL+GPx7EfbFNVzL1gSsKjHglM/A/x7EqNnGw/XiMXzDnNbwdP4SZsDqIdRW+VfRRLy3LNrae99ttrNpcRL3Fci0eFK3yqUvXzhZCtmyGiuElMy4ZuQEAYNGt3ceVeEVqncD3XNUO5QN3wtlQzcC2YUglB1X0T07sB3NAlSLFlGGRKq9mLcd+wUQAz04ZPQBx7gj6B0n6LdPuV044vfQwe8g6Nw695Kb1Y6b1Y8n5i8YE6x9nbsV2vSxrzha4Mq6YaqyAa4tO26gyaGlOF6g+aqn2HXabFgBi1Bg7ay5WOB+MdIsZ74WKqxEWO+YsAvM/0mL2tw2t8yZ5e5Hx4SbrVI7Jtw9JrRCD9uhbsgYgy4b4Kmy5xuh7Aa2avquBYpvrbWAVF4IuUYT8NLg4ITR0Z9FhjuzLuw2brex+fcbmKs8P+2Ia4e2Vzvi2j3isrHmQqiaMlY8RTYs8GTP0XU51LGr6IapBZa6FnG9gK9/x2Q05gen1HvseKvjrf37p2kdb/3Rx4Idb+0eb1kKmKarhnIIiiEbpqvIruXqsootO/BsRbEtM7ucc5acRtQTB4s1FLxyf6b6Jc+0PUt1ZdPHqmwYpiK7AWBZMxxTcU0vDEIHPf8fxWJ7WSJ0AAA=",
        x = 16.2, y = 13.2, radius = 600,
        worldX = -182.92, worldY = 31.82, worldZ = -376.60,
        fishX = -190.89, fishY = 31.20, fishZ = -383.58,
    },
    {
        name            = "Deep Canopy",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Iq Br'aax Reservoir",
        time            = "10:00-12:00",
        weather         = "",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 13.7, y = 12.7, radius = 500,
        worldX = -438.47, worldY = 18.05, worldZ = -391.69,
    },
    {
        name            = "Esperance Carp",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Pyro",
        spotName        = "Proto Alexandria",
        time            = "22:00-24:00",
        weather         = "Clouds",
        previousWeather = "Rain",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 38.5, y = 31.6, radius = 500,
        worldX = 814.81, worldY = 8.57, worldZ = 487.09,
        fishX = 822.63, fishY = 7.68, fishZ = 495.99,
    },
    {
        name            = "Excavator Catfish",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Many Fires",
        spotName        = "Marsh Ligaka",
        time            = "4:00-6:00",
        weather         = "Clouds",
        previousWeather = "Rain",
        bait            = "Popper Lure",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 25.8, y = 31.6, radius = 800,
        worldX = 150.32, worldY = 115.40, worldZ = 528.67,
        fishX = 169.07, fishY = 109.77, fishZ = 525.83,
    },
    {
        name            = "Gigagiant Snakehead",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Aero",
        spotName        = "Mu Springs Eternal",
        time            = "4:00-6:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 12.6, y = 11.5, radius = 300,
        worldX = -433.48, worldY = -5.00, worldZ = -524.62,
        fishX = -436.41, fishY = -5.27, fishZ = -514.38,
    },
    {
        name            = "Gondola Louvar",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Mnemo",
        spotName        = "Canal Town South",
        time            = "8:00-12:00",
        weather         = "Fair Skies",
        previousWeather = "Rain",
        bait            = "Ghost Nipper",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 14.3, y = 34.8, radius = 1050,
        worldX = -354.26, worldY = 0.05, worldZ = 540.32,
        fishX = -368.37, fishY = 0.04, fishZ = 550.58,
    },
    {
        name            = "Harlequin Queen",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Aero",
        spotName        = "The Knowable",
        time            = "16:00-18:00",
        weather         = "Fair Skies",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 7.2, y = 14.3, radius = 400,
        worldX = -728.20, worldY = -6.18, worldZ = -344.54,
        fishX = -718.79, fishY = -6.18, fishZ = -334.48,
    },
    {
        name            = "Heirloom Goldgrouper",
        expansion       = "Dawntrail",
        zone            = "Heritage Found",
        zoneId          = 1191,
        aetheryte       = "Electrope Strike",
        spotName        = "Alexandrian Ruins",
        time            = "12:00-16:00",
        weather         = "Fair Skies",
        previousWeather = "Fog",
        bait            = "Popper Lure",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 6.8, y = 34.0, radius = 1000,
        worldX = -674.07, worldY = -14.00, worldZ = 611.24,
        fishX = -678.18, fishY = -14.00, fishZ = 623.29,
    },
    {
        name            = "Hwittayoanaan Cichlid",
        expansion       = "Dawntrail",
        zone            = "Shaaloani",
        zoneId          = 1190,
        aetheryte       = "Mehwahhetsoan",
        spotName        = "Niikwerepi",
        time            = "4:00-8:00",
        weather         = "Clear Skies, Fair Skies",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "",
        x = 29.8, y = 7.4, radius = 600,
        worldX = 420.92, worldY = -17.70, worldZ = -708.28,
    },
    {
        name            = "Icuvlo's Barter",
        expansion       = "Dawntrail",
        zone            = "Tuliyollal",
        zoneId          = 1185,
        aetheryte       = "The Resplendent Quarter",
        spotName        = "Downripple",
        time            = "0:00-24:00",
        weather         = "Fog",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 9.7, y = 10.5, radius = 300,
        worldX = -201.72, worldY = 40.09, worldZ = -5.67,
        fishX = -207.17, fishY = 39.59, fishZ = -13.90,
    },
    {
        name            = "Ilyon Asoh Cichlid",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Xd'aa Talat Tsoly",
        time            = "0:00-24:00",
        weather         = "Clear Skies",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 8.2, y = 11.9, radius = 600,
        worldX = -589.46, worldY = 1.47, worldZ = -399.71,
        fishX = -594.79, fishY = -0.17, fishZ = -411.32,
    },
    {
        name            = "Iron Oxydoras",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Many Fires",
        spotName        = "Miyakabek'zoma",
        time            = "13:00-15:00",
        weather         = "Fog",
        previousWeather = "Clouds",
        bait            = "Golden Stonefly Nymph",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 14.5, y = 28.6, radius = 2000,
        worldX = -185.08, worldY = 110.73, worldZ = 236.09,
        fishX = -173.81, fishY = 109.20, fishZ = 224.51,
    },
    {
        name            = "Iron Shadowtongue",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Iq Rrax Tsoly",
        time            = "16:00-18:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 31.8, y = 6.8, radius = 1800,
        worldX = 500.56, worldY = 3.64, worldZ = -531.60,
        fishX = 501.90, fishY = 0.07, fishZ = -543.01,
    },
    {
        name            = "Lotl-in-waiting",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Mamook",
        spotName        = "Xobr'it Tsoly",
        time            = "0:00-4:00",
        weather         = "Clouds",
        previousWeather = "Fair Skies",
        bait            = "Golden Stonefly Nymph",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 33.3, y = 16.6, radius = 800,
        worldX = 638.16, worldY = 11.20, worldZ = -255.69,
        fishX = 651.56, fishY = 10.17, fishZ = -259.10,
    },
    {
        name            = "Moongripper",
        expansion       = "Dawntrail",
        zone            = "Urqopacha",
        zoneId          = 1187,
        aetheryte       = "Worlar's Echo",
        spotName        = "Sunken Stars",
        time            = "12:00-14:00",
        weather         = "",
        previousWeather = "",
        bait            = "White Worm",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 20.4, y = 27.6, radius = 400,
        worldX = -57.21, worldY = 7.75, worldZ = 304.67,
    },
    {
        name            = "Moonmarking Saucer",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Mamook",
        spotName        = "Cenote Jayunja",
        time            = "16:00-21:00",
        weather         = "Rain",
        previousWeather = "Clear Skies",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset = "AH6_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",
        x = 19.7, y = 32.0, radius = 1800,
        worldX = -111.17, worldY = -215.02, worldZ = 516.58,
        fishX = -113.27, fishY = -215.02, fishZ = 518.04,
    },
    {
        name            = "Moxutural Greatgar",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Cenote Moxutural",
        time            = "20:00-22:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Honeybee",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 21.7, y = 20.3, radius = 800,
        worldX = 37.80, worldY = -185.69, worldZ = -113.19,
        fishX = 31.04, fishY = -190.70, fishZ = -100.08,
    },
    {
        name            = "Muttering Matamata",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Earthenshire",
        spotName        = "Bopo'uihih",
        time            = "12:00-14:00",
        weather         = "Clear Skies",
        previousWeather = "",
        bait            = "Golden Stonefly Nymph",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 10.6, y = 12.4, radius = 1500,
        worldX = -543.71, worldY = 1.10, worldZ = -490.80,
        fishX = -524.67, fishY = -0.40, fishZ = -488.98,
    },
    {
        name            = "Ole Ole Ole",
        expansion       = "Dawntrail",
        zone            = "Urqopacha",
        zoneId          = 1187,
        aetheryte       = "Worlar's Echo",
        spotName        = "Chirwagur Lake",
        time            = "0:00-2:00",
        weather         = "Snow",
        previousWeather = "Clouds",
        bait            = "White Worm",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 20.0, y = 37.0, radius = 600,
        worldX = -75.05, worldY = 0.06, worldZ = 773.93,
        fishX = -78.47, fishY = -3.54, fishZ = 762.22,
    },
    {
        name            = "Pixel Loach",
        expansion       = "Dawntrail",
        zone            = "Solution Nine",
        zoneId          = 1186,
        aetheryte       = "Residential Sector",
        spotName        = "Residential Sector",
        time            = "0:00-4:00",
        weather         = "",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 6.5, y = 18.7, radius = 1800,
        worldX = -347.14, worldY = 14.03, worldZ = 154.19,
        fishX = -342.89, fishY = 13.73, fishZ = 161.06,
    },
    {
        name            = "Prime Adjudicator",
        expansion       = "Dawntrail",
        zone            = "Urqopacha",
        zoneId          = 1187,
        aetheryte       = "Wachunpelo",
        spotName        = "Karvarhur the First",
        time            = "12:00-16:00",
        weather         = "Fog",
        previousWeather = "Fair Skies",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 6.3, y = 20.3, radius = 1000,
        worldX = -674.72, worldY = 49.89, worldZ = 56.95,
        fishX = -683.81, fishY = 48.19, fishZ = 46.45,
    },
    {
        name            = "Punutiy Pain",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Ok'Hanu",
        spotName        = "Peaks Poga",
        time            = "8:00-12:00",
        weather         = "Rain",
        previousWeather = "Clouds",
        bait            = "Golden Stonefly Nymph",
        swimBait        = true,
        autoHookPreset  = "AH6_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",        
        x = 40.0, y = 15.1, radius = 600,
        worldX = 925.54, worldY = 5.93, worldZ = -318.99,
        fishX = 931.25, fishY = 6.06, fishZ = -319.51,
    },
    {
        name            = "Purse of Riches",
        expansion       = "Dawntrail",
        zone            = "Tuliyollal",
        zoneId          = 1185,
        aetheryte       = "Bayside Bevy Marketplace",
        spotName        = "High Tide Harbor",
        time            = "16:00-18:00",
        weather         = "Rain",
        previousWeather = "Clouds",
        bait            = "Ghost Nipper",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 16.9, y = 15.2, radius = 1800,
        worldX = 145.86, worldY = -17.96, worldZ = 155.21,
        fishX = 160.38, fishY = -17.96, fishZ = 171.30,
    },
    {
        name            = "Riverlong Candiru",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Dock Poga",
        spotName        = "Miyakabek'zu",
        time            = "0:00-4:00",
        weather         = "Clouds",
        previousWeather = "Fair Skies",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1cW0/rOhb+K1vWSPOSoDS3ptW8QLkMGtggWrQfENK4yUrqIY1zbKdsDuK/H9lJek04pYQ9lJ23dvmStexvXZLl5Wd0mAk6wFzwQRih/jM6SfA4hsM4Rn3BMtDQMU3EACc+xJeU+pOSfAM+5uIwIVMsCE3yHmXjKGPJgMYx+OIqDEvqYJJNtxrwg4gJzdTkZbcQx1xOgbm4IAlITs+jhDJYYSpnPij/ngeob3o9DZ2lowkDPqFxgPpGrUzXjFBGxBPqdzR0zk9++nEWQLAg592WZjsc0xnM5aNJQKRsQxCSwal6VoT6d+VvH/Xv7jWE8xEv9xoC1E+yOH55yWUr2HlG6oe52JBgvgRKKNdbE6pjbCVWA3IpdrVqtnrdXdbaaIwpuYQSZSvrtsCC3THs3datmsNC9DfgobOJh2ckUB8NBRYZP/QFmcHgGGkolSP+IZ5SkK1PXMD0oNAQQhN+cAYJMOIfHBNFwOzpv+bdXdFxKBhJIu1b8feakRkWcDCgDC7I+F4r+12N/we+qO13X9eCNEQCjvp3Hc+w7l8UjEtEl+DWthVyaSYNkWRWjp9PquWjz9K9WJgZjlHfMYzqVdlU+YL3OlW3O0ZnB6UyG9WpYYKjiCTRK0waOzBpNav4lAVELv4zOk9mwErChr7mjmNEpvCDJAF9nDdUmIyO6brbO5CrGTAfp+9xBMvrYzdgdpYW6JTwyckT8A3nuS7+6s46a+I7zjZ76zbL+yV+gOGEhOIIE7WmksBLwlBg/4GjvlPjl1xvU4otZOg1K8M1FgQSXwUvNxDKsSeYxU8SiQoVNRvgrrPubuWzzIa5Z+RPGGCRxyd1y7zOq7mdf7Wa5XU0wTHBD/wUzyiT7K4QSrRY2ir9Bnw6A4b6HYnwqljS9TYCiK3Ea1gZjkh0hiVmntFhEsXAeCmSWQ0iq2vYGzuzDeNew1qcxYJMKH2odSSm4ewSrzcXQi7cQnXY+1MwvPKqNEfIDXAQA5olAtg1k3+Gjzidi3dKmQ/KWClqPkYRA0lV0lue42nqlezKB5wog722SiuNh3E8FDTl1a3DlKppjTW6FLGKvimwhkaMRBEwGaHda+g2IX9kaiwyxl6IzW6oh2YPdNvtBfrYMUPdcxxjbBqh07E89KKhC8LFVSgllHNsLJpskM9WPmmxBBcZg0vgHEcyykMa+q7wjm4g+HaJo4gKjvLBIxUIymjrO2VTHP+7QNcN/JERBkEecyphS/v7A7DqIrtyEGsc5X+LtuW9Kkj5A+1Ot6ehWw4K0mk+QDbxI2XP2XxLbjksOJM91justl6SBPWNA2ODjn8W9FsO1wx8wglN6ubc6LCYdrNpZWb6CCzMapldb1+ad71ledqhgDjGrG7WtebFpOsN8zm3C7H2/92q+o2oLnQs16lKk1fhVNVjAxmVnda2uarP2q5VGtJSGYeC0fzF4n3qaFitOrbq2KrjO9XxAiJIAsyeWo38HRzkF3AktxyOaVb4iPmCXUD+uYP7OK1qz0lvjgSL0Su+x5QfiNpIsAX6BwM9h+wO8VIL2k9unXMM7B0Ud4sVWjR+cjR+7VhhxMqvNdWxQkV7TmomVug6Zvui2kL946Geg7apaKGF7Wey0HsXL+RgbDBeaPH4mfD4hSMGuVA0E0uST7LpBvGWwyDjgk7zVMNK9KCOLGYsP3Yhfyyln/Oc5qEQME3FIh7JGIwwiyQbNacCrK7T2zzK9msSpW8+2FgsV9UWLK1m5fKfJyJTxLq0niNPQu6c2KuyLW1m7zOZlr1zde/Ia1WjsU1stWh8NxqbC71aQLbmsc3WtOd2fk/v3uZgvuoRsj2FYpuDadH4GdDYZlbaE7l7bU7bfMnXPR6+p2Bs8yUtHj8JHtssyCvlYjvmNmTl1mEogC0Kx5YsHk3lmRSSREMBqbo4YPhIpmNMRG6r5Ic8aTkL4iLdVPmootc8nfKm0d+pIOHTVTLMfB+4ymOt56RO/AkdTLCY12yV802wGMFPWYWDNHRMeBrjJ1m7OKKYLx47p2z0VVTFAPHVvSHzG0NWu5/GmE9GmD+MMTv3Zbdi6iNZrSPnP6UMIkazZMH1EUC6JJaiFhtTtaFL1W+u77geeF3d95yObodWoGPb6+m259q2Y3fB9jCSabC8/K1Ixt3NCXnJ22Y53EopXLfXM14phSMzYDFNom8DnASEZSsFcZ2/Adh5AIkgPo5lerK2GtPprVeNWlsVfzdRNvrmNOMwYyH2YRjLT9e1Ajm7FSg7/w+J2ttgflGGephiBtJPYmkdnmtrqJ033B4jVfk8GNHBBPyHuTYv3dBhfCCkisLHwrwr1d+fy1MsDdEU9dG/VClksXTbXKeyB+XlykLTPL2Wm3m9U2/jv9MEVsy6pZw5TiWlwqrnZefl/EiXM8EM2Oo9H5vBhWHKq0bUlSDvO9nzWqhQpBm/dqTwukKqKnucRZM9Usm5Bhba2dmiDrmEaOX7xiNOc5z+TYyFvbGL7cDWXROHuu33DH1sW6buBw7YYTcIw56N5OVQr8VQlivvf6vTr//QP/EU/zN7wN+GDyRNgX2xIKrcj5rQaOlqtG0jo7mlaUOjfbwo71OGRrmS/qLQqI0emo4ePj50+J2+MjTiO42xhztd39Gh0wXdtqyx7oVGTzcs27I7YPh+iLfwndIn1PnOr/nVoXWY7c2ylYD4JW5Q6lv7hWCHLwRy6dovBB/4haD18Z/Ox4du13VxONa7Pd/Sbcu3dQww1s3QC23TdI1eGKgcxDk/i+lY6s0KCF7JIyw9xTdCHHgm1sH3DN3u9br62DM8ves4pjnuhoHhG+jlLwll1v5IXgAA",
        x = 29.2, y = 12.0, radius = 600,
        worldX = 366.41, worldY = 1.77, worldZ = -498.61,
        fishX = 367.97, fishY = -0.34, fishZ = -489.50,
    },    
    {
        name            = "Shin Snuffler",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Iq Br'aax",
        spotName        = "Ankledeep",
        time            = "0:00-2:00",
        weather         = "Fog",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 8.0, y = 27.2, radius = 400,
        worldX = -669.03, worldY = -185.73, worldZ = 289.21,
    },
    {
        name            = "Shined Copper Shark",
        expansion       = "Dawntrail",
        zone            = "Living Memory",
        zoneId          = 1192,
        aetheryte       = "Leynode Mnemo",
        spotName        = "Canal Town North",
        time            = "8:00-13:00",
        weather         = "Fog",
        previousWeather = "Clouds",
        bait            = "Ghost Nipper",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 9.5, y = 28.1, radius = 1050,
        worldX = -643.74, worldY = 1.10, worldZ = 335.84,
        fishX = -637.27, fishY = 1.10, fishZ = 328.49,
    },
    {
        name            = "Shuckfin Dace",
        expansion       = "Dawntrail",
        zone            = "Kozama'uka",
        zoneId          = 1188,
        aetheryte       = "Many Fires",
        spotName        = "Ku'uxage",
        time            = "4:00-6:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1cW3Obuhb+Kx3NeYQMGPDtLXUuO3PSJBOc6UOmM0eIha0djLwl4TY7k/9+RgJjg6FxErepE95gaSG0lr510fUBHaaSjbCQYhRN0PABHSc4iOEwjtFQ8hQMdMQSOcIJgfgLY2S6JF8DwUIeJnSGJWVJxrEsHKc8GbE4BiIvo2hJHU3T2cYHEY7FxhdfqZyyVNde4VNNPacJqKaeTRLGodSqrPXh8vUsRMNOf2Cg0/l4ykFMWRyiodUo1BWnjFN5j4a2gc7E8Q8SpyGEK3LGtlbbYcAWUAjIkpAq4XyQqoEz/a8JGt7qZ9tARD9LNES+xDIVh0TSBYyOkIHm6ov/yPs5qNJ7IWF2kGuEskQcnEICnJKDI6oJmN//r3N7mzP6ktNkYnzKX684XWAJByPG4ZwG34wl32XwNxDZyPetqQQZiIYCDW/tvuV8MxBNFpnQjwbKxX80MsHGdAZfaRKy73shlpCYSzTsuJaBIAnR0Olaa0J9MxBePQIaJmkcPz5mQMyx84D0Q2dlPmGBV43Abr+CQNvaCoM7AKFurlHfrEHvJYZh7axRSoXKJ5T0tjJc17bcSgPd7fRW38Jc9GcYr71mvNZ7Md56cBtNQvoSkzuxH0I2O6XT+V5IsMAxGjrW1g4ob3uT43Fty36BiXd2auF+gicTmkx+0kjrBY10duuGGA+pUv4DOksWwJeEDe+R5RyrGFcU1Dgwu9Ptbp97XC6AEzx/IofILbQeFev6cXfgBNcUdELF9PgexEbeVRW/3LNeRXzP26Zvu7tt+xd8B/6URvIzplqniiCWhMzBoaHXECW7/U0ptpBhsKsgtHXv59JeYUkhITpDvoZI/eUY8/heYVbX0NBV3aqQ3a1ibefN5OT0XxhhmWVgTV1XlaqzXQbh7BaB4ymOKb4TJ3jBuGpuibBEoGOU6ddA2AI4GtrKapokrOZIW8nXfate+0wnp1gB8QEdJpMYeJ5g6KhTJ6LTs9yNTtxGxP6OnUgaSzpl7K4xjnUs7yUjzd3l02sjr9oxwA/JcWmUX0SraxAgRyxNJPArrl7873heiHfCOAHtKzU1+0YTQ0XV0jt9r2/o2YRLAjjR8aKipVLhYRz7ks1Ffak/Z7paq0JXItbRXxc1x5xOJsBViryhmu1q3uehr9NdDn3d/tOZp4EUCDKQFH2XvY5Zhg9koowri7c5j3pZcjxoizFtA52nHL6AEHiilIQMdKG9A7pgCaD8I61AR/1ZsrkadLFE+4BrECxeQK5S1WuikpTVcGjYXrCCxVdKUBDSKWrxXZgSUNQ10owtIBsTrX8sUzFmWaFGwwWTNLq/TPyUEBA6X6rawTGZstEUy0Lu5dzWFMsx/FBIQgY6omIe43vlLccMi5UiC8oGr6bqBlCiJ9mK+bgy+0mMxXSMxV2A+RlRbMs+UphT9Z8wDhPOUoWKZRnAfE0sTX1UyLhJ6D+ptkrUiywM4HTNrhUQ0+1FoTmw3L5JnKgX9CJv0HMj9GigcyrkZaQ6t9bmVEGm/AwouXNpwso1hJ++4MmESVGCjALzBeMzHP+V++1r+CelHMJlN1oGWqZLXwFrFsUqQG70mX7PC9fdYE7K/ujavYGBbgToaDHPPlBF4rPOv3hR342AVdMUR5WhXPqFJmhoHVgbdPwjp98IuOJAqKAsaapzg2FV7WZRqWb2HXiUNja2Wr5Wb7VkvVpfQhxj3lRrpXhVabWgqPM5znqf53Dq5zqaHPZST5tZQRVOdRwbyKhlqnRzHU+l12pzlKU1+pKzbMqgao/r8/xPm6PltObYmmNrjq80x3OYQBJift9a5EcIkO8gkNwIOGJpHiMKhZ1DNpEpCJ7XlWekplSwMfTkX5diT0dN/baZYAv0Xwz0DLIvyJda0Lbe+W1B+7KsosVti9s3zCrGfDmvU59V1JRnpN1kFT2v0w5p2wT610M9A+2u8ooWtu247zfCdoeZRYvcFrm/B7l0BiyVa3M103S2QbwRMEqFZLNs+aKUZ+i98SnPNmmph7WNJdkWhEMpYTZfLSUqpjHmE9UMq3YPm9PzBtUdJvZv2tbw7A0mubbqemBNmbXaP0tkqolNS4We2sT91GLhs1xLu1j4J3mWDCYfY6msHo3tWlmLxlejcXeZVwvI1j22C0DtVqCPGd3bZZ33uittT6HYLta0aPwT0NguwbSbfPfanbYLK+93x/megrFdLmnx+Ifg8Q9aBCkdQn27VZCyZl6ytqGPzUUS+OqY55rHY/P89JsvYa7vPPG/01mAqcx8ldKj8pw5caXo2l/lXMVyyrO+/lhn5zLl13Xo2om6YODhyO5EpoWtwHRJt2P2XXtgEivshJYLQb8PSC2DZUfqchjeFoTsGN3mEbvS8bpBb9BtPl7nT1NyF9Hk0xEm5TOZ9hPgOgshkZTgWBll47lpT/28ZFrOVrdE7OKA97OXGP2UR5iAH2fHWBsE8l5264D3FhK1l1i9yi/7c8xBRT6s7P2h8Q4D7xlXgCnjPAvHbDQFcreKw8X9PNburjbYg2sNdnFwPD+MXuOjao6uX8ACePl6m80waXXUDTv6JpzXHar5WdDLF8zed8z7+TFdfbsDTifTrN/25KRuEVT1jV72lrcqKIjWZs7FjQtPZAs9O1J3foE56DpgukHkmQPLtkyC3ahjua4FQRepO9F+lg04PavXbF//xZ+u0vtp+s4SgWUvNIT3tVsJt43uhX9pw/s+3lH5/Mzw1ycCuWnuOBN4fsbY5gwvyxl+fcLwkUbJ/i4ipjcIrD6BwPQc3DNd4hBz4Lq2aXUCHAEOne6A6PH1mTiNWaCieSlxbBgjr/2BwICEAemaYEUd0+2GkRmEfdt0vU7fikIn8gIPPf4fOmDGIolbAAA=",
        x = 22.7, y = 21.1, radius = 800,
        worldX = 22.59, worldY = 25.12, worldZ = -35.49,
        fishX = 23.89, fishY = 24.74, fishZ = -24.26,
    },
    {
        name            = "Sprouting Perch",
        expansion       = "Dawntrail",
        zone            = "Heritage Found",
        zoneId          = 1191,
        aetheryte       = "The Outskirts",
        spotName        = "Outskirts Shallows",
        time            = "20:00-24:00",
        weather         = "Thunderstorms",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 19.8, y = 8.9, radius = 1400,
        worldX = -144.75, worldY = 22.30, worldZ = -770.15,
    },
    {
        name            = "Stardust Sleeper",
        expansion       = "Dawntrail",
        zone            = "Yak T'el",
        zoneId          = 1189,
        aetheryte       = "Mamook",
        spotName        = "Xty'iinbek Tsoly",
        time            = "20:00-24:00",
        weather         = "",
        previousWeather = "",
        bait            = "Crimson Lugworm",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 36.9, y = 25.9, radius = 800,
        worldX = 769.11, worldY = -81.86, worldZ = 200.56,
        fishX = 780.83, fishY = -84.30, fishZ = 197.59,
    },
    {
        name            = "Thunderous Flounder",
        expansion       = "Dawntrail",
        zone            = "Heritage Found",
        zoneId          = 1191,
        aetheryte       = "Electrope Strike",
        spotName        = "Crackling Canyons",
        time            = "0:00-24:00",
        weather         = "Rain",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 21.5, y = 32.3, radius = 1800,
        worldX = -12.44, worldY = 49.44, worldZ = 541.99,
        fishX = -9.01, fishY = 49.09, fishZ = 531.90,
    },
    {
        name            = "Thunderswift Trout",
        expansion       = "Dawntrail",
        zone            = "Heritage Found",
        zoneId          = 1191,
        aetheryte       = "Electrope Strike",
        spotName        = "The Driftdowns",
        time            = "9:00-11:00",
        weather         = "",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 13.1, y = 17.4, radius = 1500,
        worldX = -468.89, worldY = 37.00, worldZ = -148.98,
        fishX = -472.96, fishY = 37.90, fishZ = -138.44,
    },
    {
        name            = "Ttokatoa",
        expansion       = "Dawntrail",
        zone            = "Shaaloani",
        zoneId          = 1190,
        aetheryte       = "Mehwahhetsoan",
        spotName        = "Lake Toari",
        time            = "20:00-24:00",
        weather         = "Dust Storms",
        previousWeather = "Fair Skies",
        bait            = "Popper Lure",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 31.5, y = 13.8, radius = 1000,
        worldX = 363.59, worldY = -17.35, worldZ = -430.24,
        fishX = 374.19, fishY = -18.16, fishZ = -430.24,
    },
    {
        name            = "Vagrant Keeper",
        expansion       = "Dawntrail",
        zone            = "Shaaloani",
        zoneId          = 1190,
        aetheryte       = "Hhusatahwi",
        spotName        = "Westbound Zorgor",
        time            = "6:00-8:00",
        weather         = "Clouds",
        previousWeather = "Gales",
        bait            = "Dragonfly",
        swimBait        = true,
        autoHookPreset  = "AH6_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",
        x = 16.1, y = 38.2, radius = 1000,
        worldX = -164.92, worldY = -27.46, worldZ = 643.97,
        fishX = -168.57, fishY = -31.44, fishZ = 655.41,
    },
    {
        name            = "Sidereal Whale",
        expansion       = "Endwalker",
        zone            = "Ultima Thule",
        zoneId          = 960,
        aetheryte       = "Abode of the Ea",
        spotName        = "Limne 3-β",
        time            = "0:00-8:00",
        weather         = "Astromagnetic Storms",
        previousWeather = "Umbral Wind",
        bait            = "Stardust",
        swimBait        = false,
        autoHookPreset  = "",
        x = 25.1, y = 17.2, radius = 600,
        worldX = 184.35, worldY = 233.86, worldZ = -253.70,
        fishX = 186.21, fishY = 233.07, fishZ = -268.13,
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

--- List-type configs (DisabledFish, EnabledFish) come back from Config.Get()
--- as a .NET-backed collection, not a plain Lua table - it exposes .Count
--- and is indexed like a C# list (see Tokens.lua's JobsConfig for the same
--- pattern), so a plain ipairs()/type()=="table" check silently finds
--- nothing and leaves the set empty.
function ConfigListAt(list, index)
    if not list then return nil end
    if list[0] ~= nil then
        return list[index]
    end
    return list[index + 1]
end

function BuildFishNameSet(configKey)
    local set = {}
    local config = Config.Get(configKey)

    if config and config.Count then
        for i = 0, config.Count - 1 do
            local fishName = ConfigListAt(config, i)
            if fishName and fishName ~= "" then
                set[fishName] = true
            end
        end
    elseif type(config) == "table" then
        for _, fishName in ipairs(config) do
            if fishName and fishName ~= "" then
                set[fishName] = true
            end
        end
    elseif type(config) == "string" and config ~= "" then
        for fishName in config:gmatch("[^\r\n,]+") do
            local trimmed = fishName:gsub("^%s+", ""):gsub("%s+$", "")
            if trimmed ~= "" then
                set[trimmed] = true
            end
        end
    end

    return set
end

function GetFishDataNames()
    if not fishDataNames then
        fishDataNames = {}
        for _, fish in ipairs(FishData) do
            fishDataNames[fish.name] = true
        end
    end
    return fishDataNames
end

function ValidateFishNameSet(configKey, set)
    local validNames = GetFishDataNames()
    for fishName in pairs(set) do
        if not validNames[fishName] then
            local logKey = configKey .. ":" .. fishName
            if not unknownFishLog[logKey] then
                Dalamud.Log(string.format("%s WARNING: '%s' in %s does not match any DT Big Fish. Check spelling.", LogPrefix, fishName, configKey))
                unknownFishLog[logKey] = true
            end
        end
    end
end

function BuildDisabledFishSet()
    disabledFish = BuildFishNameSet("DisabledFish")
    ValidateFishNameSet("DisabledFish", disabledFish)
end

function BuildEnabledFishSet()
    enabledFish = BuildFishNameSet("EnabledFish")
    ValidateFishNameSet("EnabledFish", enabledFish)
end

function BuildBaitItemIdMap()
    baitItemIds = BaitItemIds
    baitChecksReady = true
    LogInfo(string.format("%s Loaded static bait item ID map.", LogPrefix))
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

--- For swimBait fish, also accepts the window being not-quite-open-yet if it
--- opens within SwimBaitPrepSeconds, so travel started for early bait prep
--- doesn't get cancelled while still en route. This is also what lets the
--- script begin fishing early to catch swim bait before the real window opens.
--- Falls back to the real-time IsFishUp first, so this never reports the
--- window closed any earlier than it actually does.
function IsFishReady(fish, unixSeconds)
    unixSeconds = unixSeconds or os.time()
    if IsFishUp(fish, unixSeconds) then
        return true
    end
    if fish.swimBait then
        return IsFishUp(fish, unixSeconds + SwimBaitPrepSeconds)
    end
    return false
end

-------------------
--    Fishing    --
-------------------

function IsFishAllowed(fish)
    if next(enabledFish) ~= nil then
        return enabledFish[fish.name] == true
    end
    return not disabledFish[fish.name]
end

function SelectNextFish()
    for _, fish in ipairs(FishData) do
        if fish.x and fish.y then
            local cooldownUntil = lastAttempt[fish.name]
            local hasPreset = fish.autoHookPreset and fish.autoHookPreset ~= ""
            if IsFishAllowed(fish) and HasRequiredBait(fish) and (hasPreset or not RequireAutoHookPreset) and (not cooldownUntil or os.time() >= cooldownUntil) and IsFishUp(fish) then
                return fish
            end
        end
    end

    -- Idle fallback: nothing actually open - get a head start on swimBait
    -- fish so bait can be caught before the window opens.
    for _, fish in ipairs(FishData) do
        if fish.x and fish.y and fish.swimBait then
            local cooldownUntil = lastAttempt[fish.name]
            local hasPreset = fish.autoHookPreset and fish.autoHookPreset ~= ""
            if IsFishAllowed(fish) and HasRequiredBait(fish) and (hasPreset or not RequireAutoHookPreset) and (not cooldownUntil or os.time() >= cooldownUntil) and IsFishReady(fish) then
                return fish
            end
        end
    end

    return nil
end

function CharacterState.selectFish()
    BuildDisabledFishSet()
    BuildEnabledFishSet()

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
    LogInfo(string.format("%s State Changed -> TeleportToZone", LogPrefix))
    Wait(0.3)
end

function CharacterState.teleportToZone()
    if not IsFishReady(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
        return
    end

    if not IsInZone(SelectedFish.zoneId) then
        local aetheryteName = SelectedFish.aetheryte
        if not aetheryteName or aetheryteName == "" then
            aetheryteName = GetAetheryteName(SelectedFish.zoneId)
        end
        if aetheryteName then
            Teleport(aetheryteName)
            Wait(0.3)
        end
        return
    end

    if not IsPlayerAvailable() then
        return
    end

    State = CharacterState.travelToSpot
    LogInfo(string.format("%s State Changed -> TravelToSpot", LogPrefix))
    Wait(0.3)
end

function CharacterState.travelToSpot()
    if not IsFishReady(SelectedFish) then
        LogInfo(string.format("%s %s's window closed before arrival.", LogPrefix, SelectedFish.name))
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
        return
    end

    if not IsInZone(SelectedFish.zoneId) then
        State = CharacterState.teleportToZone
        LogInfo(string.format("%s State Changed -> TeleportToZone", LogPrefix))
        return
    end

    WaitForNavMesh()

    local arrived

    if not CanMount() then
        LogInfo(string.format("%s Walking to %s (%.1f, %.1f)", LogPrefix, SelectedFish.spotName, SelectedFish.worldX, SelectedFish.worldZ))
        arrived = MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ)
        Wait(0.3)
    else
        Mount()
        Wait(0.3)
        local fly = CanFly()
        LogInfo(string.format("%s %s to %s (%.1f, %.1f)", LogPrefix, fly and "Flying" or "Riding", SelectedFish.spotName, SelectedFish.worldX, SelectedFish.worldZ))
        MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ, 0, fly)
        while IsMounted() do
            Dismount()
            Wait(1)
        end

        local landedPos = GetPlayerPosition()
        arrived = landedPos and GetDistance(landedPos, Vector3(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ)) <= 1.0
        Wait(0.3)
    end

    if not arrived then
        LogInfo(string.format("%s Failed to reach %s's spot. Cooling down and retrying later.", LogPrefix, SelectedFish.name))
        lastAttempt[SelectedFish.name] = os.time() + RetryCooldownSeconds
        State = CharacterState.selectFish
        LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
        return
    end

    local fishX = SelectedFish.fishX or SelectedFish.worldX
    local fishY = SelectedFish.fishY or SelectedFish.worldY
    local fishZ = SelectedFish.fishZ or SelectedFish.worldZ
    if fishX ~= SelectedFish.worldX or fishZ ~= SelectedFish.worldZ then
        LogInfo(string.format("%s Walking to casting spot (%.1f, %.1f)", LogPrefix, fishX, fishZ))
        local fishArrived = MoveTo(fishX, fishY, fishZ)
        Wait(0.3)

        if not fishArrived then
            LogInfo(string.format("%s Failed to reach %s's casting spot. Cooling down and retrying later.", LogPrefix, SelectedFish.name))
            lastAttempt[SelectedFish.name] = os.time() + RetryCooldownSeconds
            State = CharacterState.selectFish
            LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
            return
        end
    end

    State = CharacterState.fishing
    LogInfo(string.format("%s State Changed -> Fishing", LogPrefix))
    Wait(0.3)
end

function CharacterState.fishing()
    if not fishingStarted then
        if not IsFishReady(SelectedFish) then
            LogInfo(string.format("%s %s's window closed before fishing started.", LogPrefix, SelectedFish.name))
            CleanupAutoHookPreset(SelectedFish)
            State = CharacterState.selectFish
            LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
            return
        end

        if not IsPlayerAvailable() then
            return
        end

        LogInfo(string.format("%s Starting AutoHook preset: %s", LogPrefix, SelectedFish.name))
        catchDetected = false
        catchMessage = nil
        forcedQuit = false
        windowClosedAt = nil
        windowOpenedAt = IsFishUp(SelectedFish)
        SelectAutoHookPreset(SelectedFish)
        SetAutoHookState(true)
        Wait(1)
        local ahStartedAt = os.time()
        while not IsFishing() and (os.time() - ahStartedAt) < 10 do
            Execute("/ahstart")
            Wait(4)
        end

        if IsFishing() then
            fishingStarted = true
        else
            LogInfo(string.format("%s AutoHook failed to start fishing for %s. Forcing quit to recover.", LogPrefix, SelectedFish.name))
            CleanupAutoHookPreset(SelectedFish)
            ExecuteAction(CharacterAction.Actions.quitFishing)
            Wait(0.3)
        end
        return
    end

    if IsFishUp(SelectedFish) then
        windowOpenedAt = true
        windowClosedAt = nil
    elseif windowOpenedAt then
        if IsFishing() or IsGathering() then
            if not windowClosedAt then
                windowClosedAt = os.time()
                LogInfo(string.format("%s %s's window closed while fishing. Forcing quit in %.0f seconds.", LogPrefix, SelectedFish.name, ForceQuitDelaySeconds))
            end

            if os.time() - windowClosedAt >= ForceQuitDelaySeconds then
                forcedQuit = true
                ExecuteAction(CharacterAction.Actions.quitFishing)
                Wait(0.3)
            end
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

    local cooldownSeconds = catchDetected and CaughtCooldownSeconds or RetryCooldownSeconds
    lastAttempt[SelectedFish.name] = os.time() + cooldownSeconds
    CleanupAutoHookPreset(SelectedFish)
    fishingStarted = false
    catchDetected = false
    catchMessage = nil
    forcedQuit = false
    windowClosedAt = nil
    windowOpenedAt = false
    State = CharacterState.selectFish
    LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))
    Wait(0.3)
end

--=========================== EXECUTION ===========================--

for _, fish in ipairs(FishData) do
    if not fish.y then
        LogInfo(string.format("%s WARNING: %s has no valid coordinates (source data error) - skipping until fixed.", LogPrefix, fish.name))
    end
end

BuildBaitItemIdMap()

if not GetClassJobId(18) then
    LogInfo(string.format("%s Switching to Fisher.", LogPrefix))
    Execute("/gs change Fisher")
    Wait(1)
end

State = CharacterState.selectFish
LogInfo(string.format("%s State Changed -> SelectFish", LogPrefix))

while true do
    State()
    Wait(1)
end

--============================== END ==============================--
