--[[

***********************************************
*             Cosmic Exploration              *
*          Script for Auto Crating            *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

]]

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

local ferret = require("Ferret/Templates/StellarCraftingRelic")
require("Ferret/Plugins/ExtractMateria")
require("Ferret/Plugins/Repair")
require("Ferret/Plugins/CraftingConsumables")

-------------------------------- Variables --------------------------------

-----------------
--    Config   --
-----------------

ferret.job = Jobs.Alchemist
Logger.show_debug = true
Ferret.language = 'en'
ferret.plugins.repair.threshold = 20
ferret.plugins.crafting_consumables.food = "Rroneek Steak <HQ>"
ferret.plugins.crafting_consumables.medicine = ""
ferret.blacklist = MasterMissionList:filter_by_job(ferret.job):filter(function(mission)
    return mission.class == ''
end)

-------------------------------- Execution --------------------------------

ferret:start()

----------------------------------- End -----------------------------------