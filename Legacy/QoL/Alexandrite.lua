-- Script by Allison

-- Need VNavmesh
-- Need GlobeTrotter
-- Need RotationSolverReborn
-- Input alexandrite you already have and how much you want below.
-- Lvl 100 recommended (only tested on this)
-- Don't leave unattended, not 100% tested.
-- Start w/ no maps (opened or item form) in inventory. This includes other types of maps. 

Alexandrite = 0
desired_count = 75


CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupied31=31,
    occupied=33,
    boundByDuty34=34,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    mounting57=57,
    mounting64=64,
    beingmoved70=70,
    beingmoved75=75,
    flying=77
}

function PlayerTest()
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

function teleport(location)
    yield("/tp " .. location)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    PlayerTest()
end

function main()
    if GetItemCount(7884) < 1 then
        -- Go to Revanant's Toll
        teleport("Revenant's Toll")

        -- Go to Auriana
        yield("/vnav moveto 63.3 31.15 -736.3")
        repeat 
            yield("/wait 1")
        until NavIsReady()
        yield("/ac Sprint")
        repeat
            yield("/wait 1")
        until not PathIsRunning()
        PlayerTest()

        -- Target and Interact with Auriana
        yield("/target Auriana")
        yield("/interact")
        yield("/wait 1")
    
        -- Select Mysterious Map Exchange
        repeat
            yield("/wait 1") 
        until IsAddonReady("SelectIconString")
        yield("/callback SelectIconString true 5")

        -- Really gross hard coding for buying a map, fails if one is already in inventory
        repeat
            yield("/wait 1")
        until IsAddonReady("Talk")
        yield("/callback Talk true 0")
        yield("/wait 1")

        repeat
            yield("/wait 1") 
        until IsAddonReady("SelectYesno")
        yield("/callback SelectYesno true 0")

        repeat
            yield("/wait 1")
        until IsAddonReady("Talk")
        yield("/callback Talk true 0")
        yield("/wait 1")
    end

    -- Decipher
    yield("/ac Decipher")
    repeat
        yield("/wait 1")
    until IsAddonReady("SelectIconString")
    yield("/callback SelectIconString true 0")
    yield("/wait 1")

    repeat 
        yield("/wait 1")
    until IsAddonVisible("SelectYesno")
    yield("/callback SelectYesno true 0")
    yield("/wait 4")

    -- Use GlobeTrotter
    repeat
        yield("/tmap")
    until IsAddonVisible("AreaMap")
    PlayerTest()

    -- Go to map location
    if not IsInZone(GetFlagZone()) then
        teleport(GetAetheryteName(GetAetherytesInZone(GetFlagZone())[0]))
        PlayerTest()
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "mount roulette"')
    end
    repeat 
        yield("/wait 1")
    until NavIsReady()

    yield("/vnav flyflag")
    yield("/wait 3")
    repeat
        yield("/wait 1")
    until not PathIsRunning()

    -- At flag, dig here, and get closer to chest.
    yield("/generalaction Dig")
    yield("/wait 5")
    PlayerTest()
    yield("/target Treasure Coffer")
    yield("/vnav flytarget")
    repeat
        yield("/wait 1")
    until not PathIsRunning()

    -- Dismount and interact w/ chest
    yield("/ac dismount")
    yield("/wait 2")
    yield("/interact")

    repeat
        yield("/wait 1")
    until IsAddonVisible("SelectYesno")
    yield("/callback SelectYesno true 0")

    -- Combat w/ RSR
    repeat
        yield("/rotation auto")
        yield("/wait 1")
    until not GetCharacterCondition(CharacterCondition.inCombat)
    yield("/rotation off")

    -- Get Chest loot
    yield("/target Treasure Coffer")
    yield("/interact")

    -- Wait 1 second to check for combat again before leaving.
    yield("/wait 1")
    if GetCharacterCondition(CharacterCondition.inCombat) then
        repeat
            yield("/rotation auto")
            yield("/wait 1")
        until not GetCharacterCondition(CharacterCondition.inCombat)
    end
    yield("/rotation off")
end

while Alexandrite < desired_count do
    main()
    Alexandrite = Alexandrite + 5
    yield("/echo Alexandrite Count: " .. Alexandrite)
end