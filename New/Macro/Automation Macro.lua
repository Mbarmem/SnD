if not HasPlugin("PandorasBox") or not HasPlugin("AutoRetainer") then
    yield("/xlenablecollection Automation")
    yield("/echo || Automation Enabled ||")
else
    yield("/xldisablecollection Automation")
    yield("/echo || Automation Disabled ||")
end