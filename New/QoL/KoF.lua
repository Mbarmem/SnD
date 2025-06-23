--[[

***********************************************
*              Kupo Of Fortunes               *
*          Script for Diadem Fortunes         *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  2.0.0  *
            **********************

]]

---------------------------------- Import ---------------------------------

require("MoLib")

-------------------------------- Variables --------------------------------

local Loop = 0
local VoucherItemId = 26807  -- Kupo Voucher (adjust if needed)
local LoopCount = Inventory.GetItemCount(VoucherItemId)
local EchoPrefix = "[KoF] "

-------------------------------- Functions --------------------------------

-- Moves to target, interacts, and handles dialogue prompts
function MoveAndInteract()
    MoveToTarget()
    Wait(1)

    yield("/interact")
    Wait(1)

    repeat
        if IsAddonReady("Talk") then
            yield("/click Talk Click")
        elseif IsAddonReady("SelectYesno") then
            yield("/click SelectYesno Yes")
        end
        Wait(1)
    until IsPlayerAvailable()
end

-- Core function: interacts with Lizbeth and processes a Kupo draw
function KoF()
    Target("Lizbeth")
    MoveAndInteract()
    Wait(1)
    CloseAddons()
end

-------------------------------- Execution --------------------------------

if LoopCount == 0 then
    Echo("No Kupo Vouchers found. Script stopped.", EchoPrefix)
    yield("/snd stop")
end

Echo(string.format("Starting KoF — Found %d Kupo Vouchers.", LoopCount), EchoPrefix)

while Loop < LoopCount do
    Echo(string.format("Running KoF iteration %d/%d...", Loop + 1, LoopCount), EchoPrefix)
    KoF()
    Loop = Loop + 1
    Wait(0.1)
end

Echo("Kupo of Fortunes complete!", EchoPrefix)

----------------------------------- End -----------------------------------