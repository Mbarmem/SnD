if not HasPlugin("Artisan") or not HasPlugin("PandorasBox") then
    yield("/xlenablecollection Artisan")
    yield("/echo || Artisan Enabled ||")
else
    yield("/xldisablecollection Artisan")
    yield("/echo || Artisan Disabled ||")
end