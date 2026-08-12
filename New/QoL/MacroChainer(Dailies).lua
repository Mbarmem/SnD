--[=====[
[[SND Metadata]]
author: Mo
version: 3.0.0
description: Macro Chainer - Script for running multiple macros in sequence for daily tasks
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  MacrosToRun:
    description: |
      The macros to run, one after another, in the order listed.
      Enter the exact macro name as it appears in SND and press enter. One macro per line.
    default: []
  StartTimeout:
    description: |
      Seconds to wait for a macro to appear as running before giving up on it.
      This only comes into play when a macro name is wrong, so the macro never starts at all.
    default: 10
    min: 1
    max: 120
  RunTimeout:
    description: |
      Maximum seconds a single macro may run before it is stopped and skipped.
      Set to 0 for no limit, letting every macro take as long as it needs.
    default: 0
    min: 0
    max: 14400
[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

local MacrosToRun  = Config.Get("MacrosToRun")
local StartTimeout = Config.Get("StartTimeout")
local RunTimeout   = Config.Get("RunTimeout")
local LogPrefix    = "[MacroChainer]"

-------------------
--    Options    --
-------------------

local MacroOptions = {
    startTimeout = StartTimeout,
    runTimeout   = (RunTimeout > 0) and RunTimeout or nil,
}

--=========================== EXECUTION ==========================--

if not GetMacroScheduler() then
    LogInfo(string.format("%s SND macro scheduler unavailable, cannot track macros. Aborting..!!", LogPrefix))
    return
end

if not MacrosToRun or MacrosToRun.Count == 0 then
    LogInfo(string.format("%s No macros configured, add them in the script settings..!!", LogPrefix))
    return
end

local KnownMacros  = GetKnownMacroNames()
local NamesChecked = next(KnownMacros) ~= nil

local Macros = MacrosToRun:GetEnumerator()

while Macros:MoveNext() do
    local macroName = tostring(Macros.Current)

    if NamesChecked and not KnownMacros[macroName] then
        LogInfo(string.format("%s Macro not found in SND, check the spelling -> %s", LogPrefix, macroName))
    else
        LogInfo(string.format("%s Starting macro -> %s", LogPrefix, macroName))

        if RunMacroAndWait(macroName, MacroOptions) then
            LogInfo(string.format("%s Completed macro -> %s", LogPrefix, macroName))
        else
            LogInfo(string.format("%s Skipped macro, it never ran to completion -> %s", LogPrefix, macroName))
        end
    end

    Wait(1)
end

Echo("All macros completed. Stopping any remaining..!!", LogPrefix)
LogInfo(string.format("%s All macros completed. Stopping any remaining..!!", LogPrefix))
StopRunningMacros()

--============================== END =============================--
