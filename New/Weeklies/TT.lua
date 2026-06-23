--[=====[
[[SND Metadata]]
author: Mo
version: 3.0.0
description: Triple Triad - A barebones script for weeklies
plugin_dependencies:
- Lifestream
- Saucy
- TextAdvance
- vnavmesh
- YesAlready
dependencies:
- source: https://forgejo.mownbox.com/Mo/SnD/raw/branch/main/New/MoLib/MoLib.lua
  name: latest
  type: unknown
configs:
  AutoSelectMode:
    description: Automatically choose tournament or regular based on the biweekly Triple Triad tournament schedule.
    default: true
  TournamentWeekReference:
    description: Known tournament week date in YYYY-MM-DD format. Default is 2026-06-23.
    default: "2026-06-23"
  PlayRegular:
    description: Play the regular Triple Triad weekly when AutoSelectMode is disabled.
    default: true
  RegularMatches:
    description: Number of regular matches to play.
    default: 15
  PlayTournament:
    description: Play Triple Triad Tournament matches when AutoSelectMode is disabled.
    default: false
  TournamentMatches:
    description: Number of tournament matches to play.
    default: 20

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

AutoSelectMode          = Config.Get("AutoSelectMode")
TournamentWeekReference = Config.Get("TournamentWeekReference")
PlayRegular             = Config.Get("PlayRegular")
RegularMatches          = Config.Get("RegularMatches")
PlayTournament          = Config.Get("PlayTournament")
TournamentMatches       = Config.Get("TournamentMatches")
ClaimTournamentPrizes   = false
LogPrefix               = "[TT]"

--=========================== CONSTANTS ==========================--

--------------------
--    Schedule    --
--------------------

SecondsPerWeek          = 7 * 24 * 60 * 60
WeeklyResetOffsetUtc    = (5 * 24 * 60 * 60) + (8 * 60 * 60) -- Tuesday 11:00 AST / 08:00 UTC, relative to Unix epoch Thursday.

--=========================== FUNCTIONS ==========================--

--------------------
--    Schedule    --
--------------------

function ParseDate(dateText)
    local year, month, day = tostring(dateText):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")

    if not year then
        return nil
    end

    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = 12,
        min = 0,
        sec = 0
    })
end

function GetTTWeekIndex(unixSeconds)
    return math.floor((unixSeconds - WeeklyResetOffsetUtc) / SecondsPerWeek)
end

function IsTournamentWeek()
    local referenceTime = ParseDate(TournamentWeekReference)

    if not referenceTime then
        LogInfo(string.format("%s Invalid TournamentWeekReference '%s'. Defaulting to tournament week.", LogPrefix, tostring(TournamentWeekReference)))
        referenceTime = ParseDate("2026-06-23")
    end

    local weeksSinceReference = GetTTWeekIndex(os.time()) - GetTTWeekIndex(referenceTime)
    return weeksSinceReference % 2 == 0
end

function SelectPlayMode()
    if AutoSelectMode == false then
        LogInfo(string.format("%s AutoSelectMode disabled. Using manual config: PlayTournament=%s, PlayRegular=%s.", LogPrefix, tostring(PlayTournament), tostring(PlayRegular)))
        return
    end

    PlayTournament = IsTournamentWeek()
    PlayRegular = not PlayTournament
    ClaimTournamentPrizes = PlayRegular

    if PlayTournament then
        LogInfo(string.format("%s AutoSelectMode selected tournament matches.", LogPrefix))
    else
        LogInfo(string.format("%s AutoSelectMode selected regular matches.", LogPrefix))
    end
end

--------------------
--    Tournament  --
--------------------

function EnrollTournament()
    LogInfo(string.format("%s Enrolling in tournament...", LogPrefix))
    MoveToTarget("Tournament Recordkeeper", 3)
    Interact("Tournament Recordkeeper")

    while not IsAddonReady("SelectString") do
        if IsAddonReady("Talk") then
            Execute("/click Talk Click")
        end
        Wait(1)
    end

    Execute("/callback SelectString true 0")

    local alreadyEnrolled = false
    local start = os.time()
    repeat
        if IsAddonReady("TripleTriadRanking") then
            alreadyEnrolled = true
            break
        end

        if IsAddonReady("SelectYesno") then
            break
        end

        if IsAddonReady("Talk") then
            Execute("/click Talk Click")
        end
        Wait(1)
    until (os.time() - start) >= 30

    if alreadyEnrolled then
        LogInfo(string.format("%s Already enrolled in tournament, closing NPC window...", LogPrefix))
        Execute("/callback TripleTriadRanking true -2")
        Wait(1)

        if IsAddonReady("TripleTriadRanking") then
            Execute("/callback TripleTriadRanking true -1")
            Wait(1)
        end

        if IsAddonReady("SelectString") then
            Execute("/callback SelectString true 3")
        end
    else
        Execute("/callback SelectYesno true 0")
        Wait(1)
        while IsAddonReady("Talk") do
            Execute("/click Talk Click")
            Wait(2)
        end
    end

    WaitForPlayer()
end

function ClaimTournamentRewards()
    LogInfo(string.format("%s Claiming tournament prizes...", LogPrefix))
    MoveToTarget("Tournament Recordkeeper", 3)
    Interact("Tournament Recordkeeper")

    local start = os.time()
    local idleSince = nil
    local sawAddon = false
    local selectedPrizeOption = false
    repeat
        if IsAddonReady("SelectString") then
            sawAddon = true
            idleSince = nil
            if selectedPrizeOption then
                Execute("/callback SelectString true -1")
            else
                Execute("/callback SelectString true 0")
                selectedPrizeOption = true
            end
            Wait(1)
        elseif IsAddonReady("SelectYesno") then
            sawAddon = true
            idleSince = nil
            Execute("/callback SelectYesno true 0")
            Wait(1)
        elseif IsAddonReady("TripleTriadRanking") then
            sawAddon = true
            idleSince = nil
            Execute("/callback TripleTriadRanking true -1")
            Wait(1)
        elseif IsAddonReady("Talk") then
            sawAddon = true
            idleSince = nil
            Execute("/click Talk Click")
            Wait(1)
        else
            idleSince = idleSince or os.time()
            if sawAddon and (os.time() - idleSince) >= 2 then
                break
            end
            Wait(1)
        end
    until (os.time() - start) >= 20

    if IsAddonReady("SelectString") then
        Execute("/callback SelectString true -1")
        Wait(1)
    end

    if IsAddonReady("TripleTriadRanking") then
        Execute("/callback TripleTriadRanking true -1")
        Wait(1)
    end

    while IsAddonReady("Talk") do
        Execute("/click Talk Click")
        Wait(1)
    end

    WaitForPlayer()
end

function DoTournamentMatches()
    LogInfo(string.format("%s Starting tournament matches...", LogPrefix))
    WaitForPlayer()
    MoveToTarget("Flichoirel the Lordling", 3)
    Wait(1)
    Interact("Flichoirel the Lordling")

    WaitForAddon("SelectString")
    Execute("/callback SelectString true 1")
    Wait(1)

    while IsAddonReady("Talk") do
        Execute("/click Talk Click")
        Wait(1)
    end

    Execute("/saucy tt play " .. TournamentMatches)
    Execute("/saucy tt go")
    Wait(1)

    while IsPlayingMiniGame() do
        Wait(1)
    end

    WaitForPlayer()
end

-----------------
--    Triad    --
-----------------

function DoRegularTT()
    LogInfo(string.format("%s Starting regular Triple Triad...", LogPrefix))
    WaitForPlayer()
    MoveToTarget("Nell Half-full", 3)
    Wait(1)
    Interact("Nell Half-full")

    WaitForAddon("SelectString")
    Execute("/callback SelectString true 0")
    Wait(1)

    while IsAddonReady("Talk") do
        Execute("/click Talk Click")
        Wait(1)
    end

    Execute("/saucy tt play " .. RegularMatches)
    Execute("/saucy tt go")
    Wait(1)

    while IsPlayingMiniGame() do
        Wait(1)
    end

    WaitForPlayer()
end

----------------
--    Duty    --
----------------

function BattleHall()
    LogInfo(string.format("%s Entering Battle Hall...", LogPrefix))
    DFQueueDuty(195) -- The Triple Triad Battlehall

    while not IsBoundByDuty() do
        Wait(1)
        if IsAddonReady("ContentsFinderConfirm") then
            Wait(1)
            Execute("/click ContentsFinderConfirm Commence")
        end
    end
end

--=========================== EXECUTION ==========================--

SelectPlayMode()

if not PlayTournament and not PlayRegular then
    LogInfo(string.format("%s Nothing to do. Enable PlayRegular or PlayTournament.", LogPrefix))
else
    if not IsInZone(579) then

        if PlayTournament then
            Teleport("Entrance & Card Squares")
            EnrollTournament()
        elseif ClaimTournamentPrizes then
            Teleport("Entrance & Card Squares")
            ClaimTournamentRewards()
        end

        BattleHall()
    end

    WaitForPlayer()

    if PlayTournament then
        DoTournamentMatches()
    end

    if PlayRegular then
        DoRegularTT()
    end

    LeaveInstance()
    WaitForCondition("BoundByDuty", false)
    WaitForPlayer()
end

Echo("Triple Triad script completed successfully..!!", LogPrefix)
LogInfo(string.format("%s Triple Triad script completed successfully..!!", LogPrefix))

--============================== END =============================--
