--[[

***********************************************
*              Materia Infusion               *
*    Script for ARR Relic Materia Infusion    *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

]]

-------------------------------- Variables --------------------------------

-------------------
--    General    --
-------------------

Sphere_Scroll = "Curtana" -- Curtana, Sphairai, Bravura, Gae Bolg, Artemis Bow, Thyrus, Stardust Rod, The Veil of Wiyu, Omnilex, Holy Shield, Yoshimitsu
MateriaToUse = {
    [1] = "Quicktongue Materia",
    [2] = "Quickarm Materia"
}

local ScrollId = 0
local InfusedCount = 0

--------------------------------- Constant --------------------------------

-----------------
--    Scroll   --
-----------------

ScrollList = {
    {itemName = "Curtana", itemId = 7873},
    {itemName = "Sphairai", itemId = 7874},
    {itemName = "Bravura", itemId = 7875},
    {itemName = "Gae Bolg", itemId = 7876},
    {itemName = "Artemis Bow", itemId = 7877},
    {itemName = "Thyrus", itemId = 7878},
    {itemName = "Stardust Rod", itemId = 7879},
    {itemName = "The Veil of Wiyu", itemId = 7880},
    {itemName = "Omnilex", itemId = 7881},
    {itemName = "Holy Shield", itemId = 7882},
    {itemName = "Yoshimitsu", itemId = 9255}
}

-----------------
--    Index    --
-----------------

ItemIndex = {
    {itemName = "Savage Aim Materia I", itemIndex = 0},
    {itemName = "Savage Aim Materia II", itemIndex = 1},
    {itemName = "Savage Aim Materia III", itemIndex = 2},
    {itemName = "Savage Aim Materia IV", itemIndex = 3},
    {itemName = "Savage Might Materia I", itemIndex = 4},
    {itemName = "Savage Might Materia II", itemIndex = 5},
    {itemName = "Savage Might Materia III", itemIndex = 6},
    {itemName = "Savage Might Materia IV", itemIndex = 7},
    {itemName = "Heavens' Eye Materia I", itemIndex = 8},
    {itemName = "Heavens' Eye Materia II", itemIndex = 9},
    {itemName = "Heavens' Eye Materia III", itemIndex = 10},
    {itemName = "Heavens' Eye Materia IV", itemIndex = 11},
    {itemName = "Quickarm Materia I", itemIndex = 12},
    {itemName = "Quickarm Materia II", itemIndex = 13},
    {itemName = "Quickarm Materia III", itemIndex = 14},
    {itemName = "Quickarm Materia IV", itemIndex = 15},
    {itemName = "Quicktongue Materia I", itemIndex = 16},
    {itemName = "Quicktongue Materia II", itemIndex = 17},
    {itemName = "Quicktongue Materia III", itemIndex = 18},
    {itemName = "Quicktongue Materia IV", itemIndex = 19},
    {itemName = "Battledance Materia I", itemIndex = 20},
    {itemName = "Battledance Materia II", itemIndex = 21},
    {itemName = "Battledance Materia III", itemIndex = 22},
    {itemName = "Battledance Materia IV", itemIndex = 23},
    {itemName = "Piety Materia I", itemIndex = 24},
    {itemName = "Piety Materia II", itemIndex = 25},
    {itemName = "Piety Materia III", itemIndex = 26},
    {itemName = "Piety Materia IV", itemIndex = 27}
}

----------------
--    List    --
----------------

MateriaList = {
    {itemName = MateriaToUse[1].." I", minRange = 0, maxRange = 11},
    {itemName = MateriaToUse[1].." II", minRange = 11, maxRange = 22},
    {itemName = MateriaToUse[1].." III", minRange = 22, maxRange = 33},
    {itemName = MateriaToUse[1].." IV", minRange = 33, maxRange = 44},
    {itemName = MateriaToUse[2].." I", minRange = 44, maxRange = 55},
    {itemName = MateriaToUse[2].." II", minRange = 55, maxRange = 66},
    {itemName = MateriaToUse[2].." III", minRange = 66, maxRange = 75}
}

-------------------------------- Functions --------------------------------

------------------
--    Checks    --
------------------

function Checks()
    for _, scroll in pairs(ScrollList) do
        if Sphere_Scroll == scroll.itemName then
            ScrollId = scroll.itemId
            if GetItemCount(ScrollId) == 0 then
                yield("/echo [Materia Infuse] Stopping Script.. Sphere Scroll not found..!!")
                yield("/snd stop")
            end
            break
        end
    end
    return ScrollId
end

----------------
--    Wait    --
----------------

function PlayerTest()
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

----------------
--    Main    --
----------------

function SphereScroll()
    if GetItemCount(ScrollId) > 0 then
        yield("/hold CONTROL")
        yield("/send KEY_1")
        yield("/release CONTROL")

        repeat
            yield("/wait 1")
        until IsAddonVisible("RelicSphereScroll")

        local infused = GetNodeText("RelicSphereScroll", 70)
        InfusedCount = tonumber(infused) or 0
    end
end

-------------------------------- Execution --------------------------------

Checks()
SphereScroll()

for _, materia in pairs(MateriaList) do
    for _, index in pairs(ItemIndex) do
        if materia.itemName == index.itemName then
            while InfusedCount >= materia.minRange and InfusedCount < materia.maxRange do
                yield("/callback RelicSphereScroll true 1 "..index.itemIndex)
                yield("/wait 1")
                yield("/callback RelicSphereScroll true 2")
                PlayerTest()
                yield("/wait 1")
                SphereScroll()
            end
        end
    end
end

----------------------------------- End -----------------------------------