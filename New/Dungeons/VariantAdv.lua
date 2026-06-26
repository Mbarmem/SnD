--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Dungeon Farm for TT Cards - A barebones script
plugin_dependencies:
- AutoDuty
- Automaton
- BossMod
- Lifestream
- RotationSolver
- SkipCutscene
- TextAdvance
- vnavmesh
- YesAlready
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  PrimaryPlayer:
    description: If true, this character handles route-start interactions while the secondary waits.
    default: false
  RepairThreshold:
    description: Repairs gear after each run when durability falls below this percentage. Set to 0 to disable.
    default: 20
    min: 0
    max: 100

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

RunsPlayed          = 0
State               = nil
DeadStartedAt       = nil
RecoverAfterDeath   = false
QueueInitialized    = false
CombatStarted       = false
RouteSelected       = false
PrimaryPlayer       = Config.Get("PrimaryPlayer")
RepairThreshold     = Config.Get("RepairThreshold")
LogPrefix           = "[Variant]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

-----------------
--    Zones    --
-----------------

Zones = {
    MerchantTale = {
        Id   = 1316,
        Name = "The Merchant's Tale",
    },
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function RotationON()
    LogInfo(string.format("%s Setting rotation to Auto mode...", LogPrefix))
    Execute("/rotation auto LowHP")
    Wait(0.5)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    Execute("/vbmai on")
    Wait(0.5)
end

function SetState(newState)
    State = newState
    QueueInitialized = false
    CombatStarted = false
    DeadStartedAt = nil
    RecoverAfterDeath = false
    RouteSelected = false
    LogInfo(string.format("%s State changed -> %s", LogPrefix, GetStateName(newState)))
end

function GetStateName(state)
    for name, fn in pairs(CharacterState) do
        if fn == state then
            return name
        end
    end

    return tostring(state)
end

function IsPartnerReady()
    local partner = Entity.NearestOtherCharacter
    if not partner then
        return false
    end

    if partner.CurrentHp <= 0 then
        return false
    end

    if not partner.IsTargetable then
        return false
    end

    return true
end

----------------
--    Duty    --
----------------

function CharacterState.QueueForDuty()
    if IsInZone(Zones.MerchantTale.Id) then
        SetState(CharacterState.EnterVariant)
        return
    end

    if not IsPlayerAvailable() then
        return
    end

    if not QueueInitialized then
        Teleport("auto")
        WaitForLifestream()
        WaitForPlayer()

        while not IsPartnerReady() do
            Wait(1)
        end

        QueueInitialized = true
    end

    if PrimaryPlayer and not IsAddonReady("VVDFinder") then
        Execute("/hold CONTROL")
        Execute("/send L")
        Wait(1.5)
        Execute("/release CONTROL")
        Wait(1)
    end

    if not PrimaryPlayer and IsAddonReady("ContentsFinderConfirm") then
        Execute("/callback ContentsFinderConfirm Commence")
        Wait(1)
    end

    if PrimaryPlayer and IsAddonReady("VVDFinder") then
        Execute("/callback VVDFinder true 12")
        SetState(CharacterState.EnterVariant)
    elseif not PrimaryPlayer and (IsBoundByDuty() or IsBetweenAreas()) then
        SetState(CharacterState.EnterVariant)
    end
end

function CharacterState.EnterVariant()
    if IsInZone(Zones.MerchantTale.Id) then
        SetState(CharacterState.StartRoute)
        return
    end

    if WaitForAddon("ContentsFinderConfirm", 3) then
        Execute("/callback ContentsFinderConfirm Commence")
        Wait(2)
    end
end

function CharacterState.StartRoute()
    if not IsPlayerAvailable() then
        return
    end

    if not IsPartnerReady() then
        Wait(1)
        return
    end

    if WaitForAddon("VVDVoteRoute", 3) then
        Execute("/callback VVDVoteRoute true 1 1")
        Wait(1)
        RouteSelected = true
        return
    elseif PrimaryPlayer and MoveToTarget("The Merchant's Tale: Abridged", 3) then
        Wait(0.3)
        Interact("The Merchant's Tale: Abridged")
        return
    end

    if not RouteSelected then
        Wait(1)
        return
    end

    if MoveToTarget("Aetherial Flow", 3) then
        Wait(0.3)
        Interact("Aetherial Flow")
        Wait(5)
        WaitForPlayer()
        SetState(CharacterState.KillBoss)
    end
end

function CharacterState.KillBoss()
    local boss = Entity.GetEntityByName("Pari of Plenty")

    if IsDead() then
        DeadStartedAt = DeadStartedAt or os.time()

        if os.time() - DeadStartedAt >= 30 and IsAddonReady("SelectYesno") then
            while IsDead() and IsAddonReady("SelectYesno") do
                Execute("/callback SelectYesno true 0")
                Wait(0.1)
            end

            RecoverAfterDeath = true
            Wait(1)
        end

        Wait(1)
        return
    end

    DeadStartedAt = nil

    if not IsPlayerAvailable() then
        return
    end

    if RecoverAfterDeath then
        if not IsPartnerReady() then
            Wait(1)
            return
        end

        if MoveToTarget("Shortcut", 3) then
            Wait(0.3)
            Interact("Shortcut")
            if WaitForAddon("SelectYesno", 3) then
                Execute("/callback SelectYesno true 0")
                Wait(1)
            end

            WaitForPlayer()
            RecoverAfterDeath = false
            CombatStarted = false
        else
            Wait(1)
        end
        return
    end

    if not IsPartnerReady() then
        Wait(1)
        return
    end

    if not CombatStarted then
        if MoveToTarget("Pari of Plenty") or IsInCombat() or Target("Pari of Plenty") then
            CombatStarted = true
        else
            Wait(1)
        end
        return
    end

    if not IsInCombat() and (not boss or (boss.CurrentHp ~= nil and boss.CurrentHp <= 0)) then
        SetState(CharacterState.LootChest)
        return
    end

    Wait(2)
end

function CharacterState.LootChest()
    if IsPlayerAvailable() and MoveToTarget("Personal Spoils", 3) then
        Wait(0.3)
        Interact("Personal Spoils")
        Wait(1)
        SetState(CharacterState.LeaveRun)
    end
end

function CharacterState.LeaveRun()
    if not IsInZone(Zones.MerchantTale.Id) then
        if RepairThreshold > 0 then
            Repair(RepairThreshold)
        end

        RunsPlayed = RunsPlayed + 1
        LogInfo(string.format("%s Runs played: %s", LogPrefix, RunsPlayed))
        SetState(CharacterState.QueueForDuty)
        return
    end

    if IsPlayerAvailable() and LeaveInstance() then
        Wait(1)
    end

    Wait(2)
end

--=========================== EXECUTION ==========================--

RotationON()
AiON()
SetState(CharacterState.QueueForDuty)

while true do
    State()
    Wait(1)
end

--============================== END =============================--
