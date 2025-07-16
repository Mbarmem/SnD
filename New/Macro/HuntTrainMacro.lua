--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: HuntTrain Macro - Macro for enabling or disabling HuntTrain collection
dependencies:
- source: ''
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--============================ CONSTANT ==========================--

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "HuntTrainAssistant"
}

--=========================== FUNCTIONS ==========================--

function AreAllPluginsEnabled()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            return false
        end
    end
    return true
end

--=========================== EXECUTION ==========================--

if AreAllPluginsEnabled() then
    Echo("|| HuntTrain Disabled ||")
    LogInfo("|| HuntTrain Disabled ||")
    yield("/xldisablecollection HuntTrain")
else
    Echo("|| HuntTrain Enabled ||")
    LogInfo("|| HuntTrain Enabled ||")
    yield("/xlenablecollection HuntTrain")
end

--============================== END =============================--