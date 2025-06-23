--[[
  Name: HybridGathererCraftAndSubmit
  Author: SubaruYashiro
  Version: 2.3
  
  Requirements:
    -> Artisan
    -> SomethingNeedDoing (Expanded Edition) (Testing Version) v12.0.0.0
    -> (Optional) Pandora's Box
    -> (Optional) ChatCoordinates
    -> (Optional) V(ery) Island | Make your own route
    -> (Optional) Ice's Cosmic Exploration | Run with this to auto grab missions
 
  Pandora's Box:
  - Disable Auto Interact
  - Enable Quick Gather with Pandora Gathering, Remember Item, and Bountiful Harvest/Yield
  
  Make sure you're on SomethingNeedDoing (Expanded Edition) and it's in testing version, it should be around v12.0.0.0

  Very Island Preset (Copy each line and import):
  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
]]

-- Plugin Checks
HasArtisan = HasPlugin("Artisan")
HasPandoraBox = HasPlugin("PandorasBox")
HasChatCoordinates = HasPlugin("ChatCoordinates")
HasVisland = HasPlugin("visland")
--HasICE = HasPlugin("ExplorersIcebox")

-- Settings
BotanistGearset = "Botanist" -- Your Botanist Gearset Name
MinerGearset = "Miner" -- Your Miner Gearset Name
ShowNameAndCoords = HasChatCoordinates
NormalMode = true
MinGP = 400

-- Variables, editable
MinerNormalMissionName = "A-2: Soothing Censers" -- MIN/GSM
MinerNormalItem = 48655
MinerNormalCoords = "/coord 7.7 6.4"

MinerMoonMissionName = "A-3: Lunar Leather" -- MIN/LTW
MinerMoonItem = 48653
MinerMoonCoords = "/coord 22.9 11.8"

MinerUmbralMissionName = "A-3: High-quality Floor Tiling" -- MIN/WVR
MinerUmbralItem = 48725
MinerUmbralCoords = "/coord 8.1 11.1"

BotanistNormalMissionName = "A-2: Lunar Tanning Agents" -- BTN/LTW
BotanistNormalItem = 48675
BotanistNormalCoords = "/coord 27.1 23.6"

BotanistMoonMissionName = "A-3: Lunar Tools" -- BTN/CRP
BotanistMoonItem = 48691
BotanistMoonCoords = "/coord 30.6 26.3"

BotanistUmbralMissionName = "A-3: High Burn Furnace" -- BTN/ARM
BotanistUmbralItem = 48697
BotanistUmbralCoords = "/coord 33.6 30.8"

itemId = 0
missionName = ""
coords = ""

classId = GetClassJobId()
weatherId = GetActiveWeatherID()
previousWeatherType = ""

-- Functions
local function init()
  if classId == 16 then
    class = MinerGearset
    
    if not NormalMode then
      if previousWeatherType == "Normal" then
        itemId = MinerNormalItem
        missionName = MinerNormalMissionName
        coords = MinerNormalCoords
      elseif previousWeatherType == "Moon" then
        itemId = MinerMoonItem
        missionName = MinerMoonMissionName
        coords = MinerMoonCoords
      elseif previousWeatherType == "Umbral" then
        itemId = MinerUmbralItem
        missionName = MinerUmbralMissionName
        coords = MinerUmbralCoords
      end
    else
      itemId = MinerNormalItem
      missionName = MinerNormalMissionName
      coords = MinerNormalCoords
    end
  elseif classId == 17 then
    class = BotanistGearset
    
    if not NormalMode then
      if previousWeatherType == "Normal" then
        itemId = BotanistNormalItem
        missionName = BotanistNormalMissionName
        coords = BotanistNormalCoords
      elseif previousWeatherType == "Moon" then
        itemId = BotanistMoonItem
        missionName = BotanistMoonMissionName
        coords = BotanistMoonCoords
      elseif previousWeatherType == "Umbral" then
        itemId = BotanistUmbralItem
        missionName = BotanistUmbralMissionName
        coords = BotanistUmbralCoords
      end
    else
      itemId = BotanistNormalItem
      missionName = BotanistNormalMissionName
      coords = BotanistNormalCoords
    end
  else
    yield("Wrong Class")
    return false
  end
  
  return true
end

local function getWeatherType(weatherId)
    if weatherId == 148 then
        return "Moon"
    elseif weatherId == 49 then
        return "Umbral"
    else
        return "Normal"
    end
end

local function startCrafting()
  if not IsAddonVisible("WKSRecipeNotebook") then
    if not IsAddonVisible("WKSMissionInfomation") then
      yield("/callback WKSHud true 11")
      yield("/wait 0.2")
    end
  
    if not IsAddonVisible("WKSRecipeNotebook") then
      yield("/callback WKSMissionInfomation true 14 1")
    end
  end
  
  yield("/wait 0.5")
  
  ArtisanSetEnduranceStatus(true)
end

local function submitReport()
  if not IsAddonVisible("WKSMissionInfomation") then
    yield("/callback WKSHud true 11")
    yield("/wait 0.2")
  end

  if IsAddonVisible("WKSRecipeNotebook") then
    yield("/callback WKSMissionInfomation true 14 1")
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end

  yield("/gs change " ..class)
  yield("/wait 1")
  yield("/callback WKSMissionInfomation true 11 1")
end

local function abandonMission()
  if not IsAddonVisible("WKSMissionInfomation") then
    yield("/callback WKSHud true 11")
    yield("/wait 0.2")
  end

  if IsAddonVisible("WKSRecipeNotebook") then
    yield("/callback WKSMissionInfomation true 14 1")
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end

  yield("/gs change " ..class)
  yield("/wait 1")
  yield("/callback WKSMissionInfomation true 12 1")
  yield("/wait 0.5")
  yield("/callback SelectYesno true 0")
end
-- End of Functions

previousWeatherType = getWeatherType(weatherId)
if init() then
  if ShowNameAndCoords then
    yield(missionName)
    yield(coords)
  end
  
  if not HasArtisan then
    return
  end
else
  return
end

if HasPandoraBox then
  PandoraSetFeatureState("Auto-Cordial", true)
end

while true do
  ::restart::
  local currentWeatherType = getWeatherType(GetActiveWeatherID())
  local currentMissionName = ""
  local timerCheck = 240 -- 2 minutes failsafe check for gathering item
  
  if not NormalMode then
    if (currentWeatherType ~= previousWeatherType) then
      VislandStopRoute()
      return
    end
  end
  
  while (currentMissionName ~= missionName) do
    yield("/wait 0.5")
    if IsAddonVisible("WKSMissionInfomation") then
      currentMissionName = GetNodeText("WKSMissionInfomation", 29)
    elseif not IsAddonVisible("WKSMissionInfomation") then
      yield("/callback WKSHud true 11")
      yield("/wait 0.2")
    end
  end
  
  if GetItemCount(itemId) >= 18 then
    goto craft
  elseif GetGp() < MinGP then
    yield("Waiting for GP to reach " ..MinGP)
  end
  
  while GetGp() < MinGP do
    yield("/wait 0.5")
  end
    
  if HasVisland and VislandIsRoutePaused() then
    VislandSetRoutePaused(false)
  end

  yield("Trying to get Item until 18")
  while GetItemCount(itemId) < 18 do
    yield("/wait 0.5")
    timerCheck = timerCheck - 1
    if timerCheck <= 0 then
      if HasVisland and IsVislandRouteRunning() then
        VislandSetRoutePaused(true)
      end
      yield("Ran out of time, restarting")
      abandonMission()
      
      goto restart
    end
  end
  
  ::craft::
  
  if HasVisland and IsVislandRouteRunning() then
    VislandSetRoutePaused(true)
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end
  
  startCrafting()
  yield("/wait 2")
  
  while ArtisanGetEnduranceStatus() do
    yield("/wait 0.5")
  end
  
  if IsNotCrafting() then
    submitReport()
  end
end