--[[

***********************************************
*          Dungeon Farm for Minions           *
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
        Name = "The Grand Cosmos",
        dutyId = 884,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 28626
    },
    {
        Name = "Anamnesis Anyder",
        dutyId = 898,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 30096
    },
    {
        Name = "Paglth'an",
        dutyId = 938,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 33693
    },
    {
        Name = "Matoya's Relict",
        dutyId = 933,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 32856
    },
    {
        Name = "The Antitower",
        dutyId = 1111,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 14099
    },
    {
        Name = "Dohn Mheg",
        dutyId = 821,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 26801
    },
    {
        Name = "The Heroes' Gauntlet",
        dutyId = 916,
        dutyMode = "Regular",
        dutyUnsynced = "true",
        minionId = 30872
    }
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [Minion Farmer] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [Minion Farmer] Stopping the script..!!")
        yield("/snd stop")
    end
end

-------------------------------- Execution --------------------------------

Plugins()
for _, minions in ipairs(Dungeons) do
    RunCount = 1
    while GetItemCount(minions.minionId) < 1 do
        yield("/echo [Minion Farmer] [Run: "..RunCount.."] DutyMode: "..minions.dutyMode.." - "..minions.Name)
        yield("/ad cfg Unsynced "..minions.dutyUnsynced)
        yield("/ad run "..minions.dutyMode.." "..minions.dutyId.." 1 true")
        yield("/bmrai on")
        yield("/rotation auto")
        yield("/wait 10")
        while GetCharacterCondition(CharacterCondition.boundByDuty) or GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.boundByDuty56) do -- wait for duty to be finished
            yield("/wait 1")
        end
        RunCount = RunCount + 1
    end
    yield("/echo [Minion Farmer] "..minions.Name.." is done.")
end

----------------------------------- End -----------------------------------