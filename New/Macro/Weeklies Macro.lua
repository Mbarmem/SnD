if not HasPlugin("AutoDuty") then
    yield("/xlenablecollection Weeklies")
    yield("/echo || Weeklies Enabled ||")
    if not HasWeeklyBingoJournal() or IsWeeklyBingoExpired() or WeeklyBingoNumPlacedStickers() == 9 then
        yield("/echo || Running Weekly Tasks ||")
        yield("/snd")
        yield("/wait 15")
        yield("/snd run Weeklies Macro")
    end
else
    yield("/xldisablecollection Weeklies")
    yield("/echo || Weeklies Disabled ||")
end