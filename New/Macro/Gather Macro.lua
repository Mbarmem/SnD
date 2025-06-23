if not HasPlugin("AutoHook") then
    yield("/xlenablecollection Gather")
    yield("/echo || Gather Enabled ||")
else
    yield("/xldisablecollection Gather")
    yield("/echo || Gather Disabled ||")
end