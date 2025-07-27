--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Crescent - Script for Supporting Gold Farm on Ninja
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

Feint     = 7549
Loop      = 0
LoopCount = 4
LogPrefix = "[PSkillsFT]"

--============================ CONSTANT ==========================--

---------------------
--    Condition    --
---------------------

Actions = {
    [1] = '"Phantom Action I"',
    [2] = '"Phantom Action II"',
    [3] = '"Phantom Action III"'
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function TryExecute()
    for i = 1, 3 do
        LogInfo(string.format("%s Attempting to use action: %s", LogPrefix, Actions[i]))

        if not Entity.Player.Target then
            LogInfo(string.format("%s No target found, acquiring new target...", LogPrefix))
            yield("/targetenemy")
            Wait(1)
        end

        yield("/ac " .. Actions[i])
        Wait(2)
    end
end

--=========================== EXECUTION ==========================--

if Actions.GetActionInfo(Feint).SpellCooldown < 1 and Entity.Player.Target then
    LogInfo(string.format("%s Executing Feint on: %s", LogPrefix, Entity.Player.Target.Name))

    yield("/ac Feint")
    Wait(0.5)
else
    LogInfo(string.format("%s Feint not used. Cooldown active or no valid target.", LogPrefix))
end

while Loop < LoopCount do
    LogInfo(string.format("%s Executing TryExecute iteration %d of %d.", LogPrefix, Loop + 1, LoopCount))
    TryExecute()
    Wait(0.1)
    Loop = Loop + 1
end

LogInfo(string.format("%s Script execution completed succesfully..!!", LogPrefix))

--============================== END =============================--

