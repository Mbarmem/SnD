--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Gather Macro - Macro for enabling or disabling Gather collection
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
    "GatherbuddyReborn",
    "AutoHook",
    "vnavmesh",
    "visland",
    "PandorasBox",
    "YesAlready",
    "AutoRetainer"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Gather")
Echo(string.format("|| Gather %s ||", status))

--============================== END =============================--