--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Weekly Hunts Doer - A barebones script to accept Weekly Hunts
plugin_dependencies:
- BossModReborn
- Lifestream
- RotationSolver
- visland
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

LogPrefix  = "[WeeklyHunts]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState    = {}

local StopFlag    = false
local State       = nil
local BoardNumber = 1
local HuntNumber  = 0

-----------------------
--    Hunt Boards    --
-----------------------

HuntBoards = {
	{
		city          = "Ul'dah",
		zoneId        = 130,
		aetheryte     = "Ul'dah Aetheryte Plaza",
		boardName     = "Hunt Board",
		bills         = 2001362,
		x             = -151,
        y             =    4,
        z             =  -94,
	},
    {
        city          = "Ishgard",
        zoneId        = 418,
        aetheryte     = "Foundation",
        miniAethernet = {
            name      = "Forgotten Knight",
            x         =  45,
            y         =  24,
            z         =   0,
        },
        boardName     = "Clan Hunt Board",
        bills         = 2001703,
        x             =  73,
        y             =  24,
        z             =  22,
    },
    {
        city          = "Kugane",
        zoneId        = 628,
        aetheryte     = "Kugane",
        boardName     = "Clan Hunt Board",
        bills         = 2002116,
        x             = -32,
        y             =   0,
        z             = -44,
    },
    {
        city          = "Crystarium",
        zoneId        = 819,
        aetheryte     = "The Crystarium",
        miniAethernet = {
            name      = "Temenos Rookery",
            x         = -108,
            y         =   -1,
            z         =  -59,
        },
        boardName     = "Nuts Board",
        bills         = 2002631,
        x             =  -84,
        y             =   -1,
        z             =  -91,
    },
    {
        city          = "Old Sharlayan",
        zoneId        = 962,
        aetheryte     = "Old Sharlayan",
        miniAethernet = {
            name      = "Scholar's Harbor",
            x         =  16,
            y         = -17,
            z         = 127,
        },
        boardName     = "Guildship Hunt Board",
        bills         = 2003093,
        x             =  29,
        y             = -16,
        z             =  98,
    },
    {
        city          = "Tuliyollal",
        zoneId        = 1185,
        aetheryte     = "Tuliyollal",
        miniAethernet = {
            name      = "Bayside Bevy Marketplace",
            x         = -15,
            y         = -11,
            z         = 135,
        },
        boardName     = "Hunt Board",
        bills         = 2003513,
        x             =  25,
        y             = -15,
        z             = 135,
    },
}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function CharacterState.goToHuntBoardWeekly()
    if BoardNumber > #HuntBoards then
        State = CharacterState.endScriptWeekly
        LogInfo(string.format("%s State changed to: EndScriptWeekly", LogPrefix))
        Wait(0.5)
        return
    end

    Board = HuntBoards[BoardNumber]
    LogInfo(string.format("%s Checking board: %s", LogPrefix, Board.city))

    local skipBoard = true
    if GetItemCount(Board.bills) == 0 then
        skipBoard = false
    end

    LogInfo(string.format("%s skipBoard = %s", LogPrefix, tostring(skipBoard)))

    if skipBoard then
        BoardNumber = BoardNumber + 1
        return
    end

    if not IsInZone(Board.zoneId) then
        LogInfo(string.format("%s Not in %s, teleporting to %s", LogPrefix, Board.city, Board.aetheryte))
        Teleport(Board.aetheryte)
    end

    if Board.miniAethernet ~= nil then
        local distanceToBoard       = GetDistanceToPoint(Board.x, Board.y, Board.z)
        local distanceFromAethernet = DistanceBetween(Board.miniAethernet.x, Board.miniAethernet.y, Board.miniAethernet.z, Board.x, Board.y, Board.z)

        LogInfo(string.format("%s Distance to board: %.2f", LogPrefix, distanceToBoard))
        LogInfo(string.format("%s Distance from mini aetheryte: %.2f", LogPrefix, distanceFromAethernet))

        if distanceToBoard > (distanceFromAethernet + 20) then
            Target("Aetheryte")
            MoveToTarget("Aetheryte", 7)
            Wait(1)
            Teleport(Board.miniAethernet.name)
        end
    end

    if GetDistanceToPoint(Board.x, Board.y, Board.z) > 3 then
        if not PathIsRunning() and not PathfindInProgress() then
            MoveTo(Board.x, Board.y, Board.z, 3)
        end
    end

    if GetDistanceToPoint(Board.x, Board.y, Board.z) < 4 then
        State = CharacterState.pickUpHuntsWeekly
        LogInfo(string.format("%s State changed to: PickUpHuntsWeekly", LogPrefix))
    end
end

function CharacterState.pickUpHuntsWeekly()
    if HuntNumber >= 1 then
        if IsAddonReady("Mobhunt") or IsAddonReady("Mobhunt" .. BoardNumber) then
            local addonName = (BoardNumber == 1) and "Mobhunt" or ("Mobhunt" .. BoardNumber)
            Execute(string.format("/callback %s true -1", addonName))
        else
            HuntNumber = 0
            BoardNumber = BoardNumber + 1
            State = CharacterState.goToHuntBoardWeekly
            LogInfo(string.format("%s State changed to: GoToHuntBoardWeekly %d", LogPrefix, BoardNumber))
        end
        return
    end

    if IsAddonReady("SelectYesno") and GetNodeText("SelectYesno", 15) == "Pursuing a new mark will result in the abandonment of your current one. Proceed?" then
        Execute("/callback SelectYesno true 1")
        HuntNumber = HuntNumber + 1
        return
    end

    if IsAddonReady("SelectString") then
        local optionIndex = (BoardNumber == 1) and 1 or 3
        Execute(string.format("/callback SelectString true %s", optionIndex))
        return
    end

    if IsAddonReady("Mobhunt") or IsAddonReady("Mobhunt" .. BoardNumber) then
        local addonName = (BoardNumber == 1) and "Mobhunt" or ("Mobhunt" .. BoardNumber)
        Execute(string.format("/callback %s true 0", addonName))
        HuntNumber = HuntNumber + 1
        return
    end

    if Board and Board.boardName then
        Interact(Board.boardName)
    end
end

function CharacterState.endScriptWeekly()
    StopFlag = true
    LogInfo(string.format("%s Weekly hunt script ended.", LogPrefix))
end

--=========================== EXECUTION ==========================--

State = CharacterState.goToHuntBoardWeekly

while not StopFlag do
    State()
    Wait(0.1)
end

Echo("Weekly Hunts script completed successfully. All Marks Obtained..!!", LogPrefix)
LogInfo(string.format("%s Weekly Hunts script completed successfully. All Marks Obtained..!!", LogPrefix))

--============================== END =============================--