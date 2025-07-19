--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Daily Hunts Doer - A barebones script to accept Daily Hunts
plugin_dependencies:
- vnavmesh
- Lifestream
- TeleporterPlugin
dependencies:
- source: ''
  name: SnD
  type: git

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

LogPrefix  = "[DailyHunts]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterStates   = {}

local StopFlag    = false
local State       = nil
local BoardNumber = 1
local HuntNumber  = 0

-----------------------
--    Hunt Boards    --
-----------------------

HuntBoards = {
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
        bills         = { 2001700, 2001701, 2001702 },
        x             =  73,
        y             =  24,
        z             =  22,
    },
    {
        city          = "Kugane",
        zoneId        = 628,
        aetheryte     = "Kugane",
        boardName     = "Clan Hunt Board",
        bills         = { 2002113, 2002114, 2002115 },
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
        bills         = { 2002628, 2002629, 2002630 },
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
        bills         = { 2003090, 2003091, 2003092 },
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
        bills         = { 2003510, 2003511, 2003512 },
        x             =  25,
        y             = -15,
        z             = 135,
    },
}

--=========================== FUNCTIONS ==========================--

----------------
--    Main    --
----------------

function CharacterStates.goToHuntBoard()
    if BoardNumber > #HuntBoards then
        State = CharacterStates.endScript
        LogInfo(string.format("%s State Change: EndScript", LogPrefix))
        Wait(0.5)
        return
    end

    Board = HuntBoards[BoardNumber]
    LogInfo(string.format("%s Checking board: %s", LogPrefix, Board.city))

    local skipBoard = true
    for _, bill in ipairs(Board.bills) do
        if GetItemCount(bill) == 0 then
            skipBoard = false
        end
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
            WaitForPathRunning()
            Wait(1)
            Lifestream(Board.miniAethernet.name)
            WaitForLifeStream()
        end
    end

    if GetDistanceToPoint(Board.x, Board.y, Board.z) > 3 then
        if not PathIsRunning() and not PathfindInProgress() then
            MoveTo(Board.x, Board.y, Board.z, 3)
            WaitForPathRunning()
        end
    end

    if GetDistanceToPoint(Board.x, Board.y, Board.z) < 4 then
        BoardNumber = BoardNumber + 1
        State = CharacterStates.pickUpHunts
        LogInfo(string.format("%s State Change: PickUpHunts", LogPrefix))
    end
end

function CharacterStates.pickUpHunts()
    if HuntNumber >= #Board.bills then
        if IsAddonVisible("Mobhunt" .. BoardNumber) then
            local callback = "/callback Mobhunt"..BoardNumber.." true -1"
            yield(callback)
        else
            HuntNumber = 0
            State = CharacterStates.goToHuntBoard
            LogInfo(string.format("%s State Change: GoToHuntBoard %d", LogPrefix, BoardNumber))
        end

    elseif GetItemCount(Board.bills[HuntNumber+1]) >= 1 then
        HuntNumber = HuntNumber + 1

    elseif IsAddonVisible("SelectYesno") and GetNodeText("SelectYesno", 15) == "Pursuing a new mark will result in the abandonment of your current one. Proceed?" then
        yield("/callback SelectYesno true 1")
        HuntNumber = HuntNumber + 1

    elseif IsAddonVisible("SelectString") then
        local callback = "/callback SelectString true "..HuntNumber
        yield(callback)

    elseif IsAddonVisible("Mobhunt"..BoardNumber) then
        Clicks = 0
        while Clicks < 4 do
            local callback = "/callback Mobhunt"..BoardNumber.." true 1"
            Wait(0.5)
            yield(callback)
            Clicks = Clicks + 1
        end
        Wait(0.5)
        local callback = "/callback Mobhunt"..BoardNumber.." true 0"
        yield(callback)
        HuntNumber = HuntNumber + 1

    else
        Interact(Board.boardName)
    end
end

function CharacterStates.endScript()
    StopFlag = true
end

--=========================== EXECUTION ==========================--

State = CharacterStates.goToHuntBoard

while not StopFlag do
    State()
    Wait(0.1)
end

Echo("Daily Hunts script completed successfully. All Marks Obtained..!!", LogPrefix)
LogInfo(string.format("%s Daily Hunts script completed successfully. All Marks Obtained..!!", LogPrefix))

--============================== END =============================--