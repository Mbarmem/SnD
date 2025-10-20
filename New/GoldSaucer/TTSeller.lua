--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Triple Triad Seller - Sells your acumulated Triple Triad cards
plugin_dependencies:
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
    if not IsInZone(144) then
        LogInfo(string.format("%s Not in Gold Saucer; skipping distance check", LogPrefix))
        return nil
    end

    local distanceTest = GetDistanceToPoint(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
    LogInfo(string.format("%s Distance to seller: %.2f", LogPrefix, distanceTest))
    return distanceTest
end

function GoToSeller()
    if IsInZone(144) then
        local distance = DistanceToSeller()

        if distance and distance > 0 and distance < 100 then
            MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
            return
        end
    end

    Teleport("The Gold Saucer")
    MoveTo(Npc.Position.X, Npc.Position.Y, Npc.Position.Z)
end

function CardsForSale()
    if IsNodeVisible("TripleTriadCoinExchange", 1, 11) then
        return false
    end
    return true
end

function CardsQty()
    local nodeText = GetNodeText("TripleTriadCoinExchange", 1, 10, 5, 6) or ""
    return tonumber(nodeText:match("%d+")) or 0
end

----------------
--    Main    --
----------------

function InteractNpc()
    Interact(Npc.Name)
    WaitForAddon("SelectIconString")
    Execute("/callback SelectIconString true 1")
    Wait(1)
    WaitForAddon("TripleTriadCoinExchange")
end

function SellTTCards()
    while CardsForSale() do
        local cardsToSell = CardsQty()
        Execute("/callback TripleTriadCoinExchange true 0")
        Wait(1)
        WaitForAddon("ShopCardDialog")
        Execute(string.format("/callback ShopCardDialog true 0 %d", cardsToSell))
        Wait(1)
    end

    Execute("/callback TripleTriadCoinExchange true -1")
    Wait(1)
end

--=========================== EXECUTION ==========================--

GoToSeller()
InteractNpc()
SellTTCards()

Echo(string.format("Triple Triad Seller script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Triple Triad Seller script completed successfully..!!", LogPrefix))

--============================== END =============================--