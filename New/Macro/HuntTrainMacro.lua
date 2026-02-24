--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: HuntTrain Macro - Macro for enabling or disabling HuntTrain collection
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
    "HuntTrainAssistant"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("HuntTrain")
Echo(string.format("|| HuntTrain %s ||", status))

--============================== END =============================--