--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Crescent - Script for Supporting Gold Farm on Ninja
plugin_dependencies:
- BossModReborn
- RotationSolver
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

LogPrefix = "[GoldNinja]"

--============================ CONSTANT ==========================--

------------------
--    Action    --
------------------

Action = {
    [1] = { id = CharacterAction.Actions.dokumori,                name = "Dokumori"           },
    [2] = { id = CharacterAction.GeneralActions.phantomActionI,   name = "Phantom Action I"   },
    [3] = { id = CharacterAction.GeneralActions.phantomActionII,  name = "Phantom Action II"  },
    [4] = { id = CharacterAction.GeneralActions.phantomActionIII, name = "Phantom Action III" }
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

        if i == 1 then
            ExecuteAction(action.id)
        else
            ExecuteGeneralAction(action.id)
        end

        Wait(2)
    end
end


--=========================== EXECUTION ==========================--

TryExecute()

if IsInCombat() then
    LogInfo(string.format("%s Starting RSR Rotation and BMR-AI.", LogPrefix))

    yield("/rotation auto HighHP")
    yield("/bmrai on")

    WaitForCondition("InCombat", false)

    LogInfo(string.format("%s Stopping RSR Rotation and BMR-AI.", LogPrefix))
end

yield("/rotation off")
yield("/bmrai off")

Echo(string.format("Script execution completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Script execution completed successfully..!!", LogPrefix))

--============================== END =============================--