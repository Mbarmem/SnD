--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Allied Societies Quests - Script for Dailies
plugin_dependencies:
- Artisan
- Lifestream
- Questionable
- RotationSolver
- TextAdvance
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  ManualQuestPickup:
    default: false
    description: If selected, accept quests Manually from the quest giver; otherwise Questionable handles quest acceptance.
  FirstAlliedSociety:
    description: The first allied society from which to accept quests.
    is_choice: true
    choices:
        - "None"
        - "Yok Huy"
        - "Mamool Ja"
        - "Pelupelu"
        - "Omicrons"
        - "Loporrits"
        - "Arkasodara"
        - "Dwarves"
        - "Qitari"
        - "Pixies"
        - "Namazu"
        - "Ananta"
        - "Kojin"
        - "Moogles"
        - "Vath"
        - "Vanu Vanu"
        - "Ixal"
        - "Sahagin"
        - "Kobolds"
        - "Sylphs"
        - "Amalj'aa"
  FirstClass:
    description: Class to assign for first allied society.
    is_choice: true
    choices:
        - "None"
        - "Viper"
        - "Weaver"
        - "Botanist"
  SecondAlliedSociety:
    description: The second allied society from which to accept quests.
    is_choice: true
    choices:
        - "None"
        - "Yok Huy"
        - "Mamool Ja"
        - "Pelupelu"
        - "Omicrons"
        - "Loporrits"
        - "Arkasodara"
        - "Dwarves"
        - "Qitari"
        - "Pixies"
        - "Namazu"
        - "Ananta"
        - "Kojin"
        - "Moogles"
        - "Vath"
        - "Vanu Vanu"
        - "Ixal"
        - "Sahagin"
        - "Kobolds"
        - "Sylphs"
        - "Amalj'aa"
  SecondClass:
    description: Class to assign for second allied society.
    is_choice: true
    choices:
        - "None"
        - "Viper"
        - "Weaver"
        - "Botanist"
  ThirdAlliedSociety:
    description: The third allied society from which to accept quests.
    is_choice: true
    choices:
        - "None"
        - "Yok Huy"
        - "Mamool Ja"
        - "Pelupelu"
        - "Omicrons"
        - "Loporrits"
        - "Arkasodara"
        - "Dwarves"
        - "Qitari"
        - "Pixies"
        - "Namazu"
        - "Ananta"
        - "Kojin"
        - "Moogles"
        - "Vath"
        - "Vanu Vanu"
        - "Ixal"
        - "Sahagin"
        - "Kobolds"
        - "Sylphs"
        - "Amalj'aa"
  ThirdClass:
    description: Class to assign for third allied society.
    is_choice: true
    choices:
        - "None"
        - "Viper"
        - "Weaver"
        - "Botanist"
  FourthAlliedSociety:
    description: The fourth allied society from which to accept quests.
    is_choice: true
    choices:
        - "None"
        - "Yok Huy"
        - "Mamool Ja"
        - "Pelupelu"
        - "Omicrons"
        - "Loporrits"
        - "Arkasodara"
        - "Dwarves"
        - "Qitari"
        - "Pixies"
        - "Namazu"
        - "Ananta"
        - "Kojin"
        - "Moogles"
        - "Vath"
        - "Vanu Vanu"
        - "Ixal"
        - "Sahagin"
        - "Kobolds"
        - "Sylphs"
        - "Amalj'aa"
  FourthClass:
    description: Class to assign for fourth allied society.
    is_choice: true
    choices:
        - "None"
        - "Viper"
        - "Weaver"
        - "Botanist"

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

ManualQuestPickup  = Config.Get("ManualQuestPickup")
LogPrefix          = "[AlliedQuests]"

--============================ CONSTANT ==========================--

-----------------------
--    Allied Data    --
-----------------------

AlliedSocietiesTable = {
    amaljaa = {
        alliedSocietyName = "Amalj'aa",
        questGiver        = "Fibubb Gah",
        mainQuests        = { first = 1217, last = 1221 },
        dailyQuests       = { first = 1222, last = 1251, blackList = { [1245] = true } },
        x                 = 103.12,
        y                 = 15.05,
        z                 = -359.51,
        zoneId            = 146,
        aetheryteName     = "Little Ala Mhigo",
        expac             = "A Realm Reborn"
    },
    sylphs = {
        alliedSocietyName = "Sylphs",
        questGiver        = "Tonaxia",
        mainQuests        = { first = 1252, last = 1256 },
        dailyQuests       = { first = 1257, last = 1286 },
        x                 = 46.41,
        y                 = 6.07,
        z                 = 252.91,
        zoneId            = 152,
        aetheryteName     = "The Hawthorne Hut",
        expac             = "A Realm Reborn"
    },
    kobolds = {
        alliedSocietyName = "Kobolds",
        questGiver        = "789th Order Dustman Bo Bu",
        mainQuests        = { first = 1320, last = 1324 },
        dailyQuests       = { first = 1325, last = 1373 },
        x                 = 12.857726,
        y                 = 16.164295,
        z                 = -178.77,
        zoneId            = 180,
        aetheryteName     = "Camp Overlook",
        expac             = "A Realm Reborn"
    },
    sahagin = {
        alliedSocietyName = "Sahagin",
        questGiver        = "Houu",
        mainQuests        = { first = 1374, last = 1378 },
        dailyQuests       = { first = 1380, last = 1409 },
        x                 = -244.53,
        y                 = -41.46,
        z                 = 52.75,
        zoneId            = 138,
        aetheryteName     = "Aleport",
        expac             = "A Realm Reborn"
    },
    ixal = {
        alliedSocietyName = "Ixal",
        questGiver        = "Ehcatl Nine Manciple",
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1494, last = 1568 },
        x                 = 173.21,
        y                 = -5.37,
        z                 = 81.85,
        zoneId            = 154,
        aetheryteName     = "Fallgourd Float",
        expac             = "A Realm Reborn"
    },
    vanuvanu = {
        alliedSocietyName = "Vanu Vanu",
        questGiver        = "Muna Vanu",
        mainQuests        = { first = 2164, last = 2225 },
        dailyQuests       = { first = 2171, last = 2200 },
        x                 = -796.3722,
        y                 = -133.27,
        z                 = -404.35,
        zoneId            = 401,
        aetheryteName     = "Ok' Zundu",
        expac             = "Heavensward"
    },
    vath = {
        alliedSocietyName = "Vath",
        questGiver        = "Vath Keeneye",
        mainQuests        = { first = 2164, last = 2225 },
        dailyQuests       = { first = 2171, last = 2200 },
        x                 = 58.80,
        y                 = -48.00,
        z                 = -171.64,
        zoneId            = 398,
        aetheryteName     = "Tailfeather",
        expac             = "Heavensward"
    },
    moogles = {
        alliedSocietyName = "Moogles",
        questGiver        = "Mogek the Marvelous",
        mainQuests        = { first = 2320, last = 2327 },
        dailyQuests       = { first = 2290, last = 2319 },
        x                 = -335.28,
        y                 = 58.94,
        z                 = 316.30,
        zoneId            = 400,
        aetheryteName     = "Zenith",
        expac             = "Heavensward"
    },
    kojin = {
        alliedSocietyName = "Kojin",
        questGiver        = "Zukin",
        mainQuests        = { first = 2973, last = 2978 },
        dailyQuests       = { first = 2979, last = 3002 },
        x                 = 391.22,
        y                 = -119.59,
        z                 = -234.92,
        zoneId            = 613,
        aetheryteName     = "Tamamizu",
        expac             = "Stormblood"
    },
    ananta = {
        alliedSocietyName = "Ananta",
        questGiver        = "Eshana",
        mainQuests        = { first = 3036, last = 3041 },
        dailyQuests       = { first = 3043, last = 3069 },
        x                 = -26.91,
        y                 = 56.12,
        z                 = 233.53,
        zoneId            = 612,
        aetheryteName     = "The Peering Stones",
        expac             = "Stormblood"
    },
    namazu = {
        alliedSocietyName = "Namazu",
        questGiver        = "Seigetsu the Enlightened",
        mainQuests        = { first = 3096, last = 3102 },
        dailyQuests       = { first = 3103, last = 3129 },
        x                 = -777.72,
        y                 = 127.81,
        z                 = 98.76,
        zoneId            = 622,
        aetheryteName     = "Dhoro Iloh",
        expac             = "Stormblood"
    },
    pixies = {
        alliedSocietyName = "Pixies",
        questGiver        = "Uin Nee",
        mainQuests        = { first = 3683, last = 3688 },
        dailyQuests       = { first = 3689, last = 3716 },
        x                 = -453.69,
        y                 = 71.21,
        z                 = 573.54,
        zoneId            = 816,
        aetheryteName     = "Lydha Lran",
        expac             = "Shadowbringers"
    },
    qitari = {
        alliedSocietyName = "Qitari",
        questGiver        = "Qhoterl Pasol",
        mainQuests        = { first = 3794, last = 3805 },
        dailyQuests       = { first = 3806, last = 3833 },
        x                 = 786.83,
        y                 = -45.82,
        z                 = -214.51,
        zoneId            = 817,
        aetheryteName     = "Fanow",
        expac             = "Shadowbringers"
    },
    dwarves = {
        alliedSocietyName = "Dwarves",
        questGiver        = "Regitt",
        mainQuests        = { first = 3896, last = 3901 },
        dailyQuests       = { first = 3902, last = 3929 },
        x                 = -615.48,
        y                 = 65.60,
        z                 = -423.82,
        zoneId            = 813,
        aetheryteName     = "The Ostall Imperative",
        expac             = "Shadowbringers"
    },
    arkosodara = {
        alliedSocietyName = "Arkasodara",
        questGiver        = "Maru",
        mainQuests        = { first = 4545, last = 4550 },
        dailyQuests       = { first = 4551, last = 4578 },
        x                 = -68.21,
        y                 = 39.99,
        z                 = 323.31,
        zoneId            = 957,
        aetheryteName     = "Yedlihmad",
        expac             = "Endwalker"
    },
    loporrits = {
        alliedSocietyName = "Loporrits",
        questGiver        = "Managingway",
        mainQuests        = { first = 4681, last = 4686 },
        dailyQuests       = { first = 4687, last = 4714 },
        x                 = -201.27,
        y                 = -49.15,
        z                 = -273.8,
        zoneId            = 959,
        aetheryteName     = "Bestways Burrow",
        expac             = "Endwalker"
    },
    omicrons = {
        alliedSocietyName = "Omicrons",
        questGiver        = "Stigma-4",
        mainQuests        = { first = 4601, last = 4606 },
        dailyQuests       = { first = 4607, last = 4634 },
        x                 = 315.84,
        y                 = 481.99,
        z                 = 152.08,
        zoneId            = 960,
        aetheryteName     = "Base Omicron",
        expac             = "Endwalker"
    },
    pelupleu = {
        alliedSocietyName = "Pelupelu",
        questGiver        = "Yubli",
        mainQuests        = { first = 5193, last = 5198 },
        dailyQuests       = { first = 5199, last = 5226 },
        x                 = 770.89954,
        y                 = 12.846571,
        z                 = -261.0889,
        zoneId            = 1188,
        aetheryteName     = "Dock Poga",
        expac             = "Dawntrail"
    },
    mamoolja = {
        alliedSocietyName = "Mamool Ja",
        questGiver        = "Kageel Ja",
        mainQuests        = { first = 5255, last = 5260 },
        dailyQuests       = { first = 5261, last = 5288 },
        x                 = 589.3,
        y                 = -142.9,
        z                 = 730.5,
        zoneId            = 1189,
        aetheryteName     = "Mamook",
        expac             = "Dawntrail"
    },
    yokhuy = {
        alliedSocietyName = "Yok Huy",
        questGiver        = "Vuyargur",
        mainQuests        = { first = 0, last = 0 },
        dailyQuests       = { first = 0, last = 0 },
        x                 = 495.40,
        y                 = 142.24,
        z                 = 784.53,
        zoneId            = 1187,
        aetheryteName     = "Worlar's Echo",
        expac             = "Dawntrail"
    }
}

--=========================== FUNCTIONS ==========================--

-----------------------
--    Allied Data    --
-----------------------

ToDoList = {}

local societyConfigKeys = {
    { societyKey = "FirstAlliedSociety",  classKey = "FirstClass"  },
    { societyKey = "SecondAlliedSociety", classKey = "SecondClass" },
    { societyKey = "ThirdAlliedSociety",  classKey = "ThirdClass"  },
    { societyKey = "FourthAlliedSociety", classKey = "FourthClass" }
}

for _, entry in ipairs(societyConfigKeys) do
    local society = Config.Get(entry.societyKey)
    local class   = Config.Get(entry.classKey)

    if society and class and society ~= "None" and class ~= "None" then
        table.insert(ToDoList, { alliedSocietyName = society, class = class })
    end
end

----------------
--    Main    --
----------------

function GetAlliedSocietyTable(alliedSocietyName)
    for _, alliedSociety in pairs(AlliedSocietiesTable) do
        if alliedSociety.alliedSocietyName == alliedSocietyName then
            return alliedSociety
        end
    end
end

function GetAcceptedAlliedSocietyQuests(alliedSocietyName)
    local accepted = {}
    local allAcceptedQuests = Quests.GetAcceptedQuests()
    local count = allAcceptedQuests.Count - 1

    for i = 1, count do
        local allAcceptedQuestId = allAcceptedQuests[i]
        local row = Excel.GetRow("Quest", allAcceptedQuestId)

        if row and row.BeastTribe and row.BeastTribe.Name:lower() == alliedSocietyName:lower() then
            table.insert(accepted, allAcceptedQuestId)
        end
    end

    return accepted
end

function CheckAllowances()
    if not IsAddonReady("ContentsInfo") then
        Execute("/timers")
        Wait(3)
    end

    local timerName = GetNodeText("ContentsInfo", 1, 4, 41009, 6, 8) or 0
    local timerConv = tonumber(timerName:match("%d+$"))
    Wait(1)
    CloseAddons()

    if timerConv then
        return timerConv
    end

    return 0
end

--=========================== EXECUTION ==========================--

Execute("/at y")

for _, alliedSociety in ipairs(ToDoList) do
    local remainingAllowances = CheckAllowances()
    LogInfo(string.format("%s Remaining daily quest allowances: %d", LogPrefix, remainingAllowances))

    if remainingAllowances <= 0 then
        LogInfo(string.format("%s No allowances left. Stopping script.", LogPrefix))
        return
    end

    local alliedSocietyTable = GetAlliedSocietyTable(alliedSociety.alliedSocietyName)
    if alliedSocietyTable then
        WaitForPlayer()

        if not IsInZone(alliedSocietyTable.zoneId) then
            Teleport(alliedSocietyTable.aetheryteName)
        end

        Mount()
        WaitForCondition("Mounted", true)

        MoveTo(alliedSocietyTable.x, alliedSocietyTable.y, alliedSocietyTable.z, 2, true)

        Execute(string.format("/gs change %s", alliedSociety.class))
        Wait(3)

        if ManualQuestPickup then
            for i = 1, 3 do
                Target(alliedSocietyTable.questGiver)
                Interact(alliedSocietyTable.questGiver)

                repeat
                    Wait(1)
                until IsAddonReady("SelectIconString")
                Execute("/callback SelectIconString true 0")

                repeat
                    Wait(0.1)
                until IsPlayerAvailable()
                LogInfo(string.format("%s Accepted %d/3 quest(s) via quest giver.", LogPrefix, i))
            end
        else
            local timeout = os.time()
            local quests = {}
            local blackList = alliedSocietyTable.dailyQuests.blackList or {}

            for questId = alliedSocietyTable.dailyQuests.first, alliedSocietyTable.dailyQuests.last do
                if not QuestionableIsQuestLocked(tostring(questId)) and not blackList[questId] then
                    table.insert(quests, questId)
                    QuestionableClearQuestPriority()
                    QuestionableAddQuestPriority(tostring(questId))

                    repeat
                        if not QuestionableIsRunning() then
                            Execute("/qst start")
                        elseif os.time() - timeout > 15 then
                            LogInfo(string.format("%s Took more than 15 seconds to pick up the quest. Reloading...", LogPrefix))
                            Execute("/qst reload")
                            timeout = os.time()
                        end
                        Wait(0.1)
                    until Quests.IsQuestAccepted(questId)

                    timeout = os.time()
                    Execute("/qst stop")
                end
            end

            for _, questId in ipairs(quests) do
                QuestionableAddQuestPriority(tostring(questId))
            end
        end

        repeat
            if not QuestionableIsRunning() then
                Execute("/qst start")
            end
            Wait(2)
        until #GetAcceptedAlliedSocietyQuests(alliedSociety.alliedSocietyName) == 0

        Execute("/qst stop")
    else
        LogInfo(string.format("%s Allied society '%s' not found in data table.", LogPrefix, alliedSociety.alliedSocietyName))
    end
end

Echo(string.format("Daily Allied Quests script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Daily Allied Quests script completed successfully..!!", LogPrefix))

--============================== END =============================--