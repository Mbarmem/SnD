--[[

***********************************************
*              Alexandrite Farm               *
*         Script for ARR Relic Farm           *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  2.0.1  *
            **********************

]]

---------------------------------- Import ---------------------------------

require("MoLib")

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

local Alexandrite     = 0
local Desired_count   = 75
local EchoPrefix      = "[Alexandrite] "

--------------------------------- Constant --------------------------------

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    mounted   = 4,
    inCombat  = 26
}

-------------------------------- Functions --------------------------------

-- Main routine: obtains maps, deciphers, travels, digs, fights, and loots.
function Main()
    LogInfo(string.format("%sStarting cycle. Alexandrite so far: %s", EchoPrefix, Alexandrite))

    -- Acquire Mysterious Map if none in inventory
    if Inventory.GetItemCount(7884) < 1 then
        LogInfo(string.format("%sNo map found, teleporting to Revenant's Toll.", EchoPrefix))
        Teleport("Revenant's Toll")

        LogInfo(string.format("%sTraveling to Auriana to purchase map.", EchoPrefix))
        MoveTo(63.3, 31.15, -736.3)
        WaitForNavMesh()
        yield("/ac Sprint")
        WaitForPathRunning()
        PlayerTest()

        Target("Auriana")
        yield("/interact")
        Wait(1)
        repeat

            if IsAddonReady("SelectIconString") then
                yield("/callback SelectIconString true 5")
            end

            if IsAddonReady("Talk") then
                yield("/callback Talk true 0")
            end

            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end

            Wait(1)
        until IsPlayerAvailable()
    end

    -- Decipher the map
    LogInfo(string.format("%sDeciphering the map.", EchoPrefix))
    yield("/ac Decipher")
    WaitForAddon("SelectIconString")
    yield("/callback SelectIconString true 0")
    Wait(1)

    WaitForAddon("SelectYesno")
    yield("/callback SelectYesno true 0")
    Wait(4)

    -- Open treasure map
    repeat
        yield("/tmap")
    until IsAddonReady("AreaMap")
    PlayerTest()

    -- Travel to flagged zone
    TeleportFlagZone()

    -- Mount up and fly to flag
    if not GetCharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "mount roulette"')
    end
    WaitForNavMesh()

    yield("/vnav flyflag")
    Wait(3)
    WaitForPathRunning()

    -- Dig at flag and approach chest
    LogInfo(string.format("%sDigging at flag.", EchoPrefix))
    yield("/generalaction Dig")
    Wait(5)
    PlayerTest()

    Target("Treasure Coffer")
    yield("/vnav flytarget")
    WaitForPathRunning()

    -- Dismount and open chest
    yield("/ac dismount")
    Wait(2)
    yield("/interact")
    WaitForAddon("SelectYesno")
    yield("/callback SelectYesno true 0")

    -- Fight if necessary
    repeat
        yield("/rotation auto")
        Wait(1)
    until not GetCharacterCondition(CharacterCondition.inCombat)
    yield("/rotation off")

    -- Loot
    Target("Treasure Coffer")
    yield("/interact")
    Wait(1)
    if GetCharacterCondition(CharacterCondition.inCombat) then
        repeat
            yield("/rotation auto")
            Wait(1)
        until not GetCharacterCondition(CharacterCondition.inCombat)
        yield("/rotation off")
    end

    LogInfo(string.format("%sCycle completed.", EchoPrefix))
end

-------------------------------- Execution --------------------------------

while Alexandrite < Desired_count do
    Main()
    Alexandrite = Alexandrite + 5
    Echo(string.format("Alexandrite Count: %d / %d", Alexandrite, Desired_count), EchoPrefix)
end

Echo(string.format("Farming complete! Total Alexandrite: %d", Alexandrite), EchoPrefix)

----------------------------------- End -----------------------------------