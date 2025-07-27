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

---------------------
--    Condition    --
---------------------

Actions = {
    [1] = '"Dokumori"',
    [2] = '"Phantom Action I"',
    [3] = '"Phantom Action II"',
    [4] = '"Phantom Action III"'
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function TryExecute()
    for i = 1, 4 do
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

TryExecute()

if IsInCombat() then
    LogInfo(string.format("%s Starting RSR Rotation and BMR-AI.", LogPrefix))

    yield("/rotation auto HighHP")
    yield("/bmrai on")

    repeat
        Wait(1)
    until not IsInCombat()

    LogInfo(string.format("%s Stopping RSR Rotation and BMR-AI.", LogPrefix))
end

yield("/rotation off")
yield("/bmrai off")

LogInfo(string.format("%s Script execution completed successfully..!!", LogPrefix))

--============================== END =============================--