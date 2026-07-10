--[=====[
[[SND Metadata]]
author: Mo
version: 0.3.0
description: Multi-Account AutoDuty Hybrid - Primary Runner + Secondary Monitor
plugin_dependencies:
- AutoDuty
- Automaton
- BossModReborn
- Lifestream
- RotationSolver
- SkipCutscene
- vnavmesh
- YesAlready
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  PrimaryPlayer:
    description: Enable this only on the primary/leader account.
    default: false
  ZoneID:
    description: The Zone ID / AutoDuty Duty ID of the dungeon to farm.
    default: 837
  MaxRuns:
    description: Number of runs to complete (primary role only). Set to 0 for infinite.
    default: 0
    min: 0
    max: 100
  Unsynced:
    description: Run duty unsynced (primary role only).
    default: false
  DutyMode:
    description: AutoDuty duty mode (primary role only).
    default: "Regular"
    is_choice: true
    choices:
      - "Regular"
      - "Duty Support"
      - "Trust"
      - "Scenario"
      - "Variant"
  MaxTime:
    description: Max time in dungeon before abandoning (secondary role only).
    default: 1800
  RepairThreshold:
    description: Gear % at which to trigger repairs (primary repairs before queueing, secondary repairs after leaving the dungeon). Set to 0 to disable.
    default: 20

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

PrimaryPlayer   = Config.Get("PrimaryPlayer")
ZoneID          = Config.Get("ZoneID")
MaxRuns         = Config.Get("MaxRuns")
Unsynced        = Config.Get("Unsynced")
DutyMode        = Config.Get("DutyMode")
MaxTime         = Config.Get("MaxTime")
RepairThreshold = Config.Get("RepairThreshold")
LogPrefix       = "[MultiAD]"

--============================ CONSTANT ==========================--

------------------
--    Timeouts   --
------------------

BoundTimeout = 60   -- seconds to wait for BoundByDuty before treating the queue as failed
RunTimeout   = 1800 -- seconds to wait for AutoDuty to finish before treating the run as stuck

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function RunsText()
    if MaxRuns == 0 then
        return "Infinite"
    end

    return tostring(MaxRuns)
end

-------------------
--    Primary    --
-------------------

function RunPrimary()
    LogInfo(string.format("%s Primary mode started.", LogPrefix))
    LogInfo(string.format("%s ZoneID/DutyID: %s", LogPrefix, tostring(ZoneID)))
    LogInfo(string.format("%s DutyMode: %s", LogPrefix, tostring(DutyMode)))
    LogInfo(string.format("%s Unsynced: %s", LogPrefix, tostring(Unsynced)))
    LogInfo(string.format("%s MaxRuns: %s", LogPrefix, RunsText()))

    local runCount = 0

    while MaxRuns == 0 or runCount < MaxRuns do
        runCount = runCount + 1

        LogInfo(string.format("%s Starting run %s / %s", LogPrefix, tostring(runCount), RunsText()))

        if RepairThreshold > 0 and NeedsRepair(RepairThreshold) then
            LogInfo(string.format("%s Gear below %d%% durability. Repairing before queueing.", LogPrefix, RepairThreshold))
            Repair(RepairThreshold)
            Wait(1)
        end

        AutoDutyConfig("Unsynced", tostring(Unsynced))
        Wait(2)

        AutoDutyConfig("dutyModeEnum", DutyMode)
        Wait(2)

        AutoDutyRun(ZoneID, 1, true)
        Wait(2)

        Execute("/bmrai on")
        Execute("/rotation auto")
        Wait(1)

        LogInfo(string.format("%s Waiting until bound by duty.", LogPrefix))
        local bound = WaitForCondition("BoundByDuty", true, BoundTimeout)

        if not bound then
            LogInfo(string.format("%s Timed out waiting to be bound by duty. Aborting this attempt.", LogPrefix))
            Execute("/rotation off")
            AutoDutyStop()
            Wait(5)
        else
            LogInfo(string.format("%s Bound by duty. Waiting for AutoDuty to finish.", LogPrefix))

            local startTime = os.time()
            local stuck = false

            while AutoDutyIsRunning() do
                if (os.time() - startTime) >= RunTimeout then
                    LogInfo(string.format("%s AutoDuty has been running for over %ds. Forcing stop.", LogPrefix, RunTimeout))
                    stuck = true
                    break
                end

                Wait(5)
            end

            if stuck then
                Execute("/rotation off")
                AutoDutyStop()
                Wait(5)
            end

            Execute("/rotation off")
            WaitForPlayer()

            LogInfo(string.format("%s Run finished %s / %s", LogPrefix, tostring(runCount), RunsText()))

            AutoDutyStop()
            Wait(5)
        end
    end

    LogInfo(string.format("%s MaxRuns completed. Primary script finished.", LogPrefix))
    Echo(string.format("Multi-Account AutoDuty primary completed successfully..!!"), LogPrefix)

    while true do
        Wait(30)
    end
end

---------------------
--    Secondary    --
---------------------

function RunSecondary()
    LogInfo(string.format("%s Secondary mode started.", LogPrefix))
    LogInfo(string.format("%s ZoneID: %s", LogPrefix, tostring(ZoneID)))
    LogInfo(string.format("%s MaxTime: %s", LogPrefix, tostring(MaxTime)))
    LogInfo(string.format("%s RepairThreshold: %s", LogPrefix, tostring(RepairThreshold)))

    local gearFine  = true
    local inDungeon = 0
    local isDead    = 0
    local maxZone   = 0
    local zoneLeft  = 0

    Execute("/bmrai on")
    Execute("/rotation auto")

    while true do
        Wait(1)

        if IsInZone(ZoneID) then
            inDungeon = inDungeon + 1
        end

        if IsPlayerAvailable() and not IsDead() then
            if IsInZone(ZoneID) then
                zoneLeft = InstancedContent.ContentTimeLeft

                if type(zoneLeft) == "number" then
                    if zoneLeft > maxZone then
                        maxZone = zoneLeft
                    end

                    if (maxZone - zoneLeft) < 10 then
                        inDungeon = maxZone - zoneLeft
                    end
                end

                if gearFine and RepairThreshold > 0 and NeedsRepair(RepairThreshold) then
                    LogInfo(string.format("%s Gear degraded. Will repair after this run.", LogPrefix))
                    SetYesAlready(false)
                    gearFine = false
                end

                if inDungeon > MaxTime then
                    LogInfo(string.format("%s Dungeon time limit exceeded. Leaving instance.", LogPrefix))
                    LeaveInstance()
                end
            else
                if not gearFine then
                    Repair(RepairThreshold)
                    SetYesAlready(true)
                    gearFine = true
                end

                if inDungeon > 0 then
                    AutoDutyStop()
                    inDungeon = 0
                    maxZone = 0
                end

                if IsAddonReady("ContentsFinderConfirm") then
                    Wait(1)

                    if IsAddonReady("ContentsFinderConfirm") then
                        LogInfo(string.format("%s Duty confirm detected. Accepting.", LogPrefix))
                        Execute("/callback ContentsFinderConfirm Commence")
                        SetYesAlready(true)
                    end
                end
            end
        end

        if inDungeon > 10 and IsInZone(ZoneID) then
            if IsAddonReady("SelectYesno") then
                Execute("/click SelectYesno Yes")
            end

            if IsDead() then
                isDead = isDead + 1

                if isDead > 120 then
                    LogInfo(string.format("%s Warning: Player has been dead for over 2 minutes.", LogPrefix))
                end
            else
                isDead = 0
            end
        end
    end
end

--=========================== EXECUTION ==========================--

if PrimaryPlayer then
    RunPrimary()
else
    RunSecondary()
end

--============================== END =============================--
