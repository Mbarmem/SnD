--[[

***********************************************
*          Dungeon Farm for TT Cards          *
*             A barebones script.             *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

            *********************
            *  Required Plugins *
            *********************

Plugins that are used are:
    -> AutoDuty
    -> Rotation Solver Reborn
    -> BossMod Reborn
    -> Vnavmesh
    -> Teleporter
    -> Lifestream
    -> Something Need Doing [Expanded Edition]
    -> Yes Already
    -> SkipCutscene
    -> Automaton (CBT)
    -> TextAdvance

]]

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "AutoDuty",
    "RotationSolver",
    "BossModReborn",
    "vnavmesh",
    "TeleporterPlugin",
    "Lifestream",
    "YesAlready",
    "SkipCutscene",
    "Automaton",
    "TextAdvance"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    boundByDuty=34,
    betweenAreas=51,
    boundByDuty56=56
}

--------------------
--    Dungeons    --
--------------------

Dungeons = {
    {
        Name = "Pharos Sirius (Hard)",
        dutyId = 510,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 13369
    },
    {
        Name = "The Drowned City Of Skalla",
        dutyId = 1172,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 21184
    },
    {
        Name = "The Ghimlyt Dark",
        dutyId = 1174,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 24872
    },
    {
        Name = "The Burn",
        dutyId = 1173,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 23910
    },
    {
        Name = "Saint Mocianne's Arboretum (Hard)",
        dutyId = 788,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 23909
    },
    {
        Name = "Baelsar's Wall",
        dutyId = 1114,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 17683
    },
    {
        Name = "The Fractal Continuum (Hard)",
        dutyId = 743,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 22381
    },
    {
        Name = "The Swallow's Compass",
        dutyId = 768,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        cardId = 23047
    }
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [TT Farmer] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [TT Farmer] Stopping the script..!!")
        yield("/snd stop")
    end
end

-------------------------------- Execution --------------------------------

Plugins()
for _, cards in ipairs(Dungeons) do
    RunCount = 1
    while GetItemCount(cards.cardId) < 1 do
        yield("/echo [TT Farmer] [Run: "..RunCount.."] DutyMode: "..cards.dutyMode.." - "..cards.Name)
        yield("/ad cfg Unsynced "..cards.dutyUnsynced)
        yield("/ad run "..cards.dutyMode.." "..cards.dutyId.." 1 true")
        yield("/bmrai on")
        yield("/rotation auto")
        yield("/wait 10")
        while GetCharacterCondition(CharacterCondition.boundByDuty) or GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.boundByDuty56) do -- wait for duty to be finished
            yield("/wait 1")
        end
        RunCount = RunCount + 1
    end
    yield("/echo [TT Farmer] "..cards.Name.." is done.")
end

----------------------------------- End -----------------------------------