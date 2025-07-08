--[[

***********************************************
*               Crescent Occult               *
*             Script for AR Macro             *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

]]

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "RotationSolver"
}

HasAR = HasPlugin("RotationSolver")

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    inCombat=26,
    casting=27,
    boundByDuty=34,
    occupied=39,
    betweenAreas=45
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [ARMacro] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [ARMacro] Stopping the script..!!")
        yield("/snd stop")
    end
end

function StanceOff()
    if HasStatus("Defiance") and IsPlayerAvailable() then
        yield("/action Defiance")
    end
end

-------------------------------- Execution --------------------------------

Plugins()
while true do
    StanceOff()
    if not GetCharacterCondition(CharacterCondition.inCombat) and HasAR then
        yield("/rotation manual")
    elseif GetCharacterCondition(CharacterCondition.inCombat) and HasAR then
        yield("/rotation auto")
        yield("/wait 30")
    else
        yield("/wait 10")
    end
end

----------------------------------- End -----------------------------------
