--[[

***********************************************
*              Crescent Occult                *
*          Script for Auto Farming            *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

]]

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

local MountCommand = '/mount "Air-wheeler A9"';
local LogPrefix = "[FufuCEFarm] ";
local Actions = {
  OccultReturn = 41343,
};

----------------
--    Zone    --
----------------

local ZoneID = GetZoneID();
local Zones = {
  SouthHorn = 1252,
};
local Aetherytes = {
  [Zones.SouthHorn] = {
    Northwest = {
      name = "The Wanderer's Haven",
    },
    West = {
      name = "Crystallized Caverns",
    },
    Southwest = {
      name = "Stonemarsh",
    },
    Southeast = {
      name = "Eldergrowth",
    },
    Home = {
      name = "Expedition Base Camp",
      coord = { 831, 73, -699 },
    },
  },
};
local CEData = {
  [Zones.SouthHorn] = {
    name = "South Horn",
    aetherytes = Aetherytes[Zones.SouthHorn],
    ceList = {
      [1] = {
        eventID = 1,
        name = "Scourge of the Mind",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 302, 70, 732 },
      },
      [2] = {
        eventID = 2,
        name = "The Black Regiment",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 447, 65, 357 },
      },
      [3] = {
        eventID = 3,
        name = "The Unbridled",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 618, 79, 803 },
      },
      [4] = {
        eventID = 4,
        name = "Crawling Death",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 682, 74, 533 },
      },
      [5] = {
        eventID = 5,
        realType = 1,
        name = "Calamity Bound",
        aetheryte = Aetherytes[Zones.SouthHorn].Southwest,
        coord = { -338, 75, 802 },
      },
      [6] = {
        eventID = 6,
        name = "Trial by Claw",
        aetheryte = Aetherytes[Zones.SouthHorn].West,
        coord = { -410, 92, 66 },
      },
      [7] = {
        eventID = 7,
        name = "From Times Bygone",
        aetheryte = Aetherytes[Zones.SouthHorn].Southwest,
        coord = { -799, 44, 250 },
      },
      [8] = {
        eventID = 8,
        realType = 3,
        name = "Company of Stone",
        aetheryte = Aetherytes[Zones.SouthHorn].Home,
        coord = { 679, 96, -279 },
      },
      [9] = {
        eventID = 9,
        name = "Shark Attack",
        aetheryte = Aetherytes[Zones.SouthHorn].Northwest,
        coord = { -116, 1, -851 },
      },
      [10] = {
        eventID = 10,
        name = "On the Hunt",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 639, 108, -49 },
      },
      [11] = {
        eventID = 11,
        name = "With Extreme Prejudice",
        aetheryte = Aetherytes[Zones.SouthHorn].Northwest,
        coord = { -349, 5, -605 },
      },
      [12] = {
        eventID = 12,
        name = "Noise Complaint",
        aetheryte = Aetherytes[Zones.SouthHorn].Home,
        coord = { 461, 97, -361 },
      },
      [13] = {
        eventID = 13,
        name = "Cursed Concern",
        aetheryte = Aetherytes[Zones.SouthHorn].Northwest,
        coord = { 75, 20, -544 },
      },
      [14] = {
        eventID = 14,
        name = "Eternal Watch",
        aetheryte = Aetherytes[Zones.SouthHorn].Southeast,
        coord = { 883, 122, 192 },
      },
      [15] = {
        eventID = 15,
        name = "Flame of Dusk",
        aetheryte = Aetherytes[Zones.SouthHorn].West,
        coord = { -572, 97, -160 },
      },
    },
  },
};

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "RotationSolver",
	"BossModReborn",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "YesAlready"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    mounted=4,
    inCombat=26,
    casting=27,
    boundByDuty=34,
    occupied=39,
    betweenAreas=45
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [CEFarm] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [CEFarm] Stopping the script..!!")
        yield("/snd stop")
    end
end

----------------
--    Wait    --
----------------

function waitWhileMoving()
  LogVerbose(LogPrefix .. "Waiting until navigation is finished...");
  yield("/wait 1");
  while (PathIsRunning() or PathfindInProgress()) do
    yield("/wait 0.5");
  end
  LogVerbose(LogPrefix .. "Navigation finished!");
end

function awaitReady()
  -- Verify not in combat or occupied
  LogVerbose(LogPrefix .. "Waiting until player is available...");
  while GetCharacterCondition(CharacterCondition.inCombat) == true or IsPlayerAvailable() == false or IsMoving() == true do
    yield("/wait 0.5");
  end
  LogVerbose(LogPrefix .. "Player is available!");

  -- Verify navmesh is ready
  if NavIsReady() == false then
    LogDebug(LogPrefix .. "Building Mesh Please wait...");
    while NavIsReady() == false do
      yield("/wait 0.5");
    end
    LogDebug(LogPrefix .. "Mesh is Ready!");
  end

  -- buffer
  yield("/wait 0.2");
end

function AwaitCEPop()
  while true do
    local ceList = GetOccultCrescentEvents();
    for i = 0, ceList.Count - 1 do
      local eventid = tonumber(ceList[i]);
      if GetOccultCrescentEventState(eventid) == "Register" then
        local ce = CEData[ZoneID].ceList[eventid];
        if ce ~= nil then
          LogDebug(LogPrefix .. "Found active CE: " .. ce.name);
          return ce;
        end
      end
    end
    LogVerbose(LogPrefix .. "CE condition not met. Checking again in 3 seconds...");
    yield("/wait 3");
  end
end

----------------
--    Move    --
----------------

function MoveTo(x, y, z, randomness)
  local randX = rand(x, randomness);
  local randZ = rand(z, randomness);
  awaitReady();
  LogVerbose(LogPrefix .. "Moving to coords: " .. tostring(randX) .. ", " .. tostring(y) .. ", " .. tostring(z));
  yield('/vnav moveto ' .. randX .. ' ' .. y .. ' ' .. randZ)
  waitWhileMoving();
end

function MoveToCE(activeCE)
  local eventid = activeCE.eventID;
  local x = GetOccultCrescentEventLocationX(eventid);
  local y = GetOccultCrescentEventLocationY(eventid);
  local z = GetOccultCrescentEventLocationZ(eventid);
  MoveTo(x, y, z, 7);
end

-----------------
--    Mount    --
-----------------

function mountUp()
  -- Mount up
  LogVerbose(LogPrefix .. "Mounting...");
  while GetCharacterCondition(CharacterCondition.mounted) == false do
    yield(MountCommand);
    yield("/wait 3");
  end
  LogVerbose(LogPrefix .. "Mounted!");
end

function dismount()
  -- Dismount
  LogVerbose(LogPrefix .. "Dismounting...");
  while GetCharacterCondition(CharacterCondition.mounted) do
    yield("/gaction Dismount");
    yield("/wait 0.5")
  end
  LogVerbose(LogPrefix .. "Dismounted!");
end

----------------
--    Misc    --
----------------

function rand(value, range)
  local offset = (range * 2) * math.random();
  local randnum = (value - range) + offset;
  return randnum;
end

----------------
--    Main    --
----------------

function GoToCE(activeCE)
  LogDebug(LogPrefix .. "Going to CE...");
  awaitReady()
  
  -- go to aetheryte
  LogVerbose(LogPrefix .. "Navigating next to home aetheryte...");
  local homeCoord = Aetherytes[ZoneID].Home.coord;
  MoveTo(homeCoord[1], homeCoord[2], homeCoord[3], 0.5);
  LogVerbose(LogPrefix .. "Finished navigating to home aetheryte");

  -- use aetheryte
  if activeCE.aetheryte.name ~= Aetherytes[ZoneID].Home.name then
    dismount();
    LogVerbose(LogPrefix .. "Using aetheryte to go to " .. activeCE.aetheryte.name .. "...");
    yield("/li " .. activeCE.aetheryte.name);
    yield("/wait 3");
  end
  awaitReady();

  -- navigate to CE
  LogVerbose(LogPrefix .. "Navigating to CE...");
  mountUp();
  MoveToCE(activeCE);
  LogVerbose(LogPrefix .. "Finished navigating to CE");

  -- dismount();
  LogDebug(LogPrefix .. "Got to CE!");
  return true;
end

function AwaitCEFinish(activeCE)
  LogVerbose(LogPrefix .. "Waiting for CE to finish...");
  while GetOccultCrescentEventState(activeCE.eventID) ~= "Inactive" do
    local eventState = GetOccultCrescentEventState(activeCE.eventID);
    LogVerbose(LogPrefix .. "CE still active. Checking again in 5 seconds...");
    yield("/wait 5");
  end
  LogDebug(LogPrefix .. "CE Finished!");
  yield("/wait " .. rand(3, 1));
  awaitReady()
  return true;
end

function GoHome()
  LogDebug(LogPrefix .. "Going home...");
  LogVerbose(LogPrefix .. "Too far away from destination. Teleporting...");
  ExecuteAction(Actions.OccultReturn);
  while GetCharacterCondition(CharacterCondition.betweenAreas) == false do
    yield("/wait 0.2");
  end
  awaitReady();
  mountUp();
  awaitReady();
  LogDebug(LogPrefix .. "Got home!");
  return true;
end

function StartFarm()
  local ceCount = 0;
  LogInfo(LogPrefix .. "Starting CE farm");
  yield("/bmrai on");

  while true do
    local activeCE = AwaitCEPop();
    GoToCE(activeCE);
    AwaitCEFinish(activeCE);
    GoHome();

    yield("/wait 1");
  end

  yield("/bmrai off");
  LogInfo(LogPrefix .. "Stopping CE farm. Total CEs: " .. ceCount);
  return ceCount;
end

-------------------------------- Execution --------------------------------

Plugins();
StartFarm();

----------------------------------- End -----------------------------------