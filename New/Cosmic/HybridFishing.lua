--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Cosmic Exploration - Hybrid Fishing and Crafting
plugin_dependencies:
- AutoHook
- Artisan
- Lifestream
- vnavmesh
- ICE
dependencies:
- source: ''
  name: SnD
  type: git
configs:
  WeatherSelection:
    default: Normal
    description: Specifies the desired weather type. Options - All, Normal, Moon, Umbral.
    type: string
    required: true
  RepairThreshold:
    default: 20
    description: Durability percentage at which tools should be repaired.
    type: int
    min: 0
    max: 100
  ExtractMateria:
    default: true
    description: Automatically extract materia from fully spiritbonded gear.
    type: boolean

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

WeatherSelection          = Config.Get("WeatherSelection")
RepairThreshold           = Config.Get("RepairThreshold")
ExtractMateria            = Config.Get("ExtractMateria")
LogPrefix                 = "[HybridFishing]"

FisherNormalMissionName   = "A-2: Refined Moon Gel"
FisherNormalCoords        = "/coord 15.8 19.4"
FisherNormalPreset        = "A-2: Refined Moon Gel"
FisherNormalItem          = 45922
FisherNormalAmount        = 2

FisherMoonMissionName     = "A-3: Eel Rations"
FisherMoonCoords          = "/coord 7.0 9.4"
FisherMoonPreset          = ""
FisherMoonItem            = 45934
FisherMoonAmount          = 2

FisherUmbralMissionName   = ""
FisherUmbralCoords        = ""
FisherUmbralPreset        = ""
FisherUmbralItem          = 0
FisherUmbralAmount        = 0

local missionName         = ""
local SuccessCount        = 0
local coords              = ""
local preset              = ""
local itemId              = 0
local itemAmount          = 0
local classId             = Player.Job.Id
local weatherId           = Instances.EnvManager.ActiveWeather
local previousWeatherType = ""

--=========================== FUNCTIONS ==========================--

function Init()
    if classId == 18 then
        Class = Player.Gearset.Name

        local weatherData = {
            Normal = {
                missionName = FisherNormalMissionName,
                coords = FisherNormalCoords,
                preset = FisherNormalPreset,
                itemId = FisherNormalItem,
                itemAmount = FisherNormalAmount
            },
            Moon = {
                missionName = FisherMoonMissionName,
                coords = FisherMoonCoords,
                preset = FisherMoonPreset,
                itemId = FisherMoonItem,
                itemAmount = FisherMoonAmount
            },
            Umbral = {
                missionName = FisherUmbralMissionName,
                coords = FisherUmbralCoords,
                preset = FisherUmbralPreset,
                itemId = FisherUmbralItem,
                itemAmount = FisherUmbralAmount
            }
        }

        local selectedType = WeatherSelection == "All" and previousWeatherType or WeatherSelection
        local data = weatherData[selectedType]

        if data then
            missionName = data.missionName
            coords = data.coords
            preset = data.preset
            itemId = data.itemId
            itemAmount = data.itemAmount
        end
    else
        LogInfo(string.format("%s Wrong Class!!!", LogPrefix))
        return false
    end
    return true
end

function GetWeatherType(weatherId)
    if weatherId == 148 then
        return "Moon"
    elseif weatherId == 49 then
        return "Umbral"
    else
        return "Normal"
    end
end

function MoveToSpot()
    Lifestream("Cosmic")
    WaitForLifeStream()
    Wait(1)
    MoveTo(-89.203, -3.337, -27.259)
    WaitForPathRunning()
    yield("/ice start")
end

function WaitForFishingItem(maxWaitSeconds)
    local waitElapsed = 0
    local retryCount = 0
    local maxRetries = 3

    SetAutoHookPreset(preset)
    SetAutoHookState(true)
    Wait(1)

    while not IsFishing() and retryCount < maxRetries do
        LogInfo(string.format("%s Attempting to start fishing (retry %d)", LogPrefix, retryCount))
        yield("/ahstart")
        Wait(5)
        retryCount = retryCount + 1
    end

    if not IsFishing() then
        LogInfo(string.format("%s Fishing did not start after retries.", LogPrefix))
        return false
    end

    LogInfo(string.format("%s Waiting to obtain item ID %s x%d", LogPrefix, tostring(itemId), itemAmount))
    while GetItemCount(itemId) < itemAmount and waitElapsed < maxWaitSeconds do
        Wait(1)
        waitElapsed = waitElapsed + 1
    end

    if GetItemCount(itemId) < itemAmount then
        SetAutoHookState(false)
        Wait(1)
        while IsGathering() do
            yield("/ac Quit")
            Wait(0.1)
        end
        LogInfo(string.format("%s Timeout acquiring item ID %s", LogPrefix, tostring(itemId)))
        return false
    end

    if IsFishing() then
        LogInfo(string.format("%s Still in fishing mode, waiting to exit.", LogPrefix))
        Wait(1)
        while IsFishing() do
            Wait(0.1)
        end
    end

    LogInfo(string.format("%s Successfully acquired required items.", LogPrefix))
    return true
end

function StartCrafting()
    if not IsAddonReady("WKSRecipeNotebook") then
        if not IsAddonReady("WKSMissionInfomation") then
            yield("/callback WKSHud true 11")
            Wait(0.2)
        end

        if not IsAddonReady("WKSRecipeNotebook") then
            yield("/callback WKSMissionInfomation true 14 1")
        end
    end

    Wait(0.5)
    LogInfo(string.format("%s Crafting..", LogPrefix))
    ArtisanSetEnduranceStatus(true)
    Wait(10)

    while ArtisanGetEnduranceStatus() do
        Wait(0.5)
    end

    LogInfo(string.format("%s Crafting completed successfully.", LogPrefix))
    Wait(1)
end

function SubmitReport()
    LogInfo(string.format("%s Reporting the Mission..", LogPrefix))
    if not IsAddonReady("WKSMissionInfomation") then
        yield("/callback WKSHud true 11")
        Wait(0.2)
    end

    if IsAddonReady("WKSRecipeNotebook") then
        yield("/callback WKSMissionInfomation true 14 1")
    end

    while IsCrafting() do
        Wait(0.1)
    end

    Wait(1)
    LogInfo(string.format("%s Changing Gearset to %s", LogPrefix, tostring(Class)))
    yield("/gs change "..Class)
    Wait(1)
    yield("/callback WKSMissionInfomation true 11 1")
    Wait(1)
end

--=========================== EXECUTION ==========================--

previousWeatherType = GetWeatherType(weatherId)
if Init() then
    LogInfo(string.format("%s MissionName: %s", LogPrefix, tostring(missionName)))
    LogInfo(string.format("%s MissionCoords: %s", LogPrefix, tostring(coords)))
    LogInfo(string.format("%s MissionPreset: %s", LogPrefix, tostring(preset)))
else
    return
end

while true do
    if SuccessCount == 0 then
        MoveToSpot()
        MoveTo(-264.005, 22.156, -94.770)
        WaitForPathRunning()
    elseif SuccessCount == 5 then
        MoveTo(-297.165, 22.075, -91.238)
        WaitForPathRunning()
    elseif SuccessCount == 10 then
        MoveTo(-269.529, 26.526, -132.304)
        MoveTo(-277.559, 26.449, -134.192)
        WaitForPathRunning()
    end

    local currentWeatherType = GetWeatherType(Instances.EnvManager.ActiveWeather)
    local currentMissionName = ""

    if WeatherSelection == "All" then
        if (currentWeatherType ~= previousWeatherType) then
            return
        end
    end

    while (currentMissionName ~= missionName) do
        Wait(0.5)
        if IsAddonReady("WKSMissionInfomation") then
            currentMissionName = GetNodeText("WKSMissionInfomation", 1, 3)
        end
    end

    Wait(1)
    if not WaitForFishingItem(500) then
        LogInfo(string.format("%s Fishing step failed or timed out.", LogPrefix))
        WaitForPlayer()
        SubmitReport()
        SuccessCount = 0
    elseif GetItemCount(itemId) >= itemAmount then
        LogInfo(string.format("%s Sufficient items available, starting crafting.", LogPrefix))
        WaitForPlayer()
        StartCrafting()
        SubmitReport()
        SuccessCount = SuccessCount + 1
        LogInfo(string.format("%s SuccessCount: %s", LogPrefix, tostring(SuccessCount)))
    end

    WaitForPlayer()
    Repair(RepairThreshold)
    MateriaExtraction(ExtractMateria)

    if SuccessCount == 15 then
        SuccessCount = 0
    end
end

--============================== END =============================--