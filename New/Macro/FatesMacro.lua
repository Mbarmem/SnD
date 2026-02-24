--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Fates Macro - Macro for enabling or disabling Fates collection
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown

[[End Metadata]]
--]=====]

--============================ CONSTANT ==========================--

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "RotationSolver",
    "BossModReborn",
    "vnavmesh",
    "YesAlready",
    "TextAdvance",
    "AutoRetainer",
    "SkipCutscene"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Fates", {
    runAfterEnable = "MultiZoneFarming"
})

Echo(string.format("|| Fates %s ||", status))

--============================== END =============================--