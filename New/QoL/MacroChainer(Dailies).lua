--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Macro Chainer - Script for running multiple macros in sequence for daily tasks
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

local macroDone          = false
local currentEchoTrigger = nil
local LogPrefix          = "[MacroChainer]"

local MacrosToRun        = {
    { macroName = "MiniCactpot",            echoTrigger = "MiniCactpot"  },
    { macroName = "TTSeller",               echoTrigger = "TTSeller"     },
    { macroName = "AlliedSocietiesQuests", 	echoTrigger = "AlliedQuests" },
}

--=========================== FUNCTIONS ==========================--

function OnChatMessage()
    local messageType = TriggerData.type
    local sender = TriggerData.sender
    local message = TriggerData.message

    if currentEchoTrigger and message:find(currentEchoTrigger) then
        LogInfo(string.format("%s Detected echo for: %s | Type: %s | Sender: %s | Message: %s", LogPrefix, currentEchoTrigger, tostring(messageType), tostring(sender), tostring(message) ))
        macroDone = true
    end
end

--=========================== EXECUTION ==========================--

for _, macro in ipairs(MacrosToRun) do
    currentEchoTrigger = macro.echoTrigger
    macroDone = false

    LogInfo(string.format("%s Starting macro: %s", LogPrefix, macro.macroName))
    Execute("/snd run " .. macro.macroName)

    while not macroDone do
        Execute("/wait 1")
    end

    LogInfo(string.format("%s Completed macro: %s", LogPrefix, macro.macroName))
    Execute("/wait 1")
end

currentEchoTrigger = nil
macroDone = false

LogInfo(string.format("%s All macros completed. Stopping any remaining..!!", LogPrefix))
StopRunningMacros()

--============================== END =============================--