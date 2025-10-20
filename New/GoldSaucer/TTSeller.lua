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

----------------
--    Main    --
----------------

function Main()
    Interact(Npc.Name)
    WaitForAddon("SelectIconString")
    Wait(1)
    Execute("/callback SelectIconString true 1")
    Wait(1)

    while true do
        WaitForAddon("TripleTriadCoinExchange")
        Wait(1)
        if IsNodeVisible("TripleTriadCoinExchange", 1, 11) then
            Wait(1)
            break
        end

        ::start::
        if IsNodeVisible("TripleTriadCoinExchange", 1, 10, 5) then
            Execute("/callback TripleTriadCoinExchange true 0")
            Wait(1)
            WaitForAddon("ShopCardDialog")
            Wait(1)
        end

        local nodeText = GetNodeText("TripleTriadCoinExchange", 1, 10, 5, 6)
        if not nodeText then
            Wait(1)
            goto start
        end

        local nodeNumber = tonumber(nodeText)
        if not nodeNumber then
            LogInfo(string.format("%s Could not parse int from %q", LogPrefix, nodeText))
            goto start
        end

        if IsAddonReady("ShopCardDialog") then
            Execute(string.format("/callback ShopCardDialog true 0 %d", nodeNumber))
            Wait(1)
        end
        Wait(1)
    end
    Execute("/callback TripleTriadCoinExchange true -1")
    Wait(1)
end

--=========================== EXECUTION ==========================--

GoToSeller()
Main()

Echo(string.format("Triple Triad Seller script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Triple Triad Seller script completed successfully..!!", LogPrefix))

--============================== END =============================--