--[[

      ***********************************************
      *         Triple Triad + Auto Retainer        * 
      *     Play TT and process AR when needed      *
      ***********************************************

      *************************
      *    Author: T0mball    *
      *************************

      **********************
      * Version  |  1.0.2  *
      **********************

      -> 1.0.2  : Code optimizations, added fail handling, separated code into functions
      -> 1.0.1  : Fixed issue with summoning bell interaction
      -> 1.0.0  : Basic Functionality, it works. Prob needs a revision

      ***************
      * Description *
      ***************

      This script will tp to Foundation, go to House Fortemps and play TT with the servant. It stops playing when AR needs to be processed and
      goes to the Summoning Bell in Jeweled Crozier. Processes AR and goes back to playing.
      
      Many thanks to Ice and UcanPatatess, a lot of my code is based on theirs.

      *********************
      *  Required Plugins *
      *********************


      Plugins that are used are:
      -> Saucy : https://love.puni.sh/ment.json
        -> Triple Triad:
            -> Open Saucy when challenging an NPC = YES
            -> Automatically choose your deck with the best win chance = YES
      -> Teleporter
      -> Lifestream : https://github.com/NightmareXIV/Lifestream/blob/main/Lifestream/Lifestream.json
      -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat
      -> YesAlready : https://love.puni.sh/ment.json
        -> For each of the following categories add the given inputs:
            -> YesNo
                -> "Enter Fortemps Manor?"
                -> "Leave Fortemps Manor?"
            -> Talk
                -> "House Fortemps Guard"
                -> "House Fortemps Manservant"
            -> List (Target Restricted = YES)
                -> text: "Triple Triad Challenge" target: "House Fortemps Manservant"
]]

--[[

  **************
  *  Settings  *
  **************
  ]]
  
-- The NPC you will be playing agains (Manservant or Klynthota)
-- For House Fortemps Manservant enter 0 (default value). Will go to foundation and use the bell there as well
-- For Klynthota enter 1 *Not implemented yet. Will go to Revenant's toll and idk yet which bell will be used
PlayAgainstNpc = 0

-- This is used when teleporting, interacting or targeting. When one of these fails, the script will automatically try to do it again.
-- It will try again 5 times, this will be handled as a single falilure. Upon a failure the script will run from the beginning.
-- Once it reaches a total of x failures it will stop the script. This is that x value
maxFailuresAllowed = 5


--[[

  ************
  *  Script  *
  *   Start  *
  ************

]]


--[[ HELPER FUNCTIONS ]]

    FailedToTargetCount = 0
    FailedToInteractCount = 0
    FailedTeleportCount = 0

    function ZoneTransition()
        yield("/wait 0.3") -- Might need to be increased. This is for /li
        while IsPlayerAvailable() == false or GetCharacterCondition(32) do
            yield("/wait 0.2")
            yield("/e Player Not available yet")
        end
    end

    function TeleportTest()
        while GetCharacterCondition(27) do 
            yield("/wait 1") 
        end
        yield("/wait 1")
        while GetCharacterCondition(45) or GetCharacterCondition(51) do 
            yield("/wait 3") 
        end
    end

    function PathFinding()
        yield("/wait 0.2")
        while PathfindInProgress() do
            yield("/wait 0.5")
        end
    end
    
    function moveToTarget(minDistanceOverride)
        minDistance = minDistanceOverride or 7
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
    
    -- Try to target an object/npc. In case of failure, jump to beginning
    function Target(destination)
        attemptsCount = 0
        yield("/target "..destination)
        yield("/wait 0.5")
        while GetTargetName():lower() ~= destination:lower() do
            yield("/target "..destination)
            attemptsCount = attemptsCount + 1
            if attemptsCount > 5 then
                yield("/e Unable to Target "..destination.." Starting from the top")
                FailedToTargetCount = FailedToTargetCount + 1
                CheckForConsecutiveFailures("target")
                StartScript()
            end
            yield("/wait 0.5")
        end
        FailedToTargetCount = 0
    end

    -- Try to interact with current target. In case of failure, jump to beginning
    function Interact()
        attemptsCount = 0
        yield("/interact")
        yield("/wait 0.5")
        while IsPlayerOccupied() == false do
            yield("/interact")
            attemptsCount = attemptsCount + 1
            if attemptsCount > 5 then
                yield("/e Unable to Interact starting from the top")
                FailedToInteractCount = FailedToInteractCount + 1
                CheckForConsecutiveFailures("interact")
                StartScript()
            end
            yield("/wait 0.5")
        end
        FailedToInteractCount = 0
    end
    
    -- In case of multiple repeated failures. This will stop the script
    function CheckForConsecutiveFailures(reason)
        if FailedToInteractCount > maxFailuresAllowed or FailedToTargetCount > maxFailuresAllowed or FailedTeleportCount > maxFailuresAllowed then
            yield("/e Fatal Error - Could not "..reason..". Stopping Script.")
            yield("/pcraft stop")
        end
    end
    
    function CanTargetAetheryte()
        yield("/target Aetheryte")
        yield("/wait 0.5")
        if GetTargetName():lower() ~= "aetheryte" then
            return false
        end
        return true
    end
    
    --Teleport To zone
    function teleportTo(zoneName, zoneId)
        --Foundation: 418
        --while char is not in zone and not casting or (unable to target Aetheryte, is in zone and not casting)
        while (IsInZone(zoneId) == false and GetCharacterCondition(27) == false) or (CanTargetAetheryte() == false and IsInZone(zoneId) and GetCharacterCondition(27)) do
            yield("/e Tp Will staart")
            yield("/tp ".. zoneName)
            yield("/wait 1")
        end
        TeleportTest()
        if (IsInZone(zoneId) == false and GetCharacterCondition(27) == false) or (CanTargetAetheryte() == false and IsInZone(zoneId) and GetCharacterCondition(27)) then
            yield("/e Tp Will repeat")
            FailedTeleportCount = FailedTeleportCount + 1
            CheckForConsecutiveFailures("teleport")
            yield("/echo Hmm.... either you moved, or the teleport failed, lets try that again")
            yield("/wait 0.5")
            teleportTo(zoneName, zoneId)
        end
        FailedTeleportCount = 0
    end
    
    
--[[ GENERAL FUNCTIONS ]]

    function StartScript()
        if PlayAgainstNpc == 0 then
            -- Playing Manservant. Goto Foundation
            PlayManservant()
        else
            --Playing Klynthota. Goto Revenant's Toll
        end
    end
    
    function StopScript()
        yield("/echo Stopping script, thanks for using")
        yield("/pcraft stop")
    end
    
    
--[[ TRIPLE TRIAD ]]

    -- Play TT until AR needs to be processed
    function PlayTTUntilNeeded()
        while IsPlayerOccupied()==false do --make sure that player is in playing ui before starting to play
            yield("/wait 0.5")
            yield("/e Waiting for game UI")
        end
        yield("/saucy tt go")
        yield("/wait 1")
        while ARAnyWaitingToBeProcessed() == false do
            yield("/wait 1")
        end
        -- AR is ready, play one last game
        if GetCharacterCondition(13)==true then
            yield("/saucy tt play 1")
        end
        -- Wait for last game to finish
        while GetCharacterCondition(13)==true do
            yield("/wait 1")
        end
        -- Go to bell
        yield("/wait 1")
        yield("/e Done Playing... Heading to bell") 
    end
    
    
--[[ AUTO RETAINER ]]

    function ProcessAR()
        yield("/wait 1")
        while ARAnyWaitingToBeProcessed() == true and IsPlayerOccupied() == true do
            -- yield("/e Processing Retainers... Player is occupied")
            yield("/wait 1")
        end
        yield("/waitaddon RetainerList")
        yield("/e Finished processing retainers...")
        yield("/pcall RetainerList true -1")
        yield("/wait 1")
    end

    
--[[ MANSERVANT ]]

    function PlayManservant()
        -- Is In House Fortemps, skip to that part of script
        if IsInZone(433) == true then
            -- goto HouseFortemps
        end
        -- Not in Foundation, tp there
        teleportTo("Foundation", 418)
        ::Foundation::
        --LogInfo("[TT+AR] Currently in Foundation!")
        ZoneTransition()
        Target("Aetheryte")
        moveToTarget()
        yield("/li Last")
        --LogInfo("[TT+AR] Heading to The Last Vigil")
        ::LastVigil::
        ZoneTransition()
        Target("House Fortemps Guard")
        moveToTarget()
        Interact()
        ::HouseFortemps::
        ZoneTransition()
        Target("House Fortemps Manservant")
        moveToTarget()
        Interact()
        PlayTTUntilNeeded()
        Target("Manor Exit")
        moveToTarget(4)
        Interact()
        ZoneTransition()
        Target("Aethernet Shard")
        moveToTarget()
        yield("/li Jeweled")
        ZoneTransition()
        Target("Summoning Bell")
        moveToTarget(4)
        Interact()
        ProcessAR()
        -- Continue playing TT
        Target("Aethernet Shard")
        moveToTarget()
        yield("/li Last")
        ZoneTransition()
        goto LastVigil
    end

    
--[[ KLYNTHOTA ]]

    function PlayKlynthota()
       -- TODO 
    end
    
    
--[[ START ]]

StartScript()
StopScript()