--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Bozja/Zadnor - Automates FATE farming in Save the Queen areas
plugin_dependencies:
- BossModReborn
- Lifestream
- RotationSolver
- vnavmesh
- YesAlready
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

LogPrefix  = "[BozjanClusters]"

--============================ CONSTANT ==========================--

----------------
--    Zone    --
----------------

Zones = {
    Gangos = { Id = 915, Name = "Gangos",               Teleport = "Gangos"      },
    Bozja  = { Id = 920, Name = "Bozja Southern Front", Teleport = "EnterBozja"  },
    Zadnor = { Id = 975, Name = "Zadnor",               Teleport = "EnterZadnor" },
}

--=========================== FUNCTIONS ==========================--

----------------
--    Misc    --
----------------

function StanceOff()
    if not IsPlayerAvailable() then
        return
    end

    if HasStatusId(91) then
        LogInfo(string.format("%s Turning off Defiance stance...", LogPrefix))
        ExecuteAction(CharacterAction.Actions.defiance)
        Wait(1)
    end
end

function RotationON()
    LogInfo(string.format("%s Setting rotation to LowHP mode...", LogPrefix))
    Execute("/rotation auto LowHP")
    Wait(1)
end

function RotationOFF()
    LogInfo(string.format("%s Turning rotation OFF...", LogPrefix))
    Execute("/rotation off")
    Wait(1)
end

function AiON()
    LogInfo(string.format("%s Enabling BattleMod AI...", LogPrefix))
    Execute("/bmrai on")
    Wait(1)
end

function AiOFF()
    LogInfo(string.format("%s Turning BattleMod AI OFF...", LogPrefix))
    Execute("/bmrai off")
    Wait(1)
end

--=========================== EXECUTION ==========================--

while true do
    -- 1. If in Gangos, move to Zadnor
    if IsInZone(Zones.Gangos.Id) then
        StanceOff()
		RotationOFF()
		AiOFF()

        LogInfo("[Loop] In Gangos. Entering Zadnor...")
        Lifestream("EnterZadnor") -- Standard Lifestream shortcut for Zadnor
        while not IsInZone(Zones.Zadnor.Id) do
            Wait(2)
        end
        WaitForPlayer()
    end

    -- 2. Move to Aetheryte coordinates
    if IsInZone(Zones.Zadnor.Id) then
        LogInfo("[Loop] Moving to Aetheryte coordinates...")
        MoveToTarget("Bozjan Aetheryte", 3)
        Wait(1)

        -- 3. Teleport using Lifestream command
        LogInfo("[Loop] Executing Teleport command...")
        Lifestream("Hrmovir Point")
        Wait(5)
        WaitForPlayer()
		Mount()

        -- 4. Move to second set of coordinates
        LogInfo("[Loop] Moving to secondary coordinates...")
        MoveTo(-228.05629, 301.59552, -226.71388)
		RotationON()
		AiON()
		Dismount()

        -- 5. Wait until we are back in Gangos
        LogInfo("[Loop] Waiting to return to Gangos...")
        while not IsInZone(Zones.Gangos.Id) do
            Wait(2)
        end
    end

    -- 6. Repeat
    LogInfo("[Loop] Cycle complete. Restarting...")
    Wait(2)
end

--============================== END =============================--