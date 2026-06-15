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
  PlayRegular:
    description: Play the regular Triple Triad weekly (Nell Half-full in Battlehall).
    default: true
  RegularMatches:
    description: Number of regular matches to play.
    default: 15
  PlayTournament:
    description: Play Triple Triad Tournament matches in Battlehall.
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

PlayRegular       = Config.Get("PlayRegular")
RegularMatches    = Config.Get("RegularMatches")
PlayTournament    = Config.Get("PlayTournament")
TournamentMatches = Config.Get("TournamentMatches")
LogPrefix         = "[TT]"

--=========================== FUNCTIONS ==========================--

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
    Wait(1)

    if IsAddonReady("TripleTriadRanking") then
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
        while not IsAddonReady("SelectYesno") do
            if IsAddonReady("Talk") then
                Execute("/click Talk Click")
            end
            Wait(1)
        end
        Execute("/callback SelectYesno true 1")
    end

    WaitForPlayer()
end

function DoTournamentMatches()
    LogInfo(string.format("%s Starting tournament matches...", LogPrefix))
    WaitForPlayer()
    MoveToTarget("Flichoirel the Lordling", 3)
    Wait(1)
    Interact("Flichoirel the Lordling")
    WaitForCondition("PlayingMiniGame", true)
    Execute("/saucy tt play "..TournamentMatches)
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
    WaitForCondition("PlayingMiniGame", true)
    Execute("/saucy tt play "..RegularMatches)
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

if not PlayTournament and not PlayRegular then
    LogInfo(string.format("%s Nothing to do. Enable PlayRegular or PlayTournament.", LogPrefix))
else
    if not IsInZone(579) then

        if PlayTournament then
            Teleport("Entrance & Card Squares")
            EnrollTournament()
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
