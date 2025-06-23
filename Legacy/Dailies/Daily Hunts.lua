--[[

***********************************************
*              Daily Hunts Doer               *
*  A barebones script to accept Daily Hunts.  *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

            *********************
            *  Required Plugins *
            *********************

Plugins that are used are:
    -> Vnavmesh
    -> Teleporter
    -> Lifestream

]]

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh"
}

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    casting=27,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    beingMoved=70
}

-----------------------
--    Hunt Boards    --
-----------------------

HuntBoards =
{
    {
        city = "Ishgard",
        zoneId = 418,
        aetheryte = "Foundation",
        miniAethernet = {
            name = "Forgotten Knight",
            x=45, y=24, z=0
        },
        boardName = "Clan Hunt Board",
        bills = { 2001700, 2001701, 2001702 },
        x=73, y=24, z=22,
    },
    {
        city = "Kugane",
        zoneId = 628,
        aetheryte = "Kugane",
        boardName = "Clan Hunt Board",
        bills = { 2002113, 2002114, 2002115 },
        x=-32, y=0, z=-44
    },
    {
        city = "Crystarium",
        zoneId = 819,
        aetheryte = "The Crystarium",
        miniAethernet = {
            name = "Temenos Rookery",
            x=-108, y=-1, z=-59
        },
        boardName = "Nuts Board",
        bills = { 2002628, 2002629, 2002630 },
        x=-84, y=-1, z=-91
    },
    {
        city = "Old Sharlayan",
        zoneId = 962,
        aetheryte = "Old Sharlayan",
        miniAethernet = {
            name = "Scholar's Harbor",
            x=16, y=-17, z=127
        },
        boardName = "Guildship Hunt Board",
        bills = { 2003090, 2003091, 2003092 },
        x=29, y=-16, z=98
    },
    {
        city = "Tuliyollal",
        zoneId = 1185,
        aetheryte = "Tuliyollal",
        miniAethernet = {
            name = "Bayside Bevy Marketplace",
            x=-15, y=-11, z=135
        },
        boardName = "Hunt Board",
        bills = { 2003510, 2003511, 2003512 },
        x=25, y=-15, z=135
    }
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [DailyHunts] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [DailyHunts] Stopping the script..!!")
        yield("/snd stop")
    end
end

----------------
--    Move    --
----------------

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[DailyHunts] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[DailyHunts] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastStuckCheckTime = os.clock()
    LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}
end

function GetClosestAetheryte(x, y, z, zoneId, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    local aetheryteIds = GetAetherytesInZone(zoneId)
    for i=0, aetheryteIds.Count-1 do
        local aetheryteCoords = GetAetheryteRawPos(aetheryteIds[i])
        local aetheryte =
        {
            aetheryteId = aetheryteIds[i],
            aetheryteName = GetAetheryteName(aetheryteIds[i]),
            x = aetheryteCoords.Item1,
            z = aetheryteCoords.Item2
        }

        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        -- LogInfo("[DailyHunts] Distance via aetheryte #"..aetheryte.aetheryteId.." adjusted for tp penalty is "..tostring(comparisonDistance))
        -- LogInfo("[DailyHunts] AetheryteX: "..aetheryte.x..", AetheryteZ: "..aetheryte.z)

        if comparisonDistance < closestTravelDistance then
            -- LogInfo("[DailyHunts] Updating closest aetheryte to #"..aetheryte.aetheryteId)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestAetheryte
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = x + (x_adjust * math.cos(angle))
    local randomY = y + maxDistance
    local randomZ = z + (z_adjust * math.sin(angle))

    return randomX, randomY, randomZ
end

----------------
--    Main    --
----------------

BoardNumber = 1
function GoToHuntBoard()
    if BoardNumber > #HuntBoards then
        State = EndScript
        LogInfo("[DailyHunts] State Change: EndScript")
        return
    end

    Board = HuntBoards[BoardNumber]
    local skipBoard = true
    for _, bill in ipairs(Board.bills) do
        if GetItemCount(bill) == 0 then
            skipBoard = false
        end
    end
    if not LogInfo("[DailyHunts] Check SkipBoard") and skipBoard then
        BoardNumber = BoardNumber + 1
    elseif not LogInfo("[DailyHunts] Check ZoneId") and not IsInZone(Board.zoneId) then
        TeleportTo(Board.aetheryte)
    elseif not LogInfo("[DailyHunts] Check Distance to Board") and Board.miniAethernet ~= nil and GetDistanceToPoint(Board.x, Board.y, Board.z) > (DistanceBetween(Board.miniAethernet.x, Board.miniAethernet.y, Board.miniAethernet.z, Board.x, Board.y, Board.z) + 20) then
        LogInfo("[DailyHunts] Distance to board is: "..GetDistanceToPoint(Board.x, Board.y, Board.z))
        LogInfo("[DailyHunts] Distance between board and mini aetheryte: "..DistanceBetween(Board.miniAethernet.x, Board.miniAethernet.y, Board.miniAethernet.z, Board.x, Board.y, Board.z))
        yield("/target aetheryte")
        yield("/wait 0.5")
        if GetDistanceToTarget() > 7 then
            PathMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
            yield("/li "..Board.miniAethernet.name)
            yield("/wait 5")
        end
    elseif IsAddonVisible("TelepotTown") then
        yield("/callback TelepotTown true -1")
    elseif GetDistanceToPoint(Board.x, Board.y, Board.z) > 3 then
        if not PathIsRunning() and not PathfindInProgress() then
            PathfindAndMoveTo(Board.x, Board.y, Board.z)
        end
    else
        if PathIsRunning() or PathfindInProgress() then
            yield("/vnav stop")
        else
            BoardNumber = BoardNumber + 1
            State = PickUpHunts
            LogInfo("[DailyHunts] State Change: PickUpHunts")
        end
    end
end

function Next()
    Clicks = 0
    while Clicks < 5 do
        local callback = "/callback Mobhunt"..BoardNumber.." true 1"
        LogInfo("[DailyHunts] Executing "..callback)
        yield("/wait 1")
        yield(callback)
        Clicks = Clicks + 1
    end
end

HuntNumber = 0
function PickUpHunts()
    if HuntNumber >= #Board.bills then
        if IsAddonVisible("Mobhunt"..BoardNumber) then
            local callback = "/callback Mobhunt"..BoardNumber.." true -1"
            LogInfo("[DailyHunts] Executing "..callback)
            yield(callback)
        else
            HuntNumber = 0
            State = GoToHuntBoard
            LogInfo("[DailyHunts] State Change: GoToHuntBoard "..BoardNumber)
        end
    elseif GetItemCount(Board.bills[HuntNumber+1]) >= 1 then
        HuntNumber = HuntNumber + 1
    elseif IsAddonVisible("SelectYesno") and GetNodeText("SelectYesno", 15) == "Pursuing a new mark will result in the abandonment of your current one. Proceed?" then
        yield("/callback SelectYesno true 1")
        HuntNumber = HuntNumber + 1
    elseif IsAddonVisible("SelectString") then
        local callback = "/callback SelectString true "..HuntNumber
        LogInfo("[DailyHunts] Executing ".."/callback SelectString true "..HuntNumber)
        yield(callback)
    elseif IsAddonVisible("Mobhunt"..BoardNumber) then
        Next()
        local callback = "/callback Mobhunt"..BoardNumber.." true 0"
        LogInfo("[DailyHunts] Executing "..callback)
        yield(callback)
        HuntNumber = HuntNumber + 1
    elseif not HasTarget() or GetTargetName() ~= Board.boardName then
        yield("/target "..Board.boardName)
    else
        yield("/interact")
    end
end

function EndScript()
    yield("/echo [DailyHunts] All Marks Obtained..!!")
    StopFlag = true
end

-------------------------------- Execution --------------------------------

Plugins()
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}
State = GoToHuntBoard
while not StopFlag do
    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        State()
        yield("/wait 0.1")
    end
end

----------------------------------- End -----------------------------------