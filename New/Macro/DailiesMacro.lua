--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dailies Macro - Macro for enabling or disabling Dailies collection
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
    "Questionable",
    "RotationSolver",
    "Artisan",
    "vnavmesh",
    "TextAdvance",
    "Automaton",
    "YesAlready"
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

function CheckAllowances()
    if not IsAddonReady("ContentsInfo") then
        Execute("/timers")
        Wait(3)
    end

    local timerName = GetNodeText("ContentsInfo", 1, 4, 41009, 6, 8) or 0
    local timerConv = tonumber(timerName:match("%d+$"))
    Wait(1)
    CloseAddons()

    if timerConv then
        return timerConv
    end

    return 0
end

--=========================== EXECUTION ==========================--

if AreAllPluginsEnabled() then
    Echo("|| Dailies Disabled ||")
    LogInfo("|| Dailies Disabled ||")
    Execute("/xldisablecollection Dailies")
else
    Echo("|| Dailies Enabled ||")
    LogInfo("|| Dailies Enabled ||")
    Execute("/xlenablecollection Dailies")
    local Allowance = CheckAllowances()
    Wait(5)
    if Allowance == 12 then
        Echo("|| Running Daily Tasks ||")
        Execute("/snd")
        repeat
            Wait(1)
        until AreAllPluginsEnabled()
        Execute("/snd run MacroChainer(Dailies)")
    end
end

--============================== END =============================--