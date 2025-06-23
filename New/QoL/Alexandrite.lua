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

local Alexandrite     = 0
local Desired_count   = 75
local EchoPrefix      = "[Alexandrite] "

--------------------------------- Constants --------------------------------

CharacterCondition = {
    mounted   = 4,
    inCombat  = 26
}

-------------------------------- Functions --------------------------------

-- Main routine: obtains maps, deciphers, travels, digs, fights, and loots.
function Main()
    LogInfo(EchoPrefix .. "Starting cycle. Alexandrite so far: " .. Alexandrite)

    -- Acquire Mysterious Map if none in inventory
    if Inventory.GetItemCount(7884) < 1 then
        LogInfo(EchoPrefix .. "No map found, teleporting to Revenant's Toll.")
        Teleport("Revenant's Toll")

        LogInfo(EchoPrefix .. "Traveling to Auriana to purchase map.")
        MoveTo(63.3, 31.15, -736.3)
        WaitForNavMesh()
        yield("/ac Sprint")
        WaitForPathRunning()
        PlayerTest()

        Target("Auriana")
        yield("/interact")
        WaitForAddon("SelectIconString")
        yield("/callback SelectIconString true 5")

        WaitForAddon("Talk")
        yield("/callback Talk true 0")
        Wait(1)

        WaitForAddon("SelectYesno")
        yield("/callback SelectYesno true 0")

        WaitForAddon("Talk")
        yield("/callback Talk true 0")
        Wait(1)
    end

    -- Decipher the map
    LogInfo(EchoPrefix .. "Deciphering the map.")
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
    local flagZone = GetFlagZone()
    if not IsInZone(flagZone) then
        local aeth = GetAetheryteName(GetAetherytesInZone(flagZone)[0])
        LogInfo(EchoPrefix .. "Teleporting to map zone: " .. tostring(aeth))
        Teleport(aeth)
        PlayerTest()
    end

    -- Mount up and fly to flag
    if not CharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "mount roulette"')
    end
    WaitForNavMesh()

    yield("/vnav flyflag")
    Wait(3)
    WaitForPathRunning()

    -- Dig at flag and approach chest
    LogInfo(EchoPrefix .. "Digging at flag.")
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

    LogInfo(EchoPrefix .. "Cycle completed.")
end

-------------------------------- Execution --------------------------------

while Alexandrite < Desired_count do
    Main()
    Alexandrite = Alexandrite + 5
    Echo(string.format("Alexandrite Count: %d / %d", Alexandrite, Desired_count), EchoPrefix)
end

Echo(string.format("Farming complete! Total Alexandrite: %d", Alexandrite), EchoPrefix)

----------------------------------- End -----------------------------------