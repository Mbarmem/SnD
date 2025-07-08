function Target(destination)
    AttemptsCount = 0
    yield("/target "..destination)
    yield("/wait 0.5")
    while GetTargetName():lower() ~= destination:lower() do
        yield("/target "..destination)
        AttemptsCount = attemptsCount + 1
        if attemptsCount > 5 then
            yield("/e Unable to Target "..destination.." Stopping")
            return
        end
        yield("/wait 0.5")
    end
end

function PathFinding()
    yield("/wait 0.2")
    while PathfindInProgress() do
        yield("/wait 0.5")
    end
end

function MoveToTarget(minDistanceOverride)
    local minDistance = minDistanceOverride or 7
    local targetX = GetTargetRawXPos() or 0
    local targetY = GetTargetRawYPos() or 0
    local targetZ = GetTargetRawZPos() or 0
    if GetDistanceToPoint(targetX, targetY, targetZ) > minDistance then
        PathfindAndMoveTo(targetX, targetY, targetZ, false)
        PathFinding()
        while GetDistanceToPoint(targetX, targetY, targetZ) > minDistance do
            yield("/wait 0.1")
        end
        PathStop()
    end
end

function MoveAndInteract()
    moveToTarget()
    yield("/wait 1")
    yield("/interact")
    yield("/wait 1")
    yield("/click Talk Click")
    repeat
        yield("/wait 1")
    until IsAddonReady("SelectYesno")
    yield("/click SelectYesno Yes")
    repeat
        yield("/wait 1")
    until IsAddonReady("Talk")
    yield("/click Talk Click")
    repeat
        yield("/wait 1")
    until IsPlayerAvailable()
end

function GetOUT()
    repeat
        yield("/wait 1")
        if IsAddonVisible("SelectIconString") then
            yield("/callback SelectIconString true -1")
        end
        if IsAddonVisible("SelectString") then
            yield("/callback SelectString true -1")
        end
    until IsPlayerAvailable()
end

local state = "start"
function KoF()
    if state == "end" then
        GetOUT()
        state = "start"
    elseif state == "start" then
        Target("Lizbeth")
        MoveAndInteract()
        state = "end"
    end
end

while state do
    KoF()
end