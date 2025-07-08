--[[

***********************************************
*              Crescent Occult                *
*          Script for Auto Farming            *
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

className = "Warrior"
aetheryteName = "Occult Aetheryte"
routeFarm = "Lvl 14 Crescent Panther v1.2"
routeAetheryte = "MoveToAetheryte"

--[[

KillRoute = H4sIAAAAAAAACu2c3W/bNhDA/5WAz8KBPN4d7/Q2ZG2RbW2zNUDXDntwE7UxYFtZLHcoivzvAy35I83SBZgBGwmfLNE2RVE/3Pfpq3s1mjaudr98nhwFOjq+bubnzaw7Oh3Nusvm+uhzAHSVe3HdLq5c7V6fny8m3fpnrnLP2/bC1b5yL0ezxWiyPDwbXX9quhejPMNJ10yXg29HX67a8aybu/qPr+60nY+7cTtz9Vf3u6tRDBIlw8q9c3VSwKReKvfe1YQGQVnopnLv21lz8qOrAzJW7rfRxXgxd3WEfPn2czPNS6qxcqej7vLjeHbh6u560VTuZNY116Pz7u24u3ydJ/C3x4ZNcLdHv1mjz5d5N3y+X37eVG5+2f69+tO4nc1d/XE0mW9dczlBqNyzads1q2t3zXQ4/GH5i+Hk10Uz77aP3zR/9ZvbfhiG33Tt1XE7uxhW5iv383gyOW4X+dZ95X5rF12zuZ/jy1F33E6no7wZeSCv9+1o3G0Wms+et9e3J82DZ+Np83J+6/TZ2d3NuKncyfz0cjTr2ul60vwEXD1bTCaVe9U0F/OX/Qr759GjMZ59Ovty1bjaLE/xqr1o1v/PJz+1H1ztb6q7tCQPxElXsHjFoD0sEcGiYboXFg+8DYsvsDwMln5v/pMVjLukZfj6f+MiQIFiWvGiTGEQLtGDJB8KL3vihfNTOTReVMBYwqCMEng1sZ4XMqBkIRZe9sNLiAcJTAJUoRUvAQ3jmheUYA+1XQouB2y77AgWCyARw5oWUcx275IWBjEpwmVPwoViPDxclCB5W9NCJpxojYtSkIJLwWX1LCIhKDEOvpFAItNeukRVMGHWwsuebBdPh6eOIhMwauQeGAYm5TQAw2BCWIyXwsuGF/Og4nv5IgqBKcrgTAcETQnvV0gFmKcIjIJItD76IgkINZszS2A8ePGFl30ZMCQHiItB8sqywQWl10fkCRL7+OBMQOFlt7wo0eHxkuO5KYZBvBgkFsvWzFK+RMBAofBSoi9r8RLBJK6tF0oUelhiVCB/v3NUsoxPLMsYbRltycqn10RCrH0aIFKEyGZcJMt+NFHUA9REloCJcnCu54WNsPeMIgUwVC2R3cLL+llQyJHdGHpcCMzMtNdFmAhQUnGMHoMy2hEtFMGC3KKlV0aoAcS8L8KlhF22eRFAxuyx3QVGwTTw/UUvRbw8vSIG4gQpaLZY7gAjChRZSyagSJgtYCSH4yjFfwOGAa3wsi9eEh1eZpokQog6VGF+a+8GSFGtAFMyARtgLEIy9YN8YUiksU8coSkocizxlyJgNrzksl1V3tZHKQy8EKjgw3tICi9PgRfO2aFtg5dzZiDH67wHC1b0UQnA3FJHaEtFOeCiIXvXS1wYUMN3ugIKLk8NF9YAyqkvqxMCElkZu0s9ZQ8O7pZM42PPNLJ6IMn9rgMrLCIDLEaAWBpIHgUsu5EsggkwrvQQQrLcCZvVUEhAKiWuu78wXThEXBBow0sEW/YeLXkJIIHSg2teCi879oowHBwuLBG8932ekQ2CRBz6R1CBJMXiFBVcNriwAAYccFFIKCvpggLqpVguhZYtWjwwDbW6rCCEREP5JSYgSkW4FFw2uFACQdVtXAZdFAOwmhVTd0+4HGLvK1Mu99e1dEne+0EX5de8yPde21FweWpuNJNACOz7CB0bWEx+1flKEXz4Tvi/VNQ9uUYj9gQUbXgTgwhELznXmHERBE5sRbwU8bLGJSCkkGxDC+cW2IEWCimW6u5Cy4aWBMa8qtYVQEQeHCNGSCmEEqUruGx0UQAmnwNzPS6MMpRGRY0gauVtqY+Blp1kF0kEdIj+aw7WaV8URSFAVIsP9qELKs2jQuXPm38Awk46+/9ZAAA=

AetheryteRoute = H4sIAAAAAAAACmVSXW/bMAz8K8M9a4GTNE2st8L9QDYkzVoDaTP0QY3ZWoAtZhbdIQj83wvZbuF1TyJPFHl31AlrUxI0VvxGKV+Q5FQdhaBwU3F9gMbtfl8X8i2pyO/JCRSumTPoSGFlXG2KNkxN9UpyY8L7pVDZgltzPLB14qF/n7Bhb8Wygz7hAXoxjUbzs/OFwiP0fDKKF9NFrLCD/n4ez0bxPJ7MGoUdO1peQo8ns4nCncls7aHPRmE8v1EZKIVZGyP5i3UZtFQ1KSydUGX2srWS34YG0b9Yr5s7dWYgfFj1hXMUxj725649GwWf89+PR5adh34xhR9waBuMFa5KFvrgIlT24UVb0Se/avIyjO/pT2c2P/fwvfAhYZf1zCKFn7YoEq57K+64Fur1QSHJjSRcliaYE4DAd2tsWEvnVUiuuRr0HHdgaktaeehpFLXr7JCr9H87GoWl3+TGCZef+sNOoF1dFAprosyvOo79dfdbrHtNjweCjuPQY80ZfVaE5Ac/Q0fNU/MOHbPQq6wCAAA=

]]

--------------------------------- Constant --------------------------------

-------------------
--    Plugins    --
-------------------

RequiredPlugins = {
    "RotationSolver",
    "Lifestream",
    "TeleporterPlugin",
    "vnavmesh",
    "visland",
    "YesAlready",
}

HasVisland = HasPlugin("visland")

---------------------
--    Condition    --
---------------------

CharacterCondition = {
    inCombat=26,
    casting=27,
    boundByDuty=34,
    occupied=39,
    betweenAreas=45
}

-------------------------------- Functions --------------------------------

-------------------
--    Plugins    --
-------------------

function Plugins()
    for _, plugin in ipairs(RequiredPlugins) do
        if not HasPlugin(plugin) then
            yield("/echo [GoldFarm] Missing required plugin: "..plugin)
            StopFlag = true
        end
    end
    if StopFlag then
        yield("/echo [GoldFarm] Stopping the script..!!")
        yield("/snd stop")
    end
end

------------------
--    Checks    --
------------------

function Checks()
    if GetClassJobId() ~= 21 then
        yield("/gearset change "..className)
        yield("/wait 1")
        yield("/echo [GoldFarm] Crafter class changed to: "..className)
    end
end

----------------
--    Wait    --
----------------

function PlayerTest()
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

function WaitForLifeStream()
    repeat
        yield("/wait 1")
    until not LifestreamIsBusy()
    PlayerTest()
end

function WaitForTp()
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait 1")
    end
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 1")
    end
    PlayerTest()
    yield("/wait 1")
end

----------------
--    Move    --
----------------

function Target(destination)
    attemptsCount = 0
    yield("/target "..destination)
    yield("/wait 0.5")
    while GetTargetName():lower() ~= destination:lower() do
        yield("/target "..destination)
        yield("/wait 0.5")
    end
end

function MoveToOC()
    PlayerTest()
    if IsInZone(1278) then
        Target("Jeffroy")
        yield("/wait 0.5")
        yield("/interact")
        while not GetCharacterCondition(CharacterCondition.boundByDuty) do
            yield("/wait 1")
            if IsAddonVisible("SelectString") then
                yield("/callback SelectString true 0")
                yield("/wait 1")
            elseif IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 0")
                yield("/wait 1")
            elseif IsAddonVisible("ContentsFinderConfirm") then
                yield("/wait 1")
                yield("/click ContentsFinderConfirm Commence")
            end
        end
    else
        yield("/li Occult")
        yield("/echo [GoldFarm] Moving to Occult Crescent")
        WaitForLifeStream()
    end
end

function MoveToEG()
    yield("/visland exec "..routeAetheryte)
    yield("/wait 3")
    VislandStop()
    yield("/li Eldergrowth")
    yield("/echo [GoldFarm] Moving to Eldergrowth")
    WaitForLifeStream()
end

function VislandStop()
    if HasVisland and IsVislandRouteRunning() then
        yield("/visland stop")
    end
end

function VislandPause()
    if HasVisland and IsVislandRouteRunning() then
        VislandSetRoutePaused(true)
    end
end

function VislandResume()
    if HasVisland and VislandIsRoutePaused() then
        VislandSetRoutePaused(false)
    elseif HasVisland and not IsVislandRouteRunning() then
        yield("/visland exec "..routeFarm)
    end
end

----------------
--    Misc    --
----------------

function JobSwitch()
    if true then
        if GetCharacterCondition(CharacterCondition.inCombat) and not combat then
            combat = true
        end

        if not GetCharacterCondition(CharacterCondition.inCombat) and combat then
            for i=0,5,1 do
            yield("/phantomjob thief")
            yield("/wait 0.1")
        end

        yield("/phantomjob cannoneer")
        combat = false
        end
        yield("/wait 0.3")
    end
end

-------------------------------- Execution --------------------------------

Plugins()
Checks()

state = true
combat = false

while state do
    if not IsInZone(1252) then
        VislandStop()
        MoveToOC()
        WaitForTp()
        MoveToEG()
        WaitForTp()
        VislandResume()
        yield("/rsr auto")
        yield("/bmrai on")
    else
        JobSwitch()
        yield("/wait 1")
    end        
end

----------------------------------- End -----------------------------------