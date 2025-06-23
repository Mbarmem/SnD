if not HasPlugin("vnavmesh") or not HasPlugin("BossModReborn") then
    yield("/xlenablecollection Fates")
    yield("/echo || Fates Enabled ||")
    yield("/snd")
    yield("/wait 15")
    yield("/echo || Running Fates ||")
    yield("/snd run Multi Zone Farming")
else
    yield("/xldisablecollection Fates")
    yield("/echo || Fates Disabled ||")
end