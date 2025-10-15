--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Job Cycle - Script for Gold Mission
plugin_dependencies:
- Artisan
- AutoHook
- ICE
- Lifestream
- vnavmesh
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

IdleSeconds = 120
LogPrefix   = "[CosmicCycle]"

--============================ CONSTANT ==========================--

----------------
--    Jobs    --
----------------

Order = {
    "Carpenter",
    "Blacksmith",
    "Armorer",
    "Goldsmith",
    "Leatherworker",
    "Weaver",
    "Alchemist",
    "Culinarian",
    "Miner",
    "Botanist",
    "Fisher"
}

----------------
--  Job Keys  --
----------------

CanonicalByKey = {
    carpenter      = "Carpenter",      crp = "Carpenter",
    blacksmith     = "Blacksmith",     bsm = "Blacksmith",
    armorer        = "Armorer",        arm = "Armorer",
    goldsmith      = "Goldsmith",      gsm = "Goldsmith",
    leatherworker  = "Leatherworker",  ltw = "Leatherworker",
    weaver         = "Weaver",         wvr = "Weaver",
    alchemist      = "Alchemist",      alc = "Alchemist",
    culinarian     = "Culinarian",     cul = "Culinarian",
    miner          = "Miner",          min = "Miner",
    botanist       = "Botanist",       btn = "Botanist",
    fisher         = "Fisher",         fsh = "Fisher",
}

--=========================== FUNCTIONS ==========================--

------------------
--   Utility    --
------------------

function JobCycleNowMS()
    local ok,socket = pcall(require, "socket")
    if ok and socket and socket.gettime then
        return math.floor(socket.gettime() * 1000)
    end

    return math.floor(os.clock() * 1000)
end

function JobCycleGetPos()
    local playerPos = Player and Player.Entity and Player.Entity.Position
    if playerPos then
        return playerPos.X, playerPos.Y, playerPos.Z
    end
end

function JobCycleJobId()
    local playerJobId = Player and Player.Job and Player.Job.Id
    if playerJobId then
        return playerJobId
    end
end

function JobCycleCurrentJob()
    local id = JobCycleJobId()
    if not id then
        return nil
    end

    return Player.Job.Name
end

function JobCycleCanonicalJob(job)
    if not job then
        return nil
    end

    local key
    if type(job) == "string" then
        key = job
    elseif type(job) == "table" then
        key = job.Name or job.Abbreviation or ""
    else
        key = tostring(job or "")
    end

    key = key:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if key == "" then
        return nil
    end

    return CanonicalByKey[key]
end

local idx = 1
function JobCycleIndex(t,v)
    for i, x in ipairs(t) do
        if x == v then
            return i
        end
    end
end

function JobCycleNextJob()
    local j = Order[idx]
    idx = (idx % #Order) + 1
    return j
end

--=========================== EXECUTION ==========================--

do
    local job       = JobCycleCurrentJob()
    local detected  = JobCycleCanonicalJob(job)
    LogInfo(string.format("%s Startup: JobId=%s, Name=%s", LogPrefix, tostring(JobCycleJobId()), tostring(job or "nil")))

    if detected then
        local i = JobCycleIndex(Order,detected) or 0
        idx = (i % #Order) + 1
        LogInfo(string.format("%s Starting after %s → next %s", LogPrefix, detected, Order[idx]))
    else
        LogInfo(string.format("%s Could not map current job; starting from head.", LogPrefix))
    end
end

local pendingStartICE = false
if IsPlayerAvailable() then
    LogInfo(string.format("%s Free at startup → /ice start", LogPrefix))
    Execute("/ice start")
else
    LogInfo(string.format("%s Busy at startup → will start ICE when free.", LogPrefix))
    pendingStartICE = true
end

local last_active = JobCycleNowMS()
local px, py, pz  = JobCycleGetPos()

while true do
    local x, y, z = JobCycleGetPos()

    local moved=false
    if px and x and pz and z then
        local dx = x - px
        local dy = y - py
        local dz = z - pz
        moved = (dx * dx + dy * dy + dz * dz) > (0.02 * 0.02)
    end

    if moved or not IsPlayerAvailable() then
        last_active = JobCycleNowMS()
        px, py, pz = x, y, z
    end

    if pendingStartICE and IsPlayerAvailable() then
        LogInfo(string.format("%s Became free → /ice start", LogPrefix))
        Execute("/ice start")
        pendingStartICE = false
        last_active = JobCycleNowMS()
    end

    if (JobCycleNowMS() - last_active) >= (IdleSeconds * 1000) and IsPlayerAvailable() then
        local target = JobCycleNextJob()
        LogInfo(string.format("%s Idle ≥ %ds & free → /gs change %s + /ice start", LogPrefix, IdleSeconds, target))
        Execute(string.format('/gs change %s', target))
        Wait(1.5)

        if IsPlayerAvailable() then
            Execute('/ice start')
        else
            LogInfo(string.format("%s Became busy during swap → delaying ICE.", LogPrefix))
        end

        last_active = JobCycleNowMS()
    end

    Wait(1)
end

Echo(string.format("Cosmic Job Cycle script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Cosmic Job Cycle script completed successfully..!!", LogPrefix))

--============================== END =============================--