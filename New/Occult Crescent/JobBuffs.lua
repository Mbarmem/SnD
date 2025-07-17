--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Artisan - Script for Crafting & Turning In
plugin_dependencies:
- Artisan
- TeleporterPlugin
- Lifestream
- vnavmesh
- AutoRetainer
dependencies:
- source: ''
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

local useSimpleTweaksCommand  = true        -- Requires Simple Tweaks command support
local jobChangeCommand        = "/phantomjob"
local intervalTime            = 0.2         -- Delay between actions (in seconds)
local actionStatusThreshold   = 10          -- Threshold for buff reapplication (in seconds)
EchoPrefix                    = "[JobBuffs]"

--============================ CONSTANT ==========================--

-- Execute the action number(s) defined in JOB_MAP.
local JOBACTION_ORDER = {
    { job = "Bard",      actions = { 2     } },
    { job = "Geomancer", actions = { 3, 1  } },
    { job = "Thief",     actions = { 1     } },
}

-- Job names are available in multiple languages.
-- If 'actions' is omitted, the first defined action is executed.
local CRYSTALACTION_ORDER = {
    { job = "Knight" },
    { job = "Bard"   },
    { job = "Monk"   },
}

local CRYSTAL_MAP = {
    [1252] = { -- South Horn
        { x =  835.9, y =  73.1, z = -709.3 },
        { x = -165.8, y =   6.5, z = -616.5 },
        { x = -347.2, y = 100.3, z = -124.1 },
        { x = -393.1, y =  97.5, z =  278.7 },
        { x =  302.6, y = 103.1, z =  313.7 },
    },
}

local JOB_MAP = {
    Freelancer = {
        jobName     = { jp = "すっぴん", en = "Freelancer",  de = "Freiberufler", fr = "Freelance" },
        jobId       = 0,
        jobStatusId = 4357,
        actions     = {}
    },

    Knight = {
        jobName     = { jp = "ナイト", en = "Knight", de = "Ritter", fr = "Paladin" },
        jobId       = 1,
        jobStatusId = 4358,
        actions     = {
            { actionId = 32, actionStatusId = 4233, actionLevel = 2, statusTime = 1800, crystal = true }, -- Pray (30min buff)
            { actionId = 31, actionStatusId = 4231, actionLevel = 1, statusTime = 10  }, -- Phantom Guard
            { actionId = 32, actionStatusId = 4232, actionLevel = 2, statusTime = 30  }, -- Pray
            { actionId = 34, actionStatusId = 4234, actionLevel = 6, statusTime = 10  }, -- Pledge
        }
    },

    Berserker = {
        jobName     = { jp = "バーサーカー", en = "Berserker", de = "Berserker", fr = "Berserker" },
        jobId       = 2,
        jobStatusId = 4359,
        actions     = {}
    },

    Monk = {
        jobName     = { jp = "モンク", en = "Monk", de = "Mönch", fr = "Moine" },
        jobId       = 3,
        jobStatusId = 4360,
        actions     = {
            { actionId = 33, actionStatusId = 4239, actionLevel = 3, statusTime = 1800, crystal = true }, -- Counterstance (30min buff)
            { actionId = 33, actionStatusId = 4238, actionLevel = 3, statusTime = 60  }, -- Counterstance
        }
    },

    Ranger = {
        jobName     = { jp = "狩人", en = "Ranger", de = "Jäger", fr = "Rôdeur" },
        jobId       = 4,
        jobStatusId = 4361,
        actions     = {
            { actionId = 31, actionStatusId = {4240, 4241}, actionLevel = 1, statusTime = 30 }, -- Phantom Aim
            { actionId = 34, actionStatusId = 4243, actionLevel = 6, statusTime = 30 }, -- Occult Unicorn
        }
    },

    Samurai = {
        jobName     = { jp = "侍", en = "Samurai", de = "Samurai", fr = "Samouraï" },
        jobId       = 5,
        jobStatusId = 4362,
        actions     = {}
    },

    Bard = {
        jobName     = { jp = "吟遊詩人", en = "Bard", de = "Barde", fr = "Barde" },
        jobId       = 6,
        jobStatusId = 4363,
        actions     = {
            { actionId = 32, actionStatusId = 4244, actionLevel = 2, statusTime = 1800, crystal = true }, -- Romeo's Ballad
            { actionId = 31, actionStatusId = 4247, actionLevel = 1, statusTime = 70  }, -- Offensive Aria
            { actionId = 33, actionStatusId = 4246, actionLevel = 3, statusTime = 30  }, -- Mighty March
            { actionId = 34, actionStatusId = 4249, actionLevel = 4, statusTime = 20  }, -- Hero's Rime
        }
    },

    Geomancer = {
        jobName     = { jp = "風水士", en = "Geomancer", de = "Geomant", fr = "Chronomancien" },
        jobId       = 7,
        jobStatusId = 4364,
        actions     = {
            { actionId = 31, actionStatusId = 4251, actionLevel = 1, statusTime = 60  }, -- Battle Bell
            -- { actionId = 32, actionStatusId = {4253, 4254, 4255, 4256, 4280}, actionLevel = 2, statusTime = 20 }, -- Weather (disabled: includes non-buff)
            { actionId = 33, actionStatusId = 4257, actionLevel = 3, statusTime = 60  }, -- Ringing Respite
            { actionId = 34, actionStatusId = 4258, actionLevel = 4, statusTime = 60  }, -- Suspend
        }
    },

    TimeMage = {
        jobName     = { jp = "時魔道士", en = "Time Mage", de = "Zeitmagier", fr = "Artilleur" },
        jobId       = 8,
        jobStatusId = 4365,
        actions     = {
            { actionId = 35, actionStatusId = 4260, actionLevel = 5, statusTime = 20 }, -- Occult Quick
        }
    },

    Cannoneer = {
        jobName     = { jp = "砲撃士", en = "Cannoneer", de = "Grenadier", fr = "Canonier" },
        jobId       = 9,
        jobStatusId = 4366,
        actions     = {}
    },

    Chemist = {
        jobName     = { jp = "薬師", en = "Chemist", de = "Alchemist", fr = "Alchimiste" },
        jobId       = 10,
        jobStatusId = 4367,
        actions     = {}
    },

    Oracle = {
        jobName     = { jp = "予言士", en = "Oracle", de = "Seher", fr = "Devin" },
        jobId       = 11,
        jobStatusId = 4368,
        actions     = {
            { actionId = 32, actionStatusId = 4271, actionLevel = 2, statusTime = 20 }, -- Recuperation
            { actionId = 34, actionStatusId = 4274, actionLevel = 4, statusTime = 20 }, -- Phantom Rejuvenation
            { actionId = 35, actionStatusId = 4275, actionLevel = 5, statusTime = 8  }, -- Invulnerability
        }
    },

    Thief = {
        jobName     = { jp = "シーフ", en = "Thief", de = "Dieb", fr = "Voleur" },
        jobId       = 12,
        jobStatusId = 4369,
        actions     = {
            { actionId = 31, actionStatusId = 4276, actionLevel = 1, statusTime = 10 }, -- Occult Sprint
            { actionId = 33, actionStatusId = 4277, actionLevel = 3, statusTime = 20 }, -- Vigilance
        }
    },
}

-- Create a lowercase-indexed version of JOB_MAP for quick lookup
local JOB_MAP_LOWER = {}
for name, data in pairs(JOB_MAP) do
    JOB_MAP_LOWER[string.lower(name)] = data
end

--=========================== FUNCTIONS ==========================--

-- Finds a job key in JOB_MAP using any localized job name (EN, JP, DE, FR)
local function findJobKeyByAnyName(name)
    local nameLower = string.lower(name)

    for key, data in pairs(JOB_MAP) do
        for _, jobName in pairs(data.jobName) do
            if jobName and string.lower(jobName) == nameLower then
                return key
            end
        end
    end

    return nil
end

local function openSupportJob()
    while not IsAddonVisible("MKDSupportJob") do
        yield("/callback MKDInfo true 1 0")
        Wait(intervalTime)
    end
end

local function openSupportJobList()
    while not IsAddonVisible("MKDSupportJobList") do
        openSupportJob()
        yield("/callback MKDSupportJob true 0 0 0")
        Wait(intervalTime)
    end
end

local function getOriginalJobName()
    for jobName, data in pairs(JOB_MAP) do
        if HasStatusId(data.jobStatusId) then
            LogInfo(string.format("%s Detected current job as: %s", EchoPrefix, jobName))
            return jobName
        end
    end

    LogInfo(string.format("%s No matching jobStatusId found", EchoPrefix))
    return nil
end

local function getCurrentJobLevel()
    local levelText = GetNodeText("MKDInfo", 1, 20, 30)

    if levelText then
        local level = tonumber(levelText)
        LogInfo(string.format("%s Current job level detected: %d", EchoPrefix, level or -1))
        return level
    end

    LogInfo(string.format("%s Failed to detect job level, defaulting to 1", EchoPrefix))
    return 1
end

local function isNearAnyCrystal()
    local zoneId = GetZoneID()
    local crystalList = CRYSTAL_MAP[zoneId]

    if not crystalList then
        LogInfo(string.format("%s No crystals defined for zone ID: %s", EchoPrefix, tostring(zoneId)))
        return false
    end

    local playerX = GetPlayerRawXPos()
    local playerZ = GetPlayerRawZPos()

    for _, crystal in ipairs(crystalList) do
        local dx       = playerX - crystal.x
        local dz       = playerZ - crystal.z
        local distance = math.sqrt(dx * dx + dz * dz)

        if distance <= 4.8 then
            LogInfo(string.format("%s Player is near a crystal (%.1f units)", EchoPrefix, distance))
            return true
        end
    end
end

local function changeSupportJob(jobName)
    local jobKey = findJobKeyByAnyName(jobName)
    local jobData = jobKey and JOB_MAP[jobKey] or nil

    if not jobData then
        LogInfo(string.format("%s Invalid job name: %s", EchoPrefix, tostring(jobName)))
        return
    end

    if HasStatusId(jobData.jobStatusId) then
        LogInfo(string.format("%s Job '%s' is already active.", EchoPrefix, jobName))
        return
    end

    if useSimpleTweaksCommand then
        repeat
            yield(string.format("%s %d", jobChangeCommand, jobData.jobId))
            Wait(intervalTime)
        until HasStatusId(jobData.jobStatusId)
    else
        repeat
            openSupportJobList()
            yield(string.format("/callback MKDSupportJobList true 0 %d", jobData.jobId))
            Wait(intervalTime)
        until HasStatusId(jobData.jobStatusId)
    end

    LogInfo(string.format("%s Successfully changed support job to '%s'.", EchoPrefix, jobName))
end

local function getJobData(jobNameInput)
    local jobKey = findJobKeyByAnyName(jobNameInput) or string.lower(jobNameInput)
    return JOB_MAP[jobKey] or JOB_MAP_LOWER[jobKey]
end

local function shouldSkipAction(action)
    if action.crystal == true and not isNearAnyCrystal() then
        LogInfo(string.format("%s Action requires crystal, but player is not near any crystal. Skipping action.", EchoPrefix))
        return true
    end
    return false
end

local function hasActiveStatus(action, threshold)
    if not action.actionStatusId then
        return false
    end

    local ids = type(action.actionStatusId) == "table" and action.actionStatusId or { action.actionStatusId }
    for _, id in ipairs(ids) do
        if HasStatusId(id) and GetStatusTimeRemaining(id) >= threshold then
            return true
        end
    end
    return false
end

local function performAction(action)
    local threshold = (action.statusTime or 0) - actionStatusThreshold

    if not action.actionId or getCurrentJobLevel() < action.actionLevel then
        return
    end

    LogInfo(string.format("%s Attempting to perform actionId: %s with threshold: %s", EchoPrefix, tostring(action.actionId), tostring(threshold)))

    local function tryExecute()
        if not Svc.Condition[27] then
            ExecuteGeneralAction(action.actionId)
        end
    end

    if threshold <= 0 then
        repeat
            tryExecute()
            Wait(intervalTime)
        until HasStatusId(action.actionStatusId)
    else
        repeat
            tryExecute()
            Wait(intervalTime)
        until hasActiveStatus(action, threshold)
    end
end

local function useSupportAction(actionOrderList)
    for _, jobEntry in ipairs(actionOrderList) do
        local jobData = getJobData(jobEntry.job)
        if not jobData then
            LogInfo(string.format("%s Invalid job name: %s", EchoPrefix, tostring(jobEntry.job)))
            goto continue
        end

        local actionIndexes = jobEntry.actions or {1}
        for _, idx in ipairs(actionIndexes) do
            local action = jobData.actions[idx]
            if not action then
                LogInfo(string.format("%s No action index %d for job %s", EchoPrefix, idx, jobEntry.job))
                goto action_continue
            end

            if shouldSkipAction(action) then
                goto action_continue
            end

            changeSupportJob(jobData.jobName["en"] or jobEntry.job)

            local threshold = (action.statusTime or 0) - actionStatusThreshold
            if hasActiveStatus(action, threshold) then
                LogInfo(string.format("%s Action already active for job: %s action#%d", EchoPrefix, jobEntry.job, idx))
                goto action_continue
            end

            performAction(action)

            ::action_continue::
        end
        ::continue::
    end
end

--=========================== EXECUTION ==========================--

local originalJob = getOriginalJobName()
LogInfo(string.format("%s Original job: %s", EchoPrefix, tostring(originalJob)))

if isNearAnyCrystal() then
    LogInfo(string.format("%s Near a crystal, using support actions.", EchoPrefix))
    useSupportAction(CRYSTALACTION_ORDER)
else
    LogInfo(string.format("%s Not near any crystal, using job order actions.", EchoPrefix))
    useSupportAction(JOBACTION_ORDER)
end

if originalJob then
    LogInfo(string.format("%s Reverting to original job: %s", EchoPrefix, originalJob))
    changeSupportJob(originalJob)
end

--============================== END =============================--