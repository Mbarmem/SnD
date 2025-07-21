--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.4
description: Triple Triad Seller - Sells your acumulated Triple Triad cards
plugin_dependencies:
- TeleporterPlugin
- Lifestream
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

Npc         = { Name = "Triple Triad Trader", Position = { X = -52.42, Y = 1.6, Z = 15.77 } }
LogPrefix   = "[TTSeller]"

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function DistanceToSeller()
    if IsInZone(144) then -- The Gold Saucer
        Distance_Test = GetDistanceToPoint(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
        LogInfo(string.format("%s Distance to seller: %.2f", LogPrefix, Distance_Test))
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
    Wait(1)

    while true do
        WaitForAddon("TripleTriadCoinExchange")
        local Visible = IsNodeVisible("TripleTriadCoinExchange", 1, 11)
        if Visible then
            break
        end

        if IsNodeVisible("TripleTriadCoinExchange", 1, 10, 5) then
            yield("/callback TripleTriadCoinExchange true 0")
            WaitForAddon("ShopCardDialog")
            Wait(1)
        end

        local Node = GetNodeText("TripleTriadCoinExchange", 1, 10, 5, 6)
        local a = tonumber(Node)

        if IsAddonVisible("ShopCardDialog") then
            yield(string.format("/callback ShopCardDialog true 0 %d", a))
            Wait(1)
        end
        Wait(1)
    end
    yield("/callback TripleTriadCoinExchange true -1")
    Wait(1)
    return false
end

--=========================== EXECUTION ==========================--

GoToSeller()
Main()

Echo(string.format("Triple Triad Seller script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Triple Triad Seller script completed successfully..!!", LogPrefix))

--============================== END =============================--