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
--                                  SelectedFish.noMount entries (zones with no
--                                  mounting at all, e.g. Tuliyollal), where
--                                  vnavmesh failed to path there ground-walking
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
--                                  Mount() -> MoveTo(worldX, Y, worldZ, 0, true)
--                                  -> Dismount() (flight), or for noMount
--                                  entries just MoveTo(worldX, Y, worldZ) on
--                                  foot. worldX/worldZ is a landing spot, not
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
--     working end-to-end on live runs across noMount (Cabinkeep Permit: walked,
--     cast, caught) and flying (Hwittayoanaan Cichlid) entries alike.
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
--     pathing timeout). Since the spot is close to its aetheryte, it's now
--     marked noMount and walked to instead, which sidesteps the issue.
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
--- fishX/fishZ skip that walk and fish right where they land. noMount is optional - set
--- it true for zones where mounting isn't available at all (e.g. Tuliyollal), so
--- travelToSpot ground-walks to worldX/worldZ instead of trying to fly there. aetheryte
--- is optional (works for both noMount and flying entries) - when set, teleportToZone
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
        swimBait        = false,
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
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1dW2/bOhL+KwFf9kVa6H4xdhdI3PZsgCYpYgfF4qAPFDWyhciij0S5zQny3xekJF9kyXEcpbFbvtkkRZHDj/yGHI7mEZ0XjA5xzvJhNEGDR/QxxUEC50mCBiwrQEEfaMqGOCWQXFFKpnXyLRCcs/M0nmEW07QsgQYRTnJQ0LjI0iFNEiDsJoqWycNpMdvvka8xm9JC1N8oxxv7OU6BN/ZyktIMNtpVtj+s/16GaGB4voL+mI+nGeRTmoRooHV260sW0yxmD2igK+gy//iDJEUI4Sq5LLZW23lAF1CnD2kaxrxzI2C8gTPxrgka/Fn/Jmjw5zcF4fKJp28KAjRIiyR5eir7VjXnEYkfxmpMwqUIRKccr9EpXdurWz30SzRXaW+W7x4ia623RnERcph1yc3SNeswwbU3sar6DQFRTYodHdIPELnRq8RHKZ5M4nSyo5HaAY00+4UFzcIYJ2LhSBeQ1Qlbg1kuK+N4Bl/jNKTflxkti4tuOM7+y8vNAjKC569Bxbp8rPfC5Kc4n358gHxrEW4KahMDdkNQtr0PCpweerkGgyt8D6NpHLELHIv+84S8ThgxTO5zNLDbqcTxtjvxigWul5F6RAwN0Aquww9IQXNePmc4Y2jgO5qCIBVLnac9idEUA6uUj54TwceUJiH9nq4ej2ueidNF/cTy2Z34+IJZDCkRJH0LEe/bR5wlD7yRot0tsrV0zWmI1tkLH35fstW7ZHuQgJTDx2VNtsorRvqQgcviv2GIWamCdCgeW+Nk7MegZr8TeTzFSYzv8094QTPe3I2EeiJ7ymb6LRC6gAwNdA6ujjm+pSJY/j4dfOlKVau0L5jmu6BYcRF7mIMAM52jAfoP2nfsL+LJH5jPz0d0nk4SyPJahkb7im66mrUFhX3k5L0Xb10VCYunlN53KiqGZjfpXN+jS/0psGuzu1Xp/sEyvLFXW4L3FnJgQ1qkDLIvGf8z+o7ny+59ohkBQXEitXxGJIY8VfTe9GxPEXvCGwI4FTTfkNJG5nmSjBid5+25ozkV1WqNdN7FtvTtDitonMWTCWS5GOVGh9+EHncu5mL0zxc4TnhDljVtFxwxzIpq/qxPUt4Pw3W9bwqaxWk9v/QWUh59j2cBjssBXVWx4AqsqYj5bpmuZXa9my8UC2i+27O1b8+uBwriECkhtBzZ8u+YluhBKipLlUpUVYb/qUs8ivmk6gr6XGRwBXmOJ4AGCCnoWqwy6JqmgKqHxJLF+8LhVK5xYuLdQk6TBVR7IC70vKGTt5QQoL6myyIjPs4cYGKHsnwuLAjw1LWkGV1AKb71h1mRj2mZKVB1TVkcPdyko4IQyIUS3JwlH8mUDqeYLfu9PAHBbAw/+DAhBX2I83mCH/iqO6Y4XwlymbJVVqSKBsREHKOsDlA2y39KcD4d4/w+wNklWSt3kcWpWOg/0QwmGS048us8gPlav0TqE8fVW808/VkF6Ahxqb0JLutFXMJyT1h+U9BdGv9VCC5BfgC27QZE9W07UC0dNDUAzVJN03Ux9nTb1nWuCn2Oc3YT8cFt5RSeUS4KJVAqSuzCyi2EZ1d4MqEs34AMB/M1zWY4+W+lbdzCX0WcQVgvL5qC6l3SV8CiCC+aA2u0qPxb5a1zd5VUvtDSXV9BdzkIFWdePsCz8gux68qWwrzLYdUyXqJZYDP3KuaI/6e2lY5/VOl3OXzJgMR5TNOuOrcKrKrdztqomX6HLCo6G9vMX6u3mbNe7YhBkuCsq9ZG9qrSZsayztcd6dT1tWlAm2JvK7ElwdZCDXG0lWn0rlUBrUE7YhktD/xeB1vNlLA9dtgeptP2cyzykkOMron00ul4pFPuM0wgDXH20DbrNk5e5bSTbHEU0L3L4QMtKkQuQfoZSgtCTvC8Lb9MerFaVD29QTAGPxGTatFx8EuJmxNSdkogHqDqSCgeuYZ+olDcqQJINJ7qfvHk0HiXwzirjxnaeb0lv0zqh9dd25A7RwngQwFcQrEvZpdglKvpq8HYI7dLPEo8vgaP8Qxowda0lWkx20q8y2FY5IzOyoPBDaYXt7SLrLwhyH+sXSUpL1KcMwaz+cpGxwuNcTbhzTBaL+aYru03L9+JSzw/43bGi6+bVOJqG4I1abaK/zJlhUjssh3Z/M7ZwdajthVDmo/kgvE+RqF2NEqrkNTt39ZeIgEpT0ukFUReDpGHfdIK8tveUzq5c2dpBZFoPB40SiuIvPZ50suptIJIbj8yMEoriNQ1f3kriLmPFUTr8rq1/e1PmPx0H9UDbRvCjypikK28Vdd2M3ReuUONGMyFA2DtBlkSJ5cj3xVViR0e1EtnsbLU0pzyoqd/Mye/UvptI7rmY+WaxPZAD1Vs6Y5qEctQvQBbaujqhh0RYjm+hbgdrHSyqnC4j5OVa5ndTlYXSZyGZxcZZUWCN9ys9D7crF54c176Wcnzizc0lEk/jpM9Tdt9R6BcZ6W3kvQRPOkj41/YtVU6K0kf7hM+zJPOSvLo5KigKJ2VpNH4GNAozXTSTCfNdNI55Cj3UyenZkoznbwSdlR4fGczXefHcVu8laSzknRWkndIj+RzWtJZSd5ofn/6ks5KUp86Kn1KWkGkFeSEt6fSCiKtIEcFRWkFkVaQY0CjtIJIK8gvcPAsP9kmt+1HA0bprCSdlY5kcZTOSkfvrPRTg7ruih+3jA35b9QeSa7zq3bSp6pvnyqN6L5uRrpq2WCplhXYamAGpurZUQChFQXEtNd8qkq3qW2XqnV3KtvQeATTTneqmDHIApzdnw1xPMPp2ZZP1S7gX4aQspjghJtNO+No2n4zMqi516ca+wgNWs/eIoswgVFShn3raKZ9WCxbu792Vq94LH8YOwLvHha4Xu/N77O1Wb57QGT3roDYBzRqNMcZcAbFfD4+dkaq3TbGdzeUz6bLcEyHUyD3Kz6vW2loPY7+8Yek7SN8YhWSsWU9aQngeA0LyDYjym/TrWZYShV8/nUeKtLT9xktRMTmxcVk2lQm4pps9gzdyRHQquAuw3o+Q5aRQ6LItSIVe5qu8pmhYhIEqucHpoUDFwKLoJZ4pb05G0tiPBJi3IjXfjS8uNaqd6PFnxWNdxf1rn+0+1XMW03Wnqn3mTiHuyNvi53Tvzo2Tm8Z3VAqC4crC1JT6PWbIL2QuRtoRugajqo7oKmWC5bqR76m6qGlYTPwsB26m2ReNbbB5uaOve7/8P3Z+B+QnA0xi/hjktDlTlfudOVO95R2upK8jo+8NN1zfM82VM3AvmoZpqn6mIQqRK7jE8dwrDDci7yMbnxdFaHkLHk6K09n5ensyZ3OSs46Ps6yNTtwdCdSIbBC1dICrPqhZqkWDkgIPjgh2YuzrP02XNy0KPdbcr8l91tyvyW56/f9gHAv3BXogRFFmq66PgHVIiRUAy8iqqu7buQEnhlp3vPcZZmm181dQ0gpg7Obh5xBJplLMpdkLslckrkkcw1fZebyQ424kaF6Grb4LU9b9W0dVCCR63iub+qk/Gj+Zf5HQgNuZd7Ye3fd2kQbbyHEDXTd1NUwNG3V8iBSA4gcNXLMKNBxQAxDR0//B7PDTQjwqQAA",
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
        noMount         = true,
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
        autoHookPreset  = "AH6_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",
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
        swimBait        = false,
        autoHookPreset  = "AH6_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",
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
        noMount         = true,
        time            = "10:00-12:00",
        weather         = "",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_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",
        x = 13.7, y = 12.7, radius = 500,
        worldX = -424.90, worldY = 19.79, worldZ = -391.79,
        fishX = -438.47, fishY = 18.05, fishZ = -391.69,
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
        swimBait        = false,
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
        noMount         = true,
        time            = "0:00-24:00",
        weather         = "Fog",
        previousWeather = "",
        bait            = "Red Maggots",
        swimBait        = false,
        autoHookPreset  = "AH6_H4sIAAAAAAAACu1cW2/iuhb+KyPrSOclqXKFwBull4PUTqtCNQ9VpWOSRfBuiBnbocOuKu2/sf/e+SVHdsItJB1KM1vQyRssX7KW/a2Ls7L8gjqJoF3MBe+OQtR+QecxHkbQiSLUFiwBDZ3RWHRx7EN0Tak/XpDvwMdcdGIywYLQOO2xaBwkLO7SKAJf3IxGC2p3nEy2BoxwxLdGfCNiTBM1e66fZPWKxCBZ7YUxZbDBVcp9sPjbC1Db8loaupwOxgz4mEYBahulQt0yQhkRc9Q2NdTj5z/8KAkgWJHTbmuzdYZ0BksBaRwQKVwfhGRwop4VovaD+m1qyFe/BWqjvsAi4R1fkBl0z5CGpnLEv8R8CrJ1zgVMTrIVITTmJ5cQAyP+yRlRBMzm/7UeHrKOfcFIHGpfsr+3jMywgJMuZXBFho/aot/N8A/wRWm/x7IWpCEScNR+MD3DftQQiWep0K8aysR/1VLBvgEWY2BHJJPzuCbFo4bw6iegdpxE0etrirwMLC9I/bBW+hIsAaog1/BykDONnUBXAeoUu1oxW63mPppgVMaUXEJpBMrWzTENZ7+FK2Yxm/od6mquqavxWdS1GN1amZB9gf0nfhxClpuhy+lRSDDDEWrbhrGrBcp4f0ODzD103KpUxfsxDkMSh28waezBpF2tHaIsIHLxX1AvngFbELasRxplDMgEvpE4oM/LhoJYw7Qajd2jjZsZMB9PfxI1ZBpajIr19XEqMIJrC3RB+Ph8Dnwr0sqLv7mzbk58191lbxvV8n6Nn6A/JiNxiolaU0ngC0Jq4FDbLXGTDW9bih1kaFUrwy0WBGJfRbp3MJJjzzGL5hKJChUlG9DIs97YyYNaFXPPyJ/QxSINl8qWOc+rtZu3t6vldTDGEcFP/ALPKJPsbhAWaLG1Tfod+HQGDLVNifAyCfPxzE7yVawNpyS8xBI0L6gThxGwzMUru1/EuN00nK2t2YVxr2I1TiJBxpQ+lXoSy3D3Od1VF9Ku/EJxGP5DMLxxsl76izvgILo0iQWwWyb/9J/xdCneBWU+KGulqOkYRQwkVUlve66nqRP8jQ84VhY7t0objZ0o6gs65cWt/SlV0xo5uhSxiL4tsIYGjIQhMBl6PmroPibfEzUWea0GDIe+rTdGgaM7Fg50z3A83XBcFzdbTctybPSqoSvCxc1ISijn2Fo02SCfrZzSagmuEgbXwDkOZZiHNPRV4R3dQfDlGochFRylgwcqEpTh1lfKJjj6T4auO/ieEAZBGgIrYRcG+Btg1UV25SByHKV/s7b1vcpI6QMds9nS0D0HBelpOkA28VNl0NlyS+45rDiTPfIdNluvSYzaxomxRcc/Mvo9h1sGPuGExmVzbnVYTbvdtDEzfQY2SkqZzbevzZtvWZ+2LyCKMCubNde8mjTfsJxztxjr+I96xUeisthxsU5FmrwJp6IeW8go7JTb5qI+uV0rNKQLZewLRtOTxcfU0bBrdazVsVbHD6rjFYQQB5jNa438HRzkJ3Ak9xzOaJL5iOWCXUH6voP7eFrUnpLeHQlmozd8jyXfENWRYA30Xwz0FLJ7xEs1aA/cOqcYODoo7hcr1Gg8cDR+7lhhwBZva4pjhYL2lFRNrNB0rfqgWkP910M9BW1V0UIN20Oy0EcXL6RgrDBeqPF4SHj8xBGDXCiaiDXJx8lki3jPoZtwQSdpqmEjelAfuCYs/e5C/ljLP6c5zY4QMJmKVTySMBhgFko2SjLRdtNtbX9Z988kSt+326s1LNqCtdUsXP5eLBJFLEvrufLLzL0Te0W2pc7sHZJpOTpX94G8VjEa68RWjcYPo7G60KsGZG0e62xN/d3O7+nd6xzMZ/2E7EihWOdgajQeAhrrzEr9Re5Rm9M6X/J5Pw8/UjDW+ZIajweCxzoL8ka52J65DVm51RkJYKvCsTWLR6fymxQSh30BU3WPQf+ZTIaYiNRWyRd50nJmxFW6qfBRWa9lOuVdo79SQUbzm7if+D5wlcfK56TO/THtjrFY1mwt5htjMYAfsgoHaeiM8GmE57J2cUAxXz12Sdnqq6iKAeKra2aWN9Jsdr+IMB8PMH8aYtbzZbds6lNZrSPnv6AMQkaTeMX1KcB0TSxFzTamaEPXqt+awxa4rtPQHc+xdMcb2XrLhqGOzaCFA6PVBBeQTIOl5W9ZMu5hSUhL3rbL4TZK4RzbbpWXwvX8ZBbRf/Mvp5gJYBvlcOZP4NULIBbEx5FMTpbWYrqtfM2ovVPtdxVFo+9OMvYTNsI+9CP54rpUIHe/+mS3ujLY+saZD5Xn9qeYgfRoWOrxS2m1s/uOa2ek0vWCAe2OwX9a+dflXRpGhbt/+AXQyorQNAGUGiLdLLdCX2kMG6bHVu4GTyWlwPKkhdGL+ZEuZ4IZsM2rKLbdn2HJ2zDUrRUf+/bkLWeWJcI+ty97u1ZW1YHjJByn+3Yk5bJLZ6lu3zF3qJRdQLQwIn7G0xSnP4kC/GHL9HFg60GzMdIdt+nrnmkb+mjYwIaFW65rWEjeX/SWl7cbDadcv64p/54QQb+oMZ/Lxy+2osRzr27h2dlxL41MpZ773bFI7eMP3cdnWlc7+YNy8r/ew/9Ox9V+FS6u0RqNDAcHemC3HN1pGk196LiebowMB6yG65iOpw66PX4Z0aF0vxsg2Dis/u+vv9eOq2tPcTAOGrZv6KbpYt3xPUf3LGzqnuvbjuMFjcC00Ov/AfHx3N/cVgAA",
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
        autoHookPreset  = "AH6_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",
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
        noMount         = true,
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
        swimBait        = false,
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
        noMount         = true,
        time            = "16:00-18:00",
        weather         = "Rain",
        previousWeather = "Clouds",
        bait            = "Ghost Nipper",
        swimBait        = false,
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
        swimBait        = true,
        autoHookPreset  = "AH6_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",
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
        autoHookPreset  = "AH6_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",
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
        swimBait        = false,
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

function BuildDisabledFishSet()
    disabledFish = BuildFishNameSet("DisabledFish")
end

function BuildEnabledFishSet()
    enabledFish = BuildFishNameSet("EnabledFish")
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

    if SelectedFish.noMount then
        LogInfo(string.format("%s Walking to %s (%.1f, %.1f)", LogPrefix, SelectedFish.spotName, SelectedFish.worldX, SelectedFish.worldZ))
        arrived = MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ)
        Wait(0.3)
    else
        LogInfo(string.format("%s Flying to %s (%.1f, %.1f)", LogPrefix, SelectedFish.spotName, SelectedFish.worldX, SelectedFish.worldZ))
        Mount()
        Wait(0.3)
        MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ, 0, true)
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
        Execute("/ahstart")
        Wait(3)

        if IsFishing() then
            fishingStarted = true
        else
            CleanupAutoHookPreset(SelectedFish)
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
