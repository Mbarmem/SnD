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

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

StopAtLevel        = 50
MaxRunsPerTier     = 10
LogPrefix          = "[LevelFarmer]"

--============================ CONSTANT ==========================--

----------------
--    Jobs    --
----------------

Jobs = {
    "Dark Knight",
    "Monk",
    "Ninja",
    "Astrologian",
    "Bard",
    "Machinist",
    "Black Mage"
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
}

--=========================== FUNCTIONS ==========================--

function GetLevel()
    return tonumber(Player.Job.Level)
end

function ReachedStopCap(level)
    return level >= 50
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

function RunDungeon(d)
    LogInfo(string.format("%s Run → %s (Lv %d+) Mode:%s", LogPrefix, d.Name, d.dutyLevel, d.dutyMode))

    Execute("/equiprecommended")
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

function AdvanceLeaderToNextCeiling(jobName)
    Execute(string.format("/gs change %s", jobName))
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

    local hi_next = (Dungeons[curIdx + 2] and Dungeons[curIdx + 2].dutyLevel) or math.huge
    local next_ceiling = (hi_next == math.huge) and StopAtLevel or (hi_next - 1)
    local goal = math.min(StopAtLevel, next_ceiling)

    if level >= goal then
        return
    end

    LogInfo(string.format("%s [Leader] %s advancing from Lv %d to next ceiling Lv %d", LogPrefix, jobName, level, goal))

    local runs = 0
    while true do
        level = GetLevel()
        if ReachedStopCap(level) or level >= goal then
            LogInfo(string.format("%s [Leader] %s reached goal Lv %d", LogPrefix, jobName, level))
            break
        end

        local idx = BestRunnableDungeonIndex(level)
        if not idx then
            LogInfo(string.format("%s [Leader] %s Lv %d below lowest dungeon (%d). Stop leader advance.", LogPrefix, jobName, level, Dungeons[1].dutyLevel))
            break
        end

        RunDungeon(Dungeons[idx])

        runs = runs + 1
        if runs >= MaxRunsPerTier then
            LogInfo(string.format("%s [Leader] Safety break after %d runs.", LogPrefix, runs))
            break
        end
    end
end

function ScanLevels()
    local levels = {}

    for _, jobName in ipairs(Jobs) do
        Execute(string.format("/gs change %s", jobName))
        Wait(1)
        WaitForPlayer()
        local lv = GetLevel()
        levels[jobName] = lv
        LogInfo(string.format("%s [Scan] %s → Lv %d", LogPrefix, jobName, lv))
    end
    return levels
end

--=========================== EXECUTION ==========================--

do
    while true do
        local levels   = ScanLevels()
        local maxLv    = 0
        local allAtCap = true

        for _, jobName in ipairs(Jobs) do
            local lv = levels[jobName] or 1

            if lv > maxLv then
                maxLv = lv
            end

            if lv < StopAtLevel then
                allAtCap = false
            end
        end

        if allAtCap then
            break
        end

        local TargetLevel = math.min(StopAtLevel, maxLv)
        LogInfo(string.format("%s TargetLevel for this cycle → %d", LogPrefix, TargetLevel))

        local allAtTarget = true
        for _, jobName in ipairs(Jobs) do
            if (levels[jobName] or 1) < TargetLevel then
                allAtTarget = false
                break
            end
        end

        if (not allAtCap) and allAtTarget then
            local leader = nil

            for _, jobName in ipairs(Jobs) do
                if (levels[jobName] or 1) == TargetLevel then
                    leader = jobName
                    break
                end
            end

            if leader then
                LogInfo(string.format("%s All jobs at Lv %d. Advancing leader to next ceiling: %s", LogPrefix, TargetLevel, leader))
                AdvanceLeaderToNextCeiling(leader)
                goto cycle_end
            end
        end

        for _, jobName in ipairs(Jobs) do
            Execute(string.format("/gs change %s", jobName))
            Wait(1)
            WaitForPlayer()

            local level = GetLevel()
            LogInfo(string.format("%s === Job: %s (Lv %d / Target %d) ===", LogPrefix, jobName, level, TargetLevel))

            if ReachedStopCap(level) or level >= TargetLevel then
                LogInfo(string.format("%s %s meets target/cap. Skipping.", LogPrefix, jobName))
                goto next_job
            end

            local curIdx = select(1, TierForLevel(level))
            if not curIdx then
                LogInfo(string.format("%s %s Lv %d is below first dungeon requirement (%d). Skipping.", LogPrefix, jobName, level, Dungeons[1].dutyLevel))
                goto next_job
            end

            local runs = 0
            while true do
                level = GetLevel()

                if ReachedStopCap(level) then
                    LogInfo(string.format("%s %s reached cap (Lv %d). Next job.", LogPrefix, jobName, level))
                    goto next_job
                end

                if level >= TargetLevel then
                    LogInfo(string.format("%s %s reached cycle target (Lv %d). Next job.", LogPrefix, jobName, level))
                    goto next_job
                end

                local idx = BestRunnableDungeonIndex(level)
                if not idx then
                    LogInfo(string.format("%s %s Lv %d below lowest dungeon (%d). Next job.", LogPrefix, jobName, level, Dungeons[1].dutyLevel))
                    goto next_job
                end

                local dungeon = Dungeons[idx]
                LogInfo(string.format("%s %s Lv %d → %s (tier %d). Cycle target: %d", LogPrefix, jobName, level, dungeon.Name, idx, TargetLevel))

                RunDungeon(dungeon)

                runs = runs + 1
                if runs >= MaxRunsPerTier then
                    LogInfo(string.format("%s Safety break: MaxRunsPerTier (%d). Next job.", LogPrefix, MaxRunsPerTier))
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