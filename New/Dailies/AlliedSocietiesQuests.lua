--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Allied Societies Quests - Script for Dailies
plugin_dependencies:
- Questionable
- RotationSolver
- Artisan
- vnavmesh
- Lifestream
- TeleporterPlugin
- TextAdvance
dependencies:
- source: ''
  name: SnD
  type: git
configs:
  FirstAlliedSociety:
    description: The first allied society from which to accept quests.
    type: string
    required: true
  FirstClass:
    description: Class to assign for first allied society.
    type: string
    required: true
  SecondAlliedSociety:
    description: The second allied society from which to accept quests.
    type: string
  SecondClass:
    description: Class to assign for second allied society.
    type: string
  ThirdAlliedSociety:
    description: The third allied society from which to accept quests.
    type: string
  ThirdClass:
    description: Class to assign for third allied society.
    type: string
  FourthAlliedSociety:
    description: The fourth allied society from which to accept quests.
    type: string
  FourthClass:
    description: Class to assign for fourth allied society.
    type: string

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

EchoPrefix  = "[AlliedQuests]"

ToDoList = {
    { alliedSocietyName = Config.Get("FirstAlliedSociety"), class = Config.Get("FirstClass") },
    { alliedSocietyName = Config.Get("SecondAlliedSociety"), class = Config.Get("SecondClass") },
    { alliedSocietyName = Config.Get("ThirdAlliedSociety"), class = Config.Get("ThirdClass") },
    { alliedSocietyName = Config.Get("FourthAlliedSociety"), class = Config.Get("FourthClass") }
}

--============================ CONSTANT ==========================--

-----------------------
--    Allied Data    --
-----------------------

AlliedSocietiesTable = {
    amaljaa = {
        alliedSocietyName = "Amalj'aa",
        questGiver        = "Fibubb Gah",
        x                 = 103.12,
        y                 = 15.05,
        z                 = -359.51,
        zoneId            = 146,
        aetheryteName     = "Little Ala Mhigo"
    },
    sylphs = {
        alliedSocietyName = "Sylphs",
        questGiver        = "Tonaxia",
        x                 = 46.41,
        y                 = 6.07,
        z                 = 252.91,
        zoneId            = 152,
        aetheryteName     = "The Hawthorne Hut"
    },
    kobolds = {
        alliedSocietyName = "Kobolds",
        questGiver        = "789th Order Dustman Bo Bu",
        x                 = 12.857726,
        y                 = 16.164295,
        z                 = -178.77,
        zoneId            = 180,
        aetheryteName     = "Camp Overlook"
    },
    sahagin = {
        alliedSocietyName = "Sahagin",
        questGiver        = "Houu",
        x                 = -244.53,
        y                 = -41.46,
        z                 = 52.75,
        zoneId            = 138,
        aetheryteName     = "Aleport"
    },
    ixal = {
        alliedSocietyName = "Ixal",
        questGiver        = "Ehcatl Nine Manciple",
        x                 = 173.21,
        y                 = -5.37,
        z                 = 81.85,
        zoneId            = 154,
        aetheryteName     = "Fallgourd Float"
    },
    vanuvanu = {
        alliedSocietyName = "Vanu Vanu",
        questGiver        = "Muna Vanu",
        x                 = -796.3722,
        y                 = -133.27,
        z                 = -404.35,
        zoneId            = 401,
        aetheryteName     = "Ok' Zundu"
    },
    vath = {
        alliedSocietyName = "Vath",
        questGiver        = "Vath Keeneye",
        x                 = 58.80,
        y                 = -48.00,
        z                 = -171.64,
        zoneId            = 398,
        aetheryteName     = "Tailfeather",
        preset            = "qst:v1:MjI1NTsyMjU2OzIyNTc7MjI1ODsyMjYwOzIyNjE7MjI2MjsyMjYzOzIyNjQ7MjI2NTsyMjY2OzIyNjc7MjI2ODsyMjY5OzIyNzA7MjI3MTsyMjcyOzIyNzM7MjI3NDsyMjc1OzIyNzY7MjI3NzsyMjc4OzIyNzk7MjI4MA=="
    },
    moogles = {
        alliedSocietyName = "Moogles",
        questGiver        = "Mogek the Marvelous",
        x                 = -335.28,
        y                 = 58.94,
        z                 = 316.30,
        zoneId            = 400,
        aetheryteName     = "Zenith"
    },
    kojin = {
        alliedSocietyName = "Kojin",
        questGiver        = "Zukin",
        x                 = 391.22,
        y                 = -119.59,
        z                 = -234.92,
        zoneId            = 613,
        aetheryteName     = "Tamamizu"
    },
    ananta = {
        alliedSocietyName = "Ananta",
        questGiver        = "Eshana",
        x                 = -26.91,
        y                 = 56.12,
        z                 = 233.53,
        zoneId            = 612,
        aetheryteName     = "The Peering Stones"
    },
    namazu = {
        alliedSocietyName = "Namazu",
        questGiver        = "Seigetsu the Enlightened",
        x                 = -777.72,
        y                 = 127.81,
        z                 = 98.76,
        zoneId            = 622,
        aetheryteName     = "Dhoro Iloh"
    },
    pixies = {
        alliedSocietyName = "Pixies",
        questGiver        = "Uin Nee",
        x                 = -453.69,
        y                 = 71.21,
        z                 = 573.54,
        zoneId            = 816,
        aetheryteName     = "Lydha Lran"
    },
    qitari = {
        alliedSocietyName = "Qitari",
        questGiver        = "Qhoterl Pasol",
        x                 = 786.83,
        y                 = -45.82,
        z                 = -214.51,
        zoneId            = 817,
        aetheryteName     = "Fanow"
    },
    dwarves = {
        alliedSocietyName = "Dwarves",
        questGiver        = "Regitt",
        x                 = -615.48,
        y                 = 65.60,
        z                 = -423.82,
        zoneId            = 813,
        aetheryteName     = "The Ostall Imperative"
    },
    arkosodara = {
        alliedSocietyName = "Arkasodara",
        questGiver        = "Maru",
        x                 = -68.21,
        y                 = 39.99,
        z                 = 323.31,
        zoneId            = 957,
        aetheryteName     = "Yedlihmad"
    },
    loporrits = {
        alliedSocietyName = "Loporrits",
        questGiver        = "Managingway",
        x                 = -201.27,
        y                 = -49.15,
        z                 = -273.80,
        zoneId            = 959,
        aetheryteName     = "Bestways Burrow"
    },
    omicrons = {
        alliedSocietyName = "Omicrons",
        questGiver        = "Stigma-4",
        x                 = 315.84,
        y                 = 481.99,
        z                 = 152.08,
        zoneId            = 960,
        aetheryteName     = "Base Omicron"
    },
    pelupleu = {
        alliedSocietyName = "Pelupelu",
        questGiver        = "Yubli",
        x                 = 770.89954,
        y                 = 12.846571,
        z                 = -261.0889,
        zoneId            = 1188,
        aetheryteName     = "Dock Poga"
    },
    mamoolja = {
        alliedSocietyName = "MamoolJa",
        questGiver        = "Kageel Ja",
        x                 = 589.3,
        y                 = -142.9,
        z                 = 730.5,
        zoneId            = 1189,
        aetheryteName     = "Mamook"
    }
}

--=========================== FUNCTIONS ==========================--

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
        local questId = allAcceptedQuests[i]
        local row = Excel.GetRow("Quest", questId)

        if row and row.BeastTribe and row.BeastTribe.Name:lower() == alliedSocietyName:lower() then
            table.insert(accepted, questId)
        end
    end

    return accepted
end

function CheckAllowances()
    if not IsAddonReady("ContentsInfo") then
        yield("/timers")
        Wait(3)
    end

    local timerName = GetNodeText("ContentsInfo", 1, 4, 41009, 6, 8)
    local timerConv = tonumber(timerName:match("%d+$"))
    Wait(1)

    if timerConv then
        CloseAddons()
        return timerConv
    end

    CloseAddons()
    return 0
end

--=========================== EXECUTION ==========================--

yield("/at y")

for _, alliedSociety in ipairs(ToDoList) do
    local remainingAllowances = CheckAllowances()
    LogInfo(string.format("%s Remaining daily quest allowances: %d", EchoPrefix, remainingAllowances))

    if remainingAllowances <= 0 then
        LogInfo(string.format("%s No allowances left. Stopping script.", EchoPrefix))
        return
    end

    local alliedSocietyTable = GetAlliedSocietyTable(alliedSociety.alliedSocietyName)
    if alliedSocietyTable then
        WaitForPlayer()

        if not IsInZone(alliedSocietyTable.zoneId) then
            Teleport(alliedSocietyTable.aetheryteName)
        end

        if not IsMounted() then
            UseMount()
        end

        repeat
            Wait(1)
        until IsMounted()

        MoveTo(alliedSocietyTable.x, alliedSocietyTable.y, alliedSocietyTable.z, 2, true)
        WaitForPathRunning()

        yield("/gs change " .. alliedSociety.class)
        Wait(3)

        -- accept 3 allocations
        for i=1,3 do
            Interact(alliedSocietyTable.questGiver)
            WaitForAddon("SelectIconString")
            yield("/callback SelectIconString true 0")
            WaitForPlayer()
        end

        yield("/qst start")
        repeat
            Wait(10)
        until #GetAcceptedAlliedSocietyQuests(alliedSociety.alliedSocietyName) == 0
        yield("/qst stop")
    else
        LogInfo(string.format("%s Allied society '%s' not found in data table.", EchoPrefix, alliedSociety.alliedSocietyName))
    end
end

LogInfo(string.format("%s Daily quest script completed successfully.", EchoPrefix))

--============================== END =============================--