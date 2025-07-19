---@diagnostic disable: missing-return
--- All functions in this file are provided by Something Need Doing (SND)
--- at runtime. This file exists to assist with code completion by
--- allowing the language server access to annotations.

--- Checks if AD content has a path loaded.
---@return boolean
function ADContentHasPath() end

--- Gets the current AD configuration.
---@return table
function ADGetConfig() end

--- Returns if AD loop is running.
---@return boolean
function ADIsLooping() end

--- Returns if AD is navigating.
---@return boolean
function ADIsNavigating() end

--- Returns if AD is stopped.
---@return boolean
function ADIsStopped() end

--- Lists all AD configs.
---@return table
function ADListConfig() end

--- Runs the AD engine.
---@return boolean
function ADRun() end

--- Sets current AD configuration.
---@param config table
---@return boolean
function ADSetConfig(config) end

--- Starts AD automation.
---@return boolean
function ADStart() end

--- Stops AD automation.
---@return boolean
function ADStop() end

--- Aborts all AR tasks.
function ARAbortAllTasks() end

--- Checks if AR tasks are waiting.
---@return boolean
function ARAnyWaitingToBeProcessed() end

--- Checks if any retainers are available for the current character.
---@return boolean
function ARAreAnyRetainersAvailableForCurrentChara() end

--- Checks if AR auto-login is available.
---@return boolean
function ARCanAutoLogin() end

--- Disables all AR functions.
function ARDisableAllFunctions() end

--- Returns items to discard from AR discard logic.
---@return table
function ARDiscardGetItemsToDiscard() end

--- Enables AR multi-mode.
function AREnableMultiMode() end

--- Queues a Grand Company "Hunting Expedition Task" (HET).
function AREnqueueHET() end

--- Queues an AR initiation step.
function AREnqueueInitiation() end

--- Finishes post-processing for the current character.
function ARFinishCharacterPostProcess() end

--- Gets all registered character content IDs.
---@return table<number>
function ARGetCharacterCIDs() end

--- Gets character data for a given content ID.
---@param cid number
---@return table
function ARGetCharacterData(cid) end

--- Gets seconds remaining for the closest retainer venture.
---@return number
function ARGetClosestRetainerVentureSecondsRemaining() end

--- Gets a list of enabled retainers.
---@return table
function ARGetEnabledRetainers() end

--- Gets the current Grand Company info.
---@return table
function ARGetGCInfo() end

--- Gets the number of free inventory slots.
---@return number
function ARGetInventoryFreeSlotCount() end

--- Checks whether multi-mode is enabled.
---@return boolean
function ARGetMultiModeEnabled() end

--- Checks if Retainer Sense is enabled.
---@return boolean
function ARGetOptionRetainerSense() end

--- Gets the Retainer Sense item threshold.
---@return number
function ARGetOptionRetainerSenseThreshold() end

--- Gets all registered characters.
---@return table
function ARGetRegisteredCharacters() end

--- Gets all registered and enabled characters.
---@return table
function ARGetRegisteredEnabledCharacters() end

--- Gets all registered and enabled retainers.
---@return table
function ARGetRegisteredEnabledRetainers() end

--- Gets all registered retainers.
---@return table
function ARGetRegisteredRetainers() end

--- Returns true if AR is currently busy.
---@return boolean
function ARIsBusy() end

--- Forces a relog of the current character.
function ARRelog() end

--- Returns the number of retainers waiting to be processed.
---@return number
function ARRetainersWaitingToBeProcessed() end

--- Enables or disables multi-mode functionality.
---@param enabled boolean
function ARSetMultiModeEnabled(enabled) end

--- Enables or disables Retainer Sense.
---@param enabled boolean
function ARSetOptionRetainerSense(enabled) end

--- Sets the item threshold for Retainer Sense.
---@param threshold number
function ARSetOptionRetainerSenseThreshold(threshold) end

--- Sets suppression mode (used for temporarily pausing AR functions).
---@param suppressed boolean
function ARSetSuppressed(suppressed) end

--- Returns number of submarines waiting to be processed.
---@return number
function ARSubsWaitingToBeProcessed() end

--- Adds an item to the active craft list.
---@param itemId number
---@param quantity number
---@return boolean
function ATAddItemToCraftList(itemId, quantity) end

--- Creates a new craft list by name.
---@param name string
---@return boolean
function ATAddNewCraftList(name) end

--- Returns the current crafting character's name.
---@return string
function ATCurrentCharacter() end

--- Disables the background item filter for crafting.
function ATDisableBackgroundFilter() end

--- Disables a specific craft list by name.
---@param listName string
function ATDisableCraftList(listName) end

--- Disables the UI item filter for crafting.
function ATDisableUiFilter() end

--- Enables the background item filter for crafting.
function ATEnableBackgroundFilter() end

--- Enables a specific craft list by name.
---@param listName string
function ATEnableCraftList(listName) end

--- Enables the UI item filter for crafting.
function ATEnableUiFilter() end

--- Returns the inventory items for the current character.
---@return table
function ATGetCharacterItems() end

--- Returns items of a specific type from the character.
---@param itemType number
---@return table
function ATGetCharacterItemsByType(itemType) end

--- Returns a list of characters owned by the current player.
---@return table
function ATGetCharactersOwnedByActive() end

--- Returns all items available for crafting.
---@return table
function ATGetCraftItems() end

--- Returns all defined craft lists.
---@return table
function ATGetCraftLists() end

--- Returns the currently active filter items.
---@return table
function ATGetFilterItems() end

--- Returns all retrieval items.
---@return table
function ATGetRetrievalItems() end

--- Returns active search filters.
---@return table
function ATGetSearchFilters() end

--- Returns the number of inventory items of a given type.
---@param itemType number
---@return number
function ATInventoryCountByType(itemType) end

--- Returns the number of inventory items for each given type.
---@param itemTypes table<number>
---@return number
function ATInventoryCountByTypes(itemTypes) end

--- Returns whether the Artisan system is initialized.
---@return boolean
function ATIsInitialized() end

--- Returns the number of items in inventory for a specific item.
---@param itemId number
---@return number
function ATItemCount(itemId) end

--- Returns the number of HQ items in inventory for a specific item.
---@param itemId number
---@return number
function ATItemCountHQ(itemId) end

--- Returns the number of a specific item owned across all characters.
---@param itemId number
---@return number
function ATItemCountOwned(itemId) end

--- Removes an item from the craft list.
---@param itemId number
---@return boolean
function ATRemoveItemFromCraftList(itemId) end

--- Toggles the background filter.
function ATToggleBackgroundFilter() end

--- Toggles the visibility of the craft list.
function ATToggleCraftList() end

--- Toggles the UI filter.
function ATToggleUiFilter() end

--- Crafts a specified item in a specified quantity.
---@param itemId number
---@param quantity number
---@return boolean
function ArtisanCraftItem(itemId, quantity) end

--- Gets the current endurance status (whether crafting endurance is active).
---@return boolean
function ArtisanGetEnduranceStatus() end

--- Checks if a stop request for crafting has been set.
---@return boolean
function ArtisanGetStopRequest() end

--- Returns true if the craft list is currently paused.
---@return boolean
function ArtisanIsListPaused() end

--- Returns true if the craft list is currently running.
---@return boolean
function ArtisanIsListRunning() end

--- Sets the endurance status.
---@param status boolean
function ArtisanSetEnduranceStatus(status) end

--- Pauses or resumes the craft list.
---@param paused boolean
function ArtisanSetListPause(paused) end

--- Sets a stop request for the crafting process.
---@param stop boolean
function ArtisanSetStopRequest(stop) end

--- Adds a transient BossMod strategy.
---@param strategy table
function BMAddTransientStrategy(strategy) end

--- Adds a transient BossMod strategy targeting a specific enemy by object ID.
---@param strategy table
---@param enemyOID number
function BMAddTransientStrategyTargetEnemyOID(strategy, enemyOID) end

--- Clears the active BossMod strategies.
function BMClearActive() end

--- Creates a new BossMod by name.
---@param modName string
---@return table
function BMCreate(modName) end

--- Deletes a BossMod by name.
---@param modName string
function BMDelete(modName) end

--- Gets a BossMod by name.
---@param modName string
---@return table|nil
function BMGet(modName) end

--- Gets the currently active BossMod.
---@return table|nil
function BMGetActive() end

--- Gets the list of BossMods forcibly disabled.
---@return table
function BMGetForceDisabled() end

--- Sets a BossMod active by name.
---@param modName string
function BMSetActive(modName) end

--- Sets the force-disabled status of a BossMod.
---@param modName string
---@param forceDisabled boolean
function BMSetForceDisabled(modName, forceDisabled) end

--- Checks if a materia can be extracted from an item.
---@param itemId number
---@return boolean
function CanExtractMateria(itemId) end

--- Clears the current focus target.
function ClearFocusTarget() end

--- Clears the current target.
function ClearTarget() end

--- Forces a game crash (for testing purposes).
function CrashTheGame() end

--- Deletes all anonymous AutoHook presets.
function DeleteAllAutoHookAnonymousPresets() end

--- Deletes the currently selected AutoHook preset.
function DeletedSelectedAutoHookPreset() end

--- Returns true if Deliveroo turn-in is running.
---@return boolean
function DeliverooIsTurnInRunning() end

--- Calculates the distance between two 3D points.
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@return number
function DistanceBetween(x1, y1, z1, x2, y2, z2) end

--- Checks if an object exists.
---@param objectId any
---@return boolean
function DoesObjectExist(objectId) end

--- Gets the quantity of an item in Dropbox.
---@param itemId number
---@return number
function DropboxGetItemQuantity(itemId) end

--- Returns true if Dropbox is currently busy.
---@return boolean
function DropboxIsBusy() end

--- Sets the quantity of an item in Dropbox.
---@param itemId number
---@param quantity number
function DropboxSetItemQuantity(itemId, quantity) end

--- Starts the Dropbox process.
function DropboxStart() end

--- Stops the Dropbox process.
function DropboxStop() end

--- Compares two values for equality.
---@param a any
---@param b any
---@return boolean
function Equals(a, b) end

--- Executes an action by action ID.
---@param actionId number
---@return boolean
function ExecuteAction(actionId) end

--- Executes a general action by action ID.
---@param actionId number
---@return boolean
function ExecuteGeneralAction(actionId) end

--- Checks if the focus target has a specific status effect.
---@param statusId number
---@return boolean
function FocusTargetHasStatus(statusId) end

--- Gets a list of all accepted quests.
---@return table<number>
function GetAcceptedQuests() end

--- Gets the raw X coordinate of the Accursed Hoard.
---@return number
function GetAccursedHoardRawX() end

--- Gets the raw Y coordinate of the Accursed Hoard.
---@return number
function GetAccursedHoardRawY() end

--- Gets the raw Z coordinate of the Accursed Hoard.
---@return number
function GetAccursedHoardRawZ() end

--- Gets the number of actions currently stacked.
---@return number
function GetActionStackCount() end

--- Returns a list of active FATEs.
---@return table
function GetActiveFates() end

--- Returns the name of the currently active macro.
---@return string
function GetActiveMacroName() end

--- Returns the active mini-map gathering marker ID.
---@return number
function GetActiveMiniMapGatheringMarker() end

--- Returns the current weather ID.
---@return number
function GetActiveWeatherID() end

--- Returns the rank in the Adders Grand Company.
---@return number
function GetAddersGCRank() end

--- Returns a list of Aetherytes.
---@return table
function GetAetheryteList() end

--- Returns the name of a specific Aetheryte.
---@param aetheryteId number
---@return string
function GetAetheryteName(aetheryteId) end

--- Returns the raw position of a specific Aetheryte.
---@param aetheryteId number
---@return number, number, number x
function GetAetheryteRawPos(aetheryteId) end

--- Returns a list of Aetherytes in the current zone.
---@return table
function GetAetherytesInZone() end

--- Returns a list of Bronze Chest locations.
---@return table
function GetBronzeChestLocations() end

--- Returns remaining time on the buddy system buff.
---@return number
function GetBuddyTimeRemaining() end

--- Checks a specific character condition.
---@param condition number
---@return boolean
GetCharacterCondition = GetCharacterCondition or function(condition) return false end

--- Returns the character's name.
---@return string
function GetCharacterName() end

--- Returns the Job ID of the character.
---@return number
function GetClassJobId() end

--- Returns the number of clicks registered.
---@return number
function GetClicks() end

--- Returns the current contents of the clipboard.
---@return string
function GetClipboard() end

--- Returns the current condition of the player.
---@return number
function GetCondition() end

--- Returns the time left in the current content.
---@return number
function GetContentTimeLeft() end

--- Returns the current crafting points.
---@return number
function GetCp() end

--- Returns the ID of the current bait equipped.
---@return number
function GetCurrentBait() end

--- Returns the current Eorzea hour (0-23).
---@return integer
function GetCurrentEorzeaHour() end

--- Returns the current Eorzea minute (0-59).
---@return integer
function GetCurrentEorzeaMinute() end

--- Returns the current Eorzea second (0-59).
---@return integer
function GetCurrentEorzeaSecond() end

--- Returns the current Eorzea timestamp.
---@return number
function GetCurrentEorzeaTimestamp() end

--- Returns the goal count for the current Ocean Fishing mission 1.
---@return number
function GetCurrentOceanFishingMission1Goal() end

--- Returns the name for the current Ocean Fishing mission 1.
---@return string
function GetCurrentOceanFishingMission1Name() end

--- Returns the progress count for the current Ocean Fishing mission 1.
---@return number
function GetCurrentOceanFishingMission1Progress() end

--- Returns the type for the current Ocean Fishing mission 1.
---@return number
function GetCurrentOceanFishingMission1Type() end

--- Returns the goal count for the current Ocean Fishing mission 2.
---@return number
function GetCurrentOceanFishingMission2Goal() end

--- Returns the name for the current Ocean Fishing mission 2.
---@return string
function GetCurrentOceanFishingMission2Name() end

--- Returns the progress count for the current Ocean Fishing mission 2.
---@return number
function GetCurrentOceanFishingMission2Progress() end

--- Returns the type for the current Ocean Fishing mission 2.
---@return number
function GetCurrentOceanFishingMission2Type() end

--- Returns the goal count for the current Ocean Fishing mission 3.
---@return number
function GetCurrentOceanFishingMission3Goal() end

--- Returns the name for the current Ocean Fishing mission 3.
---@return string
function GetCurrentOceanFishingMission3Name() end

--- Returns the progress count for the current Ocean Fishing mission 3.
---@return number
function GetCurrentOceanFishingMission3Progress() end

--- Returns the type for the current Ocean Fishing mission 3.
---@return number
function GetCurrentOceanFishingMission3Type() end

--- Returns the current Ocean Fishing points.
---@return number
function GetCurrentOceanFishingPoints() end

--- Returns the current Ocean Fishing route ID.
---@return number
function GetCurrentOceanFishingRoute() end

--- Returns the current Ocean Fishing score.
---@return number
function GetCurrentOceanFishingScore() end

--- Returns the current Ocean Fishing status.
---@return number
function GetCurrentOceanFishingStatus() end

--- Returns the current Ocean Fishing time of day.
---@return number
function GetCurrentOceanFishingTimeOfDay() end

--- Returns the current Ocean Fishing time offset.
---@return number
function GetCurrentOceanFishingTimeOffset() end

--- Returns the total current Ocean Fishing score.
---@return number
function GetCurrentOceanFishingTotalScore() end

--- Returns the current Ocean Fishing weather ID.
---@return number
function GetCurrentOceanFishingWeatherID() end

--- Returns the current Ocean Fishing zone ID.
---@return number
function GetCurrentOceanFishingZone() end

--- Returns the current Ocean Fishing zone time left.
---@return number
function GetCurrentOceanFishingZoneTimeLeft() end

--- Returns the current world ID.
---@return number
function GetCurrentWorld() end

--- Returns the progress of the Dragon's Demand Passage.
---@return number
function GetDDPassageProgress() end

--- Returns the number of Aether gauge bars in the Diadem.
---@return number
function GetDiademAetherGaugeBarCount() end

--- Returns the distance from the player to the focus target.
---@return number
function GetDistanceToFocusTarget() end

--- Returns the distance from the player to an object.
---@param objectId any
---@return number
function GetDistanceToObject(objectId) end

--- Returns the distance from the player to a party member by index.
---@param partyIndex number
---@return number
function GetDistanceToPartyMember(partyIndex) end

--- Calculates distance from player to a point.
---@param x number
---@param y number
---@param z number
---@return number distance
GetDistanceToPoint = GetDistanceToPoint or function(x, y, z) return 0 end

--- Returns the distance from the player to the current target.
---@return number
function GetDistanceToTarget() end

--- Returns current durability of equipped gear.
---@return number
function GetDurability() end

--- Returns the player's Free Company.
---@return table
function GetFCGrandCompany() end

--- Returns the number of online members in the Free Company.
---@return number
function GetFCOnlineMembers() end

--- Returns the Free Company rank.
---@return number
function GetFCRank() end

--- Returns the total number of members in the Free Company.
---@return number
function GetFCTotalMembers() end

--- Returns the FATE chain ID of the current FATE.
---@return number
function GetFateChain() end

--- Returns the duration of the current FATE.
---@return number
function GetFateDuration() end

--- Returns the event item for the current FATE.
---@return number
function GetFateEventItem() end

--- Returns the number of hand-ins for the current FATE.
---@return number
function GetFateHandInCount() end

--- Returns the icon ID of the current FATE.
---@return number
function GetFateIconId() end

--- Returns true if the current FATE is a bonus.
---@return boolean
function GetFateIsBonus() end

--- Returns the level of the current FATE.
---@return number
function GetFateLevel() end

--- Returns the X coordinate of the current FATE's location.
---@return number
function GetFateLocationX() end

--- Returns the Y coordinate of the current FATE's location.
---@return number
function GetFateLocationY() end

--- Returns the Z coordinate of the current FATE's location.
---@return number
function GetFateLocationZ() end

--- Returns the maximum level of the current FATE.
---@return number
function GetFateMaxLevel() end

--- Returns the name of the current FATE.
---@return string
function GetFateName() end

--- Returns the progress percentage of the current FATE.
---@return number
function GetFateProgress() end

--- Returns the radius of the current FATE.
---@return number
function GetFateRadius() end

--- Returns the start time of the current FATE as an epoch timestamp.
---@return number
function GetFateStartTimeEpoch() end

--- Returns the state of the current FATE.
---@return number
function GetFateState() end

--- Returns the X coordinate of a flag in the map.
---@return number
function GetFlagXCoord() end

--- Returns the Y coordinate of a flag in the map.
---@return number
function GetFlagYCoord() end

--- Returns the zone ID where the flag is located.
---@return number
function GetFlagZone() end

--- Returns the rank in the Flames Grand Company.
---@return number
function GetFlamesGCRank() end

--- Returns the action ID the focus target is currently using.
---@return number
function GetFocusTargetActionID() end

--- Returns the FATE ID of the focus target.
---@return number
function GetFocusTargetFateID() end

--- Returns the current HP of the focus target.
---@return number
function GetFocusTargetHP() end

--- Returns the current HP percentage of the focus target.
---@return number
function GetFocusTargetHPP() end

--- Returns the maximum HP of the focus target.
---@return number
function GetFocusTargetMaxHP() end

--- Returns the name of the focus target.
---@return string
function GetFocusTargetName() end

--- Returns the raw X position of the focus target.
---@return number
function GetFocusTargetRawXPos() end

--- Returns the raw Y position of the focus target.
---@return number
function GetFocusTargetRawYPos() end

--- Returns the raw Z position of the focus target.
---@return number
function GetFocusTargetRawZPos() end

--- Returns the rotation of the focus target.
---@return number
function GetFocusTargetRotation() end

--- Returns the number of free slots in the specified container.
---@param containerId number
---@return number
function GetFreeSlotsInContainer(containerId) end

--- Returns the current amount of Gil (currency) the player has.
---@return number
function GetGil() end

--- Returns a list of Gold Chest locations.
---@return table
function GetGoldChestLocations() end

--- Returns the current GP (Gathering Points) of the player.
---@return number
function GetGp() end

--- Returns the current HP of the player.
---@return number
function GetHP() end

--- Returns a hash code for the given input.
---@param input any
---@return number
function GetHashCode(input) end

--- Returns the player's home world name.
---@return string
function GetHomeWorld() end

--- Returns the number of free inventory slots.
---@return number
function GetInventoryFreeSlotCount() end

--- Returns the number of items in inventory by item ID.
---@param itemId number The item ID to check.
---@return number The quantity of that item in inventory.
GetItemCount = GetItemCount or function(itemId) return 0 end

--- Returns the number of items in a specific container.
---@param containerId number
---@return number
function GetItemCountInContainer(containerId) end

--- Returns the number of items in a specific slot.
---@param containerId number
---@param slotIndex number
---@return number
function GetItemCountInSlot(containerId, slotIndex) end

--- Returns the item ID of the item in the specified slot.
---@param containerId number
---@param slotIndex number
---@return number
function GetItemIdInSlot(containerId, slotIndex) end

--- Returns a list of item IDs in a container.
---@param containerId number
---@return table<number>
function GetItemIdsInContainer(containerId) end

--- Returns the name of an item by its ID.
---@param itemId number
---@return string
function GetItemName(itemId) end

--- Returns the current experience points for the job.
---@return number
function GetJobExp() end

--- Returns the character level.
---@return number
function GetLevel() end

--- Returns the number of Limit Break bars.
---@return number
function GetLimitBreakBarCount() end

--- Returns the value of the Limit Break bar.
---@return number
function GetLimitBreakBarValue() end

--- Returns the current Limit Break value.
---@return number
function GetLimitBreakCurrentValue() end

--- Returns the current MP (Mana Points) of the player.
---@return number
function GetMP() end

--- Returns the rank in the Maelstrom Grand Company.
---@return number
function GetMaelstromGCRank() end

--- Returns the maximum Crafting Points.
---@return number
function GetMaxCp() end

--- Returns the maximum durability of equipped gear.
---@return number
function GetMaxDurability() end

--- Returns the maximum GP (Gathering Points).
---@return number
function GetMaxGp() end

--- Returns the maximum HP of the player.
---@return number
function GetMaxHP() end

--- Returns the maximum MP of the player.
---@return number
function GetMaxMP() end

--- Returns the maximum progress in crafting.
---@return number
function GetMaxProgress() end

--- Returns the maximum quality in crafting.
---@return number
function GetMaxQuality() end

--- Returns a list of Mimic Chest locations.
---@return table
function GetMimicChestLocations() end

--- Returns Monster Note rank info.
---@return table
function GetMonsterNoteRankInfo() end

--- Returns the names of nearby objects.
---@return table<string>
function GetNearbyObjectNames() end

--- Returns the nearest FATE info.
---@return table
function GetNearestFate() end

--- Returns the count of nodes in the current node list.
---@return number
function GetNodeListCount() end

--- Gets text from a UI node.
---@param addonName string
---@param nodeId number
---@param param number
---@return string
GetNodeText = GetNodeText or function(addonName, nodeId) return "" end or function(addonName, nodeId, param) return "" end

--- Returns the action ID of an object.
---@param objectId any
---@return number
function GetObjectActionID(objectId) end

--- Returns the data ID of an object.
---@param objectId any
---@return number
function GetObjectDataID(objectId) end

--- Returns the FATE ID associated with an object.
---@param objectId any
---@return number
function GetObjectFateID(objectId) end

--- Returns the HP of an object.
---@param objectId any
---@return number
function GetObjectHP(objectId) end

--- Returns the HP percentage of an object.
---@param objectId any
---@return number
function GetObjectHPP(objectId) end

--- Returns the hitbox radius of an object.
---@param objectId any
---@return number
function GetObjectHitboxRadius(objectId) end

--- Returns the hunt rank of an object.
---@param objectId any
---@return number
function GetObjectHuntRank(objectId) end

--- Returns the maximum HP of an object.
---@param objectId any
---@return number
function GetObjectMaxHP(objectId) end

--- Returns the raw X position of an object.
---@param objectId any
---@return number
function GetObjectRawXPos(objectId) end

--- Returns the raw Y position of an object.
---@param objectId any
---@return number
function GetObjectRawYPos(objectId) end

--- Returns the raw Z position of an object.
---@param objectId any
---@return number
function GetObjectRawZPos(objectId) end

--- Returns the rotation of an object.
---@param objectId any
---@return number
function GetObjectRotation(objectId) end

--- Returns the index of the party leader.
---@return number
function GetPartyLeadIndex() end

--- Returns the action ID of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberActionID(partyIndex) end

--- Returns the HP of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberHP(partyIndex) end

--- Returns the HP percentage of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberHPP(partyIndex) end

--- Returns the maximum HP of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberMaxHP(partyIndex) end

--- Returns the name of a party member.
---@param partyIndex number
---@return string
function GetPartyMemberName(partyIndex) end

--- Returns the raw X position of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberRawXPos(partyIndex) end

--- Returns the raw Y position of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberRawYPos(partyIndex) end

--- Returns the raw Z position of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberRawZPos(partyIndex) end

--- Returns the rotation of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberRotation(partyIndex) end

--- Returns the world ID of a party member.
---@param partyIndex number
---@return number
function GetPartyMemberWorldId(partyIndex) end

--- Returns the world name of a party member.
---@param partyIndex number
---@return string
function GetPartyMemberWorldName(partyIndex) end

--- Returns the location of the passage (likely related to dungeons or events).
---@return table
function GetPassageLocation() end

--- Returns remaining penalty time in minutes.
---@return number
function GetPenaltyRemainingInMinutes() end

--- Returns the percentage of HQ (high quality) items.
---@return number
function GetPercentHQ() end

--- Returns the player's account ID.
---@return number
function GetPlayerAccountId() end

--- Returns the player character's content ID.
---@return number
function GetPlayerContentId() end

--- Returns the player's Grand Company affiliation.
---@return number
function GetPlayerGC() end

--- Returns the player's raw X position.
---@return number
function GetPlayerRawXPos() end

--- Returns the player's raw Y position.
---@return number
function GetPlayerRawYPos() end

--- Returns the player's raw Z position.
---@return number
function GetPlayerRawZPos() end

--- Returns the version of the plugin.
---@return string
function GetPluginVersion() end

--- Returns current progress value (crafting, etc).
---@return number
function GetProgress() end

--- Returns the increase in progress (crafting, etc).
---@return number
function GetProgressIncrease() end

--- Returns current quality value (crafting).
---@return number
function GetQuality() end

--- Returns the increase in quality value.
---@return number
function GetQualityIncrease() end

--- Returns the Allied Society for a quest.
---@return string
function GetQuestAlliedSociety() end

--- Returns the quest ID by name.
---@param questName string
---@return number
function GetQuestIDByName(questName) end

--- Returns the quest sequence number.
---@param questId number
---@return number
function GetQuestSequence(questId) end

--- Returns the real recast time (skill cooldown).
---@param actionId number
---@return number
function GetRealRecastTime(actionId) end

--- Returns the elapsed real recast time.
---@param actionId number
---@return number
function GetRealRecastTimeElapsed(actionId) end

--- Returns the real cooldown of a spell.
---@param spellId number
---@return number
function GetRealSpellCooldown(spellId) end

--- Returns the recast time of an action.
---@param actionId number
---@return number
function GetRecastTime(actionId) end

--- Returns the elapsed recast time of an action.
---@param actionId number
---@return number
function GetRecastTimeElapsed(actionId) end

--- Requests achievement progress data.
---@param achievementId number
function RequestAchievementProgress(achievementId) end

--- Returns an SND property by key.
---@param key string
---@return any
function GetSNDProperty(key) end

--- Returns the text for a select icon string in UI.
---@param index number
---@return string
function GetSelectIconStringText(index) end

--- Returns the text for a select string in UI.
---@param index number
---@return string
function GetSelectStringText(index) end

--- Returns the shield percentage of the player.
---@return number
function GetShieldPercentage() end

--- Returns a list of silver chest locations.
---@return table
function GetSilverChestLocations() end

--- Returns the cooldown time remaining for a spell.
---@param spellId number
---@return number
function GetSpellCooldown(spellId) end

--- Returns the integer cooldown time for a spell.
---@param spellId number
---@return number
function GetSpellCooldownInt(spellId) end

--- Returns the source ID of a status effect.
---@param statusId number
---@return number
function GetStatusSourceID(statusId) end

--- Returns the stack count of a status on the player or target.
---@param statusId number
---@return number
function GetStatusStackCount(statusId) end

--- Returns the time remaining on a status effect.
---@param statusId number
---@return number
function GetStatusTimeRemaining(statusId) end

--- Returns the current crafting step.
---@return number
function GetStep() end

--- Returns the action ID of the current target.
---@return number
function GetTargetActionID() end

--- Returns the FATE ID of the current target.
---@return number
function GetTargetFateID() end

--- Returns the HP of the current target.
---@return number
function GetTargetHP() end

--- Returns the HP percentage of the current target.
---@return number
function GetTargetHPP() end

--- Returns the hitbox radius of the current target.
---@return number
function GetTargetHitboxRadius() end

--- Returns the hunt rank of the current target.
---@return number
function GetTargetHuntRank() end

--- Returns the maximum HP of the current target.
---@return number
function GetTargetMaxHP() end

--- Returns the name of the current target.
---@return string
function GetTargetName() end

--- Returns the object kind of the current target.
---@return number
function GetTargetObjectKind() end

--- Returns the raw X position of the current target.
---@return number
function GetTargetRawXPos() end

--- Returns the raw Y position of the current target.
---@return number
function GetTargetRawYPos() end

--- Returns the raw Z position of the current target.
---@return number
function GetTargetRawZPos() end

--- Returns the rotation of the current target.
---@return number
function GetTargetRotation() end

--- Returns the sub-kind of the current target.
---@return number
function GetTargetSubKind() end

--- Returns the world ID of the current target.
---@return number
function GetTargetWorldId() end

--- Returns the world name of the current target.
---@return string
function GetTargetWorldName() end

--- Returns the text from a toast notification node.
---@return string
function GetToastNodeText() end

--- Returns a list of tradeable white item IDs.
---@return table<number>
function GetTradeableWhiteItemIDs() end

--- Returns a list of trap locations.
---@return table
function GetTrapLocations() end

--- Returns the type of the specified object.
---@param objectId any
---@return number
function GetType(objectId) end

--- Returns weekly bingo order data (multiple versions).
---@return table
function GetWeeklyBingoOrderDataData() end

function GetWeeklyBingoOrderDataKey() end
function GetWeeklyBingoOrderDataText() end
function GetWeeklyBingoOrderDataType() end

--- Returns weekly bingo task status.
---@return number
function GetWeeklyBingoTaskStatus() end

--- Returns the zone ID.
---@return number
function GetZoneID() end

--- Returns the zone instance number.
---@return number
function GetZoneInstance() end

--- Returns the zone name.
---@return string
function GetZoneName() end

--- Checks if the player has a specific condition.
---@param conditionId number
---@return boolean
function HasCondition(conditionId) end

--- Checks if the player has unlocked flight.
---@return boolean
function HasFlightUnlocked() end

--- Checks if crafting progress is at maximum.
---@return boolean
function HasMaxProgress() end

--- Checks if crafting quality is at maximum.
---@return boolean
function HasMaxQuality() end

--- Checks if a plugin is installed.
---@param name string Plugin name.
---@return boolean True if plugin is installed, false otherwise.
HasPlugin = HasPlugin or function(name) return true end

--- Checks if the player has stats.
---@return boolean
function HasStats() end

--- Checks if the player or target has a status.
---@param statusId number
---@return boolean
function HasStatus(statusId) end

--- Checks if the player or target has a status by ID.
---@param statusId number
---@return boolean
function HasStatusId(statusId) end

--- Checks if there is a current target.
---@return boolean
function HasTarget() end

--- Checks if the player has the weekly bingo journal.
---@return boolean
function HasWeeklyBingoJournal() end

--- Checks if the player is currently in a sanctuary area.
---@return boolean
function InSanctuary() end

--- Retrieves the internal macro text.
---@return string
function InternalGetMacroText() end

--- Checks if an achievement is complete.
---@param achievementId number
---@return boolean
function IsAchievementComplete(achievementId) end

--- Checks if an addon is ready.
---@param addonName string
---@return boolean
function IsAddonReady(addonName) end

--- Checks if a specified addon UI is currently visible.
---@param addonName string The name of the addon (e.g., "Repair").
---@return boolean True if the addon is visible, false otherwise.
IsAddonVisible = IsAddonVisible or function(addonName) return false end

--- Checks if a specific Aetheryte is unlocked.
---@param aetheryteId number
---@return boolean
function IsAetheryteUnlocked(aetheryteId) end

--- Checks if an item is collectable.
---@param itemId number
---@return boolean
function IsCollectable(itemId) end

--- Checks if the player is currently crafting.
---@return boolean
function IsCrafting() end

--- Checks if the focus target is casting.
---@return boolean
function IsFocusTargetCasting() end

--- Checks if a friend is online.
---@param friendName string
---@return boolean
function IsFriendOnline(friendName) end

--- Checks if the player is in a FATE.
---@return boolean
function IsInFate() end

--- Checks if the player is currently in the specified zone.
---@param zoneId number
---@return boolean
IsInZone = IsInZone or function(zoneId) return false end

--- Checks if a levequest is accepted.
---@param leveId number
---@return boolean
function IsLeveAccepted(leveId) end

--- Checks if the player is level synced.
---@return boolean
function IsLevelSynced() end

--- Checks if the local player object is null.
---@return boolean
function IsLocalPlayerNull() end

--- Checks if a macro is running or queued.
---@return boolean
function IsMacroRunningOrQueued() end

--- Checks if the player is currently moving.
---@return boolean
function IsMoving() end

--- Checks if a UI node is visible.
---@param addonName string
---@param nodeId number
---@return boolean
function IsNodeVisible(addonName, nodeId) end

--- Checks if the player is not crafting.
---@return boolean
function IsNotCrafting() end

--- Checks if an object is casting a spell.
---@param objectId any
---@return boolean
function IsObjectCasting(objectId) end

--- Checks if an object is in combat.
---@param objectId any
---@return boolean
function IsObjectInCombat(objectId) end

--- Checks if an object is mounted.
---@param objectId any
---@return boolean
function IsObjectMounted(objectId) end

--- Checks if a party member is casting.
---@param partyIndex number
---@return boolean
function IsPartyMemberCasting(partyIndex) end

--- Checks if a party member is in combat.
---@param partyIndex number
---@return boolean
function IsPartyMemberInCombat(partyIndex) end

--- Checks if a party member is mounted.
---@param partyIndex number
---@return boolean
function IsPartyMemberMounted(partyIndex) end

--- Checks if the pause loop flag is set.
---@return boolean
function IsPauseLoopSet() end

--- Checks if the player is available for actions.
---@return boolean
function IsPlayerAvailable() end

--- Checks if the player is casting a spell.
---@return boolean
function IsPlayerCasting() end

--- Checks if the player is dead.
---@return boolean
function IsPlayerDead() end

--- Checks if the player is occupied (busy).
---@return boolean
function IsPlayerOccupied() end

--- Checks if a quest is accepted.
---@param questId number
---@return boolean
function IsQuestAccepted(questId) end

--- Checks if a quest is complete.
---@param questId number
---@return boolean
function IsQuestComplete(questId) end

--- Checks if the stop loop flag is set.
---@return boolean
function IsStopLoopSet() end

--- Checks if the current target is casting a spell.
---@return boolean
function IsTargetCasting() end

--- Checks if the current target is in combat.
---@return boolean
function IsTargetInCombat() end

--- Checks if the current target is mounted.
---@return boolean
function IsTargetMounted() end

--- Checks if the Visland route is currently running.
---@return boolean
function IsVislandRouteRunning() end

--- Checks if the weekly bingo event has expired.
---@return boolean
function IsWeeklyBingoExpired() end

--- Leaves the current duty (dungeon, trial, etc).
function LeaveDuty() end

--- Aborts the current Lifestream process.
function LifestreamAbort() end

--- Performs an Aethernet teleport via Lifestream.
function LifestreamAethernetTeleport() end

--- Executes a command using Lifestream.
---@param command string
function LifestreamExecuteCommand(command) end

--- Checks if Lifestream is busy.
---@return boolean
function LifestreamIsBusy() end

--- Teleports the player using Lifestream.
function LifestreamTeleport() end

--- Teleports the player to their apartment via Lifestream.
function LifestreamTeleportToApartment() end

--- Teleports the player to Free Company estate via Lifestream.
function LifestreamTeleportToFC() end

--- Teleports the player to their home via Lifestream.
function LifestreamTeleportToHome() end

--- Lists all available functions.
---@return table<string>
function ListAllFunctions() end

--- Logs a debug message.
---@param message string
function LogDebug(message) end

--- Logs an informational message.
---@param message string
LogInfo = LogInfo or function(message) end

--- Logs a verbose message.
---@param message string
function LogVerbose(message) end

--- Moves an item to a container.
---@param itemId number
---@param fromContainer number
---@param toContainer number
---@param quantity number
function MoveItemToContainer(itemId, fromContainer, toContainer, quantity) end

--- Returns the progress of the navigation build.
---@return number
function NavBuildProgress() end

--- Returns if navigation autoload is enabled.
---@return boolean
function NavIsAutoLoad() end

--- Returns if navigation is ready.
---@return boolean
function NavIsReady() end

--- Starts pathfinding to the specified coordinates.
---@param x number
---@param y number
---@param z number
---@return boolean success
function NavPathfind(x, y, z) end

--- Rebuilds the navigation mesh.
function NavRebuild() end

--- Reloads navigation data.
function NavReload() end

--- Sets whether navigation autoload is enabled.
---@param enabled boolean
function NavSetAutoLoad(enabled) end

--- Checks if player's equipment needs repair based on threshold.
---@param threshold number
---@return boolean
NeedsRepair = NeedsRepair or function(threshold) return false end

--- Checks if an object has a status.
---@param objectId any
---@param statusId number
---@return boolean
function ObjectHasStatus(objectId, statusId) end

--- Checks if Ocean Fishing spectral is active.
---@return boolean
function OceanFishingIsSpectralActive() end

--- Opens a regular duty (dungeon, trial).
---@param dutyId number
function OpenRegularDuty(dutyId) end

--- Opens a roulette duty.
---@param rouletteId number
function OpenRouletteDuty(rouletteId) end

--- Returns whether a Pandora feature config is enabled.
---@param featureName string
---@return boolean
function PandoraGetFeatureConfigEnabled(featureName) end

--- Returns whether a Pandora feature is enabled.
---@param featureName string
---@return boolean
function PandoraGetFeatureEnabled(featureName) end

--- Pauses a Pandora feature.
---@param featureName string
function PandoraPauseFeature(featureName) end

--- Sets Pandora feature config state.
---@param featureName string
---@param state boolean
function PandoraSetFeatureConfigState(featureName, state) end

--- Sets Pandora feature state.
---@param featureName string
---@param state boolean
function PandoraSetFeatureState(featureName, state) end

--- Checks if a party member has a status.
---@param partyIndex number
---@param statusId number
---@return boolean
function PartyMemberHasStatus(partyIndex, statusId) end

--- Gets alignment status of camera for pathfinding.
---@return boolean
function PathGetAlignCamera() end

--- Checks if movement is allowed in pathfinding.
---@return boolean
function PathGetMovementAllowed() end

--- Gets the tolerance value for pathfinding.
---@return number
function PathGetTolerance() end

--- Checks if pathfinding is running.
---@return boolean
function PathIsRunning() end

--- Moves to specified coordinates via pathfinding.
---@param x number
---@param y number
---@param z number
function PathMoveTo(x, y, z) end

--- Returns the number of waypoints in pathfinding.
---@return number
function PathNumWaypoints() end

--- Sets whether to align camera in pathfinding.
---@param enabled boolean
function PathSetAlignCamera(enabled) end

--- Sets whether movement is allowed in pathfinding.
---@param allowed boolean
function PathSetMovementAllowed(allowed) end

--- Sets the tolerance for pathfinding.
---@param tolerance number
function PathSetTolerance(tolerance) end

--- Stops pathfinding.
function PathStop() end

--- Starts pathfinding and moves to a position.
---@param x number
---@param y number
---@param z number
---@param fly boolean Whether to fly
PathfindAndMoveTo = PathfindAndMoveTo or function(x, y, z, fly) end

--- Checks if pathfinding is in progress.
---@return boolean
function PathfindInProgress() end

--- Pauses an action or routine.
function PauseYesAlready() end

--- Queries the nearest mesh point X coordinate.
---@return number
function QueryMeshNearestPointX() end

--- Queries the nearest mesh point Y coordinate.
---@return number
function QueryMeshNearestPointY() end

--- Queries the nearest mesh point Z coordinate.
---@return number
function QueryMeshNearestPointZ() end

--- Queries the mesh point on the floor X coordinate.
---@return number
function QueryMeshPointOnFloorX() end

--- Queries the mesh point on the floor Y coordinate.
---@return number
function QueryMeshPointOnFloorY() end

--- Queries the mesh point on the floor Z coordinate.
---@return number
function QueryMeshPointOnFloorZ() end

--- Adds a quest to the priority list (questionable API).
---@param questId number
function QuestionableAddQuestPriority(questId) end

--- Clears the quest priority list.
function QuestionableClearQuestPriority() end

--- Exports the quest priority list.
---@return table
function QuestionableExportQuestPriority() end

--- Gets the current quest ID.
---@return number
function QuestionableGetCurrentQuestId() end

--- Gets current quest step data.
---@return table
function QuestionableGetCurrentStepData() end

--- Imports quest priority data.
---@param data table
function QuestionableImportQuestPriority(data) end

--- Inserts a quest into priority list.
---@param questId number
---@param position number
function QuestionableInsertQuestPriority(questId, position) end

--- Checks if a quest is locked.
---@param questId number
---@return boolean
function QuestionableIsQuestLocked(questId) end

--- Checks if Questionable API is running.
---@return boolean
function QuestionableIsRunning() end

--- Adds a blacklist name ID to RSR.
---@param nameId number
function RSRAddBlacklistNameID(nameId) end

--- Adds a priority name ID to RSR.
---@param nameId number
function RSRAddPriorityNameID(nameId) end

--- Changes operating mode in RSR.
---@param mode number
function RSRChangeOperatingMode(mode) end

--- Removes a blacklist name ID from RSR.
---@param nameId number
function RSRRemoveBlacklistNameID(nameId) end

--- Removes a priority name ID from RSR.
---@param nameId number
function RSRRemovePriorityNameID(nameId) end

--- Triggers a special state in RSR.
---@param state number
function RSRTriggerSpecialState(state) end

--- Requests achievement progress.
---@param achievementId number
function RequestAchievementProgress(achievementId) end

--- Restores a paused state or action.
function RestoreYesAlready() end

--- Selects a duty.
---@param dutyId number
function SelectDuty(dutyId) end

--- Sets the Adder's Grand Company rank.
---@param rank number
function SetAddersGCRank(rank) end

--- Sets the auto-hook gig size.
---@param size number
function SetAutoHookAutoGigSize(size) end

--- Sets the auto-hook gig speed.
---@param speed number
function SetAutoHookAutoGigSpeed(speed) end

--- Sets the auto-hook gig state.
---@param state boolean
function SetAutoHookAutoGigState(state) end

--- Sets the auto-hook preset.
---@param presetName string
function SetAutoHookPreset(presetName) end

--- Sets the auto-hook state.
---@param state boolean
function SetAutoHookState(state) end

--- Sets the clipboard content.
---@param text string
function SetClipboard(text) end

--- Sets Deep Dungeon explorer mode.
---@param enabled boolean
function SetDFExplorerMode(enabled) end

--- Sets if Deep Dungeon join is in progress.
---@param inProgress boolean
function SetDFJoinInProgress(inProgress) end

--- Sets Deep Dungeon language to German.
---@param enabled boolean
function SetDFLanguageD(enabled) end

--- Sets Deep Dungeon language to English.
---@param enabled boolean
function SetDFLanguageE(enabled) end

--- Sets Deep Dungeon language to French.
---@param enabled boolean
function SetDFLanguageF(enabled) end

--- Sets Deep Dungeon language to Japanese.
---@param enabled boolean
function SetDFLanguageJ(enabled) end

--- Sets Deep Dungeon level sync state.
---@param enabled boolean
function SetDFLevelSync(enabled) end

--- Sets Deep Dungeon limited leveling state.
---@param enabled boolean
function SetDFLimitedLeveling(enabled) end

--- Sets Deep Dungeon minimum item level.
---@param minILvl number
function SetDFMinILvl(minILvl) end

--- Sets Deep Dungeon silence echo state.
---@param enabled boolean
function SetDFSilenceEcho(enabled) end

--- Sets Deep Dungeon unrestricted mode.
---@param enabled boolean
function SetDFUnrestricted(enabled) end

--- Sets Flames Grand Company rank.
---@param rank number
function SetFlamesGCRank(rank) end

--- Sets Maelstrom Grand Company rank.
---@param rank number
function SetMaelstromGCRank(rank) end

--- Sets a map flag.
---@param x number
---@param y number
---@param flag boolean
function SetMapFlag(x, y, flag) end

--- Sets the text of a UI node.
---@param addonName string
---@param nodeId number
---@param text string
function SetNodeText(addonName, nodeId, text) end

--- Sets an SND property.
---@param key string
---@param value any
function SetSNDProperty(key, value) end

--- Targets the closest enemy.
function TargetClosestEnemy() end

--- Targets the closest FATE enemy.
function TargetClosestFateEnemy() end

--- Checks if target has a specific status.
---@param statusId number
---@return boolean
function TargetHasStatus(statusId) end

--- Teleports to a Grand Company town.
function TeleportToGCTown() end

--- Checks if the territory supports mounting.
---@return boolean
function TerritorySupportsMounting() end

--- Converts an object to string.
---@param obj any
---@return string
function ToString(obj) end

--- Uses an auto-hook anonymous preset.
---@param presetName string
function UseAutoHookAnonymousPreset(presetName) end

--- Checks if Visland route is paused.
---@return boolean
function VislandIsRoutePaused() end

--- Sets Visland route paused state.
---@param paused boolean
function VislandSetRoutePaused(paused) end

--- Starts Visland route.
function VislandStartRoute() end

--- Stops Visland route.
function VislandStopRoute() end

--- Returns the number of placed stickers in Weekly Bingo.
---@return number
function WeeklyBingoNumPlacedStickers() end

--- Returns the number of second chance points in Weekly Bingo.
---@return number
function WeeklyBingoNumSecondChancePoints() end

--- A yield function (coroutine support).
---@param command string
function yield(command) end

--- Vector3 coordinate structure.
---@class Vector3Coords
---@field x number
---@field y number
---@field z number
--- Hub city structure with scrip exchange coordinates.
---@class HubCity
---@field scripExchange Vector3Coords
--- Selected hub city with default coordinates.
---@type HubCity
SelectedHubCity = SelectedHubCity or {scripExchange = { x = 0, y = 0, z = 0, }} or {aethernet = {aethernetZoneId = 0,}}