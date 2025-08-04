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

------------------
--    Action    --
------------------

Action = {
    [1] = { id = CharacterAction.GeneralActions.phantomActionI,   name = "Phantom Action I"   },
    [2] = { id = CharacterAction.GeneralActions.phantomActionII,  name = "Phantom Action II"  },
    [3] = { id = CharacterAction.GeneralActions.phantomActionIII, name = "Phantom Action III" }
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function TryExecute()
    for i = 1, #Action do
        local action = Action[i]
        LogInfo(string.format("%s Attempting to use action: %s (ID: %d)", LogPrefix, action.name, action.id))

        if not HasTarget() then
            LogInfo(string.format("%s No target found, acquiring new target...", LogPrefix))
            yield("/targetenemy")
            Wait(1)
        end

        ExecuteGeneralAction(action.id)
        Wait(2)
    end
end

--=========================== EXECUTION ==========================--

if Actions.GetActionInfo(Feint).SpellCooldown < 1 and HasTarget() then
    LogInfo(string.format("%s Executing Feint on: %s", LogPrefix, Entity.Player.Target.Name))

    ExecuteAction(CharacterAction.Actions.feint)
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

Echo(string.format("Script execution completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Script execution completed successfully..!!", LogPrefix))

--============================== END =============================--