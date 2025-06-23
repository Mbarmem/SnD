if not HasPlugin("HuntTrainAssistant") then
    yield("/xlenablecollection HuntTrain")
    yield("/echo || HuntTrain Enabled ||")
else
    yield("/xldisablecollection HuntTrain")
    yield("/echo || HuntTrain Disabled ||")
end