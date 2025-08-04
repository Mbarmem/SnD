--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Weeklies Macro - Macro for enabling or disabling Weeklies collection
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
    "AutoDuty",
    "RotationSolver",
    "BossModReborn",
    "vnavmesh",
    "visland",
    "Avarice",
    "YesAlready",
    "Deliveroo",
    "TextAdvance",
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
    Echo("|| Weeklies Disabled ||")
    LogInfo("|| Weeklies Disabled ||")
    Execute("/xldisablecollection Weeklies")
else
    Echo("|| Weeklies Enabled ||")
    LogInfo("|| Weeklies Enabled ||")
    Execute("/xlenablecollection Weeklies")
    if not Player.Bingo.HasWeeklyBingoJournal or Player.Bingo.IsWeeklyBingoExpired or Player.Bingo.WeeklyBingoNumPlacedStickers == 9 then
        Echo("|| Running Weekly Tasks ||")
        Execute("/snd")
        repeat
            Wait(1)
        until AreAllPluginsEnabled()
        Execute("/snd run MacroChainer(Weeklies)")
    end
end

--============================== END =============================--