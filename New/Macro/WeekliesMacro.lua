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
    "TextAdvance",
    "SkipCutscene"
}

--=========================== EXECUTION ==========================--

local status = ToggleCollection("Weeklies", {
    runAfterEnable = "MacroChainer(Weeklies)",
    shouldRun = function()
        return (not Player.Bingo.HasWeeklyBingoJournal)
            or Player.Bingo.IsWeeklyBingoExpired
            or (Player.Bingo.WeeklyBingoNumPlacedStickers == 9)
    end
})

Echo(string.format("|| Weeklies %s ||", status))

--============================== END =============================--