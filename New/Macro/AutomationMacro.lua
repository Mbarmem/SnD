--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Automation Macro - Macro for enabling or disabling Automation collection
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
    "PandorasBox",
    "AutoRetainer",
    "Dagobert"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Automation")
Echo(string.format("|| Automation %s ||", status))

--============================== END =============================--