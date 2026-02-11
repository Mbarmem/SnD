--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Gear Synchronizer.
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

LogPrefix = "[GearSync]"

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

--=========================== FUNCTIONS ==========================--

function UpdateJobGear(job)
    if not job or not job.id then return end

    -- 1. Switch to the Gear Set ID
    Execute(string.format("/gs change %d", job.id))
    Wait(2.5)

    -- 2. Validate current job matches the table
    local currentJobName = Player.Job.Name

    if currentJobName:lower() ~= job.name:lower() then
        LogInfo(string.format("%s [SKIP] ID #%d is %s, expected %s.", LogPrefix, job.id, currentJobName, job.name))
        return -- Break out of this job update and move to the next
    end

    -- 3. If validation passes, proceed with update
    LogInfo(string.format("%s [MATCH] Updating gear for %s...", LogPrefix, job.name))

    Execute("/equiprecommended")
    Wait(1.5)

    Execute(string.format("/gs save %d", job.id))
    LogInfo(string.format("%s [SUCCESS] %s (Set #%d) updated and saved.", LogPrefix, job.name, job.id))

    Wait(1.0)
end

--=========================== EXECUTION ==========================--

do
    LogInfo(string.format("%s Starting batch gear synchronization...", LogPrefix))

    for _, job in ipairs(Jobs) do
        UpdateJobGear(job)
    end
end


Echo("Gear synchronization complete!", LogPrefix)
LogInfo(string.format("%s Process finished.", LogPrefix))

--============================== END =============================--