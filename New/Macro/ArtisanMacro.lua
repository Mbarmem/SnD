--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Artisan Macro - Macro for enabling or disabling Artisan collection
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
    "Artisan",
    "vnavmesh",
    "PandorasBox",
    "YesAlready",
    "AutoRetainer"
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
    Echo("|| Artisan Disabled ||")
    LogInfo("|| Artisan Disabled ||")
    Execute("/xldisablecollection Artisan")
else
    Echo("|| Artisan Enabled ||")
    LogInfo("|| Artisan Enabled ||")
    Execute("/xlenablecollection Artisan")
end

--============================== END =============================--