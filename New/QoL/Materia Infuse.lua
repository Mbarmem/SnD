--[[

***********************************************
*              Materia Infusion               *
*    Script for ARR Relic Materia Infusion    *
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

-------------------
--    General    --
-------------------

Sphere_Scroll = "Stardust Rod" -- Curtana, Sphairai, Bravura, Gae Bolg, Artemis Bow, Thyrus, Stardust Rod, The Veil of Wiyu, Omnilex, Holy Shield, Yoshimitsu
MateriaToUse = {
    [1] = "Quicktongue Materia",
    [2] = "Quickarm Materia"
}

local ScrollId     = 0
local InfusedCount = 0
local EchoPrefix   = "[Materia Infuse] "

--------------------------------- Constant --------------------------------

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    occupied = 39
}

----------------------
--    Scroll Data   --
----------------------

ScrollList = {
    { itemName = "Curtana",           itemId = 7873 },
    { itemName = "Sphairai",          itemId = 7874 },
    { itemName = "Bravura",           itemId = 7875 },
    { itemName = "Gae Bolg",          itemId = 7876 },
    { itemName = "Artemis Bow",       itemId = 7877 },
    { itemName = "Thyrus",            itemId = 7878 },
    { itemName = "Stardust Rod",      itemId = 7879 },
    { itemName = "The Veil of Wiyu",  itemId = 7880 },
    { itemName = "Omnilex",           itemId = 7881 },
    { itemName = "Holy Shield",       itemId = 7882 },
    { itemName = "Yoshimitsu",        itemId = 9255 }
}

-------------------------
--    Materia Index    --
-------------------------

ItemIndex = {
    { itemName = "Heavens' Eye Materia I",      itemIndex = 0  },
    { itemName = "Heavens' Eye Materia II",     itemIndex = 1  },
    { itemName = "Heavens' Eye Materia III",    itemIndex = 2  },
    { itemName = "Heavens' Eye Materia IV",     itemIndex = 3  },
    { itemName = "Quickarm Materia I",          itemIndex = 4  },
    { itemName = "Quickarm Materia II",         itemIndex = 5  },
    { itemName = "Quickarm Materia III",        itemIndex = 6  },
    { itemName = "Quickarm Materia IV",         itemIndex = 7  },
    { itemName = "Savage Aim Materia I",        itemIndex = 8  },
    { itemName = "Savage Aim Materia II",       itemIndex = 9  },
    { itemName = "Savage Aim Materia III",      itemIndex = 10 },
    { itemName = "Savage Aim Materia IV",       itemIndex = 11 },
    { itemName = "Piety Materia I",             itemIndex = 12 },
    { itemName = "Piety Materia II",            itemIndex = 13 },
    { itemName = "Piety Materia III",           itemIndex = 14 },
    { itemName = "Piety Materia IV",            itemIndex = 15 },
    { itemName = "Savage Might Materia I",      itemIndex = 16 },
    { itemName = "Savage Might Materia II",     itemIndex = 17 },
    { itemName = "Savage Might Materia III",    itemIndex = 18 },
    { itemName = "Savage Might Materia IV",     itemIndex = 19 },
    { itemName = "Quicktongue Materia I",       itemIndex = 20 },
    { itemName = "Quicktongue Materia II",      itemIndex = 21 },
    { itemName = "Quicktongue Materia III",     itemIndex = 22 },
    { itemName = "Quicktongue Materia IV",      itemIndex = 23 },
    { itemName = "Battledance Materia I",       itemIndex = 24 },
    { itemName = "Battledance Materia II",      itemIndex = 25 },
    { itemName = "Battledance Materia III",     itemIndex = 26 },
    { itemName = "Battledance Materia IV",      itemIndex = 27 },
}

-------------------------
--    Materia Range    --
-------------------------

MateriaRange = {
    { itemName = MateriaToUse[1] .. " I",   minRange = 0,  maxRange = 11 },
    { itemName = MateriaToUse[1] .. " II",  minRange = 11, maxRange = 22 },
    { itemName = MateriaToUse[1] .. " III", minRange = 22, maxRange = 33 },
    { itemName = MateriaToUse[1] .. " IV",  minRange = 33, maxRange = 44 },
    { itemName = MateriaToUse[2] .. " I",   minRange = 44, maxRange = 55 },
    { itemName = MateriaToUse[2] .. " II",  minRange = 55, maxRange = 66 },
    { itemName = MateriaToUse[2] .. " III", minRange = 66, maxRange = 75 }
}

-------------------------------- Functions --------------------------------

--- Checks for the selected Sphere Scroll in the ScrollList and validates its presence in the inventory.
--- If not found, it logs an error and stops the script.
function Checks()
    for _, scroll in ipairs(ScrollList) do
        if Sphere_Scroll == scroll.itemName then
            local item = Inventory.GetInventoryItem(scroll.itemId)
            ScrollId = scroll.itemId

            -- If the item isn't present in inventory, stop the script
            if not item or item.ItemId == 0 then
                Echo(string.format("Stopping Script... Sphere Scroll not found in inventory!"), EchoPrefix)
                yield("/snd stop all")
            end

            return ScrollId
        end
    end

    -- Scroll name was not found in the ScrollList
    Echo(string.format("Stopping Script... Sphere Scroll '%s' is invalid!", Sphere_Scroll), EchoPrefix)
    yield("/snd stop all")
end

-- Opens the Sphere Scroll UI and updates the InfusedCount
function SphereScroll()
    if Inventory.GetItemCount(ScrollId) > 0 and not IsAddonReady("RelicSphereScroll") then
        yield("/hold CONTROL")
        yield("/send KEY_1")
        yield("/release CONTROL")
        WaitForAddon("RelicSphereScroll")
    end

    local infused = GetNodeText("RelicSphereScroll", 1, 2, 10)
    InfusedCount = tonumber(infused) or 0
end

-------------------------------- Execution --------------------------------

-- Build fast lookup map for materia indices
local ItemIndexMap = {}
for _, item in ipairs(ItemIndex) do
    ItemIndexMap[item.itemName] = item.itemIndex
end

Checks()
SphereScroll()

for _, materia in ipairs(MateriaRange) do
    local itemIndex = ItemIndexMap[materia.itemName]
    if itemIndex then
        while InfusedCount >= materia.minRange and InfusedCount < materia.maxRange do
            LogInfo(string.format("%sInfusing %s (Index %d)...", EchoPrefix, materia.itemName, itemIndex))

            yield(string.format("/callback RelicSphereScroll true 1 %d", itemIndex))
            Wait(1)

            yield("/callback RelicSphereScroll true 2")
            Wait(1)

            -- Retry loop to avoid infinite wait
            local retryCount = 0
            repeat
                Wait(0.1)
                retryCount = retryCount + 1
            until not GetCharacterCondition(CharacterCondition.occupied) or retryCount > 100

            if retryCount > 100 then
                Echo("Timed out waiting for infusion to complete. Exiting loop.", EchoPrefix)
                break
            end

            PlayerTest()
            SphereScroll()
        end
    else
        Echo(string.format("No item index found for '%s'", tostring(materia.itemName)), EchoPrefix)
    end
end

Echo("Materia infusion complete!", EchoPrefix)

----------------------------------- End -------------------------------------