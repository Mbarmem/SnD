--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dungeon Farm for Levelling  - A barebones script
plugin_dependencies:
- AutoDuty
- Automaton
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
configs:
  StopAtLevel:
    description: Automatically stops leveling once all selected jobs reach the specified level.
    default: 60
    min: 1
    max: 100
  MaxRunsPerTier:
    description: Limits the number of dungeon runs per tier.
    default: 10
    min: 1
    max: 100
  Food:
    description: The food item to consume for extra experience gain.
    default: Apple Juice <hq>

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

StopAtLevel      = Config.Get("StopAtLevel")
MaxRunsPerTier   = Config.Get("MaxRunsPerTier")
Food             = Config.Get("Food")
LogPrefix        = "[LevelFarmer]"

--============================ CONSTANT ==========================--

----------------
--    Jobs    --
----------------

Jobs = {
    { name = "Paladin",      id = 1 },
    { name = "Warrior",      id = 2 },
    { name = "Dark Knight",  id = 3 },
    { name = "Gunbreaker",   id = 4 },
    { name = "White Mage",   id = 5 },
    { name = "Scholar",      id = 6 },
    { name = "Astrologian",  id = 7 },
    { name = "Sage",         id = 8 },
    { name = "Monk",         id = 9 },
    { name = "Dragoon",      id = 10 },
    { name = "Ninja",        id = 11 },
    { name = "Samurai",      id = 12 },
    { name = "Reaper",       id = 13 },
    { name = "Viper",        id = 14 },
    { name = "Bard",         id = 15 },
    { name = "Machinist",    id = 16 },
    { name = "Dancer",       id = 17 },
    { name = "Black Mage",   id = 18 },
    { name = "Summoner",     id = 19 },
    { name = "Red Mage",     id = 20 },
    { name = "Pictomancer",  id = 21 }
}

--------------------
--    Dungeons    --
--------------------

Dungeons = {
    {
        Name         = "Haukke Manor",
        dutyId       = 1040,
        dutyMode     = "Support",
        dutyLevel    = 28
    },
    {
        Name         = "Brayflox's Longstop",
        dutyId       = 1041,
        dutyMode     = "Support",
        dutyLevel    = 32
    },
    {
        Name         = "The Sunken Temple of Qarn",
        dutyId       = 1267,
        dutyMode     = "Support",
        dutyLevel    = 35
    },
    {
        Name         = "Cutter's Cry",
        dutyId       = 1303,
        dutyMode     = "Support",
        dutyLevel    = 38
    },
    {
        Name         = "The Stone Vigil",
        dutyId       = 1042,
        dutyMode     = "Support",
        dutyLevel    = 41
    },
    {
        Name         = "The Porta Decumana",
        dutyId       = 1048,
        dutyMode     = "Support",
        dutyLevel    = 50
    },
    {
        Name         = "Castrum Abania",
        dutyId       = 1145,
        dutyMode     = "Support",
        dutyLevel    = 69
    },
    {
        Name         = "Holminster Switch",
        dutyId       = 837,
        dutyMode     = "Trust",
        dutyLevel    = 71
    },
    {
        Name         = "The Qitana Ravel",
        dutyId       = 823,
        dutyMode     = "Trust",
        dutyLevel    = 75
    },
    {
        Name         = "Malikah's Well",
        dutyId       = 836,
        dutyMode     = "Trust",
        dutyLevel    = 77
    },
    {
        Name         = "Mt. Gulg",
        dutyId       = 822,
        dutyMode     = "Trust",
        dutyLevel    = 79
    },
    {
        Name         = "The Tower of Zot",
        dutyId       = 952,
        dutyMode     = "Trust",
        dutyLevel    = 81
    },
    {
        Name         = "The Tower of Babil",
        dutyId       = 969,
        dutyMode     = "Trust",
        dutyLevel    = 83
    },
    {
        Name         = "Vanaspati",
        dutyId       = 970,
        dutyMode     = "Trust",
        dutyLevel    = 85
    },
    {
        Name         = "Ktisis Hyperboreia",
        dutyId       = 974,
        dutyMode     = "Trust",
        dutyLevel    = 87
    },
    {
        Name         = "The Aitiascope",
        dutyId       = 978,
        dutyMode     = "Trust",
        dutyLevel    = 89
    },
    {
        Name         = "Ihuykatumu",
        dutyId       = 1167,
        dutyMode     = "Trust",
        dutyLevel    = 91
    },
    {
        Name         = "Worqor Zormor",
        dutyId       = 1193,
        dutyMode     = "Trust",
        dutyLevel    = 93
    },
    {
        Name         = "The Skydeep Cenote",
        dutyId       = 1194,
        dutyMode     = "Trust",
        dutyLevel    = 95
    },
    {
        Name         = "Vanguard",
        dutyId       = 1198,
        dutyMode     = "Trust",
        dutyLevel    = 97
    },
    {
        Name         = "Origenics",
        dutyId       = 1208,
        dutyMode     = "Trust",
        dutyLevel    = 99
    }
}

--=========================== FUNCTIONS ==========================--

function GetLevel()
    return tonumber(Player.Job.Level)
end

function ReachedStopCap(level)
    return level >= StopAtLevel
end

function BestRunnableDungeonIndex(level)
    local best = 0

    for i, d in ipairs(Dungeons) do
        if level >= (d.dutyLevel or 1) then
            best = i
        else
            break
        end
    end

    if best == 0 then
        return nil
    end
    return best
end

function TierForLevel(level)
    for i, d in ipairs(Dungeons) do
        local lo = d.dutyLevel or 1
        local hi = (Dungeons[i+1] and Dungeons[i+1].dutyLevel) or math.huge

        if level >= lo and level < hi then
            return i, lo, hi
        end
    end

    if level < (Dungeons[1].dutyLevel or 1) then
        return nil, nil, nil
    else
        return #Dungeons, Dungeons[#Dungeons].dutyLevel or 1, math.huge
    end
end

function RunDungeon(d, job)
    LogInfo(string.format("%s Run → %s (Lv %d+) Mode:%s", LogPrefix, d.Name, d.dutyLevel, d.dutyMode))

    -- Gear Management using IDs from the Jobs table
    Execute("/equiprecommended")
    Wait(1.5)
    if job and job.id then
        Execute(string.format("/gs save %d", job.id))
        LogInfo(string.format("%s Updated Gear Set #%d", LogPrefix, job.id))
    end

    Wait(1)
    Repair(20)
    Wait(1)
    FoodCheck()
    Wait(1)

    AutoDutyConfig("dutyModeEnum", d.dutyMode)
    AutoDutyRun(d.dutyId, 1, true)
    Execute("/rotation auto")
    WaitForCondition("BoundByDuty", true)

    repeat
        Wait(1)
    until not AutoDutyIsRunning()
    WaitForPlayer()
end

function FoodCheck()
    if not HasStatusId(48) or GetStatusTimeRemaining(48) < 1500 then
        if Food ~= "" and GetItemCount(4747) > 1 then
            Engines.Run(string.format("/item %s", Food))
        end
    end
end

function AdvanceLeaderToNextCeiling(job)
    Execute(string.format("/gs change %d", job.id))
    Wait(1)
    WaitForPlayer()

    local level = GetLevel()
    if ReachedStopCap(level) then
        return
    end

    local curIdx = TierForLevel(level)
    if not curIdx then
        return
    end

    local goal = math.min(StopAtLevel, NextCeilingFromLevel(level))
    if level >= goal then
        return
    end

    LogInfo(string.format("%s [Leader] %s advancing from Lv %d to next ceiling Lv %d", LogPrefix, job.name, level, goal))

    local runs = 0
    while true do
        level = GetLevel()
        if ReachedStopCap(level) or level >= goal then
            LogInfo(string.format("%s [Leader] %s reached goal Lv %d", LogPrefix, job.name, level))
            break
        end

        local idx = BestRunnableDungeonIndex(level)
        if not idx then
            LogInfo(string.format("%s [Leader] %s Lv %d below lowest dungeon (%d). Stop leader advance.", LogPrefix, job.name, level, Dungeons[1].dutyLevel))
            break
        end

        RunDungeon(Dungeons[idx], job)

        runs = runs + 1
        if runs >= MaxRunsPerTier then
            LogInfo(string.format("%s [Leader] Safety break after %d runs.", LogPrefix, runs))
            break
        end
    end
end

function ScanLevels()
    local levels = {}
    LogInfo(string.format("%s Starting full job/gear scan...", LogPrefix))

    for _, job in ipairs(Jobs) do
        -- Switch Job
        Execute(string.format("/gs change %d", job.id))
        Wait(1.5)
        WaitForPlayer()

        -- Update Gear during Scan
        Execute("/equiprecommended")
        Wait(1.5)
        Execute(string.format("/gs save %d", job.id))

        local lv = GetLevel()
        levels[job.name] = lv
        LogInfo(string.format("%s [Scan] %s → Lv %d", LogPrefix, job.name, lv))
    end
    return levels
end

function NextCeilingFromLevel(level)
    for _, d in ipairs(Dungeons) do
        if d.dutyLevel > level then
            return d.dutyLevel
        end
    end
    return StopAtLevel
end

function FoodCheck()
    if not HasStatusId(48) or GetStatusTimeRemaining(48) < 1500 then
        local foodForExp = GetItemCount(4747)
        if Food ~= "" and foodForExp and foodForExp > 1 then
            LogInfo(string.format("%s Using %s for this cycle", LogPrefix, Food))
            Engines.Run(string.format("/item %s", Food))
        end
    end
end

--=========================== EXECUTION ==========================--

do
    while true do
        local levels   = ScanLevels()
        local maxLv    = 0
        local minLv    = math.huge
        local minJob   = nil -- This will now store the full job object
        local allAtCap = true

        -- Fix 1: Loop through job objects instead of strings
        for _, job in ipairs(Jobs) do
            local lv = levels[job.name] or 1

            if lv > maxLv then
                maxLv = lv
            end

            if lv < minLv then
                minLv  = lv
                minJob = job -- Store the object
            end

            if lv < StopAtLevel then
                allAtCap = false
            end
        end

        if allAtCap then
            break
        end

        local TargetLevel = math.min(StopAtLevel, NextCeilingFromLevel(minLv))
        TargetLevel = math.max(TargetLevel, minLv + 1)
        LogInfo(string.format("%s TargetLevel for this cycle → %d", LogPrefix, TargetLevel))

        local allAtTarget = true
        for _, job in ipairs(Jobs) do
            if (levels[job.name] or 1) < TargetLevel then
                allAtTarget = false
                break
            end
        end

        if (not allAtCap) and allAtTarget then
            local leader = minJob
            if leader then
                LogInfo(string.format("%s All jobs >= Lv %d. Advancing leader: %s", LogPrefix, TargetLevel, leader.name))
                -- Fix 2: Passing the leader object so it can use leader.id
                AdvanceLeaderToNextCeiling(leader)
                goto cycle_end
            end
        end

        -- Fix 3: Updated loop to use job object properties
        for _, job in ipairs(Jobs) do
            -- Use the ID to change gearsets correctly
            Execute(string.format("/gs change %d", job.id))
            Wait(1.5)
            WaitForPlayer()

            local level = GetLevel()
            LogInfo(string.format("%s === Job: %s ===", LogPrefix, job.name))

            if ReachedStopCap(level) or level >= TargetLevel then
                LogInfo(string.format("%s %s meets target/cap. Skipping.", LogPrefix, job.name))
                goto next_job
            end

            local curIdx = select(1, TierForLevel(level))
            if not curIdx then
                LogInfo(string.format("%s %s Lv %d below first dungeon. Skipping.", LogPrefix, job.name, level))
                goto next_job
            end

            local runs = 0
            while true do
                level = GetLevel()

                if ReachedStopCap(level) or level >= TargetLevel then
                    goto next_job
                end

                local idx = BestRunnableDungeonIndex(level)
                if not idx then goto next_job end

                local dungeon = Dungeons[idx]
                -- Fix 4: Pass the whole job object to RunDungeon so it can save via ID
                RunDungeon(dungeon, job)

                runs = runs + 1
                if runs >= MaxRunsPerTier then
                    LogInfo(string.format("%s Safety break: MaxRunsPerTier. Next job.", LogPrefix))
                    goto next_job
                end
            end

            ::next_job::
        end

        ::cycle_end::
        Wait(2)
    end
end

Echo(string.format("Level Farmer script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Level Farmer script completed successfully..!!", LogPrefix))

--============================== END =============================--