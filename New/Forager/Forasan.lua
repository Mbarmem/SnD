--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Forasan - Script for Looping GBR and Artisan
plugin_dependencies:
- Artisan
- GatherBuddyReborn
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

LogPrefix  = "[Forasan]"

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

    if IsInZone(342) and available then
        LogInfo(string.format("%s Entered zone 342 with player available → executing artisan start and stopping loop.", LogPrefix))
        Execute("/artisan lists 28694 start")
        break
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
                    Actions.ExecuteGeneralAction(2) -- Jump
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
    local ArtisanTimeoutStartTime = os.clock()
    repeat
        Wait(1)
    until (os.clock() - ArtisanTimeoutStartTime) > 20 or IsCrafting()

    if not IsCrafting() then
        Wait(1)
        CloseAddons()
        WaitForPlayer()
    end

    Execute("/gbr auto on")
    Wait(1)
    WaitForTeleport()
    goto MainLoop
end

--============================== END =============================--