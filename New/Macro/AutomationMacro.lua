--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Automation Macro - Macro for enabling or disabling Automation collection
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
    "PandorasBox",
    "AutoRetainer",
    "Dagobert"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Automation")
Echo(string.format("|| Automation %s ||", status))

--============================== END =============================--