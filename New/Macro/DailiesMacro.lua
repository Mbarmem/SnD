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

local status = ToggleCollection("Dailies", {
    runAfterEnable = "MacroChainer(Dailies)",
    shouldRun = function()
        local Allowance = CheckAllowances()
        Wait(5)
        return Allowance == 12
    end
})

Echo(string.format("|| Dailies %s ||", status))

--============================== END =============================--