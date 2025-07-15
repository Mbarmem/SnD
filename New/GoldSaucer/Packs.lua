--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: TT Packs Buying Script - Buys Triple Triad Packs and opens them
plugin_dependencies:
- TeleporterPlugin
- Lifestream
- vnavmesh
dependencies:
- source: ''
  name: SnD
  type: git
configs:
  PackToBuy:
    description: Name of the pack to buy. Options - Bronze, Silver, Gold, Mythril, Imperial, Dream
    type: string
    required: true
  CardId:
    description: Continues buying packs until this specific card ID is obtained.
    type: int
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

PackToBuy   = Config.Get("PackToBuy")
CardId      = Config.Get("CardId")
EchoPrefix  = "[TTPacks]"

--============================ CONSTANT ==========================--

-----------------
--    Packs    --
-----------------

TTPacks = {
    {
        packName        = "Bronze Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 36,
        packId          = 10128
    },
    {
        packName        = "Silver Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 37,
        packId          = 10129
    },
    {
        packName        = "Gold Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 38,
        packId          = 10130
    },
    {
        packName        = "Mythril Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 39,
        packId          = 13380
    },
    {
        packName        = "Imperial Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 40,
        packId          = 17702
    },
    {
        packName        = "Dream Triad Card",
        categoryMenu    = 1,
        subcategoryMenu = 41,
        packId          = 28652
    }
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function DistanceToSeller()
    if IsInZone(144) then -- The Gold Saucer
        Distance_Test = GetDistanceToPoint(55, 1, 16)
        LogInfo(string.format("%s Distance to seller: %.2f", EchoPrefix, Distance_Test))
    end
end

function GoToSeller()
    if IsInZone(144) then
        DistanceToSeller()
        if Distance_Test > 0 and Distance_Test < 100 then
            MoveTo(55, 1, 16)
            return
        end
    end

    Teleport("The Gold Saucer")
    WaitForTeleport()
    MoveTo(55, 1, 16)
end

----------------
--    Main    --
----------------

function Main()
    for _, packs in ipairs(TTPacks) do
        if packs.packName == PackToBuy then
            SelectedPackToBuy = packs
            break
        end
    end

    if not SelectedPackToBuy then
        LogInfo(string.format("%s PackToBuy not found in TTPacks.", EchoPrefix))
        State = false
        return
    end

    local packCount = GetItemCount(SelectedPackToBuy.packId)
    if packCount > 0 then
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
        else
            yield("/item " .. SelectedPackToBuy.packName)
            if GetItemCount(CardId) > 0 then
                State = false
                LogInfo(string.format("%s Card obtained, stopping the script.", EchoPrefix))
            end
        end
        return
    end

    if GetTargetName() ~= "Triple Triad Trader" then
        Target("Triple Triad Trader")
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("ShopExchangeCurrency") then
        yield("/callback ShopExchangeCurrency true 0 "..SelectedPackToBuy.subcategoryMenu.." 10")
        return
    end

    Interact("Triple Triad Trader")
end

--=========================== EXECUTION ==========================--

GoToSeller()

while State do
    Main()
    Wait(1)
end

--============================== END =============================--