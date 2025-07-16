--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Gather Macro - Macro for enabling or disabling Gather collection
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
    "GatherbuddyReborn",
    "AutoHook",
    "vnavmesh",
    "visland",
    "PandorasBox",
    "YesAlready",
    "AutoRetainer",
    "Deliveroo"
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
    Echo("|| Gather Disabled ||")
    LogInfo("|| Gather Disabled ||")
    yield("/xldisablecollection Gather")
else
    Echo("|| Gather Enabled ||")
    LogInfo("|| Gather Enabled ||")
    yield("/xlenablecollection Gather")
end

--============================== END =============================--