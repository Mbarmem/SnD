--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Triple Triad Seller - Sells your acumulated Triple Triad cards
plugin_dependencies:
- TeleporterPlugin
- Lifestream
- vnavmesh
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

Npc         = { Name = "Triple Triad Trader", Position = { X = -52.42, Y = 1.6, Z = 15.77 } }
EchoPrefix  = "[TTSeller]"

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function DistanceToSeller()
    if IsInZone(144) then -- The Gold Saucer
        Distance_Test = GetDistanceToPoint(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
        LogInfo(string.format("%s Distance to seller: %.2f", EchoPrefix, Distance_Test))
    end
end

function GoToSeller()
    if IsInZone(144) then
        DistanceToSeller()

        if Distance_Test > 0 and Distance_Test < 100 then
            MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
            return
        end
    end

    Teleport("The Gold Saucer")
    WaitForTeleport()
    MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
end

----------------
--    Main    --
----------------

function Main()
    Interact(Npc.Name)
    WaitForAddon("SelectIconString")
    yield("/callback SelectIconString true 1")

    WaitForAddon("TripleTriadCoinExchange")

    while not IsNodeVisible("TripleTriadCoinExchange", 1, 11) do
        local nodenumber = GetNodeText("TripleTriadCoinExchange",3 ,1 ,5)
        local a = tonumber(nodenumber)

        repeat
            Wait(0.1)
        until IsNodeVisible("TripleTriadCoinExchange", 1, 10, 5)

        yield("/callback TripleTriadCoinExchange true 0")

        WaitForAddon("ShopCardDialog")
        yield(string.format("/callback ShopCardDialog true 0 %d", a))

        Wait(1)
    end
    yield("/callback TripleTriadCoinExchange true -1")
end

--=========================== EXECUTION ==========================--

GoToSeller()
Main()
LogInfo(string.format("%s Cards sold. Stopping the script.", EchoPrefix))

--============================== END =============================--