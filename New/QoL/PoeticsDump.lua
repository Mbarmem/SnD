--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Poetics Dump - Buy Grade 3 Thanalan Topsoil
plugin_dependencies:
- Lifestream
- TextAdvance
- vnavmesh
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  MinPoeticsToRun:
    description: Minimum Poetics required to start the dump.
    default: 1800
[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

PoeticsItemId    = 28
OreItemId        = 13586
MinPoeticsToRun  = Config.Get("Alexandrite")
LogPrefix        = "[PoeticsDump]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}
StopFlag       = false

----------------
--    Zone    --
----------------

IdyllshireTurnIn = {
    x            = -12.30,
    y            = 211.00,
    z            = -40.85,
    mapId        =    478,
    price        = 150.00,
    oreNpc       = "Hismena",
    turnInNpc    = "Bertana"
}

--=========================== FUNCTIONS ==========================--

function SafeQtyToBuy(poetics, price)
    local qty = math.floor(poetics / price)
    if qty < 1 then return 0 end
    return qty
end

function CharacterState.poeticsGoToIdyllshireTurnIn()
    if not IsInZone(IdyllshireTurnIn.mapId) then
        Teleport("Idyllshire")
        Wait(1)
        return
    end

    if GetDistanceToPoint(IdyllshireTurnIn.x, IdyllshireTurnIn.y, IdyllshireTurnIn.z) > 5 then
        Mount()
        if not PathfindInProgress() and not PathIsRunning() then
            MoveTo(IdyllshireTurnIn.x, IdyllshireTurnIn.y, IdyllshireTurnIn.z)
        end
    else
        State = CharacterState.poeticsBuyUnidentifiableOre
        LogInfo(string.format("%s State changed to: BuyUnidentifiableOre", LogPrefix))
    end
end

function CharacterState.poeticsBuyUnidentifiableOre()
    local poetics = GetItemCount(PoeticsItemId)
    local qty     = SafeQtyToBuy(poetics, IdyllshireTurnIn.price)

    if qty == 0 then
        if GetItemCount(OreItemId) > 0 then
            State = CharacterState.poeticsTurnIn
            LogInfo(string.format("%s State changed to: PoeticsTurnIn", LogPrefix))
        else
            CloseAddons()
            StopFlag = true
        end
        return
    end

    State = CharacterState.poeticsGoToIdyllshireTurnIn
    LogInfo(string.format("%s State changed to: GoToIdyllshireTurnIn", LogPrefix))

    if not HasTarget(IdyllshireTurnIn.oreNpc) then
        Target(IdyllshireTurnIn.oreNpc)
        return
    end

    if IsAddonReady("SelectYesno") then
        Execute("/callback SelectYesno true 0")
        return
    end

    if IsAddonReady("SelectIconString") then
        Execute("/callback SelectIconString true 6")
        return
    end

    if IsAddonReady("ShopExchangeCurrency") then
        Execute(string.format("/callback ShopExchangeCurrency true 0 7 %d 0", qty))
        return
    end

    Interact(IdyllshireTurnIn.oreNpc)
end

function CharacterState.poeticsTurnIn()
    local ore = GetItemCount(OreItemId)

    if ore == 0 then
        WaitForAddon("ShopExchangeItem", 10)
        if IsAddonReady("ShopExchangeItem") then
            Execute("/callback ShopExchangeItem true -1")
        else
            CloseAddons()
            StopFlag = true
        end
        return
    end

    LogInfo(string.format("%s State changed to: GoToIdyllshireTurnIn", LogPrefix))
    State = CharacterState.poeticsGoToIdyllshireTurnIn

    if not HasTarget(IdyllshireTurnIn.turnInNpc) then
        Target(IdyllshireTurnIn.turnInNpc)
        return
    end

    if IsAddonReady("SelectIconString") then
        Execute("/callback SelectIconString true 5")
        return
    end

    if IsAddonReady("ShopExchangeItemDialog") then
        Execute("/callback ShopExchangeItemDialog true 0")
        return
    end

    if IsAddonReady("ShopExchangeItem") then
        Execute(string.format("/callback ShopExchangeItem true 0 1 %d 0", ore))
        return
    end

    Interact(IdyllshireTurnIn.turnInNpc)
end

function CharacterState.poeticsReady()
    if GetItemCount(PoeticsItemId) >= MinPoeticsToRun or GetItemCount(OreItemId) > 0 then
        State = CharacterState.poeticsGoToIdyllshireTurnIn
        LogInfo(string.format("%s State changed to: GoToIdyllshireTurnIn", LogPrefix))
    else
        CloseAddons()
        StopFlag = true
    end
end

--=========================== EXECUTION ==========================--

Execute("/at y")
State = CharacterState.poeticsReady
LogInfo(string.format("%s State changed to: PoeticsReady", LogPrefix))

while not StopFlag do
    State()
    Wait(0.1)
end

Echo(string.format("Script execution completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Script execution completed successfully..!!", LogPrefix))

--============================== END =============================--