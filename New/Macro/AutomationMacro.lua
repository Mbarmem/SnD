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
    Echo("|| Automation Disabled ||")
    LogInfo("|| Automation Disabled ||")
    yield("/xldisablecollection Automation")
else
    Echo("|| Automation Enabled ||")
    LogInfo("|| Automation Enabled ||")
    yield("/xlenablecollection Automation")
end

--============================== END =============================--