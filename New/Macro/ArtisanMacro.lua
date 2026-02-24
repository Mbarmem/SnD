--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Artisan Macro - Macro for enabling or disabling Artisan collection
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
    "Artisan",
    "vnavmesh",
    "PandorasBox",
    "YesAlready",
    "AutoRetainer"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Artisan")
Echo(string.format("|| Artisan %s ||", status))

--============================== END =============================--