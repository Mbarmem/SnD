--[[
  Name: HybridFishingCraftAndSubmit
  Author: SubaruYashiro
  Version: 1.2
  
  Requirements:
    -> SomethingNeedDoing (Expanded Edition) (Testing Version) v12.0.0.0
    -> Autohook
    -> Artisan
    -> (Optional) ChatCoordinates
    -> (Optional) Ice's Cosmic Exploration | Run with this to auto grab missions
  
  Make sure you're on SomethingNeedDoing (Expanded Edition) and it's in testing version, it should be around v12.0.0.0

  Autohook preset:
    Normal:
      Moon Gel: AH4_H4sIAAAAAAAACu1YS2/jNhD+KwbPYkFRoh6+ed1sNoCTDeIUPQQ9jCTKJiJTXoraJg383wvqEUuK7TjZdLEpcrOHnG8e+maG5AOalDqfQqGLabpA4wd0IiHK+CTL0FirklvoisdQ6IkUK9Ail1OQMX9cvC6VnOZZxmP9NU1b6XRZrvYoGFMzIbkxdbaQueLneR4v0TiFrOBWYz5pt58laEyD0EKXSuRK6Hs0ti10VpzcxVmZ8GQrNvs3NX6D+ICqH7QyZXC8wEKn6+ul4sUyzxI0tgnpIR+GrjBCv6dBnnXG5KL1wLWJO3DBGbjQatU57Sja3W30ebO5SgRk2y/aS6lNPa+XVLdR+yyK5ck9LzqG2cBjxnoee23S4ZbPlyLVn0BUfhtB0QrmGuLbAo1Zk0YveIrbRQ0b1EvQgsuYd/zxhnpeP4O0VVXiHz4FXVOhtTrUDoK+ttNoXy8hE3BbfIbvuTIAPUEbjmP15Vc8zr9zhca2SdIuLnuBoUDHYJu/T2JxCqsq0IlcZFwVrRHzsQ1TfOIOvac9qGCzsdDJnVbQ1LLJ/HU+/xvWZ1KXwlTjKQjZ5gPbFpqVip/zooAFR2OELHRROYEucsmRVSPcrzkam8TswJvlhX413qXiBd/tIcJoz3ptsVrf+jNf81gryKalUlzqN4pygPpmse709knEO61Xu2qCzHW+NvUq5GKu+brqjFvfGxJN1Nu43IWrfPhDim8lN7goDlhA3Ihg4oYOdmMe4iCkNrZZ6gURI4nv+WhjoZko9NfU2CjQ+Kampwng0cEw3O/hJMtGterQzYtcrSD7kue3BqjtGH9yqP4becH1Yy325kyzaAJsq7QR1fCu7ZtO1GLOtcplZ0ruUD+HOyO9Fqu6DfxGnkASpwM54wsuE1D3r/W1sjToNOdCdp2gxgkzh3btNfL+fm+fz7/nZZQ9l9ieIvXCR71t8l6qeUyOBnl/EkKNd63E+oUR+Iw6j5ovjKGne0wUP+uDtp6ZFjJJNVdTKBdLPRMrM7tpvdDvLYS6zemtVPX5wPzoDMId087xWTg88JjBuPfsYk5ZbZ9vC/qKfyuF4slcgy7NEcIc435Olf8g6tsW+nuqxndaekfWh72rPg4Xx75qOHiB2PSmbBj64CReiH0vdbHrMoIBQoLBZ55jEzuxfYI2f7VjtrkE3XTO/02kT8buS88FRw3c40rr6FJ5nvpHcPw4Mj/L2qPoeSwPfzHC/VD7/fjm7/Kbd5pMwHjoRW6EKQeGXcITHEYswT51nITYKTiMd5pM3UZuHlC3n7gspAdaynmey0zo0RTUutda7EO5OEu41CKGzCTAWKo3TFZ5KXvbKvvDe7LTf7MIjKVSpRDzeWam7M5HEpeFwzcK2sex2cZCv8xr0/bu9+rObpSNZGqyWiW0ewdsbn7mZy3ebttF1e4NMYk9xweKbR4E2KWM4iDhIeZRBD71XTuMI7SxnvDIPnAhnJUS1OgKBKygfyn8INL/lkiMxSQCl2KHERe7KfFwGIKPUzsNgQUhc9NwF5Eo3R/Al3y9FnIxmpVykRq1Z7jUftqDl6dq4aoTW0uH/5Z9++g2YMwH3eQ+ulX33O6x24kT5iQ+ZhD42CUkxhAlBKdJHPleApACrSZiDd2+VmE6Hl3xVEiejMzEG53yrP9q5qSO7/hxgGOPRNglkY8BKMd+5MUssM1Rn6HNv4W/9r6hGQAA
      Metals: AH4_H4sIAAAAAAAACs1XTW/bOBD9KwbPUqEPivq4ud40DeCkQexiD8EeaGlkE5FFh6TSZAP/94KSaEuyXbtFsNibMuS8eTOZGT6/o3Gl+IRKJSf5EiXv6KqkiwLGRYESJSqw0AOkVKpxydZUMV5OaJnC7nBeiXLCiwJS9S3PjXWyqtYnHHSoKSthHyozRzcZSrwottD1Zr4SIFe8yFASOo6F7gXjgqk3lLgWupFXr2lRZZDtzRph26Dfcp6uNHz94emvGplEA2R3gPxr6BojDnsezlkyuhKGAXYdPKAQDygYr6aiHUe3e807H5aLjNHiRJFdj5C4C4hbty9Mrq7eQHYCBwPGQdBjTEzR6RPMVixXnymreWuDNIaZoumTREnQlpFEh7hd1LhFvaeKQZlChw8Z+pF+BT3jKti/MKGqaQUTdejtDervt97zFS0YfZJf6AsXGqBnMOn4Vt/+ACl/AYESVxfpWHeTSLdAJ6Cp32e2vKbrOtFxuSxASBNE/7MzlPihgw/Y96Ci7dZCV69K0HaSdeXnfPaDbm5KVTE9i9eUlaYetmuhaSXgFqSkS0AJQha6q0mgO14CshqEtw2gRBfmCN6US/XHePcCJBxniGx04ryJWJ/v+cw2kCpBi0klBJTqg7IcoH5YrkfZHmR8NHp9q2mQmeIbPa+sXM4UbOrNuOfeNtFYfAzlLlzN4XvJnivQuCjFDoQ4JTbJFrGN/dS3aUY9O/cXEEWE4hAo2lpoyqT6lusYEiWPTXvqBHYE4/g0w3FRjBrXIc07Lta0+Mr5kwYyG+NvoPXf2i5B7WYxp4UEM5vtoU7QTGlrauCxG+pNZDBnSvBy+QGojt9BncISyoyKt48C/otXi+JcAXqOHol3fmeTPOl5SSJHnL9LmAu2adLbyYra8ls5hIGns288fzOLnu9BHnO2BjHY5res3B3pd+OT06ieY3e1vX8//BSdoKCnepwrEBNaLVdqytb6OXWbg+G411qqEs17rT86D1PzZgTxUHFE+sU7qR60zjGb1ozUAzxXTEA2U1RV+hHXQurEnF02NxfPwfm+vqCBL+vU7q2j3XdRm13UT//9P/2XQnXb2+ZxnhFMSGbjRZjbGLBnxyTy7ICkxHEX1HXyEG3/Meu8FduPO0Oz0R/fUXe14yB2w9PL/SvQl7fRWNFXpmDU2/DuYXnMWJ2oGu6cPOgXbMKrcud0k0GpWEoLXUZNr3Eer/WlfeFb0kPB5ffFb6TJVSKnKcwKvZR32QZndGawtdD/5nfKXjX8sVaY/aAbbWlrXf9a2auHVjPoz8a8v3bY4Y6H+w3pRymQPLQDb5Hb2Is8exH7gY1zCN0oDFwc+HVDNtBGL9heMroXPAUpIRuNnyuqWDq6BUULrSE6AbLQJzSE0E4dN7IxdgObQgi2F/gZCZwsdHwPbX8C2O1o0SkPAAA=
      
    Moon:
      AH4_H4sIAAAAAAAACu1YS2/jNhD+KwuepUKUKFnUzetmswGcB2IXOQQ90OLIJkKLXorKJg383wvqYUuObBdpCvSwN3k4882DH2cGfkPj0qgJK0wxyZYoeUMXOVtIGEuJEqNLcNA9pKww41ysmREqn7A8hd3hvNT5REkJqbnNslY6WZXrIwbW1VTksHfF26MrjhI/pg6600JpYV5Rgh10VVy8pLLkwPdiq7+tsa6VSlcWrPrw7VeFE8UOutzMVxqKlZIcJdjzesinoSsMOupZeGeDsXm3ERDskTMhtFZ1/Y5UhGAPd63881EozQWTR/CwH0W9GpPG7JsoVhevUHQSCA8SCMNeAlF7B+wJZiuRma9MVGlYQdEKZoalTwVKwqaqUfwet4tKG9Q7ZgTkKXTiiQ7ton5B/dZUi79gwkzNjNbrobV/cB1BYz1fMSnYU/GNPSttAXqCNp3A6cvvIVXPoFGCbZGGqB3FlhEdh239vorlJVtXiY7zpQRdtE7sZXOUBCOPvIu+BxVvtw66eDGaNc/YVn6uZj/Z5io3pbAP8ZKJvK2Hix00LTVcQ1GwJaAEIQfdVEGgG5UDcmqE1w2gxBZmAG+qCvNhvDsNBQxHiFx05Lz2WJ3v45ltIDWayUmpNeTmk7I8QP20XAejfZfxoPdKqybIzKiNfa8iX84MbKpGuY+9IdFYf07IXbgqhj9y8aMEi4siBiPqB5FLA8xdwihxaRowlzCfjbI08kjM0dZBU1GY28z6KFDyWNPTJrALkNLjEY6l/FKbHoZ5o/Saye9KPVmgtmM8AKt+W3kBZvcWMyYLaN9mc2gTbF9pI6rhCR7ZTtRizoxWeWdADpjf5vL1YQX5jTLj1IhnmMmj2F7QwZ7CEnLO9OtJeCuaizXog95yLfLdkZ0xv3nD3n5X5UIe1qbW8CO6U9gnelSlF++A1lyLzTFPo9APdirHfPWUTnhr9OxrGGcG9ISVy5WZirUdQ7g+OHwm1QJS6nrO2Y9OQx/o2sEopO/n+IkZbJeHtl+1xLyHH6XQwGeGmdKOQrudHGHrGfb9Yx79osCHKPDRO+/0xJRnKY9I5gKwzCUYwI0xJi7lUeRFMSMhy9D2z7YpNhvs405Q98XHN9RtkCSkwYkm/sBeipTJfiPHpwpzxSE3ImXSVsN6qRXGa1XmPbXK9+H2EfQ3wdh6KnXG0qbpDa+yIQ3P7GDh1kH/m5V+P1E/PEetsZVMbFWrgnYnazNP7Wct3qsN8bbLMX/kZZTHbjiy05Zy7tI4DV0fAyc+9YD6gLbOew6R4wl8V1Kqn18uQJ5jUXupw+TyOwf3naxaIvy3vPtFtPxfEs3zSY9rLAOOAzZyFzgGl2Rk5MYeoW7EYiA+4diLcNXPauh2aXODxHLpy331L4Dd3TqYCxZwD3vghiygLvEWmbuII+qCn/EIU+z7QYy2fwN+agEEnhAAAA==

    Umbral:
      ...
]]

-- Plugin Checks
HasAutohook = HasPlugin("AutoHook")
HasArtisan = HasPlugin("Artisan")
HasChatCoordinates = HasPlugin("ChatCoordinates")

-- Settings
FisherGearset = "Fisher" -- Your Fisher Gearset Name
ShowNameAndCoords = HasChatCoordinates
WeatherSelection = "Normal" -- All, Normal, Moon, Umbral

-- Variables, editable
FisherNormalMissionName = "A-2: Refined Moon Gel" -- Need More GP than Eel?
FisherNormalCoords = "/coord 15.8 19.4"
FisherNormalItem = 45922
FisherNormalAmount = 2

--FisherNormalMissionName = "A-2: Processed Aquatic Metals" -- Probably not worth it, need a lot of GP (need to try refined moon gel)
--FisherNormalCoords = "/coord 25.3 25.4"
--FisherNormalItem = 45917
--FisherNormalAmount = 14

FisherMoonMissionName = "A-3: Eel Rations" -- FSH/CUL
FisherMoonCoords = "/coord 7.0 9.4"
FisherMoonItem = 45934
FisherMoonAmount = 2

FisherUmbralMissionName = ""
FisherUmbralCoords = ""
FisherUmbralItem = 0
FisherUmbralAmount = 0

missionName = ""
coords = ""
itemId = 0
itemAmount = 0

classId = GetClassJobId()
weatherId = GetActiveWeatherID()
previousWeatherType = ""

-- Functions
local function init()
  if classId == 18 then
    class = FisherGearset

    local weatherData = {
      Normal = {
        missionName = FisherNormalMissionName,
        coords = FisherNormalCoords,
        itemId = FisherNormalItem,
        itemAmount = FisherNormalAmount
      },
      Moon = {
        missionName = FisherMoonMissionName,
        coords = FisherMoonCoords,
        itemId = FisherMoonItem,
        itemAmount = FisherMoonAmount
      },
      Umbral = {
        missionName = FisherUmbralMissionName,
        coords = FisherUmbralCoords,
        itemId = FisherUmbralItem,
        itemAmount = FisherUmbralAmount
      }
    }
    
    local selectedType = WeatherSelection == "All" and previousWeatherType or WeatherSelection
    local data = weatherData[selectedType]
    
    if data then
      missionName = data.missionName
      coords = data.coords
      itemId = data.itemId
      itemAmount = data.itemAmount
    end
  else
    yield("Wrong Class")
    return false
  end
  
  return true
end

local function getWeatherType(weatherId)
    if weatherId == 148 then
        return "Moon"
    elseif weatherId == 49 then
        return "Umbral"
    else
        return "Normal"
    end
end

local function startCrafting()
  if not IsAddonVisible("WKSRecipeNotebook") then
    if not IsAddonVisible("WKSMissionInfomation") then
      yield("/callback WKSHud true 11")
      yield("/wait 0.2")
    end
  
    if not IsAddonVisible("WKSRecipeNotebook") then
      yield("/callback WKSMissionInfomation true 14 1")
    end
  end
  
  yield("/wait 0.5")
  
  ArtisanSetEnduranceStatus(true)
end

local function submitReport()
  if not IsAddonVisible("WKSMissionInfomation") then
    yield("/callback WKSHud true 11")
    yield("/wait 0.2")
  end

  if IsAddonVisible("WKSRecipeNotebook") then
    yield("/callback WKSMissionInfomation true 14 1")
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end

  yield("/gs change " ..class)
  yield("/wait 1")
  yield("/callback WKSMissionInfomation true 11 1")
end

local function abandonMission()
  if not IsAddonVisible("WKSMissionInfomation") then
    yield("/callback WKSHud true 11")
    yield("/wait 0.2")
  end

  if IsAddonVisible("WKSRecipeNotebook") then
    yield("/callback WKSMissionInfomation true 14 1")
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end

  yield("/gs change " ..class)
  yield("/wait 1")
  yield("/callback WKSMissionInfomation true 12 1")
  yield("/wait 0.5")
  yield("/callback SelectYesno true 0")
end
-- End of Functions

previousWeatherType = getWeatherType(weatherId)
if init() then
  if ShowNameAndCoords then
    yield(missionName)
    yield(coords)
  end
  
  if not HasArtisan then
    yield("Need Artisan!")
    return
  end
  
  if not HasAutohook then
    yield("Need Autohook!")
    return
  end
else
  return
end

while true do
  local currentWeatherType = getWeatherType(GetActiveWeatherID())
  local currentMissionName = ""
  
  if WeatherSelection == "All" then
    if (currentWeatherType ~= previousWeatherType) then
      return
    end
  end
  
  while (currentMissionName ~= missionName) do
    yield("/wait 0.5")
    if IsAddonVisible("WKSMissionInfomation") then
      currentMissionName = GetNodeText("WKSMissionInfomation", 29)
    elseif not IsAddonVisible("WKSMissionInfomation") then
      yield("/callback WKSHud true 11")
      yield("/wait 0.2")
    end
  end
  
  if GetItemCount(itemId) < itemAmount then
    while not GetCharacterCondition(43) do
      yield("/ahstart")
      yield("/wait 0.2")
    end
    
    yield("Trying to get Item until " ..itemAmount)
    while GetItemCount(itemId) < itemAmount do
      yield("/wait 0.5")
    end
    
    -- just in case still in fishing mode
    yield("Wait until out of fishing mode")
    while IsPlayerOccupied() do 
      yield("/wait 0.5")
    end
  end
  
  startCrafting()
  yield("/wait 2")
  
  while ArtisanGetEnduranceStatus() do
    yield("/wait 0.5")
  end
  
  if IsNotCrafting() then
    submitReport()
  end
end