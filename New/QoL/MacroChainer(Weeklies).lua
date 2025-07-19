--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Macro Chainer - Script for running multiple macros in sequence for weekly tasks
plugin_dependencies:
- Lifestream
- vnavmesh
dependencies:
- source: ''
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

local MacrosToRun = {
    { macroName = "ChocoboRacing",   echoTrigger = "ChocoboRacing"   },
    { macroName = "IslandSanctuary", echoTrigger = "IslandSanctuary" },
    { macroName = "JumboCactpot",    echoTrigger = "JumboCactpot"    },
    { macroName = "LoV",             echoTrigger = "LoV"             },
    { macroName = "TT",              echoTrigger = "TT"              },
    { macroName = "WondrousTails",   echoTrigger = "WondrousTails"   },
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
    yield("/snd run " .. macro.macroName)

    while not macroDone do
        yield("/wait 1")
    end

    LogInfo(string.format("%s Completed macro: %s", LogPrefix, macro.macroName))
    yield("/wait 1")
end

currentEchoTrigger = nil
macroDone = false

LogInfo(string.format("%s All macros completed. Stopping any remaining..!!", LogPrefix))
StopRunningMacros()

--============================== END =============================--