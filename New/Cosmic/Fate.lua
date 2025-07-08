--[[

***********************************************
*             Cosmic Exploration              *
*            Script for Auto Fate             *
***********************************************

            **********************
            *     Author: Mo     *
            **********************

            **********************
            * Version  |  1.0.0  *
            **********************

]]

-------------------------------- Functions --------------------------------

function Target(destination)
    attemptsCount = 0
    yield("/target "..destination)
    yield("/wait 0.5")
    while GetTargetName():lower() ~= destination:lower() do
        yield("/target "..destination)
        attemptsCount = attemptsCount + 1
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

function moveToTarget(minDistanceOverride)
    minDistance = minDistanceOverride or 2
    targetX = GetTargetRawXPos()
    targetY = GetTargetRawYPos()
    targetZ = GetTargetRawZPos()
    PathfindAndMoveTo(targetX, targetY, targetZ, false)
    PathFinding()
    while GetDistanceToPoint(targetX, targetY, targetZ) > minDistance do
        yield("/wait 0.1")
    end
    PathStop()
end

function MoveAndInteract()
    moveToTarget()
    yield("/wait 1")
    yield("/interact")
    yield("/wait 5")
end

local state = "start"
function Fate()
    if state == "end" then
        Target("Depleted Mini Rover")
        MoveAndInteract()
        state = "start"
    elseif state == "charge" then
        Target("Charging Module")
        MoveAndInteract()
        state = "end"
    elseif state == "start" then
        Target("Mini Rover")
        MoveAndInteract()
        state = "charge"
    end
end

-------------------------------- Execution --------------------------------

while state do
    Fate()
end

----------------------------------- End -----------------------------------