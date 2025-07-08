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

local ferret = require("Ferret/Templates/StellarMissions")
require("Ferret/Plugins/ExtractMateria")
require("Ferret/Plugins/Repair")
require("Ferret/Plugins/CraftingConsumables")

-------------------------------- Variables --------------------------------

-----------------
--    Config   --
-----------------

ferret.job = GetClassJobId()
Logger.show_debug = false
Ferret.language = 'en'
ferret.plugins.repair.threshold = 20

---------------
--    Food   --
---------------

ferret.plugins.crafting_consumables.food = "Rroneek Steak <HQ>"
ferret.plugins.crafting_consumables.medicine = ""
ferret.plugins.crafting_consumables.medicine_threshold = 1

------------------
--    Missions  --
------------------

ferret.minimum_target_result = MissionResult.Gold
ferret.minimum_acceptable_result = MissionResult.Silver
ferret.mission_list = ferret:create_job_list_by_ids({
  32,  31,  30,  43,  40,  25,  24,   -- CRP
  77,  76,  75,  88,  85,  70,  69,   -- BSM
  122, 121, 120, 133, 130, 115, 114,  -- ARM
  167, 166, 165, 178, 175, 160, 159,  -- GSM
  212, 211, 210, 223, 220, 205, 204,  -- LTW
  257, 256, 255, 268, 265, 250, 249,  -- WVR
  302, 301, 300, 313, 310, 295, 294,  -- ALC
  347, 346, 345, 358, 355, 340, 339,  -- CUL
})

ferret.per_mission_target_result = {
  [32] = MissionResult.Silver, -- CRP
  [31] = MissionResult.Silver,
  [30] = MissionResult.Silver,
  [43] = MissionResult.Silver,
  [40] = MissionResult.Silver,
  [24] = MissionResult.Silver,
  [77] = MissionResult.Silver, -- BSM
  [76] = MissionResult.Silver,
  [75] = MissionResult.Silver,
  [88] = MissionResult.Silver,
  [85] = MissionResult.Silver,
  [69] = MissionResult.Silver,
  [122] = MissionResult.Silver, -- ARM
  [121] = MissionResult.Silver,
  [120] = MissionResult.Silver,
  [133] = MissionResult.Silver,
  [130] = MissionResult.Silver,
  [114] = MissionResult.Silver,
  [167] = MissionResult.Silver, -- GSM
  [166] = MissionResult.Silver,
  [175] = MissionResult.Silver,
  [178] = MissionResult.Silver,
  [175] = MissionResult.Silver,
  [159] = MissionResult.Silver,
  [212] = MissionResult.Silver, -- LTW
  [211] = MissionResult.Silver,
  [210] = MissionResult.Silver,
  [223] = MissionResult.Silver,
  [220] = MissionResult.Silver,
  [204] = MissionResult.Silver,
  [257] = MissionResult.Silver, -- WVR
  [256] = MissionResult.Silver,
  [255] = MissionResult.Silver,
  [268] = MissionResult.Silver,
  [265] = MissionResult.Silver,
  [249] = MissionResult.Silver,
  [302] = MissionResult.Silver, -- ALC
  [301] = MissionResult.Silver,
  [300] = MissionResult.Silver,
  [313] = MissionResult.Silver,
  [310] = MissionResult.Silver,
  [294] = MissionResult.Silver,
  [347] = MissionResult.Silver, -- CUL
  [346] = MissionResult.Silver,
  [345] = MissionResult.Silver,
  [358] = MissionResult.Silver,
  [355] = MissionResult.Silver,
  [339] = MissionResult.Silver,
}

-------------------------------- Execution --------------------------------

ferret:start()

----------------------------------- End -----------------------------------