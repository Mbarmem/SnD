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
  CardID:
    default: 1
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
CardID      = Config.Get("CardID")
Npc         = { Name = "Triple Triad Trader", Position = { X = -52.42, Y = 1.6, Z = 15.77 } }
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
    for _, packs in ipairs(TTPacks) do
        if packs.packName == PackToBuy then
            SelectedPackToBuy = packs
        end
    end

    if not SelectedPackToBuy then
        LogInfo(string.format("%s PackToBuy not found in TTPacks.", EchoPrefix))
        return false
    end

    local packCount = GetItemCount(SelectedPackToBuy.packId)
    if packCount > 0 then
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
        else
            yield("/item " .. SelectedPackToBuy.packName)
            WaitForPlayer()
            if Inventory.GetItemCount(CardID) > 0 then
                LogInfo(string.format("%s Card obtained, stopping the script.", EchoPrefix))
                return false
            end
        end
        return
    end

    if GetTargetName() ~= Npc.Name then
        Target(Npc.Name)
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
        LogInfo(string.format("%s Buying a new pack: %s.", EchoPrefix, SelectedPackToBuy.packName))
        yield("/callback ShopExchangeCurrency true 0 "..SelectedPackToBuy.subcategoryMenu.." 10")
        return
    end

    Interact(Npc.Name)
end

--=========================== EXECUTION ==========================--

GoToSeller()

while true do
    local shouldContinue = Main()
    if not shouldContinue then
        break
    end
    Wait(1)
end

--============================== END =============================--