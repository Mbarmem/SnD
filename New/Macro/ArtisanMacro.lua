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
    yield("/xldisablecollection Artisan")
else
    Echo("|| Artisan Enabled ||")
    LogInfo("|| Artisan Enabled ||")
    yield("/xlenablecollection Artisan")
end

--============================== END =============================--