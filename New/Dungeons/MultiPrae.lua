--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Multi-Account Praetorium Farm – barebones automation script
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
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--============================= USAGE =============================--

--[[
Script to help farm The Praetorium with 4 accounts.

Configuration:
    repairThreshold   – Gear condition (%) at or below which we will repair.
                        Set to 0 to completely disable repairs.
    maxpraetime       – Maximum time in seconds to stay inside a Praetorium run
                        before abandoning it.

Requirements:

    General:
        - AutoDuty set up to run Praetorium, plus this SnD script.
        - All four characters should be in a cross-world party via Duty Finder
          (subscription required for cross-world party leadership), and parked
          somewhere out of sight, e.g., in an inn room.

        Alternative:
            You may also use a regular party and park everyone in some remote
            corner of the world where no one will realistically visit.
            In this case, repairs will not work, so set "repairThreshold" to 0.

    Rotation Solver Reborn (RSR):
        - Enable “Record knockback actions” under the "List" configuration.
          This helps prevent Nero from knocking you into bad positions.

    Automaton:
        Enhanced Duty Start/End:
            - Start options: /ad start
            - End options: /ad stop
            - Auto leave: enabled, 10 seconds

        Auto queue:
            - Enabled for party leader only
            - Disabled for all other party members

    YesAlready:
        - Under the "Bothers" tab, enable ContentsFinderConfirm handling.

    Simple Tweaks:
        - Enable the /leaveduty command for all characters.

Setup Flow:

    1. Put all four party members into a cross-world party and park them in an
       inn room (or a remote area as noted above).
    2. Configure AutoDuty:
       - Leader: Praetorium path with either unrestricted + level sync
         or a normal Praetorium run.
       - Set the tank to use the "tank" path.
       - All others use the "others" path (they’ll chill in the elevator).
    3. Start this script on the three non-leader accounts first.
    4. Start the script on the leader last, then queue Praetorium.

Stopping:
    - To stop farming:
        - Uncheck "auto queue" on the party leader’s Automaton.
        - Let the final run finish.
        - Stop this script on all accounts.

Party Composition (recommended):

    - 1x Tank:
        Any tank job.

    - 1x Healer:
        Scholar preferred (Sage or Astrologian are also fine).
        White Mage is not recommended due to long cast times, especially Holy.

    - 2x DPS:
        Any physical ranged or melee DPS.
        Avoid casters where possible, as cast time can be a liability.

    Extra RSR setup tips:
        - If using Reaper, disable Harpe in RSR (cast time is risky).
        - If using Scholar:
            * Set distance-to-target to ~2.6 in AutoDuty and BossMod
              to maximize Art of War usage.
            * Disable Adloquium, Physick, and Ruin in RSR (cast times).
            * Embrace, Lustrate, Whispering Dawn, and Succor should be enough.

Paths:
    - Tank: use the tank path (handles elevator interaction automatically).
    - Others: use the "others" path (they simply stay in the elevator).

    You can try "W2Wtank" for the tank to make the second pull slightly bigger;
    this may shave off ~30 seconds if your gear and comfort allow for it.
]]

--=========================== VARIABLES ===========================--

-------------------
--    General    --
-------------------

local repairThreshold   = 10        -- % at or below which we will repair gear (0 to disable repairs)
local maxpraetime       = 1200      -- Maximum time allowed inside Praetorium (in seconds) before abandoning
local zoneid            = 1044      -- Praetorium zone ID
local gearfine          = true      -- True when gear is in acceptable condition
local inprae            = 0         -- Approximate time spent in Praetorium (seconds)
local isdead            = 0         -- Counts consecutive seconds spent dead
local maxzone           = 0         -- Tracks maximum remaining time seen (for elapsed calculation)
local zoneleft          = 0         -- Remaining duty time from InstancedContent.ContentTimeLeft

--=========================== STARTUP =============================--

Execute("/bmrai on")
Execute("/rotation auto")

--=========================== EXECUTION ==========================--

while 1 == 1 do
    Wait(1)

    if IsInZone(zoneid) then
        -- Crude counter for time in Praetorium; refined below using duty timer
        inprae = inprae + 1
    end

    if IsPlayerAvailable() and not IsDead() then
        if IsInZone(zoneid) then
            zoneleft = InstancedContent.ContentTimeLeft

            if type(zoneleft) == "number" then
                -- Track the largest remaining time seen so far to derive elapsed time
                if zoneleft > maxzone then
                    maxzone = zoneleft
                end

                -- During the first 10 seconds, sync inprae with the duty timer
                if (maxzone - zoneleft) < 10 then
                    inprae = maxzone - zoneleft
                end
            end

            -- Pre-flag that we need repairs after this run
            if gearfine and repairThreshold > 0 and NeedsRepair(repairThreshold) then
                LogInfo("Need repairs after this run.")
                SetYesAlready(false)
                gearfine = false
            end

            -- If this Praetorium run is taking too long, bail out
            if inprae > maxpraetime then
                LogInfo("Run is taking too long, leaving instance.")
                LeaveInstance()
            end
        else
            -- Outside Praetorium
            if not gearfine then
                -- Attempt repairs if flagged
                Repair(repairThreshold)
                SetYesAlready(true)
            end

            if inprae > 0 then
                -- Stop AutoDuty if we had previously been in Praetorium
                Execute("/ad stop")
            end

            -- If we still have a ContentsFinderConfirm up, withdraw from it
            if IsAddonReady("ContentsFinderConfirm") then
                Wait(1)
                if IsAddonReady("ContentsFinderConfirm") then
                    Execute("/click ContentsFinderConfirm Withdraw")
                    SetYesAlready(true)
                end
            end

            -- This branch is effectively dead code as inprae never goes negative,
            -- but kept for compatibility with existing logic.
            if inprae < 0 then
                inprae = inprae + 1
            end
        end
    end

    -- Once we've been in Prae for a bit, handle confirm prompts and death
    if inprae > 10 and IsInZone(zoneid) then
        -- Auto-confirm typical yes/no prompts (e.g., elevator, cutscene skips)
        if IsAddonReady("SelectYesno") then
            Execute("/click SelectYesno Yes")
        end

        -- Track time spent dead; if dead for too long, log and optionally leave
        if IsDead() then
            isdead = isdead + 1
            if isdead > 120 then
                LogInfo("Dead for too long; consider leaving instance.")
                -- LeaveInstance()
            end
        else
            isdead = 0
        end
    end
end

--============================== END =============================--