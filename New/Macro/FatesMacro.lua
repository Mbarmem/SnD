--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Fates Macro - Macro for enabling or disabling Fates collection
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git

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