--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Fates Macro - Macro for enabling or disabling Fates collection
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
    "RotationSolver",
    "BossModReborn",
    "vnavmesh",
    "Deliveroo",
    "YesAlready",
    "TextAdvance",
    "AutoRetainer",
    "SkipCutscene"
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
    Echo("|| Fates Disabled ||")
    LogInfo("|| Fates Disabled ||")
    yield("/xldisablecollection Fates")
else
    Echo("|| Fates Enabled ||")
    LogInfo("|| Fates Enabled ||")
    yield("/xlenablecollection Fates")
    Echo("|| Running Fates ||")
    yield("/snd")
    repeat
        Wait(1)
    until AreAllPluginsEnabled()
    yield("/snd run MultiZoneFarming")
end

--============================== END =============================--