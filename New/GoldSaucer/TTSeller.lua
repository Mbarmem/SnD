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

function SafeGetNodeText(addon, ...)
    local ok, txt = pcall(GetNodeText, addon, ...)
    if not ok or txt == nil or txt == "" then
        return nil
    end

    return tostring(txt)
end

function ParseIntLoose(string)
    if not string then
        return nil
    end

    local cleaned = tostring(string):gsub(",", "")
    local digits = cleaned:match("(%d+)")
    return digits and tonumber(digits) or nil
end

----------------
--    Main    --
----------------

function Main()
    Interact(Npc.Name)
    if not WaitForAddon("SelectIconString") then
        LogInfo(string.format("%s WaitForAddon('SelectIconString') timed out", LogPrefix))
        return
    end

    Wait(1)
    Execute("/callback SelectIconString true 1")
    Wait(1)

    while true do
        if not WaitForAddon("TripleTriadCoinExchange") then
            LogInfo(string.format("%s WaitForAddon('TripleTriadCoinExchange') timed out", LogPrefix))
            return
        end

        Wait(1)
        if IsNodeVisible("TripleTriadCoinExchange", 1, 11) then
            Wait(1)
            break
        end

        ::start::
        if IsNodeVisible("TripleTriadCoinExchange", 1, 10, 5) then
            Execute("/callback TripleTriadCoinExchange true 0")
            Wait(1)

            if not WaitForAddon("ShopCardDialog") then
                LogInfo(string.format("%s WaitForAddon('ShopCardDialog') timed out", LogPrefix))
                return
            end
            Wait(1)
        end

        local nodeText = SafeGetNodeText("TripleTriadCoinExchange", 1, 10, 5, 6)
        if not nodeText then
            Wait(1)
            goto start
        end

        local nodeNumber = ParseIntLoose(nodeText)
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