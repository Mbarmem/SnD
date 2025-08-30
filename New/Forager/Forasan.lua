--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Forasan - Script for Looping GBR and Artisan
plugin_dependencies:
- Artisan
- GatherbuddyReborn
- Lifestream
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  ArtisanList:
    description: Id of Artisan list

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

ArtisanList   = Config.Get("ArtisanList")
LogPrefix     = "[Forasan]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    FreeCompany = 342
}

--=========================== FUNCTIONS ==========================--

-------------------
--    Utility    --
-------------------

function PlayerAvailable()
    return Entity ~= nil
        and Entity.Player ~= nil
        and Entity.Player.Position ~= nil
        and Player.Available
        and not LifestreamIsBusy()
end

function SafeGetPos()
    if not PlayerAvailable() then
        return nil
    end

    local currentPos = Entity.Player.Position
    if currentPos.X == nil or currentPos.Y == nil or currentPos.Z == nil then
        return nil
    end

    return currentPos
end

function SafeIsMounted()
    if not PlayerAvailable() then
        return false
    end

    return IsMounted()
end

function SafeIsGathering()
    if not PlayerAvailable() then
        return false
    end

    return IsGathering()
end

function MovedEnough(a, b)
    return (math.abs(a.X - b.X) > 0.5)
        or (math.abs(a.Y - b.Y) > 0.5)
        or (math.abs(a.Z - b.Z) > 0.5)
end

function CheckIdleWindow(startPos)
    local invalidReads = 0
    local window = 10

    for i = 1, window do
        Wait(1)

        if not PlayerAvailable() then
            LogInfo(string.format("%s Player context lost at t=%ds → aborting idle check.", LogPrefix, i))
            return false
        end

        local currentPos = SafeGetPos()
        if not currentPos then
            invalidReads = invalidReads + 1
            LogInfo(string.format("%s Invalid currentPos at t=%ds (%d/3).", LogPrefix, i, invalidReads))

            if invalidReads >= 3 then
                LogInfo(string.format("%s Too many invalid reads → aborting idle check.", LogPrefix))
                return false
            end

        elseif MovedEnough(startPos, currentPos) then
            LogInfo(string.format("%s Player moved after %ds → cancelling idle check.", LogPrefix, i))
            return false
        end
    end

    return true, window
end

--=========================== EXECUTION ==========================--

::MainLoop::

while true do
    local available = PlayerAvailable()

    if IsInZone(Zones.FreeCompany) and available then
        LogInfo(string.format("%s Entered zone %d with player available → executing artisan start.", LogPrefix, Zones.FreeCompany))
        Execute(string.format("/artisan lists %s start", ArtisanList))

        local startClock = os.clock()
        local started = false
        repeat
            Wait(1)
            if ArtisanIsListRunning() then
                started = true
                break
            end
        until (os.clock() - startClock) > 20

        if not started then
            LogInfo(string.format("%s Artisan list did not start within 20s → resuming idle loop.", LogPrefix))
        else
            LogInfo(string.format("%s Artisan list is running → moving to post-loop handling.", LogPrefix))
            break
        end
    end

    if not available then
        LogInfo(string.format("%s Idle check skipped → Player not available (zoning/loading?).", LogPrefix))
        Wait(1)

    elseif SafeIsMounted() then
        LogInfo(string.format("%s Skipping check → Player is mounted.", LogPrefix))
        Wait(1)

    elseif SafeIsGathering() then
        LogInfo(string.format("%s Skipping check → Player is gathering.", LogPrefix))
        Wait(1)

    else
        local startPos = SafeGetPos()
        if not startPos then
            LogInfo(string.format("%s Idle check skipped → Invalid start position.", LogPrefix))
            Wait(1)
        else
            LogInfo(string.format("%s Idle check started. Monitoring player position...", LogPrefix))
            local idle, window = CheckIdleWindow(startPos)

            if idle then
                if not SafeIsGathering() and PlayerAvailable() and not IsPlayerCasting() then
                    LogInfo(string.format("%s Player idle for %ds → executing Jump action.", LogPrefix, window))
                    Actions.ExecuteGeneralAction(CharacterAction.GeneralActions.jump)
                else
                    LogInfo(string.format("%s Player idle but currently gathering/unavailable → skipping Jump.", LogPrefix))
                end
            end
        end
    end

    Wait(1)
end

if ArtisanIsListRunning() then
    Wait(1)
    local artisanTimeout = os.clock()

    repeat
        Wait(1)
        if IsCrafting() then
            LogInfo(string.format("%s Crafting detected → waiting until it finishes.", LogPrefix))
            while IsCrafting() do
                Wait(1)
            end
            LogInfo(string.format("%s Crafting finished → proceeding to GBR.", LogPrefix))
            break
        else
            LogInfo(string.format("%s Waiting for crafting to start... %ds elapsed", LogPrefix, math.floor(os.clock() - artisanTimeout)))
        end
    until (os.clock() - artisanTimeout) > 20

    if not IsCrafting() then
        LogInfo(string.format("%s Timeout: Crafting did not start within 20s → closing addons and resuming.", LogPrefix))
        Wait(1)
        CloseAddons()
        WaitForPlayer()
    end

    Execute("/gbr auto on")
    LogInfo(string.format("%s Activated GBR auto → returning to main loop.", LogPrefix))
    Wait(3)
    WaitForTeleport()
    goto MainLoop
end

--============================== END =============================--