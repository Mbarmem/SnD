--[=====[
[[SND Metadata]]
author: Mo
version: 0.3.3
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
    description: Gear % at which to trigger repairs. Set to 0 to disable.
    default: 20
  RequiredPartySize:
    description: Required number of party members before queueing or accepting a duty.
    default: 4
    min: 1
    max: 8

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

PrimaryPlayer     = Config.Get("PrimaryPlayer")
ZoneID            = Config.Get("ZoneID")
MaxRuns           = Config.Get("MaxRuns")
Unsynced          = Config.Get("Unsynced")
DutyMode          = Config.Get("DutyMode")
MaxTime           = Config.Get("MaxTime")
RepairThreshold   = Config.Get("RepairThreshold")
RequiredPartySize = Config.Get("RequiredPartySize")
LogPrefix         = "[MultiAD]"

--============================ CONSTANT ==========================--

--------------------
--    Timeouts    --
--------------------

BoundTimeout    = 60
RunTimeout      = 1800
PartyCheckDelay = 2

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

function HasRequiredParty()
    return HasPartySize(RequiredPartySize)
end

function WaitForRequiredParty()
    local lastCount = -1

    while not HasRequiredParty() do
        local partyCount = GetPartyCount()

        if partyCount ~= lastCount then
            LogInfo(string.format("%s Waiting for required party size: %d / %d members.", LogPrefix, partyCount, RequiredPartySize))
            lastCount = partyCount
        end

        if AutoDutyIsRunning() then
            LogInfo(string.format("%s AutoDuty is running without the required party size. Stopping AutoDuty.", LogPrefix))
            AutoDutyStop()
        end

        Wait(PartyCheckDelay)
    end

    LogInfo(string.format("%s Required party size detected: %d / %d members.", LogPrefix, GetPartyCount(), RequiredPartySize))
end

--------------------------------------------------------------------

function WaitUntilBoundWithPartyCheck(timeout)
    local startTime = os.time()
    local lastPartyCount = RequiredPartySize

    while not IsBoundByDuty() do
        local partyCount = GetPartyCount()

        if partyCount ~= RequiredPartySize then
            if partyCount ~= lastPartyCount then
                LogInfo(string.format("%s Party changed while queueing: %d / %d members.", LogPrefix, partyCount, RequiredPartySize))
                lastPartyCount = partyCount
            end

            return false, "party"
        end

        if (os.time() - startTime) >= timeout then
            return false, "timeout"
        end

        Wait(1)
    end

    return true, nil
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
    LogInfo(string.format("%s Required party size: %d", LogPrefix, RequiredPartySize))

    local runCount = 0

    while MaxRuns == 0 or runCount < MaxRuns do
        WaitForRequiredParty()
        local nextRun = runCount + 1
        LogInfo(string.format("%s Preparing run %s / %s.", LogPrefix, tostring(nextRun), RunsText()))

        if RepairThreshold > 0 and NeedsRepair(RepairThreshold) then
            LogInfo(string.format("%s Gear below %d%% durability. Repairing before queueing.", LogPrefix, RepairThreshold))
            Repair(RepairThreshold)
            Wait(1)
        end

        AutoDutyConfig("Unsynced", tostring(Unsynced))
        Wait(2)
        AutoDutyConfig("dutyModeEnum", DutyMode)
        Wait(2)
        -- Final check after repairs and configuration.
        if not HasRequiredParty() then
            LogInfo(string.format("%s Party changed before AutoDuty start: %d / %d members. Cancelling attempt.", LogPrefix, GetPartyCount(), RequiredPartySize))
            AutoDutyStop()
            Wait(PartyCheckDelay)
        else
            LogInfo(string.format("%s Starting run %s / %s with %d party members.", LogPrefix, tostring(nextRun), RunsText(), GetPartyCount()))
            AutoDutyRun(ZoneID, 1, true)
            Wait(2)
            Execute("/bmrai on")
            Execute("/rotation auto")
            Wait(1)
            LogInfo(string.format("%s Waiting until bound by duty.", LogPrefix))
            local bound, failureReason = WaitUntilBoundWithPartyCheck(BoundTimeout)

            if not bound then
                if failureReason == "party" then
                    LogInfo(string.format("%s Required party size was lost before entering the duty. Stopping AutoDuty.", LogPrefix))
                else
                    LogInfo(string.format("%s Timed out waiting to be bound by duty. Aborting this attempt.", LogPrefix))
                end

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
                else
                    runCount = runCount + 1
                end

                Execute("/rotation off")
                WaitForPlayer()

                if not stuck then
                    LogInfo(string.format("%s Run finished %s / %s.", LogPrefix, tostring(runCount), RunsText()))
                end

                AutoDutyStop()
                Wait(5)
            end
        end
    end

    LogInfo(string.format("%s MaxRuns completed. Primary script finished.", LogPrefix))
    Echo("Multi-Account AutoDuty primary completed successfully..!!", LogPrefix)

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
    LogInfo(string.format("%s Required party size: %d", LogPrefix, RequiredPartySize))

    local gearFine = true
    local inDungeonTime = 0
    local isDeadTime = 0
    local maxZoneTime = 0
    local wasInDungeon = false

    Execute("/bmrai on")
    Execute("/rotation auto")

    while true do
        Wait(1)
        local currentlyInDungeon = IsInZone(ZoneID)

        -- Detect entry.
        if currentlyInDungeon and not wasInDungeon then
            LogInfo(string.format("%s Entered configured duty zone.", LogPrefix))
            Execute("/bmrai on")
            Execute("/rotation auto")
            wasInDungeon = true
            inDungeonTime = 0
            isDeadTime = 0
            maxZoneTime = 0
        end

        -- Detect exit before resetting counters.
        if not currentlyInDungeon and wasInDungeon then
            LogInfo(string.format("%s Left configured duty zone. Stopping AutoDuty.", LogPrefix))

            AutoDutyStop()
            Execute("/rotation off")
            wasInDungeon = false
            inDungeonTime = 0
            isDeadTime = 0
            maxZoneTime = 0
            WaitForPlayer()

            if not gearFine then
                LogInfo(string.format("%s Repairing degraded equipment after duty.", LogPrefix))
                Repair(RepairThreshold)
                SetYesAlready(true)
                gearFine = true
            end
        end

        if IsPlayerAvailable() and not IsDead() then
            if currentlyInDungeon then
                local zoneLeft = InstancedContent.ContentTimeLeft

                if type(zoneLeft) == "number" then
                    if zoneLeft > maxZoneTime then
                        maxZoneTime = zoneLeft
                    end

                    local elapsed = maxZoneTime - zoneLeft

                    if elapsed >= 0 then
                        inDungeonTime = elapsed
                    end
                else
                    inDungeonTime = inDungeonTime + 1
                end

                if gearFine
                    and RepairThreshold > 0
                    and NeedsRepair(RepairThreshold)
                then
                    LogInfo(string.format("%s Gear degraded. Will repair after this run.", LogPrefix))
                    SetYesAlready(false)
                    gearFine = false
                end

                if inDungeonTime > MaxTime then
                    LogInfo(string.format("%s Dungeon time limit exceeded. Leaving instance.", LogPrefix))
                    LeaveInstance()
                end
            else
                -- AutoDuty must not remain active outside the duty
                -- without the configured party size.
                if AutoDutyIsRunning() and not HasRequiredParty() then
                    LogInfo(string.format("%s AutoDuty is running without the required party size: %d / %d. Stopping.", LogPrefix, GetPartyCount(), RequiredPartySize))
                    AutoDutyStop()
                end

                if not gearFine then
                    LogInfo(string.format("%s Repairing degraded equipment.", LogPrefix))
                    Repair(RepairThreshold)
                    SetYesAlready(true)
                    gearFine = true
                end

                if IsAddonReady("ContentsFinderConfirm") then
                    Wait(1)

                    if IsAddonReady("ContentsFinderConfirm") then
                        local partyCount = GetPartyCount()

                        if HasRequiredParty() then
                            LogInfo(string.format("%s Duty confirm detected with %d / %d party members. Accepting.", LogPrefix, partyCount, RequiredPartySize))
                            Execute("/callback ContentsFinderConfirm Commence")
                            SetYesAlready(true)
                        else
                            LogInfo(string.format("%s Duty confirm detected without the required party size: %d / %d. Not accepting.", LogPrefix, partyCount, RequiredPartySize))
                            AutoDutyStop()
                        end
                    end
                end
            end
        end

        if currentlyInDungeon and inDungeonTime > 10 then
            if IsAddonReady("SelectYesno") then
                Execute("/click SelectYesno Yes")
            end

            if IsDead() then
                isDeadTime = isDeadTime + 1

                if isDeadTime == 120 then
                    LogInfo(string.format("%s Warning: Player has been dead for over 2 minutes.", LogPrefix))
                end
            else
                isDeadTime = 0
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
