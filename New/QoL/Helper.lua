--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Helper - Quick utility script for coordinates and zone checks
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  LocationInfo:
    description: Whether to print a grouped location info snapshot.
    default: false
  TargetInfo:
    description: Whether to print a grouped target info snapshot.
    default: false
  ZoneInfo:
    description: Whether to print a grouped zone info snapshot.
    default: false
  CurrentCoordinates:
    description: Whether to print the current player coordinates.
    default: false
  TargetCoordinates:
    description: Whether to print the current target coordinates.
    default: false
  TargetName:
    description: Whether to print the current target name.
    default: false
  DistanceToTarget:
    description: Whether to print the current distance to target.
    default: false
  CurrentZoneID:
    description: Whether to print the current zone ID.
    default: false
  ClassJobID:
    description: Whether to print the current class or job ID.
    default: false
  AetheryteName:
    description: Whether to print the current zone aetheryte name.
    default: false
[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LocationInfo            = Config.Get("LocationInfo")
TargetInfo              = Config.Get("TargetInfo")
ZoneInfo                = Config.Get("ZoneInfo")
CurrentCoordinates      = Config.Get("CurrentCoordinates")
TargetCoordinates       = Config.Get("TargetCoordinates")
TargetName              = Config.Get("TargetName")
DistanceToTarget        = Config.Get("DistanceToTarget")
CurrentZoneID           = Config.Get("CurrentZoneID")
ClassJobID              = Config.Get("ClassJobID")
AetheryteName           = Config.Get("AetheryteName")
LogPrefix               = "[Helper]"

--=========================== FUNCTIONS ==========================--

function PrintCurrentCoordinates()
    local position = GetPlayerPosition()

    if not position then
        Echo("Current player position is not available.", LogPrefix)
        LogInfo(string.format("%s Current player position is not available.", LogPrefix))
        return
    end

    local message = string.format("Current Coordinates: X=%.2f, Y=%.2f, Z=%.2f", position.X, position.Y, position.Z)
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintLocationInfo()
    Echo("Location Info:", LogPrefix)
    LogInfo(string.format("%s Location Info:", LogPrefix))

    PrintCurrentCoordinates()
    PrintClassJobID()
end

function PrintTargetCoordinates()
    local target = Entity and Entity.Target

    if not target or not target.Position then
        Echo("No valid target found.", LogPrefix)
        LogInfo(string.format("%s No valid target found.", LogPrefix))
        return
    end

    local message = string.format(
        "Target Coordinates [%s]: X=%.2f, Y=%.2f, Z=%.2f",
        tostring(target.Name),
        target.Position.X,
        target.Position.Y,
        target.Position.Z
    )

    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintTargetInfo()
    Echo("Target Info:", LogPrefix)
    LogInfo(string.format("%s Target Info:", LogPrefix))

    PrintTargetName()
    PrintTargetCoordinates()
    PrintDistanceToTarget()
end

function PrintTargetName()
    local name = GetTargetName()

    if not name then
        Echo("No valid target found.", LogPrefix)
        LogInfo(string.format("%s No valid target found.", LogPrefix))
        return
    end

    local message = string.format("Target Name: %s", tostring(name))
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintDistanceToTarget()
    local distance = GetDistanceToTarget()

    if not distance then
        Echo("Distance to target is not available.", LogPrefix)
        LogInfo(string.format("%s Distance to target is not available.", LogPrefix))
        return
    end

    local message = string.format("Distance To Target: %.2f", distance)
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintCurrentZoneID()
    local message = string.format("Current Zone ID: %d", GetZoneID())
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintZoneInfo()
    Echo("Zone Info:", LogPrefix)
    LogInfo(string.format("%s Zone Info:", LogPrefix))

    PrintCurrentZoneID()
    PrintAetheryteName()
end

function PrintClassJobID()
    local jobId = GetClassJobId()

    if not jobId then
        Echo("Current class or job ID is not available.", LogPrefix)
        LogInfo(string.format("%s Current class or job ID is not available.", LogPrefix))
        return
    end

    local message = string.format("Current ClassJob ID: %d", jobId)
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

function PrintAetheryteName()
    local aetheryteName = GetAetheryteName(GetZoneID())

    if not aetheryteName then
        Echo("Current zone aetheryte name is not available.", LogPrefix)
        LogInfo(string.format("%s Current zone aetheryte name is not available.", LogPrefix))
        return
    end

    local message = string.format("Current Aetheryte Name: %s", tostring(aetheryteName))
    Echo(message, LogPrefix)
    LogInfo(string.format("%s %s", LogPrefix, message))
end

--=========================== EXECUTION ==========================--

if not LocationInfo and not TargetInfo and not ZoneInfo and not CurrentCoordinates and not TargetCoordinates and not TargetName and not DistanceToTarget and not CurrentZoneID and not ClassJobID and not AetheryteName then
    Echo("No helper actions enabled. Script stopped..!!", LogPrefix)
    LogInfo(string.format("%s No helper actions enabled. Script stopped..!!", LogPrefix))
    StopRunningMacros()
    return
end

if LocationInfo then
    PrintLocationInfo()
end

if TargetInfo then
    PrintTargetInfo()
end

if ZoneInfo then
    PrintZoneInfo()
end

if CurrentCoordinates then
    PrintCurrentCoordinates()
end

if TargetCoordinates then
    PrintTargetCoordinates()
end

if TargetName then
    PrintTargetName()
end

if DistanceToTarget then
    PrintDistanceToTarget()
end

if CurrentZoneID then
    PrintCurrentZoneID()
end

if ClassJobID then
    PrintClassJobID()
end

if AetheryteName then
    PrintAetheryteName()
end

Echo("Helper script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Helper script completed successfully..!!", LogPrefix))

--============================== END =============================--
