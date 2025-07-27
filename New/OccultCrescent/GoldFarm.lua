--[=====[
[[SND Metadata]]
author: Mo
version: 2.0.0
description: Occult Crescent - Script for Gold Farming
plugin_dependencies:
- BossModReborn
- Lifestream
- RotationSolver
- visland
- vnavmesh
- YesAlready
dependencies:
- source: git://Mbarmem/SnD/main/New/MoLib/MoLib.lua
  name: SnD
  type: git
configs:
  ClassName:
    default: WarriorOC
    description: Class used by the script for gold farming.
    type: string
    required: true
  AetheryteName:
    default: Occult Aetheryte
    description: Aetheryte location used to teleport to the farming location.
    type: string
    required: true
  RouteFarm:
    default: H4sIAAAAAAAACu2c3W/bNhDA/5WAz8KBPN4d7/Q2ZG2RbW2zNUDXDntwE7UxYFtZLHcoivzvAy35I83SBZgBGwmfLNE2RVE/3Pfpq3s1mjaudr98nhwFOjq+bubnzaw7Oh3Nusvm+uhzAHSVe3HdLq5c7V6fny8m3fpnrnLP2/bC1b5yL0ezxWiyPDwbXX9quhejPMNJ10yXg29HX67a8aybu/qPr+60nY+7cTtz9Vf3u6tRDBIlw8q9c3VSwKReKvfe1YQGQVnopnLv21lz8qOrAzJW7rfRxXgxd3WEfPn2czPNS6qxcqej7vLjeHbh6u560VTuZNY116Pz7u24u3ydJ/C3x4ZNcLdHv1mjz5d5N3y+X37eVG5+2f69+tO4nc1d/XE0mW9dczlBqNyzads1q2t3zXQ4/GH5i+Hk10Uz77aP3zR/9ZvbfhiG33Tt1XE7uxhW5iv383gyOW4X+dZ95X5rF12zuZ/jy1F33E6no7wZeSCv9+1o3G0Wms+et9e3J82DZ+Np83J+6/TZ2d3NuKncyfz0cjTr2ul60vwEXD1bTCaVe9U0F/OX/Qr759GjMZ59Ovty1bjaLE/xqr1o1v/PJz+1H1ztb6q7tCQPxElXsHjFoD0sEcGiYboXFg+8DYsvsDwMln5v/pMVjLukZfj6f+MiQIFiWvGiTGEQLtGDJB8KL3vihfNTOTReVMBYwqCMEng1sZ4XMqBkIRZe9sNLiAcJTAJUoRUvAQ3jmheUYA+1XQouB2y77AgWCyARw5oWUcx275IWBjEpwmVPwoViPDxclCB5W9NCJpxojYtSkIJLwWX1LCIhKDEOvpFAItNeukRVMGHWwsuebBdPh6eOIhMwauQeGAYm5TQAw2BCWIyXwsuGF/Og4nv5IgqBKcrgTAcETQnvV0gFmKcIjIJItD76IgkINZszS2A8ePGFl30ZMCQHiItB8sqywQWl10fkCRL7+OBMQOFlt7wo0eHxkuO5KYZBvBgkFsvWzFK+RMBAofBSoi9r8RLBJK6tF0oUelhiVCB/v3NUsoxPLMsYbRltycqn10RCrH0aIFKEyGZcJMt+NFHUA9REloCJcnCu54WNsPeMIgUwVC2R3cLL+llQyJHdGHpcCMzMtNdFmAhQUnGMHoMy2hEtFMGC3KKlV0aoAcS8L8KlhF22eRFAxuyx3QVGwTTw/UUvRbw8vSIG4gQpaLZY7gAjChRZSyagSJgtYCSH4yjFfwOGAa3wsi9eEh1eZpokQog6VGF+a+8GSFGtAFMyARtgLEIy9YN8YUiksU8coSkocizxlyJgNrzksl1V3tZHKQy8EKjgw3tICi9PgRfO2aFtg5dzZiDH67wHC1b0UQnA3FJHaEtFOeCiIXvXS1wYUMN3ugIKLk8NF9YAyqkvqxMCElkZu0s9ZQ8O7pZM42PPNLJ6IMn9rgMrLCIDLEaAWBpIHgUsu5EsggkwrvQQQrLcCZvVUEhAKiWuu78wXThEXBBow0sEW/YeLXkJIIHSg2teCi879oowHBwuLBG8932ekQ2CRBz6R1CBJMXiFBVcNriwAAYccFFIKCvpggLqpVguhZYtWjwwDbW6rCCEREP5JSYgSkW4FFw2uFACQdVtXAZdFAOwmhVTd0+4HGLvK1Mu99e1dEne+0EX5de8yPde21FweWpuNJNACOz7CB0bWEx+1flKEXz4Tvi/VNQ9uUYj9gQUbXgTgwhELznXmHERBE5sRbwU8bLGJSCkkGxDC+cW2IEWCimW6u5Cy4aWBMa8qtYVQEQeHCNGSCmEEqUruGx0UQAmnwNzPS6MMpRGRY0gauVtqY+Blp1kF0kEdIj+aw7WaV8URSFAVIsP9qELKs2jQuXPm38Awk46+/9ZAAA=
    description: Route or path used to navigate the farming area.
    type: string
    required: true
  RouteAetheryte:
    default: H4sIAAAAAAAACmVSXW/bMAz8K8M9a4GTNE2st8L9QDYkzVoDaTP0QY3ZWoAtZhbdIQj83wvZbuF1TyJPFHl31AlrUxI0VvxGKV+Q5FQdhaBwU3F9gMbtfl8X8i2pyO/JCRSumTPoSGFlXG2KNkxN9UpyY8L7pVDZgltzPLB14qF/n7Bhb8Wygz7hAXoxjUbzs/OFwiP0fDKKF9NFrLCD/n4ez0bxPJ7MGoUdO1peQo8ns4nCncls7aHPRmE8v1EZKIVZGyP5i3UZtFQ1KSydUGX2srWS34YG0b9Yr5s7dWYgfFj1hXMUxj725649GwWf89+PR5adh34xhR9waBuMFa5KFvrgIlT24UVb0Se/avIyjO/pT2c2P/fwvfAhYZf1zCKFn7YoEq57K+64Fur1QSHJjSRcliaYE4DAd2tsWEvnVUiuuRr0HHdgaktaeehpFLXr7JCr9H87GoWl3+TGCZef+sNOoF1dFAprosyvOo79dfdbrHtNjweCjuPQY80ZfVaE5Ac/Q0fNU/MOHbPQq6wCAAA=
    description: Route or path used to go to the Aetheryte.
    type: string
    required: true

[[End Metadata]]
--]=====]

--=========================== VARIABLES ==========================--

-------------------
--    General    --
-------------------

ClassName       = Config.Get("ClassName")
AetheryteName   = Config.Get("AetheryteName")
RouteFarm       = Config.Get("RouteFarm")
RouteAetheryte  = Config.Get("RouteAetheryte")
LogPrefix       = "[GoldFarm]"

--============================ CONSTANT ==========================--

-------------------
--    Plugins    --
-------------------

HasVisland = HasPlugin("visland")

----------------
--    Zone    --
----------------

Zones = {
    SouthHorn      = 1252,
    PhantomVillage = 1278
}

--=========================== FUNCTIONS ==========================--

------------------
--    Checks    --
------------------

function Checks()
    if GetClassJobId() ~= 21 then
        LogInfo(string.format("%s Crafter class changed to: %s", LogPrefix, className))
        yield("/gearset change ".. ClassName)
        Wait(1)
    end
end

----------------
--    Move    --
----------------

function MoveToOC()
    WaitForPlayer()

    if not IsInZone(Zones.PhantomVillage) then
        LogInfo(string.format("%s Moving to Occult Crescent", LogPrefix))
        Teleport("Occult")
        return
    end

    LogInfo(string.format("%s Interacting with Jeffroy to enter Occult Crescent", LogPrefix))
    Interact("Jeffroy")

    while not IsBoundByDuty() do
        if IsAddonVisible("SelectString") then
            yield("/callback SelectString true 0")
            LogInfo(string.format("%s Confirmed SelectString", LogPrefix))
        elseif IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            LogInfo(string.format("%s Confirmed SelectYesno", LogPrefix))
        elseif IsAddonVisible("ContentsFinderConfirm") then
            yield("/click ContentsFinderConfirm Commence")
            LogInfo(string.format("%s Commenced duty via ContentsFinderConfirm", LogPrefix))
        end
        Wait(1)
    end
    WaitForPlayer()
	Wait(1)
end

function MoveToEG()
    VislandRouteStart(RouteAetheryte, false)
    WaitForPlayer()
    VislandRouteStop()

    LogInfo(string.format("%s Moving to Eldergrowth", LogPrefix))
    Teleport("Eldergrowth")
end

----------------
--    Misc    --
----------------

function VislandPause()
    if HasVisland and IsVislandRouteRunning() then
        LogInfo(string.format("%s Pausing Visland route", LogPrefix))
        VislandSetRoutePaused(true)
    end
end

function VislandResume()
    if HasVisland and IsVislandRoutePaused() then
        LogInfo(string.format("%s Resuming paused Visland route", LogPrefix))
        VislandSetRoutePaused(false)
    elseif HasVisland and not IsVislandRouteRunning() then
        LogInfo(string.format("%s Starting Visland route: %s (Loop: true)", LogPrefix, RouteFarm))
        VislandRouteStart(RouteFarm, true)
    end
end

--=========================== EXECUTION ==========================--

Checks()

while true do
    if not IsInZone(Zones.SouthHorn) then
        VislandRouteStop()
        MoveToOC()
        MoveToEG()
        VislandResume()
        yield("/rsr auto")
        yield("/bmrai on")
        return
    elseif IsVislandRouteRunning() then
        Wait(1)
        return
    else
        LeaveInstance()
        WaitForPlayer()
        Wait(1)
    end
end

--============================== END =============================--