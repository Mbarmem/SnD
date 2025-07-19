--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Island Sanctuary - A barebones script for weeklies
plugin_dependencies:
- visland
- TeleporterPlugin
- Lifestream
- vnavmesh
- TextAdvance
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

LogPrefix = "[IslandSanctuary]"

--============================ CONSTANT ==========================--

----------------------------
--    State Management    --
----------------------------

CharacterState = {}

local StopFlag = false

---------------------
--    Locations    --
---------------------

Locations = {
    sanctuary = {
        zoneId  = 1055,

        workshop = {
            name      = "Tactful Taskmaster",
            x         = -277,
            y         = 39,
            z         = 229,
            addonName = "MJICraftSchedule",
        },

        granary = {
            name      = "Excitable Explorer",
            x         = -264,
            y         = 39,
            z         = 234,
            addonName = "MJIGatheringHouse",
        },

        ranch = {
            name      = "Creature Comforter",
            x         = -270,
            y         = 55,
            z         = 134,
            addonName = "MJIAnimalManagement",
        },

        garden = {
            name      = "Produce Producer",
            x         = -257,
            y         = 55,
            z         = 134,
            addonName = "MJIFarmManagement",
        },

        furball = {
            name       = "Felicitous Furball",
            x          = -273,
            y          = 41,
            z          = 210,
            waypointX  = -257.56,
            waypointY  = 40.0,
            waypointZ  = 210.0,
        },

        export = {
            name      = "Enterprising Exporter",
            x         = -267,
            y         = 41,
            z         = 207,
            addonName = "MJIDisposeShop",
        },

        blueCowries = {
            name      = "Horrendous Hoarder",
            x         = -265,
            y         = 41,
            z         = 207,
            addonName = "ShopExchangeCurrency",
        },
    },
}

--=========================== FUNCTIONS ==========================--

function GetStateName(stateFn)
    for key, fn in pairs(CharacterState) do
        if fn == stateFn then
            return key
        end
    end
    return "Unknown"
end

function OpenNpc(npc, nextState)
    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 20 then
        if IsPlayerCasting() then return end
        if not IsMounted() then
            UseMount()
            Wait(1)
        end
        return
    end

    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 5 then
        local flyingUnlocked = false
        local shouldFly = flyingUnlocked and IsMounted()
        if not PathfindInProgress() and not PathIsRunning() then
            MoveTo(npc.x, npc.y, npc.z, 1, shouldFly)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        PathStop()
        return
    end

    if IsMounted() then
        yield("/ac dismount")
        Wait(1)
        return
    end

    if not IsOccupiedInQuestEvent() then
        Interact(npc.name)
        return
    end

    if IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
        return
    end

    if npc.addonName and IsAddonVisible(npc.addonName) then
        State = nextState
        LogInfo(string.format("%s State changed to: %s", LogPrefix, GetStateName(nextState)))
    end
end

function OpenAndCloseNpc(npc, nextState)
    if IsAddonVisible(npc.addonName) then
        Wait(1)
        State = nextState
        LogInfo(string.format("%s State changed to: %s", LogPrefix, GetStateName(nextState)))
    else
        OpenNpc(npc, nextState)
    end
end

function CharacterState.enterIslandSanctuary()
    if IsInZone(Locations.sanctuary.zoneId) then
        State = CharacterState.openWorkshop
        LogInfo(string.format("%s State changed to: OpenWorkshop", LogPrefix))
        return
    end

    LogInfo(string.format("%s Teleporting to Island Sanctuary...", LogPrefix))
    Lifestream("Island")
    WaitForLifeStream()

    State = CharacterState.openWorkshop
    LogInfo(string.format("%s State changed to: OpenWorkshop", LogPrefix))
end

function CharacterState.openWorkshop()
    OpenNpc(Locations.sanctuary.workshop, CharacterState.setWorkshopSchedule)
    Wait(1)
end

function CharacterState.setWorkshopSchedule()
    LogInfo(string.format("%s Setting workshop schedule...", LogPrefix))

    repeat
        yield("/callback MJICraftSchedule true -1")
        Wait(0.5)
    until not IsAddonVisible("MJICraftSchedule")

    repeat
        yield("/callback SelectString true -1")
        Wait(0.5)
    until not IsAddonVisible("SelectString")

    State = CharacterState.granary
    LogInfo(string.format("%s State changed to: Granary", LogPrefix))
end

function CharacterState.granary()
    OpenAndCloseNpc(Locations.sanctuary.granary, CharacterState.ranch)
end

function CharacterState.ranch()
    OpenAndCloseNpc(Locations.sanctuary.ranch, CharacterState.garden)
end

function CharacterState.garden()
    OpenAndCloseNpc(Locations.sanctuary.garden, CharacterState.talkToFurball)
end

PathToFurball = "H4sIAAAAAAAACu1WTY/TMBD9K5XPIYodO4lzQ2VbFbRL2S0qLOLgEreJlHiK44BWVf874yT7UeDAFbW+eN6TPfM8ebJzIDeq0SQnS+XKyuwmWwvNZK5sYbSdOJjMOrtRdU0CMrfQ7XHlR7PzkS6QmwEUJI8Ccq1Mp+o+XCm7026O+bRdON305Fo97KEyriX5lwNZQlu5CgzJD+QTyV8xIcNMsiQNyGeSCxFSiQPRPckpj8JYCkGPCMHoxRvkIiECcquKqsOEcegFwA/daONIzoL+MNvKoDRnOx2QhXHaqm9uXbnyvU8QnXJjD8gp+5vKyJdBef18388oqS3h5+MmXItytqpuX9TsE9CAXDXg9GNtbMsYvu5XjOBDp1v3Mr7T34f2wmak7xzsp2CKURky76q6nkLnj47oFjqnn88zLZWbQtMo3wxPeL1rVblnoR7NwJ4m9eSqavR1ewKvVn82A5uwaJelMg6ap6T+C5DcdHWNxumtgOZaPexRlpR+ww0U+mm1B29hg+mOwV/cEcmQpVzwviIXYcwzniaDO5IoTGQiL+44X3dkYUoFZYM7WJgyyTgf3JElIac0yy53x7m6I8G7I2JcDO7Akn4M7mAxviw0SsTFHWfsjjiVcTK4g44vO6MY8Zj/86OC4PLL8d8a4+vxFx+sRHEGCwAA"
TalkedToFurball = false

function CharacterState.talkToFurball()
    local npc = Locations.sanctuary.furball

    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 20 then
        if not IsMounted() then
            LogInfo(string.format("%s Not mounted, using mount to approach Furball.", LogPrefix))
            UseMount()
            Wait(1)
            return
        elseif not IsVislandRouteRunning() then
            LogInfo(string.format("%s Starting Visland route to Furball.", LogPrefix))
            VislandRouteStart(PathToFurball, true)
            return
        end
    elseif IsVislandRouteRunning() then
        Wait(1)
        return
    end

    if IsMounted() then
        yield("/ac dismount")
        Wait(1)
        return
    end

    if not IsOccupiedInQuestEvent() then
        if TalkedToFurball then
            State = CharacterState.export
            LogInfo(string.format("%s State changed to: Export", LogPrefix))
            return
        else
            Interact(npc.name)
            return
        end
    end

    if IsAddonVisible("SelectString") then
        TalkedToFurball = true
        yield("/callback SelectString true 2")
        return
    end
end

function CharacterState.export()
    OpenAndCloseNpc(Locations.sanctuary.export, CharacterState.endIslandSanctuary)
end

function CharacterState.endIslandSanctuary()
    CloseAddons()
    StopFlag = true
end

--=========================== EXECUTION ==========================--

yield("/at y")
State = CharacterState.enterIslandSanctuary
LogInfo(string.format("%s State changed to: EnterIslandSanctuary", LogPrefix))

while not StopFlag do
    if not IsBetweenAreas() then
        State()
    end
    Wait(1)
end

Echo(string.format("Island Sanctuary script completed successfully..!!"), LogPrefix)
LogInfo(string.format("%s Island Sanctuary script completed successfully..!!", LogPrefix))

--============================== END =============================--