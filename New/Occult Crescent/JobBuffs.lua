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
configs:
  UseSimpleTweaksCommand:
    default: true
    description: Requires Simple Tweaks command support
    type: boolean
  JobChangeCommand :
    default: /phantomjob
    description: Command name in Simple Tweaks
    type: string
  ActionStatusThreshold:
    default: 10
    description: Threshold for buff reapplication (in seconds)
    type: int

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

UseSimpleTweaksCommand  = Config.Get("UseSimpleTweaksCommand")
JobChangeCommand        = Config.Get("JobChangeCommand")
ActionStatusThreshold   = Config.Get("ActionStatusThreshold")
LogPrefix               = "[JobBuffs]"

--============================ CONSTANT ==========================--

-- Execute the action number(s) defined in JOB_MAP.
JOBACTION_ORDER = {
    { job = "Bard",      actions = { 2     } },
    { job = "Geomancer", actions = { 3, 1  } },
    { job = "Thief",     actions = { 1     } },
}

-- Job names are available in multiple languages.
-- If 'actions' is omitted, the first defined action is executed.
CRYSTALACTION_ORDER = {
    { job = "Knight" },
    { job = "Bard"   },
    { job = "Monk"   },
}

CRYSTAL_MAP = {
    [1252] = { -- South Horn
        { x =  835.9, y =  73.1, z = -709.3 },
        { x = -165.8, y =   6.5, z = -616.5 },
        { x = -347.2, y = 100.3, z = -124.1 },
        { x = -393.1, y =  97.5, z =  278.7 },
        { x =  302.6, y = 103.1, z =  313.7 },
    },
}

JOB_MAP = {
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
JOB_MAP_LOWER = {}
for name, data in pairs(JOB_MAP) do
    JOB_MAP_LOWER[string.lower(name)] = data
end

--=========================== FUNCTIONS ==========================--

-- Finds a job key in JOB_MAP using any localized job name (EN, JP, DE, FR)
function FindJobKeyByAnyName(name)
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

function OpenSupportJob()
    while not IsAddonVisible("MKDSupportJob") do
        yield("/callback MKDInfo true 1 0")
        Wait(0.5)
    end
end

function OpenSupportJobList()
    while not IsAddonVisible("MKDSupportJobList") do
        OpenSupportJob()
        yield("/callback MKDSupportJob true 0 0 0")
        Wait(0.5)
    end
end

function GetOriginalJobName()
    for jobName, data in pairs(JOB_MAP) do
        if HasStatusId(data.jobStatusId) then
            LogInfo(string.format("%s Detected current job as: %s", LogPrefix, jobName))
            return jobName
        end
    end

    LogInfo(string.format("%s No matching jobStatusId found", LogPrefix))
    return "Freelancer"
end

function GetCurrentJobLevel()
    local levelText = GetNodeText("MKDInfo", 1, 20, 30)

    if levelText then
        local level = tonumber(levelText)
        LogInfo(string.format("%s Current job level detected: %d", LogPrefix, level or -1))
        return level
    end

    LogInfo(string.format("%s Failed to detect job level, defaulting to 1", LogPrefix))
    return 1
end

function IsNearAnyCrystal()
    local zoneId = GetZoneID()
    local crystalList = CRYSTAL_MAP[zoneId]

    if not crystalList then
        LogInfo(string.format("%s No crystals defined for zone ID: %s", LogPrefix, tostring(zoneId)))
        return false
    end

    local playerX = GetPlayerRawXPos()
    local playerZ = GetPlayerRawZPos()

    for _, crystal in ipairs(crystalList) do
        local dx       = playerX - crystal.x
        local dz       = playerZ - crystal.z
        local distance = math.sqrt(dx * dx + dz * dz)

        if distance <= 4.8 then
            LogInfo(string.format("%s Player is near a crystal (%.1f units)", LogPrefix, distance))
            return true
        end
    end
end

function ChangeSupportJob(jobName)
    local jobKey = FindJobKeyByAnyName(jobName) or string.lower(jobName)
    local jobData = JOB_MAP[jobKey] or JOB_MAP_LOWER[jobKey]

    if not jobData then
        LogInfo(string.format("%s Invalid job name: %s", LogPrefix, tostring(jobName)))
        return
    end

    local isFreelancer = jobKey == "Freelancer"

    if not isFreelancer and HasStatusId(jobData.jobStatusId) then
        LogInfo(string.format("%s Job '%s' is already active.", LogPrefix, jobName))
        return
    end

    SwitchedJob = true

    if UseSimpleTweaksCommand then
        repeat
            yield(string.format("%s %d", JobChangeCommand, jobData.jobId))
            Wait(0.5)
        until isFreelancer or HasStatusId(jobData.jobStatusId)
    else
        repeat
            OpenSupportJobList()
            yield(string.format("/callback MKDSupportJobList true 0 %d", jobData.jobId))
            Wait(0.5)
        until isFreelancer or HasStatusId(jobData.jobStatusId)
    end

    LogInfo(string.format("%s Successfully changed support job to '%s'.", LogPrefix, jobName))
end

function GetJobData(jobNameInput)
    local jobKey = FindJobKeyByAnyName(jobNameInput) or string.lower(jobNameInput)
    return JOB_MAP[jobKey] or JOB_MAP_LOWER[jobKey]
end

function ShouldSkipAction(action)
    if action.crystal == true and not IsNearAnyCrystal() then
        LogInfo(string.format("%s Action requires crystal, but player is not near any crystal. Skipping action.", LogPrefix))
        return true
    end
    return false
end

function HasActiveStatus(action, threshold)
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

function PerformAction(action)
    local threshold = (action.statusTime or 0) - ActionStatusThreshold

    if not action.actionId or GetCurrentJobLevel() < action.actionLevel then
        return
    end

    LogInfo(string.format("%s Attempting to perform actionId: %s with threshold: %s", LogPrefix, tostring(action.actionId), tostring(threshold)))

    function tryExecute()
        if not IsPlayerCasting() then
            Actions.ExecuteGeneralAction(action.actionId)
        end
    end

    if threshold <= 0 then
        repeat
            tryExecute()
            Wait(0.5)
        until HasStatusId(action.actionStatusId)
    else
        repeat
            tryExecute()
            Wait(0.5)
        until HasActiveStatus(action, threshold)
    end
end

function UseSupportAction(actionOrderList)
    for _, jobEntry in ipairs(actionOrderList) do
        local jobData = GetJobData(jobEntry.job)
        if not jobData then
            LogInfo(string.format("%s Invalid job name: %s", LogPrefix, tostring(jobEntry.job)))
            goto continue
        end

        local actionIndexes = jobEntry.actions or {1}
        for _, idx in ipairs(actionIndexes) do
            local action = jobData.actions[idx]
            if not action then
                LogInfo(string.format("%s No action index %d for job %s", LogPrefix, idx, jobEntry.job))
                goto action_continue
            end

            if ShouldSkipAction(action) then
                goto action_continue
            end

            ChangeSupportJob(jobData.jobName["en"] or jobEntry.job)

            local threshold = (action.statusTime or 0) - ActionStatusThreshold
            if HasActiveStatus(action, threshold) then
                LogInfo(string.format("%s Action already active for job: %s action#%d", LogPrefix, jobEntry.job, idx))
                goto action_continue
            end

            PerformAction(action)

            ::action_continue::
        end
        ::continue::
    end
end

--=========================== EXECUTION ==========================--

local originalJob = GetOriginalJobName()
LogInfo(string.format("%s Original job: %s", LogPrefix, tostring(originalJob)))

if IsNearAnyCrystal() then
    LogInfo(string.format("%s Near a crystal, using support actions.", LogPrefix))
    UseSupportAction(CRYSTALACTION_ORDER)
else
    LogInfo(string.format("%s Not near any crystal, using job order actions.", LogPrefix))
    UseSupportAction(JOBACTION_ORDER)
end

if SwitchedJob and originalJob then
    LogInfo(string.format("%s Reverting to original job: %s", LogPrefix, originalJob))
    ChangeSupportJob(originalJob)
end

--============================== END =============================--