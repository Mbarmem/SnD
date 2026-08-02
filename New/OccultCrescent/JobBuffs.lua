--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Crescent - Script for Quick Buffs
plugin_dependencies:
- vnavmesh
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  UseSimpleTweaksCommand:
    description: Requires Simple Tweaks command support.
    default: true
  JobChangeCommand :
    description: Command name in Simple Tweaks.
    default: /phantomjob

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

UseSimpleTweaksCommand  = Config.Get("UseSimpleTweaksCommand")
JobChangeCommand        = Config.Get("JobChangeCommand")
SwitchedJob             = false
LogPrefix               = "[JobBuffs]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

KnowledgeCrystalBaseId  = 2007457
KnowledgeCrystalRange   = 4.8

------------------
--    Action    --
------------------

InquiringMindActionId           = 33
InquiringMindValidationTimeout  = 8
InquiringMindMinimumRemaining   = 29 * 60

----------------
--    Jobs    --
----------------

Jobs = {
    Freelancer   = { id =  0, statusId = 4242 },
    Knight       = { id =  1, statusId = 4358 },
    Berserker    = { id =  2, statusId = 4359 },
    Monk         = { id =  3, statusId = 4360 },
    Ranger       = { id =  4, statusId = 4361 },
    Samurai      = { id =  5, statusId = 4362 },
    Bard         = { id =  6, statusId = 4363 },
    Geomancer    = { id =  7, statusId = 4364 },
    TimeMage     = { id =  8, statusId = 4365 },
    Cannoneer    = { id =  9, statusId = 4366 },
    Chemist      = { id = 10, statusId = 4367 },
    Oracle       = { id = 11, statusId = 4368 },
    Thief        = { id = 12, statusId = 4369 },
    MysticKnight = { id = 13, statusId = 4803 },
    Gladiator    = { id = 14, statusId = 4804 },
    Dancer       = { id = 15, statusId = 4805 },
    Ninja        = { id = 16, statusId = 5328 },
    WhiteMage    = { id = 17, statusId = 5329 },
    BlackMage    = { id = 18, statusId = 5330 },
    Dragoon      = { id = 19, statusId = 5331 },
    Summoner     = { id = 20, statusId = 5332 },
    BlueMage     = { id = 21, statusId = 5333 },
    RedMage      = { id = 22, statusId = 5334 },
    Necromancer  = { id = 23, statusId = 5335 },
}

InquiringMindBuffs = {
    4233, -- Enduring Fortitude
    4239, -- Fleetfooted
    4244, -- Romeo's Ballad
    4799, -- Quicker Step
}

--=========================== FUNCTIONS ==========================--

------------------
--    Checks    --
------------------

function GetCurrentJobName()
    for jobName, job in pairs(Jobs) do
        if HasStatusId(job.statusId) then
            LogInfo(string.format("%s Detected current job as: %s", LogPrefix, jobName))
            return jobName
        end
    end

    LogInfo(string.format("%s No matching jobStatusId found", LogPrefix))
    return "Freelancer"
end

function IsNearKnowledgeCrystal()
    if not Player or not Player.Entity or not Player.Entity.Position then
        return false
    end

    if not Svc or not Svc.Objects or not Svc.Objects.Length then
        return false
    end

    local playerPos = Player.Entity.Position

    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]

        if obj and obj.Position then
            local ok, baseId = pcall(function()
                return tonumber(obj.BaseId)
            end)

            if ok and baseId == KnowledgeCrystalBaseId then
                local dx = playerPos.X - obj.Position.X
                local dz = playerPos.Z - obj.Position.Z
                local distance = math.sqrt(dx * dx + dz * dz)

                if distance <= KnowledgeCrystalRange then
                    LogInfo(string.format("%s Player is near a knowledge crystal object (BaseId %d, %.1f units)", LogPrefix, KnowledgeCrystalBaseId, distance))
                    return true
                end
            end
        end
    end

    LogInfo(string.format("%s No nearby knowledge crystal object found.", LogPrefix))
    return false
end

----------------
--    Jobs    --
----------------

function OpenSupportJob()
    while not IsAddonReady("MKDSupportJob") do
        Execute("/callback MKDInfo true 1 0")
        Wait(0.5)
    end
end

function OpenSupportJobList()
    while not IsAddonReady("MKDSupportJobList") do
        OpenSupportJob()
        Execute("/callback MKDSupportJob true 0 0 0")
        Wait(0.5)
    end
end

function ChangeSupportJob(jobName)
    local job = Jobs[jobName]
    if not job then
        LogInfo(string.format("%s Invalid job name: %s", LogPrefix, tostring(jobName)))
        return false
    end

    if HasStatusId(job.statusId) then
        LogInfo(string.format("%s Job '%s' is already active.", LogPrefix, jobName))
        return true
    end

    SwitchedJob = true

    if UseSimpleTweaksCommand then
        repeat
            Execute(string.format("%s %d", JobChangeCommand, job.id))
            Wait(0.5)
        until HasStatusId(job.statusId)
    else
        repeat
            OpenSupportJobList()
            Execute(string.format("/callback MKDSupportJobList true 0 %d", job.id))
            Wait(0.5)
        until HasStatusId(job.statusId)
    end

    LogInfo(string.format("%s Successfully changed support job to '%s'.", LogPrefix, jobName))
    return true
end

----------------
--    Buffs    --
----------------

function CastInquiringMind()
    if IsMounted() then
        Dismount()
    end

    while IsPlayerCasting() or IsOccupied() do
        Wait(0.1)
    end

    LogInfo(string.format("%s Applying Inquiring Mind.", LogPrefix))
    ExecuteGeneralAction(InquiringMindActionId)
end

function ValidateInquiringMindBuffs()
    local startTime = os.time()

    repeat
        for _, statusId in ipairs(InquiringMindBuffs) do
            local remaining = GetStatusTimeRemaining(statusId) or 0
            if HasStatusId(statusId) and remaining > InquiringMindMinimumRemaining then
                LogInfo(string.format("%s Inquiring Mind validated via status ID %s with %.0f seconds remaining.", LogPrefix, tostring(statusId), remaining))
                return true
            end
        end

        Wait(0.5)
    until (os.time() - startTime) >= InquiringMindValidationTimeout

    LogInfo(string.format("%s Inquiring Mind validation timed out after %d seconds.", LogPrefix, InquiringMindValidationTimeout))
    return false
end

--=========================== EXECUTION ==========================--

originalJob = GetCurrentJobName()
LogInfo(string.format("%s Original job: %s", LogPrefix, originalJob))

if IsNearKnowledgeCrystal() then
    LogInfo(string.format("%s Near a crystal, switching to Freelancer for Inquiring Mind.", LogPrefix))

    if ChangeSupportJob("Freelancer") then
        CastInquiringMind()
        ValidateInquiringMindBuffs()
    end
else
    LogInfo(string.format("%s Not near any crystal, skipping Inquiring Mind.", LogPrefix))
end

if SwitchedJob then
    LogInfo(string.format("%s Reverting to original job: %s", LogPrefix, originalJob))
    ChangeSupportJob(originalJob)
end

Echo("Job Buufs script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Job Buufs MGP script completed successfully..!!", LogPrefix))

--============================== END =============================--
