function CheckAllowances()
    if not IsAddonVisible("ContentsInfo") then
        yield("/timers")
        yield ("/wait 1")
    end

    for i = 1, 15 do
        local timerName = GetNodeText("ContentsInfo", 8, i, 5)
        if timerName == "Next Allied Society Daily Quest Allowance" then
            yield("/echo || Daily Allowance: " ..tonumber(GetNodeText("ContentsInfo", 8, i, 4):match("%d+$")).. " ||")
            return tonumber(GetNodeText("ContentsInfo", 8, i, 4):match("%d+$"))
        end
    end
    return 0
end

function CloseTimers()
    if IsAddonVisible("ContentsInfo") then
        yield("/timers")
        yield ("/wait 1")
    end
end

if not HasPlugin("Questionable") or not HasPlugin("Saucy") then
    yield("/xlenablecollection Dailies")
    yield("/echo || Dailies Enabled ||")
    CheckAllowances()
    yield ("/wait 5")
    if CheckAllowances() == 12 then
        yield("/snd")
        yield("/wait 15")
        yield("/snd run Dailies Macro")
    end
    CloseTimers()
else
    yield("/xldisablecollection Dailies")
    yield("/echo || Dailies Disabled ||")
end