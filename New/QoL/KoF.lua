--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Kupo Of Fortunes - Script for Diadem Fortunes
plugin_dependencies:
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

LogPrefix  = "[KoF]"

--=========================== FUNCTIONS ==========================--

function MoveAndInteract()
    MoveToTarget("Lizbeth", 5)
    Interact("Lizbeth")

    repeat
        if IsAddonReady("Talk") then
            yield("/click Talk Click")
        elseif IsAddonReady("SelectYesno") then
            yield("/click SelectYesno Yes")
        end
        Wait(1)
    until IsPlayerAvailable()
end

function KoF()
    Target("Lizbeth")
    MoveAndInteract()
    Wait(1)
    CloseAddons()
end

--=========================== EXECUTION ==========================--

local Loop          = 0
local VoucherItemId = 26807    -- Kupo Voucher (adjust if needed)
local LoopCount     = GetItemCount(VoucherItemId)

if LoopCount == 0 then
    Echo("No Kupo Vouchers found. Script stopped..!!", LogPrefix)
    LogInfo(string.format("%s No Kupo Vouchers found. Script stopped..!!", LogPrefix))
    StopRunningMacros()
end

Echo(string.format("Starting KoF — Found %d Kupo Vouchers.", LoopCount), LogPrefix)

while Loop < LoopCount do
    LogInfo(string.format("%s Running KoF iteration %d/%d...", LogPrefix, Loop + 1, LoopCount))
    KoF()
    Loop = Loop + 1
    Wait(0.1)
end

Echo("Kupo of Fortunes script completed..!!", LogPrefix)
LogInfo(string.format("%s Kupo of Fortunes script completed..!!", LogPrefix))

--============================== END =============================--