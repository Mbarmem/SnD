--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Wondrous Tails Doer - A barebones script for weeklies
plugin_dependencies:
- AutoDuty
- BossModReborn
- Lifestream
- RotationSolver
- SkipCutscene
- TextAdvance
- vnavmesh
- YesAlready
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

CurrentLevel = Player.Job.Level
LogPrefix    = "[WondrousTails]"

Khloe        = {
    X        = -19.97,
    Y        = 211.0,
    Z        = 0.53,
    Name     = "Khloe Aliapoh"
}

--============================ CONSTANT ==========================--

----------------
--    Data    --
----------------

WonderousTailsDuties = {
    { -- type 0: extreme trials
        { instanceId = 20010, dutyId = 297,  dutyName = "The Howling Eye (Extreme)",               minLevel = 50 },
        { instanceId = 20009, dutyId = 296,  dutyName = "The Navel (Extreme)",                     minLevel = 50 },
        { instanceId = 20008, dutyId = 295,  dutyName = "The Bowl of Embers (Extreme)",            minLevel = 50 },
        { instanceId = 20012, dutyId = 364,  dutyName = "Thornmarch (Extreme)",                    minLevel = 50 },
        { instanceId = 20018, dutyId = 359,  dutyName = "The Whorleater (Extreme)",                minLevel = 50 },
        { instanceId = 20023, dutyId = 375,  dutyName = "The Striking Tree (Extreme)",             minLevel = 50 },
        { instanceId = 20025, dutyId = 378,  dutyName = "The Akh Afah Amphitheatre (Extreme)",     minLevel = 50 },
        { instanceId = 20013, dutyId = 348,  dutyName = "The Minstrel's Ballad: Ultima's Bane",    minLevel = 50 },
        { instanceId = 20034, dutyId = 447,  dutyName = "The Limitless Blue (Extreme)",            minLevel = 60 },
        { instanceId = 20032, dutyId = 446,  dutyName = "Thok ast Thok (Extreme)",                 minLevel = 60 },
        { instanceId = 20036, dutyId = 448,  dutyName = "The Minstrel's Ballad: Thordan's Reign",  minLevel = 60 },
        { instanceId = 20038, dutyId = 524,  dutyName = "Containment Bay S1T7 (Extreme)",          minLevel = 60 },
        { instanceId = 20040, dutyId = 566,  dutyName = "The Minstrel's Ballad: Nidhogg's Rage",   minLevel = 60 },
        { instanceId = 20042, dutyId = 577,  dutyName = "Containment Bay P1T6 (Extreme)",          minLevel = 60 },
        { instanceId = 20044, dutyId = 638,  dutyName = "Containment Bay Z1T9 (Extreme)",          minLevel = 60 },
        { instanceId = 20049, dutyId = 720,  dutyName = "Emanation (Extreme)",                     minLevel = 70 },
        { instanceId = 20056, dutyId = 779,  dutyName = "The Minstrel's Ballad: Tsukuyomi's Pain", minLevel = 70 },
        { instanceId = 20058, dutyId = 811,  dutyName = "Hells' Kier (Extreme)",                   minLevel = 70 },
        { instanceId = 20054, dutyId = 762,  dutyName = "The Great Hunt (Extreme)",                minLevel = 70 },
        { instanceId = 20061, dutyId = 825,  dutyName = "The Wreath of Snakes (Extreme)",          minLevel = 70 },
        { instanceId = 20063, dutyId = 858,  dutyName = "The Dancing Plague (Extreme)",            minLevel = 80 },
        { instanceId = 20065, dutyId = 848,  dutyName = "The Crown of the Immaculate (Extreme)",   minLevel = 80 },
        { instanceId = 20067, dutyId = 885,  dutyName = "The Minstrel's Ballad: Hades's Elegy",    minLevel = 80 },
        { instanceId = 20069, dutyId = 912,  dutyName = "Cinder Drift (Extreme)",                  minLevel = 80 },
        { instanceId = 20070, dutyId = 913,  dutyName = "Memoria Misera (Extreme)",                minLevel = 80 },
        { instanceId = 20072, dutyId = 923,  dutyName = "The Seat of Sacrifice (Extreme)",         minLevel = 80 },
        { instanceId = 20074, dutyId = 935,  dutyName = "Castrum Marinum (Extreme)",               minLevel = 80 },
        { instanceId = 20076, dutyId = 951,  dutyName = "The Cloud Deck (Extreme)",                minLevel = 80 },
        { instanceId = 20078, dutyId = 996,  dutyName = "The Minstrel's Ballad: Hydaelyn's Call",  minLevel = 90 },
        { instanceId = 20081, dutyId = 993,  dutyName = "The Minstrel's Ballad: Zodiark's Fall",   minLevel = 90 },
        { instanceId = 20083, dutyId = 998,  dutyName = "The Minstrel's Ballad: Endsinger's Aria", minLevel = 90 },
        { instanceId = 20085, dutyId = 1072, dutyName = "Storm's Crown (Extreme)",                 minLevel = 90 },
        { instanceId = 20087, dutyId = 1096, dutyName = "Mount Ordeals (Extreme)",                 minLevel = 90 },
        { instanceId = 20090, dutyId = 1141, dutyName = "The Voidcast Dais (Extreme)",             minLevel = 90 },
        { instanceId = 20092, dutyId = 1169, dutyName = "The Abyssal Fracture (Extreme)",          minLevel = 90 }
    },
    {                                                                      -- type 1: expansion cap dungeons
        { dutyName = "Dungeons (Lv. 100)", dutyId = 1266, minLevel = 100 } --Underkeep
    },
    2,
    3,
    { -- type 4: normal raids
        { dutyName = "Binding Coil of Bahamut", dutyId = 241, minLevel = 50 },
        { dutyName = "Second Coil of Bahamut",  dutyId = 355, minLevel = 50 },
        { dutyName = "Final Coil of Bahamut",   dutyId = 193, minLevel = 50 },
        { dutyName = "Alexander: Gordias",      dutyId = 442, minLevel = 60 },
        { dutyName = "Alexander: Midas",        dutyId = 520, minLevel = 60 },
        { dutyName = "Alexander: The Creator",  dutyId = 580, minLevel = 60 },
        { dutyName = "Omega: Deltascape",       dutyId = 693, minLevel = 70 },
        { dutyName = "Omega: Sigmascape",       dutyId = 748, minLevel = 70 },
        { dutyName = "Omega: Alphascape",       dutyId = 798, minLevel = 70 },
        { dutyName = "Eden's Gate",             dutyId = 849, minLevel = 80 },
        { dutyName = "Eden's Verse",            dutyId = 903, minLevel = 80 },
        { dutyName = "Eden's Promise",          dutyId = 942, minLevel = 80 },
        -- { dutyName="AAC Light-heavyweight M1 or M2", dutyId=1225, minLevel=100 },
        -- { dutyName="AAC Light-heavyweight M3 or M4", dutyId=1229, minLevel=100 }
    },
    {                                                                                            -- type 5: leveling dungeons
        { dutyName = "Leveling Dungeons (Lv. 1-49)",              dutyId = 172, minLevel = 15 }, --The Aurum Vale
        { dutyName = "Leveling Dungeons (Lv. 51-59/61-69/71-79)", dutyId = 434, minLevel = 51 }, --The Dusk Vigil
        { dutyName = "Leveling Dungeons (Lv. 81-89/91-99)",       dutyId = 952, minLevel = 81 }, --The Tower of Zot
    },
    {                                                                                            -- type 6: expansion cap dungeons
        { dutyName = "High-level Dungeons (Lv. 50 & 60)", dutyId = 362,  minLevel = 50 },        --Brayflox Longstop (Hard)
        { dutyName = "High-level Dungeons (Lv. 70 & 80)", dutyId = 1146, minLevel = 70 },        --Ala Mhigo
        { dutyName = "High-level Dungeons (Lv. 90)",      dutyId = 973,  minLevel = 90 },        --The Dead Ends

    },
    {                                                                                              -- type 7: ex trials
        {
            { instanceId = 20008, dutyId = 295, dutyName = "Trials (Lv. 50-60)",  minLevel = 50 }, -- Bowl of Embers
            { instanceId = 20049, dutyId = 720, dutyName = "Trials (Lv. 70-100)", minLevel = 70 }
        }
    },
    { -- type 8: alliance raids

    },
    { -- type 9: normal raids
        { dutyName = "Normal Raids (Lv. 50-60)", dutyId = 241, minLevel = 50 },
        { dutyName = "Normal Raids (Lv. 70-80)", dutyId = 693, minLevel = 70 },
    },
    Blacklisted = {
        {                                                                                                              -- 0
            { instanceId = 20052, dutyId = 758, dutyName = "The Jade Stoa (Extreme)",                 minLevel = 70 }, -- cannot solo double tankbuster vuln
            { instanceId = 20047, dutyId = 677, dutyName = "The Pool of Tribute (Extreme)",           minLevel = 70 }, -- cannot solo active time maneuver
            { instanceId = 20056, dutyId = 779, dutyName = "The Minstrel's Ballad: Tsukuyomi's Pain", minLevel = 70 }  -- cannot solo meteors
        },
        {},                                                                                                            -- 1
        {},                                                                                                            -- 2
        {                                                                                                              -- 3
            { dutyName = "Treasure Dungeons" }
        },
        { -- 4
            { dutyName = "Alliance Raids (A Realm Reborn)",      dutyId = 174 },
            { dutyName = "Alliance Raids (Heavensward)",         dutyId = 508 },
            { dutyName = "Alliance Raids (Stormblood)",          dutyId = 734 },
            { dutyName = "Alliance Raids (Shadowbringers)",      dutyId = 882 },
            { dutyName = "Alliance Raids (Endwalker)",           dutyId = 1054 },
            { dutyName = "Asphodelos= First to Fourth Circles",  dutyId = 1002 },
            { dutyName = "Abyssos= Fifth to Eighth Circles",     dutyId = 1081 },
            { dutyName = "Anabaseios= Ninth to Twelfth Circles", dutyId = 1147 }
        }
    }
}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function SearchWonderousTailsTable(type, data, text)
    if type == 0 then -- ex trials are indexed by instance#
        for _, duty in ipairs(WonderousTailsDuties[type + 1]) do
            if duty.instanceId == data then
                return duty
            end
        end
    elseif type == 1 or type == 5 or type == 6 or type == 7 then -- dungeons, level range ex trials
        for _, duty in ipairs(WonderousTailsDuties[type + 1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    elseif type == 4 or type == 8 then -- normal raids
        for _, duty in ipairs(WonderousTailsDuties[type + 1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    end
end

--=========================== EXECUTION ==========================--

if Player.Bingo.IsWeeklyBingoExpired or Player.Bingo.WeeklyBingoNumPlacedStickers == 9 or not Player.Bingo.HasWeeklyBingoJournal then
    if not IsInZone(478) then
        Teleport("Idyllshire")
    end

    MoveTo(Khloe.X, Khloe.Y, Khloe.Z)
    Interact(Khloe.Name)

    while not IsAddonReady("SelectString") do
        Execute("/click Talk Click")
        Wait(1)
    end

    if IsAddonReady("SelectString")then
        if not Player.Bingo.HasWeeklyBingoJournal then
            Execute("/callback SelectString true 0")
        elseif Player.Bingo.IsWeeklyBingoExpired then
            Execute("/callback SelectString true 1")
        elseif Player.Bingo.WeeklyBingoNumPlacedStickers == 9 then
            Execute("/callback SelectString true 0")
        end
    end

    while IsOccupiedInQuestEvent() do
        Execute("/click Talk Click")
        Wait(1)
    end

    Wait(1)
end

-- skip 13: Shadowbringers raids (not doable solo unsynced)
-- skip 14: Endwalker raids (not doable solo unsynced)
-- skip 15: PVP
for i = 0, 12 do
    if Player.Bingo:GetWeeklyBingoTaskStatus(i) == WeeklyBingoTaskStatus.Open then
        local dataRow = Player.Bingo:GetWeeklyBingoOrderDataRow(i)
        local type = dataRow.Type
        local data = dataRow.Data
        local text = dataRow.Text.Description
        local duty = SearchWonderousTailsTable(type, data, text)

        LogInfo(string.format("%s Wonderous Tails #%d Type: %s", LogPrefix, i + 1, type))
        LogInfo(string.format("%s Wonderous Tails #%d Data: %s", LogPrefix, i + 1, data))
        LogInfo(string.format("%s Wonderous Tails #%d Text: %s", LogPrefix, i + 1, text))


        if duty == nil then
            LogInfo(string.format("%s duty is nil", LogPrefix))
        end

        if duty ~= nil then
            if CurrentLevel < duty.minLevel then
                LogInfo(string.format("%s Cannot queue for %s as level is too low.", LogPrefix, duty.dutyName))
                duty.dutyId = nil

            elseif type == 0 then -- trials
                AutoDutyConfig("Unsynced", "true")
                AutoDutyConfig("dutyModeEnum", "Trial")

            elseif type == 4 then -- raids
                AutoDutyConfig("Unsynced", "true")
                AutoDutyConfig("dutyModeEnum", "Raid")

            elseif CurrentLevel - duty.minLevel < 20 then
                AutoDutyConfig("Unsynced", "false")
                AutoDutyConfig("dutyModeEnum", "Support")

            else
                AutoDutyConfig("Unsynced", "true")
                AutoDutyConfig("dutyModeEnum", "Regular")
            end

            if duty.dutyId ~= nil then
                LogInfo(string.format("%s Queuing duty TerritoryId#%s for Wonderous Tails #%s", LogPrefix, duty.dutyId, i + 1))
                AutoDutyRun(duty.dutyId, 1, true)

                WaitForCondition("BoundByDuty", true)

                repeat
                    Wait(1)
                until not AutoDutyIsRunning()

                Wait(10)
            else
                if duty.dutyName ~= nil then
                    LogInfo(string.format("%s Wonderous Tails Script does not support Wonderous Tails entry #%s %s", LogPrefix, i + 1, duty.dutyName))
                else
                    LogInfo(string.format("%s Wonderous Tails Script does not support Wonderous Tails entry #%s", LogPrefix, i + 1))
                end
            end
        end
    end
end

Echo(string.format("%s Wondrous Tails script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Wondrous Tails script completed successfully..!!", LogPrefix))

--============================== END =============================--