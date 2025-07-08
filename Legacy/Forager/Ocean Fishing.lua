--[[

  Automatic ocean fishing script. Options for AutoRetainer and returning to inn room between trips.

    Script runs using:
      SomethingNeedDoing (Expanded Edition): https://puni.sh/api/repository/croizat
    Required plugins:
      Autohook: https://love.puni.sh/ment.json
      Pandora: https://love.puni.sh/ment.json
      Visland: https://puni.sh/api/repository/veyn
    Required for major features:
      Teleporter: main repository
      Simple Tweaks: main repository
    Optional plugins:
      AutoRetainer: https://love.puni.sh/ment.json
      Discard Helper: https://plugins.carvel.li/
      YesAlready: https://love.puni.sh/ment.json
]]

-- Before getting on the boat
do_repair = "npc"  --"npc", "self". Add a number to set threshhold; "npc 10" to only repair if under 10%
buy_baits = 99  --Minimum number of baits you want. Will buy 99 at a time.
boat_route = "indigo"  --"indigo", "ruby", "random"
is_equip_recommended_gear = true  --Run /equiprecommended

-- Just got on the boat
food_to_eat = false  --Name of the food you want to use, in quotes. DOES NOT CHECK ITEM COUNT YET
is_wait_to_move = true  --Wait for the barrier to drop before moving to the side of the boat.
is_adjust_z = true  --true might cause stuttery movement, false might cause infinite movement. Good luck.

-- Fishing
bait_and_switch = true  --Uses /bait command from SimpleTweaks
force_autohook_presets = true
is_recast_on_spectral = true  --Cancels cast when spectral current starts
is_leveling = false  --false, "auto"
is_spam_next_zone_bait = false  --Spam chat with the bait for the next zone. Might not work?

-- Getting off the boat
score_screen_delay = 3  --How long in seconds to wait once the final score is displayed.
is_discard = false  --Requires Discard Helper. Can set to "spam" to run during cutscenes.
is_desynth = true  --Will enable Extended Desynthesis Window in Simple Tweaks. Optionally runs faster with YesAlready.

-- Waiting for next boat
wait_location = "inn"  --false, "inn", "fc", "private", "apartment", "shared", "Shared Estate (Plot [#], [#]nd ward)"
is_ar_while_waiting = true  --AutoRetainer multimode enabled in between fishing trips.

-- Other script settings
is_verbose = true  --General status messages
is_debug = false  --Spammy status messages
fishing_character = "auto"  --"First Last@Server", "auto"
movement_method = "visland" --"visland" (navmesh coming soon)
is_last_minute_entry = false  --Waits until 5 minutes before the boat leaves
is_single_run = false  --Only go on 1 fishing trip, then stop.

-- Spend white gatherer scrips
spend_scrips_when_above = true
scrip_category = 1
scrip_subcategory = 1
scrip_item_to_buy = "Hi-Cordial"

-- What to do when bags are full.
bags_full = {
  "/echo Bags full!",
  "/leaveduty",
  "/pcraft stop",
}

------------------------------------------------------------------------

function AutoHookPresets()
  if force_autohook_presets then
    if is_leveling then
      UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1ZTW/bOBD9KwHPISCJ+szN9abZYtNsEKfbQ9DDSKJswrLoUlTbbJD/XlISbUuRkrotFl1UN4XkvHnDGT6OmQc0qySfQynLebZEZw/ovIA4p7M8R2dSVPQU6clLVtD9ZGqm3qgvJ4xO0bVgXDB5j85sNVqef0nyKqXpflivf2yw3nKerDRY/eGMwfrhKbrY3q4ELVc8VyO2ZXUcPe9pCDIKOgDWi1Tnq2ozws+1LbdHMPC9Dr4B4XlOE6lxWkP7cJnzMgsuUgb5CBHfdjt4bmv1mpWr83taHvj1eoQ9r7OjvkkQrOlixTL5ClhNWw+UZmAhIVkrVG+Xp6e4h6hRi3oNktEioQd8/L6d382wY0wF+5fOQTZlY7z2rZ1efZDW+nYFOYN1+Ro+caEBOgMmHF0NnYkbmvBPVBnYepeGK/RJCXg9Dl2Os1ghorMM8tLk9hVbXsCm3pRZscypKA0hXRcKkQSW+yTSjo/wUZf7Fymgc4J3XHXSbvniM2zfFLJikvHiAlhhthKr6rmsBH1LyxKWiglCp+iq5oSuuDr2LcL9Vo3oPR3Au+Sl/G68axUXHWaIMBqZbzzW83s+i606ZwLyeSUELeRPirKH+kOxarwmnkGuTcIOAx5chu704WbF8gZY+uHErOnt1SDveseaSltIvm1xFpJua+neR91W40z8nMQewtUc3hXsY0U1LoqtNKGJl2LfojZ248zBEQGK7SyCIPaITb0QKbxLVsq/M+1DHY+7h9qbDmAnClFgB+Mc/1H+lQbl9ESv0IBXXGwg/5PztYYwAvWewnp/jPSsTpeKweSnHWoCde1AK5wxXkjBi+Ux5hY5ML+kS1qkIO6PRviDV2qx4d6u2ClBLTk9Q8ePdnZ72sdadhgPrLoVbHskr8BzyM7ySGYd22e4tev0GZhlkoo5VMuVanM2+sZThT50OOpGSJVOfaXqDyPVxEi1F/UvhGebDEVgJ2imCm/ox4oJmipsWelrVvdB/dL8tgr85kL7P9XTu5I2yW02rDkQU5E9W2QHWmsR4kWZ5WOSOjF20xhwmJEU0yjLIAQ7I6HW2mFxdcfF9QaWn5WaTqo6qeqkqpOq/maq6ie2T33LwwRSV3WwSYijJLVwaCVBCInlJ5k7qqreuKr+JZh6h3mxU/2N24Hp5p/ay6m9/GWE0IqU4HkuwXHiAHbDzMbgRSm2IXLDMCBEPZqNCqE/LoTXebXZnryfOsxJWH+Ny3/63T79bv9vO0xQHWVKMADxsOtGFEMc+jjxIy8MQuIECaDHD+aRtP0f291uoNFa/XfzKtvqavchuekyu4+zWWJ7xPJdHKSZj13LCRWF2MJg28RSD7NO7ChF/wpjwayURxwAAA==")

    elseif OceanFishingIsSpectralActive() then
      UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1ZTW/bOBD9KwHPJiDRFCXl5nrTbLDZbBCn20PQA0VSMmFZdCmqbTbIfy+pD9tyrHxscymgmzKceXwzHD7SzAOYVUbNaWnKeZqB0wdwVtAkF7M8B6dGV2IC3OClLIQbvMgKpcXfSrElOE1pXtrxJoB37hf2C0XxBFxrqbQ09+DUt9by7AfLKy74zuz8Hxv8FvEB1B9ox6MPS6IJON/cLrUolyq3Ft/zehM9P9MxyDjsAXgvUp0vq3VdChuNfQ+/wKiLUnkumNkL9Pfd0MvTKs0lzQcqQ3zcw8Nt1EdZLs/uRbk3b3BAOAh6hEm3InQlFkuZmg9U1rSdoewMC0PZyqIG24V5iruPGreo19RIUTCxx4ccxpF+AVEXquV/Yk5N0yfdrIfR6KD80zb6dklzSVflR/pNaQfQM3TpTCd9+41g6puw/r4r0vGOfNIB0x6Brp4fZHZO13XisyLLhS67Sd3au7DQw0+y6UFFj66HfxhNe1t1S8gtzK1afKebi8JU0khVnFNZdOWCtkMuK7t7RVnSzDIBYAKuak7gStn93SLcb6zF1e0I3qUqzf/Gu7Z5ieMMAQQD482M9fiOz2Jj95Km+bzSWhTmnbI8QH23XI+yBXdub8oiu6GSfzm5Unptd/cEuIAm+CidZqWfQW/rNYDetN7CqE07vjBiUwv0rgxte870+2S/D1cv46dCfq2EwwVhlKCEIQxjFiUQh4TDKMUpjGNCfI9OExYKYPEuZWn+Sd0cdr/cPdSzuQS2ShCHfjjM8V87vxWeXJw4DwfYFORPpVYOolOlz4KudvvKjbplsDl0dW9NTaLYD52sdcELo1WRvSXcm+6FX4pMFJzq+zcj/KEq69xxbz220tAe0r1AROJt3I72oEuP2hGvT6W41XLTEO6YNpY3sQoD5PJpIod49ZyeYdb6uVafpUboOa2ypb3HrN1pZvv52B6obzq2Q+rj0n3snQuNRAfx0/P+maPbEtgKWddsN+JrJbXgFttU7gh1l5rDDnxdo726n8a2+d3aZk8kpyiMeUgYnAoaQIziFEYejyGhHCeJF3txklhNO66KeFgVb2j23crgKIejHI5yOJ6iv4scpj5NExwTGGPkQ0x8AhMUIIiYFUMviURA00E5DIbl8C8t7ZvHi3fD8WQeL3TjhW78HfALChZ4Hkt5xCCNcGwvdGEKaTINIUcpp55VqUhMBxWMDCvYdV6tNyefX3WnG2VslLFRxkYZ+wUZE4yTlDEBAxHYixjyMKR+lEKeCEQ8ZH+tOhn70r3etf/iudsaGmVzfzfPha2K9V8uu9fN/rthgv0kZYF9LYwogZjHCCZ+HELCKUceY/ZSyMHjT7bcp0bcGgAA")
      autohook_preset_loaded = "spectral"
    else
      UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1ZTW/bOBD9KwHPISCJ+szN9abZYtNsEKfbQ9DDSKJswrLoUlTbbJD/XlISbUuRkrotFl1UN4XkvHnDGT6OmQc0qySfQynLebZEZw/ovIA4p7M8R2dSVPQU6clLVtD9ZGqm3qgvJ4xO0bVgXDB5j85sNVqef0nyKqXpflivf2yw3nKerDRY/eGMwfrhKbrY3q4ELVc8VyO2ZXUcPe9pCDIKOgDWi1Tnq2ozws+1LbdHMPC9Dr4B4XlOE6lxWkP7cJnzMgsuUgb5CBHfdjt4bmv1mpWr83taHvj1eoQ9r7OjvkkQrOlixTL5ClhNWw+UZmAhIVkrVG+Xp6e4h6hRi3oNktEioQd8/L6d382wY0wF+5fOQTZlY7z2rZ1efZDW+nYFOYN1+Ro+caEBOgMmHF0NnYkbmvBPVBnYepeGK/RJCXg9Dl2Os1ghorMM8tLk9hVbXsCm3pRZscypKA0hXRcKkQSW+yTSjo/wUZf7Fymgc4J3XHXSbvniM2zfFLJikvHiAlhhthKr6rmsBH1LyxKWiglCp+iq5oSuuDr2LcL9Vo3oPR3Au+Sl/G68axUXHWaIMBqZbzzW83s+i606ZwLyeSUELeRPirKH+kOxarwmnkGuTcIOAx5chu704WbF8gZY+uHErOnt1SDveseaSltIvm1xFpJua+neR91W40z8nMQewtUc3hXsY0U1LoqtNKGJl2LfojZ248zBEQGK7SyCIPaITb0QKbxLVsq/M+1DHY+7h9qbDmAnClFgB+Mc/1H+lQbl9ESv0IBXXGwg/5PztYYwAvWewnp/jPSsTpeKweSnHWoCde1AK5wxXkjBi+Ux5hY5ML+kS1qkIO6PRviDV2qx4d6u2ClBLTk9Q8ePdnZ72sdadhgPrLoVbHskr8BzyM7ySGYd22e4tev0GZhlkoo5VMuVanM2+sZThT50OOpGSJVOfaXqDyPVxEi1F/UvhGebDEVgJ2imCm/ox4oJmipsWelrVvdB/dL8tgr85kL7P9XTu5I2yW02rDkQU5E9W2QHWmsR4kWZ5WOSOjF20xhwmJEU0yjLIAQ7I6HW2mFxdcfF9QaWn5WaTqo6qeqkqpOq/maq6ie2T33LwwRSV3WwSYijJLVwaCVBCInlJ5k7qqreuKr+JZh6h3mxU/2N24Hp5p/ay6m9/GWE0IqU4HkuwXHiAHbDzMbgRSm2IXLDMCBEPZqNCqE/LoTXebXZnryfOsxJWH+Ny3/63T79bv9vO0xQHWVKMADxsOtGFEMc+jjxIy8MQuIECaDHD+aRtP0f291uoNFa/XfzKtvqavchuekyu4+zWWJ7xPJdHKSZj13LCRWF2MJg28RSD7NO7ChF/wpjwayURxwAAA==")
      autohook_preset_loaded = "normal"
    end
  end
end

baits_list = {
  unset = { name = "unset", id = 0},
  versatile = { name = "Versatile Lure", id = 29717 },
  ragworm = { name = "Ragworm", id = 29714 },
  krill = { name = "Krill", id = 29715 },
  plumpworm = { name = "Plump Worm", id = 29716 },
}

ocean_zones = {
  [1] = {id = 237, name = "Galadion Bay", normal_bait = baits_list.krill, daytime = baits_list.ragworm, sunset = baits_list.plumpworm, nighttime = baits_list.krill},
  [2] = {id = 239, name = "Southern Merlthor", normal_bait = baits_list.krill, daytime = baits_list.krill, sunset = baits_list.ragworm, nighttime = baits_list.plumpworm},
  [3] = {id = 243, name = "Northern Merlthor", normal_bait = baits_list.ragworm, daytime = baits_list.plumpworm, sunset = baits_list.ragworm, nighttime = baits_list.krill},
  [4] = {id = 241, name = "Rhotano Sea", normal_bait = baits_list.plumpworm, daytime = baits_list.plumpworm, sunset = baits_list.ragworm, nighttime = baits_list.krill},
  [5] = {id = 246, name = "The Ciedalaes", normal_bait = baits_list.ragworm, daytime = baits_list.krill, sunset = baits_list.plumpworm, nighttime = baits_list.krill},
  [6] = {id = 248, name = "Bloodbrine Sea", normal_bait = baits_list.krill, daytime = baits_list.ragworm, sunset = baits_list.plumpworm, nighttime = baits_list.krill},
  [7] = {id = 250, name = "Rothlyt Sound", normal_bait = baits_list.plumpworm, daytime = baits_list.krill, sunset = baits_list.krill, nighttime = baits_list.krill},
  [8] = {id = 286, name = "Sirensong Sea", normal_bait = baits_list.plumpworm, daytime = baits_list.krill, sunset = baits_list.krill, nighttime = baits_list.krill},
  [9] = {id = 288, name = "Kugane Coast", normal_bait = baits_list.ragworm, daytime = baits_list.krill, sunset = baits_list.ragworm, nighttime = baits_list.plumpworm},
  [10] = {id = 290, name = "Ruby Sea", normal_bait = baits_list.krill, daytime = baits_list.ragworm, sunset = baits_list.plumpworm, nighttime = baits_list.krill},
  [11] = {id = 292, name = "Lower One River", normal_bait = baits_list.krill, daytime = baits_list.ragworm, sunset = baits_list.krill, nighttime = baits_list.krill},
}

routes = { --Lua indexes from 1, so make sure to add 1 to the zone returned by SND.
  [1] = {[1] = 2, [2] = 1, [3] = 3},
  [2] = {[1] = 2, [2] = 1, [3] = 3},
  [3] = {[1] = 2, [2] = 1, [3] = 3},
  [4] = {[1] = 1, [2] = 2, [3] = 4},
  [5] = {[1] = 1, [2] = 2, [3] = 4},
  [6] = {[1] = 1, [2] = 2, [3] = 4},
  [7] = {[1] = 5, [2] = 3, [3] = 6},
  [8] = {[1] = 5, [2] = 3, [3] = 6},
  [9] = {[1] = 5, [2] = 3, [3] = 6},
  [10] = {[1] = 5, [2] = 4, [3] = 7},
  [11] = {[1] = 5, [2] = 4, [3] = 7},
  [12] = {[1] = 5, [2] = 4, [3] = 7},
  [13] = {[1] = 8, [2] = 9, [3] = 11},
  [14] = {[1] = 8, [2] = 9, [3] = 11},
  [15] = {[1] = 8, [2] = 9, [3] = 11},
  [16] = {[1] = 8, [2] = 9, [3] = 10},
  [17] = {[1] = 8, [2] = 9, [3] = 10},
  [18] = {[1] = 8, [2] = 9, [3] = 10},
}

function WaitReady(delay, is_not_ready, status, target_zone)
  if is_not_ready then loading_tick = -1
    else loading_tick = 0 end
  if not delay then delay = 3 end
  wait = 0.1
  if type(status)=="number" then wait = wait + (status / 10000) end
  while loading_tick<delay do
    if IsAddonVisible("NowLoading") then loading_tick = 0
    elseif IsPlayerOccupied() then
      if GetCharacterCondition(3) or GetCharacterCondition(11) then  --Emoting or sitting
        yield("/automove on")
        yield("/automove off")
      elseif GetCharacterCondition(16) then  --Performance
        yield("/send escape")  --I HATE using sends, it's clumsy. Need to find a better way to end performance.
      else
        loading_tick = 0
      end
    elseif loading_tick == -1 then
      if type(target_zone)=="number" then
        if IsInZone(target_zone) then loading_tick = 0 end
      end
      yield("/wait "..wait)
    else loading_tick = loading_tick + 0.1 end
    yield("/wait "..wait)
    if IsAddonVisible("IKDResult") then break end
    if is_discard=="spam" then yield("/discardall") end
  end
end

function RunDiscard(y)
  if is_discard then
    if is_desynth and y then
      verbose("You have desynth and discard turned on.")
      verbose("Waiting to discard until after desynth!")
    elseif y then
      discarded_on_1 = os.time()+10
      yield("/discardall")
    elseif discarded_on_1 then
      yield("/discardall")
      if os.time()<=discarded_on_1 then yield("/wait "..discarded_on_1-os.time()) end
    else
      yield("/discardall")
      verbose("Waiting 10 seconds to give Discard Helper time to run.")
      yield("/wait 10")
    end
  end
end

function MoveNear(near_x, near_z, near_y, radius, timeout, fast)
  if not radius then radius = 3 end
  if not timeout then timeout = 60 end
  if not type(fast)=="number" then fast = radius*2 end
  move_x = math.random((near_x-radius)*1000, (near_x+radius)*1000)/1000
  if near_z then
    move_z = near_z
  else
    move_z = math.floor(GetPlayerRawYPos()*1000)/1000
  end
  move_y = math.random((near_y-radius)*1000, (near_y+radius)*1000)/1000
  yield("/visland moveto "..move_x.." "..move_z.." "..move_y)
  yield("/wait 0.5")
  move_tick = 0
  while IsMoving() and move_tick <= timeout do
    if near_z == false then
      move_z = math.floor(GetPlayerRawYPos()*1000)/1000
      yield("/visland moveto "..move_x.." "..move_z.." "..move_y)
    end
    if fast then
      if GetDistanceToPoint(near_x, move_z, near_y)<fast then
        break
      end
      move_tick = move_tick + 0.01
      yield("/wait 0.01")
    else
      move_tick = move_tick + 0.1
      yield("/wait 0.1")
    end
  end
  if move_tick < timeout or not fast then yield("/visland stop") end
  if is_debug then
    yield("/echo Aimed for: X:"..move_x.." Z:"..move_z.." Y:"..move_y)
    yield("/echo Landed at: X:"..math.floor(GetPlayerRawXPos()*1000)/1000 .." Z:"..math.floor(GetPlayerRawYPos()*1000)/1000 .." Y:"..math.floor(GetPlayerRawZPos()*1000)/1000)
    if move_tick < timeout then
      reason = "arrived"
    else
      reason = "timeout"
    end
    yield("/echo Reason: "..reason)
  end
  return "X:"..move_x.." Z:"..move_z.." Y:"..move_y
end

function VislandRoute(route)
  while IsVislandRouteRunning() do
    yield("/visland stop")
    yield("/wait 0.2")
  end
  movement_start_point = GetPlayerRawXPos()..GetPlayerRawZPos()
  repeat
    yield("/visland stop")
    yield("/wait 0.2")
    yield("/visland exectemponce "..route)
    yield("/wait 0.8")
  until GetPlayerRawXPos()..GetPlayerRawZPos()~=movement_start_point
  bugfix_tick = 0
  while IsVislandRouteRunning() or IsMoving() do
    if bugfix_tick>=3 then
      yield("/visland stop")
      break
    elseif IsMoving() then
      bugfix_tick = 0
    else
      bugfix_tick = bugfix_tick + 1
    end
    yield("/wait 1.035")
  end
  yield("/visland stop")
end

function IsNeedBait()
  if type(buy_baits)~="number" then
    return false
  else
    if GetItemCount(29714)<buy_baits then
      verbose("Need to buy Ragworm!")
      is_purchase_ragworm = true
    end
    if GetItemCount(29715)<buy_baits then
      verbose("Need to buy Krill!")
      is_purchase_krill = true
    end
    if GetItemCount(29716)<buy_baits then
      verbose("Need to buy Plump Worm!")
      is_purchase_plump = true
    end
    if is_purchase_ragworm or is_purchase_krill or is_purchase_plump then
      return true
    else
      return false
    end
  end
end

function IsNeedRepair()
  if type(do_repair)~="string" then
    return false
  else
    repair_threshold = tonumber(string.gsub(do_repair,"%D",""))
    if not repair_threshold then repair_threshold = 99 end
    if NeedsRepair(tonumber(repair_threshold)) then
      if string.find(string.lower(do_repair),"self") then
        return "self"
      else
        return "npc"
      end
    else
      return false
    end
  end
end

function JobCheck()
  while GetClassJobId()~=18 do
    verbose("Switching to fisher!")
    if not job_change_attempts then
      verbose("Attempt 1: SimpleTweaks")
      yield("/equipjob FSH")
      job_change_attempts = 0
    elseif job_change_attempts==1 then
      verbose("Attempt 2: Fisher")
      yield("/gearset change Fisher")
    elseif job_change_attempts==2 then
      verbose("Attempt 3: FSH")
      yield("/gearset change FSH")
    elseif job_change_attempts==3 then
      verbose("Attempt 4: SimpleTweaks, after enabling EquipJobCommand")
      yield("/tweaks e EquipJobCommand")
      yield("/equipjob FSH")
      job_change_attempts = 0
    else
      verbose("Job change hasn't worked!")
      yield("/pcraft stop")
    end
    job_change_attempts = job_change_attempts + 1
    yield("/wait 1."..job_change_attempts)
  end
  job_change_attempts = nil
  if is_equip_recommended_gear then
    yield("/tweaks e RecommendEquipCommand")
    WaitReady(1)
    yield("/equiprecommended")
  end
end

function verbose(verbose_string, throttle)
  if is_verbose then
    if not throttle or ( throttle and os.date("!*t").sec==0 ) or is_debug then
      yield("/echo [FishingRaid] "..verbose_string)
    else
      yield("/wait 0.005")
    end
  end
end

function TimeCheck(context)
  time_state = false
  if is_last_minute_entry then
    if os.date("!*t").hour%2==0 and os.date("!*t").min<15 then
      if os.date("!*t").min>=11 then
        time_state = "queue"
      elseif os.date("!*t").min>=10 then
        time_state = "movewait"
      end
    end
  elseif os.date("!*t").hour%2==0 then
    if is_last_minute_entry and os.date("!*t").min>10 then
      time_state = "queue"
    elseif os.date("!*t").min<15 then
      time_state = "queue"
    end
  elseif os.date("!*t").hour%2==1 then
    if os.date("!*t").min>=55 then
      time_state = "movewait"
    elseif context and os.date("!*t").min>=45 then
      time_state = "early"
    end
  end
  return time_state
end

function EatFood()
  if type(food_to_eat)=="string" then
    eat_food_tick = 0
    while HasStatus("Well Fed")==false and eat_food_tick<8 do
      verbose("Eating "..food_to_eat)
      yield("/item "..food_to_eat)
      yield("/wait 1")
      eat_food_tick = eat_food_tick + 1
    end
    if eat_food_tick>=8 then food_to_eat = false end
  end
end

function SafeCallback(...)  -- Could be safer, but this is a good start, right?
  local callback_table = table.pack(...)
  local addon = nil
  local update = nil
  if type(callback_table[1])=="string" then
    addon = callback_table[1]
    table.remove(callback_table, 1)
  end
  if type(callback_table[1])=="boolean" then
    update = tostring(callback_table[1])
    table.remove(callback_table, 1)
  elseif type(callback_table[1])=="string" then
    if string.find(callback_table[1], "t") then
      update = "true"
    elseif string.find(callback_table[1], "f") then
      update = "false"
    end
    table.remove(callback_table, 1)
  end

  local call_command = "/pcall " .. addon .. " " .. update
  for _, value in pairs(callback_table) do
    if type(value)=="number" then
      call_command = call_command .. " " .. tostring(value)
    end
  end
  if IsAddonReady(addon) and IsAddonVisible(addon) then
    yield(call_command)
  end
end

correct_bait = baits_list.unset
normal_bait = baits_list.unset
spectral_bait = baits_list.unset
current_bait = baits_list.unset
if type(movement_method)~="string" then
  movement_method = ""
elseif string.find(string.lower(movement_method),"visland") then
  movement_method = "visland"
elseif string.find(string.lower(movement_method),"navmesh") then
  movement_method = "navmesh"
else
  verbose("Invalid movement_method")
  yield("/pcraft stop")
end
if type(is_leveling)=="string" then
  if GetLevel()>=100 then
    is_leveling = false
  else
    is_leveling = true
  end
end
if type(score_screen_delay)~="number" then score_screen_delay = 3 end
if score_screen_delay<0 or score_screen_delay>500 then score_screen_delay = 3 end
points_earned = 0

::Start::
DeleteAllAutoHookAnonymousPresets()
if IsAddonVisible("IKDResult") then
  goto FishingResults
elseif IsInZone(900) or IsInZone(1163) then
  verbose("We're on the boat!")
  goto OnBoat
elseif TimeCheck("start") then
  verbose("Starting at or near fishing time.")
  if IsInZone(129) and GetDistanceToPoint(-410,4,76)<6.9 then
    verbose("Near the ocean fishing NPC.")
    if GetCharacterCondition(91) then
      verbose("Already in queue.")
      goto Enter
    elseif IsNeedBait() then
      goto BuyBait
    elseif TimeCheck()=="queue" then
      goto PreQueue
    else
      goto WaitForBoat
    end
  else
    verbose("Not near the ocean fishing NPC.")
    goto ReturnFromWait
  end
elseif IsInZone(129) and GetDistanceToPoint(-411,4,72)<20 then
  if GetCharacterCondition(91) then
    goto Enter
  else
    goto DoneFishing
  end
elseif IsInZone(129) or IsInZone(128) then
  goto WaitLocation
elseif fishing_character~="auto" and fishing_character~=GetCharacterName(true) then
  goto MainWait
else
  if os.date("!*t").hour%2==1 then
    time_remaining = 55 - os.date("!*t").min .." minutes."
  elseif os.date("!*t").min<=55 then
    time_remaining = "1 hour and ".. 55 - os.date("!*t").min .." minutes"
  else
    time_remaining = 115 - os.date("!*t").min .." minutes"
  end
  verbose(time_remaining .." until the next boat.")
  goto StartAR
end

::MainWait::
while not TimeCheck(false) do
  if os.date("!*t").hour%2==1 then
    time_remaining = 55 - os.date("!*t").min .." minutes."
  elseif os.date("!*t").min<=55 then
    time_remaining = "1 hour and ".. 55 - os.date("!*t").min .." minutes."
  else
    time_remaining = 115 - os.date("!*t").min .." minutes."
  end
  if is_ar_while_waiting then
    verbose("Still running! AutoRetainer for the next ".. time_remaining, true)
  else
    verbose("Still running! Waiting for the next ".. time_remaining, true)
  end
  yield("/wait 1.001")
end


yield("/vnavmesh stop")
yield("/visland stop")
yield("/ays multi d")
while GetCharacterCondition(50) do
  if IsAddonVisible("RetainerList") then
    verbose("Closing retainer list.")
    yield("/callback RetainerList true -1")
  end
  yield("/wait 1.004")
end
while GetCharacterName(true)~=fishing_character do
  if IsAddonVisible("TitleConnect") or IsAddonVisible("NowLoading") or IsAddonVisible("CharaSelect") or GetCharacterCondition(53) then
    yield("/wait 1.002")
  elseif GetCharacterCondition(50,false) then
    verbose("Relogging to "..fishing_character)
    yield("/ays relog " .. fishing_character)
    WaitReady(3, true)
  else
    verbose("Waiting for AutoRetainer to finish!")
  end
  yield("/wait 1.003")
end

::ReturnFromWait::
if GetCharacterCondition(45) then
  WaitReady(1)
  goto Start
elseif IsAddonVisible("NowLoading") or GetCharacterCondition(35) then
  WaitReady(1)
end
::TeleportToLimsa::
while not ( IsInZone(177) or IsInZone(128) or IsInZone(129) ) do
  if GetCharacterCondition(27, false) and not IsPlayerOccupied() then
    yield("/tp Limsa")
  else
    WaitReady(2)
  end
  yield("/wait 0.3")
end
if IsInZone(129) and GetDistanceToPoint(-84,19,0)<20 then
  verbose("Limsa aetheryte plaza. Aethernet to arcanists guild.")
  while GetDistanceToPoint(-84,19,0)<20 do
    if IsAddonVisible("TelepotTown") then
      yield("/callback TelepotTown true 11 3u")
    elseif GetTargetName()~="aetheryte" then
      yield("/target aetheryte")
    elseif IsAddonVisible("SelectString") then
      yield("/callback SelectString true 0")
    elseif GetDistanceToTarget()<8 then
      yield("/interact")
    else
      if IsMoving() then yield("/generalaction Jump") end
      yield("/lockon on")
      yield("/automove on")
    end
    yield("/wait 0.501")
  end
  WaitReady(3)
end
::ExitInn::
if IsInZone(177) then
  verbose("In inn. Leaving.")
  while IsInZone(177) do
    if GetTargetName()~="Heavy Oaken Door" then
      yield("/target Heavy Oaken Door")
    elseif IsAddonVisible("SelectYesno") then
      yield("/callback SelectYesno true 0")
    else
      yield("/lockon on")
      yield("/automove on")
      yield("/interact")
    end
    yield("/wait 0.502")
  end
  WaitReady(3)
end
::MoveToAftcastle::
if IsInZone(128) and GetDistanceToPoint(13,40,13)<20 then
  verbose("Near inn. Moving to aftcastle.")
  if movement_method=="visland" then
    VislandRoute("H4sIAAAAAAAACuWTyWrDMBCGXyXM2QiNFkvyrXQBH9KNQrrQg2hUIqilYistxeTdqzgKCfQNGp3mnxlGvz40I1zbzkEDbQizFGfWpZXrg0tQwcL+fEYf0gDNywi3cfDJxwDNCI/QcEKlqaVUFTxlZYhEJYWo4BkarIlWRqDaZBmDay+goRXc26Vf52GMZDGPX65zIU2VNiTX27e08Gl1U7qPc8Vj9jSs4ve+ks3kae/2Y3CH9skhVnDZxbS/uE2uK+HZ1FHE3doNqcTbwQvr02HiVl3F/jyGZXk43SUffOfmuY9uqj9YKBFSG6WYPuYiJywMCUdTc3Z6WJAILSUKNlERlCCnivMJi6L5K2ltTo+KIJIaLcoOZSp0e/SOCiesVvoEVwg50UxLdqCyA4IEFar6vwN53fwCXs5zv5QFAAA=")
  elseif movement_method=="navmesh" then
  end
end
::AethernetToArcanist::
if IsInZone(128) and GetDistanceToPoint(14,40,71)<9 then
  verbose("At aftcastle. Aethernet to arcanists guild.")
  while IsInZone(128) do
    if IsAddonVisible("TelepotTown") then
      yield("/callback TelepotTown true 11 3u")
    elseif GetTargetName()~="Aethernet shard" then
      yield("/target Aethernet shard")
    elseif GetDistanceToTarget()<4 then
      yield("/interact")
    else
      yield("/lockon on")
      yield("/automove on")
    end
    yield("/wait 0.503")
  end
  WaitReady(3)
end

JobCheck()

::MoveToOcean::
if IsInZone(129) and GetDistanceToPoint(-335,12,53)<9 then
  if IsNeedRepair()=="npc" or IsNeedBait() then
    verbose("At arcanists guild. Moving to Merchant & Mender.")
    if movement_method=="visland" then
      VislandRoute("H4sIAAAAAAAACuWTyWrDMBCGXyXMWRWyFmu5hS6QQ7pRcNPSg0hUIqilYCstJfjdKy8hUPoEjU7zj35+Rh+jA9za2oGBebO2wbdpRmeN21nfAILKfu+iD6kF83qA+9j65GMAc4BnMBeME8yJIAzBCkxRYNWrEsELGC6xZqwQossyBre4yg6qETzajd/nPIoJgmX8dLULCUwWi5BcY9ep8ml71/t/9aY581jtNn4db/I8Oe3dfrTuZB+GLBBc1zG5Y1Ry9VTOB8ckHvauTVPdB1fWp1Nir25icxnDZno7GZtPvnbL7CMd+oOMUljKkg9gBNb5cCVGMBpzwUquzhOMZpjpfkcyGD6A0XrgUgosqCJnui9aY1GoEQsbsdDxI8n8rQg923WRWDEp6ASG9GDEuDBSYUappP8fzFv3A6BUZs+lBQAA")
    else yield("/pcraft stop")
    end
  else
    verbose("At arcanists guild. Moving to ocean fishing.")
    if movement_method=="visland" then
      VislandRoute("H4sIAAAAAAAACuWSy2oDMQxFfyVoPTX22J6xvAt9QBbpi0L6oAszcRpDxy4Zp6WE/Hsdz4R0kS9ItNKVxLV80AZuTWtBw3jVGO+6OIphFBpr/GjhuqXzH1DAzPx+BedjB/ptA/ehc9EFD3oDz6AvOFekRiYLeAHNGFGilCgKeAUtFEEmsNomFbydXIGmBTyauVsnL0aSmIZv21ofc2fio12ZJs5cXN4N0/9rw65ppW4ZfvadtEtyW5jPzh7G84KsgOs2xP3Dk2jbIR3niUE8rG0Xh3xnPDMuHhx36iasLoOfD/+mffHJtXaa5ui2OEKlkkRgyUXGoghNIaueSk0oq7hSx7GUJ41FYcKCss5YJMEUXPVYkDDGKTtLLFgSKcsBCs080gExUZV4hjgErYmiFfZAeL4SxP5MakFqhVKeOpb37R9ZYl91nAUAAA==")
    else yield("/pcraft stop")
    end
  end
end

::RepairNPC::
if IsNeedRepair()=="npc" then
  if IsInZone(129) and GetDistanceToPoint(-397,3,80)>5 then MoveNear(-398, 3, 78, 2, 5) end
  while not IsAddonVisible("Repair") do
    if GetTargetName()~="Merchant & Mender" then
      yield("/target Merchant & Mender")
    elseif IsAddonVisible("SelectIconString") then
      yield("/callback SelectIconString true 1")
    elseif GetCharacterCondition(32, false) then
      yield("/lockon on")
      yield("/interact")
    end
    yield("/wait 0.592")
  end
  while IsAddonVisible("Repair") do
    if string.gsub(GetNodeText("Repair",2),"%D","")~="0" then
      if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
      else
        yield("/callback Repair true 0")
      end
    else
      yield("/callback Repair true -1")
      yield("/lockon off")
    end
    yield("/wait 0.305")
  end
end

::BuyBait::
if IsNeedBait() then
  verbose("Buying more bait.")
  if IsInZone(129) and GetDistanceToPoint(-397,3,80)>5 then MoveNear(-398, 3, 78, 2, 5) end
  while not IsAddonVisible("Shop") do
    if GetTargetName()~="Merchant & Mender" then
      yield("/target Merchant & Mender")
    elseif IsAddonVisible("SelectIconString") then
      yield("/callback SelectIconString true 0")
    elseif GetCharacterCondition(32, false) then
      yield("/lockon on")
      yield("/interact")
    end
    yield("/wait 0.591")
  end
  if is_purchase_ragworm then
    yield("/callback Shop true 0 0 99")
    is_purchase_ragworm = false
    yield("/wait 0.5")
    if IsAddonVisible("SelectYesno") then yield("/callback SelectYesno true 0") end
    yield("/wait 0.5")
  end
  if is_purchase_krill then
    yield("/callback Shop true 0 1 99")
    is_purchase_krill = false
    yield("/wait 0.5")
    if IsAddonVisible("SelectYesno") then yield("/callback SelectYesno true 0") end
    yield("/wait 0.5")
  end
  if is_purchase_plump then
    yield("/callback Shop true 0 2 99")
    is_purchase_plump = false
    yield("/wait 0.5")
    if IsAddonVisible("SelectYesno") then yield("/callback SelectYesno true 0") end
    yield("/wait 0.5")
  end
  goto BuyBait
elseif IsAddonVisible("Shop") then
  yield("/callback Shop true -1")
  yield("/lockon off")
  goto BuyBait
end

::BackToOcean::
WaitReady(0.3)
if GetDistanceToPoint(-410,4,76)>6.9 then
  verbose("At Merchant & Mender. Moving to Ocean fishing.")
  if movement_method=="visland" then
    VislandRoute("H4sIAAAAAAAACuVQXUvDQBD8K2Wfz3CJqWnurVSFPtSPIsQqPhztSg+825LbKhLy393UK0XxH/g2MzsMs9PBjfUIBpa4s64dMY1ojTaAgsZ+7sgFjmCeO7ij6NhRANPBI5izUp9nuihLBSswZaYVPIGpRMt1PemFUcD5JZi8qBUs7cbtJacYfAt6R4+BwQiZB8bWrrlxvL0d/L+01E7qxC19HC/SQ9Je7VvEk/1QLldw5YnxGMXoE5weHInc7zFywkNwYx2fEgd2Te2Mwib9rL/FB+dxIT7dq78WGWcXdVGNf04iYJJX/2CSl/4LNp/3pk0CAAA=")
  else yield("/pcraft stop")
  end
end

::RepairSelf::
if IsNeedRepair()=="self" then
  while not IsAddonVisible("Repair") do
    yield("/generalaction repair")
    yield("/wait 0.5")
  end
  yield("/callback Repair true 0")
  yield("/wait 0.1")
  if IsAddonVisible("SelectYesno") then
    yield("/callback SelectYesno true 0")
    yield("/wait 0.1")
  end
  while GetCharacterCondition(39) do yield("/wait 1") end
  yield("/wait 1")
  yield("/callback Repair true -1")
end

::WaitForBoat::
if TimeCheck()=="queue" then goto PreQueue end
while TimeCheck()~="queue" do
  verbose("Still running! ".. 60 - os.date("!*t").min .." minutes until the next boat.", true)
  yield("/wait 1.005")
end

::BotPause::
notabot = math.random(2,8)
verbose("Randomly waiting "..notabot.." seconds. Soooooooo human.")
yield("/wait "..notabot)

::PreQueue::
boat_route = string.lower(boat_route)
if string.find(boat_route,"random") then
  q = math.random(0,1)
elseif string.find(boat_route,"ruby") or string.find(boat_route,"river") or string.find(boat_route,"kugane") then
  q = 1
else
  q = 0
end

JobCheck()

::Queue::
if IsInZone(129) and GetDistanceToPoint(-410,4,76)<6.9 then
  verbose("Queueing up!")
  if q==1 then
    verbose("Ruby route")
  else
    verbose("Indigo route")
  end
  while GetCharacterCondition(91, false) do
    if GetTargetName()~="Dryskthota" then
      yield("/target Dryskthota")
    elseif GetCharacterCondition(32, false) then
      yield("/lockon on")
      yield("/interact")
    elseif IsAddonVisible("Talk") then
      yield("/click Talk Click")
    elseif IsAddonReady("SelectString") then
      if GetSelectStringText(0)=="Register to board." then
        yield("/callback SelectString true 0")
      else
        yield("/callback SelectString true "..q)
      end
    elseif IsAddonVisible("SelectYesno") then
      yield("/callback SelectYesno true 0")
    end
    yield("/wait 0.511")
  end
else
  verbose("Zone: "..GetZoneID())
  if IsInZone(129) then verbose("Distance from Dryskthota: "..GetDistanceToPoint(-410,4,76)) end
  verbose("That's not gonna work, chief.")
  yield("/pcraft stop")
end
yield("/lockon off")

::Enter::
while GetCharacterCondition(91) do
  verbose("Waiting for queue to pop.", true)
  if IsAddonVisible("ContentsFinderConfirm") then
    JobCheck()
    yield("/callback ContentsFinderConfirm true 8")
  end
  yield("/wait 1.007")
end
WaitReady(3)
if not ( IsInZone(900) or IsInZone(1163) ) then
  verbose("Landed in zone "..GetZoneID()..", which isn't ocean fishing!")
  yield("/pcraft stop")
end

::PrepareRandom::
need_to_move_to_rail = true
math.randomseed(os.time())
move_y = math.random(-11000,5000)/1000
move_z = 6.750
if GetPlayerRawXPos()>0 then move_x = 7.5 else move_x = -7.5 end
if move_x==7.5 and move_y<-2 and move_y>-4 then goto PrepareRandom end
verbose("move_x: "..move_x)
verbose("move_y: "..move_y)

::OnBoat::
start_fishing_attempts = 0
is_changed_zone = true
while ( IsInZone(900) or IsInZone(1163) ) and IsAddonVisible("IKDResult")==false do
  ::AlwaysDo::
  AutoHookPresets()
  current_route = routes[GetCurrentOceanFishingRoute()]
  current_zone = current_route[GetCurrentOceanFishingZone()+1]
  normal_bait = ocean_zones[current_zone].normal_bait
  if GetCurrentOceanFishingTimeOfDay()==1 then spectral_bait = ocean_zones[current_zone].daytime end
  if GetCurrentOceanFishingTimeOfDay()==2 then spectral_bait = ocean_zones[current_zone].sunset end
  if GetCurrentOceanFishingTimeOfDay()==3 then spectral_bait = ocean_zones[current_zone].nighttime end
  if OceanFishingIsSpectralActive() then
    if spectral_bait then correct_bait = spectral_bait end
    if is_recast_on_spectral and not is_already_recast then
      is_already_recast = true
      yield("/ac hook")
    end
  else
    if normal_bait then correct_bait = normal_bait end
    is_already_recast = false
  end
  for _, bait in pairs(baits_list) do
    if GetCurrentBait()==bait.id then current_bait = bait end
  end
  verbose("FishingRoute: "..tostring(GetCurrentOceanFishingRoute()), true)
  verbose("FishingZone:  "..tostring(GetCurrentOceanFishingZone()), true)
  verbose("FishingTime:  "..tostring(GetCurrentOceanFishingTimeOfDay()), true)
  verbose("Zone name: "..ocean_zones[current_zone].name, true)
  verbose("Normal bait: "..normal_bait.name, true)
  verbose("Spectral bait: "..spectral_bait.name, true)
  verbose("Should now be using: "..correct_bait.name, true)
  verbose("Script thinks we're using: "..current_bait.name, true)
  verbose("time: "..string.format("%.1f", GetCurrentOceanFishingZoneTimeLeft()), true)
  EatFood()

  ::Ifs::
  ::Loading::
  if IsAddonVisible("NowLoading") or GetCharacterCondition(35) then
    DeleteAllAutoHookAnonymousPresets()
    is_changed_zone = true
    WaitReady(2)

  ::ShouldntNeed::
  elseif IsAddonVisible("IKDResult") then
    break

  elseif wasabi_mode and is_changed_zone then
    if math.floor(GetPlayerRawXPos())~=7 and math.floor(GetPlayerRawXPos())~=-7 then
      need_to_move_to_rail = true
      wasabi_move = true
    end

  ::Movement::
  elseif need_to_move_to_rail then
    while is_wait_to_move and ( GetCurrentOceanFishingZoneTimeLeft()>420 or GetCurrentOceanFishingZoneTimeLeft()<0 ) do
      yield("/wait 0.244")
    end
    if GetPlayerRawXPos()>0 then move_x = 7.5 else move_x = -7.5 end
    if wasabi_move then
      move_y = math.floor(GetPlayerRawZPos()*1000)/1000
      verbose("Resetting move_y to: "..move_y)
    end
    yield("/visland moveto "..move_x.." "..move_z.." "..move_y)
    yield("/wait 0.512")
    move_tick = 0
    while IsMoving() and move_tick <= 5 do
      if GetCurrentOceanFishingZoneTimeLeft()<420 and GetCurrentOceanFishingZoneTimeLeft()>0 then
        move_tick = move_tick + 0.1
      end
      if is_adjust_z then
        move_z = math.floor(GetPlayerRawYPos()*1000)/1000
        yield("/visland moveto "..move_x.." "..move_z.." "..move_y)
      end
      yield("/wait 0.119")
    end
    yield("/visland moveto "..move_x*2 .." "..move_z.." "..move_y)
    yield("/wait 0.200")
    yield("/visland stop")
    need_to_move_to_rail = false

  ::DoNothing::
  elseif GetCurrentOceanFishingZoneTimeLeft()<30 then
    if current_zone<2 and is_spam_next_zone_bait then 
      verbose("Next zone bait: "..ocean_zones[current_zone+1].normal_bait.name) 
    end

  elseif GetCurrentOceanFishingZoneTimeLeft()>420 then
    yield("/wait 0.05")

  ::BagCheck::
  elseif GetInventoryFreeSlotCount()<=2 then
    for _, command in pairs(bags_full) do
      if command=="/leaveduty" then LeaveDuty() end
      verbose("Running: "..command)
      yield(command)
    end

  ::BaitSwitch::
  elseif bait_and_switch and ( ( current_bait.id~=correct_bait.id and GetItemCount(correct_bait.id)>1 ) or ( current_bait.id==baits_list.versatile and GetItemCount(correct_bait.id)<1 ) ) then
    if GetItemCount(correct_bait.id)>1 and current_bait.id~=correct_bait.id then
      yield("/tweaks e baitcommand")
      verbose("Switching bait to: "..correct_bait.name)
      bait_switch_failsafe = 0
      while GetCurrentBait()~=correct_bait.id and GetCurrentOceanFishingZoneTimeLeft()>30 and GetCurrentOceanFishingZoneTimeLeft()<420 do
        yield("/bait "..correct_bait.name)
        yield("/wait 0.1014")
        if bait_switch_failsafe > 13 then
          for i=1,20 do
            verbose("Bait switch didn't work! Please report this.")
          end
          break
        elseif is_fishing_animation_noticed then
          if GetCharacterCondition(42, false) then
            is_fishing_animation_noticed = false
            bait_switch_failsafe = bait_switch_failsafe + 1
          end
        elseif GetCharacterCondition(42) then
          is_fishing_animation_noticed = true
        end
      end
    else
      verbose("Out of "..correct_bait.name)
      yield("/bait Versatile Lure")
    end
    current_bait = correct_bait
    is_changed_bait = true
    SetAutoHookState(true)

  ::StartFishing::
  elseif --[[ GetCurrentOceanFishingZoneTimeLeft()>30 and ]] GetCharacterCondition(43, false) then
    if not is_changed_bait and not is_changed_zone then
      not_fishing_tick = 0
      while GetCharacterCondition(43, false) and not_fishing_tick<1.5 do
        yield("/wait 0.108")
        not_fishing_tick = not_fishing_tick + 0.1
      end
    end
    is_changed_bait = false
    is_changed_zone = false
    if start_fishing_attempts>9 then
      yield("/echo [FishingRaid] Something has gone horribly wrong!")
      LeaveDuty()
      WaitReady(1,true)
      yield("/ays multi e")
      yield("/pcraft stop")
    elseif start_fishing_attempts>6 then
      if math.floor(GetPlayerRawXPos())~=7 and math.floor(GetPlayerRawXPos())~=-7 then
        verbose("Not standing at the side of the boat? Lets fix that.")
        need_to_move_to_rail = true
        wasabi_move = true
      end
    elseif start_fishing_attempts>1 then
      current_bait = ""
    elseif GetCharacterCondition(43, false) then
      start_fishing_attempts = start_fishing_attempts + 1
      verbose("Starting fishing from: X: ".. math.floor(GetPlayerRawXPos()*1000)/1000 .." Y or Z, depending on which plugin you ask: ".. math.floor(GetPlayerRawZPos()*1000)/1000 )
      verbose("Should now be using: "..correct_bait.name)
      verbose("Script thinks we're using: "..current_bait.name)
      yield("/ac Cast")
      SetAutoHookState(true)
    end

  else
    SetAutoHookState(true)
    start_fishing_attempts = 0
  end
  yield("/wait 1.010")
end

::FishingResults::
score_screen_wait = 500-(((score_screen_delay//60)*100)+(score_screen_delay%60)+40)
if IsAddonVisible("IKDResult") then
  result_timer = 501
  while IsAddonVisible("IKDResult") do
    result_raw = string.gsub(GetNodeText("IKDResult",4),"%D","")
    result_timer = tonumber(result_raw)
    if type(result_timer)~="number" then result_timer = 501 end
    if result_timer<=(score_screen_wait) then
      points_earned_string = ""
      for i=9, 1, -1 do
        if type(GetNodeText("IKDResult",27,i))=="string" then
          points_earned_string = GetNodeText("IKDResult",27,i)..points_earned_string
        end
      end
      points_earned = tonumber(points_earned_string)
      yield("/callback IKDResult true 0")
      yield("/wait 1")
    end
    yield("/wait 0.266")
  end
  verbose("Points earned: "..points_earned)
end

::DoneFishing::
DeleteAllAutoHookAnonymousPresets()
RunDiscard(1)
WaitReady(3, false, 72)
if IsInZone(129) then
  yield("/echo Landed at: X:"..math.floor(GetPlayerRawXPos()*1000)/1000 .." Z:"..math.floor(GetPlayerRawYPos()*1000)/1000 .." Y:"..math.floor(GetPlayerRawZPos()*1000)/1000)
else
  goto AtWaitLocation
end

::SpendScrips::
if type(spend_scrips_when_above)=="number" then
  if GetItemCount(25200)>spend_scrips_when_above then
    verbose("Spending scrips on "..scrip_item_to_buy)
    while IsInZone(129) and GetDistanceToPoint(-407,3.1,67.5)>6.9 do
      if IsMoving() then while IsMoving() do yield("/wait 0.1") end
      elseif GetDistanceToPoint(-410,4,76)<6.9 then  --ocean
        yield("/visland moveto -407 4 71")
      elseif GetDistanceToPoint(-408.5,3.1,56)<6.9 or GetDistanceToPoint(-396,4.3,69)<6.9 or GetDistanceToPoint(-398,3.1,75.5)<6.9 then
        yield("/visland moveto -404 4 71")  --boardwalk
      end
      yield("/wait 0.1")
    end
    yield("/visland stop")
    while IsAddonReady("InclusionShop")==false do
      if GetTargetName()~="Scrip Exchange" then
        yield("/target Scrip Exchange")
      elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
        yield("/visland stop")
      else
        yield("/lockon on")
        yield("/facetarget")
        yield("/interact")
      end
      yield("/wait 0.521")
    end
    yield("/lockon off")
    yield("/callback InclusionShop true 12 "..scrip_category)
    yield("/wait 0.522")
    yield("/callback InclusionShop true 13 "..scrip_subcategory)
    yield("/wait 1.021")
    scrips_raw = string.gsub(GetNodeText("InclusionShop", 21),"%D","")
    scrips_owned = tonumber(scrips_raw)
    for item=21, 36 do
      scrip_shop_item_name = string.gsub(GetNodeText("InclusionShop", 5, item, 12),"%G","")
      if scrip_shop_item_name==string.gsub(scrip_item_to_buy,"%G","") then
        price_raw = string.gsub(GetNodeText("InclusionShop", 5, item, 5, 1),"%D","")
        scrip_shop_item_price = tonumber(price_raw)
        scrip_number_to_buy = scrips_owned//scrip_shop_item_price
        yield("/callback InclusionShop true 14 "..item-21 .." "..scrip_number_to_buy)
        yield("/wait 1.022")
        if IsAddonVisible("ShopExchangeItemDialog") then
          yield("/callback ShopExchangeItemDialog true 0")
          yield("/wait 1.023")
        end
        break
      end
    end
    yield("/callback InclusionShop true -1")
  end
end

::WaitLocation::
if type(wait_location)=="string" then
  if string.find(string.lower(wait_location),"inn") then
    verbose("Returning to inn.")
    RunDiscard(2)
    ::MoveToArcanist::
    if IsInZone(129) and GetDistanceToPoint(-408,4,75)<20 then
      verbose("Near ocean fishing. Moving to arcanists guild.")
      if movement_method=="visland" then
        VislandRoute("H4sIAAAAAAAACuWUy0pDMRCGX6XM+hhyv5ydeIEualWEesFFaFMb8CTSkypS+u4m8ZR24RPYrDLz/0wmH8Ns4cZ2DlqYzp0No6XvVz68jVIc2fXcBt8naGBmvz+iD6mH9mULt7H3yccA7RYeoT1jhiAtjWrgCVqBcAPP0EqBBKeC7nIUgxtfQpuFe7vwm1yFFtckfrrOhVSVcUhubedp5tNqOriPc0OXuZl+Fb/2Su4iV1va994d7LU10sBVF9P+4XFy3XA9r44huNu4Pg33UnhmfTpULNF1XF/EsBh+jH+TD75zk+zDu+YPHtogJhkbeJh8KFeVCtdZ4YbzU8QiDCJYY1m5aITL4XssQhqhT5IKQ4zxMh+ZiqrTolmlkhVsuNIniYXjvFOo5BULIYULF79YKFKYSaKOsBBqTgUMU4hLqo7BkLJrChmOtJGG/H8wr7sfPGs0+LgGAAA=")
      else yield("/pcraft stop")
      end
    end
    ::AethernetToAftcastle::
    if IsInZone(129) and GetDistanceToPoint(-335,12,53)<9 then
      verbose("At arcanists guild. Aethernet to aftcastle.")
      while IsInZone(129) do
        if IsAddonVisible("TelepotTown") then
          yield("/callback TelepotTown true 11 1u")
        elseif GetTargetName()~="Aethernet shard" then
          yield("/target Aethernet shard")
        elseif GetDistanceToTarget()<4 then
          yield("/interact")
        else
          yield("/lockon on")
          yield("/automove on")
        end
        yield("/wait 0.531")
      end
      WaitReady(3)
    end
    RunDiscard(3)
    ::MoveToInn::
    if IsInZone(128) and GetDistanceToPoint(14,40,71)<9 then
      verbose("Near aftcastle. Moving to inn.")
      if movement_method=="visland" then
        VislandRoute("H4sIAAAAAAAACuWT22rDMAyGX6XoOjNyYseHu7ID9KI7Mei6sYuwetSw2CNxN0bou09JU1rYnmDVlX5JyNKH3MF1VTuwMHVp7Zrg0iTFiQ8BMlhU3x/Rh9SCfe7gNrY++RjAdvAIliNTyCWKDJZgBTLsjdQTWCWYQNRiSyoGN7sAixncVyu/oV45IzGPn652IQ2ZWUiuqV7Twqf1zVh9HBtHpJHadfzaZ2gW6vZWvbfuUD4MyDO4rGPaPzxLrh7d6VAxiruNa9Po940XlU+Hjr26is15DKtxb9wFH3zt5lSH2+w3FcKgi7LM/6LCmVJSmdOjcoaMK11oLsqBS2GY6a0cuIiCFWgwl6cHhnYzXJpc77FIThcyUOGKqOTmFKnwgnGt6RsdH4uWOyw505Jj+e9/0cv2ByD0KqubBQAA")
      else yield("/pcraft stop")
      end
    end
    ::EnterInn::
    while IsInZone(128) and GetDistanceToPoint(13,40,13)<4 do
      verbose("Near inn. Entering.")
      if GetDistanceToPoint(13,40,13)<4 then
        if GetTargetName()~="Mytesyn" then
          yield("/target Mytesyn")
        elseif GetCharacterCondition(32, false) then
          yield("/lockon on")
          yield("/interact")
        elseif IsAddonVisible("Talk") then
          yield("/click Talk Click")
        elseif IsAddonVisible("SelectString") then
          yield("/callback SelectString true 0")
        elseif IsAddonVisible("SelectYesno") then
          yield("/callback SelectYesno true 0")
        end
      end
      yield("/wait 0.532")
    end
    WaitReady(3, false, 32, 177)
  elseif string.find(string.lower(wait_location),"fc")
  or string.find(string.lower(wait_location),"private")
  or string.find(string.lower(wait_location),"personal")
  or string.find(string.lower(wait_location),"apartment")
  or string.find(string.lower(wait_location),"shared")
  then
    if string.find(string.lower(wait_location),"fc") then
      verbose_string = "FC house"
      tp_location = "Estate Hall (Free Company)"
    elseif string.find(string.lower(wait_location),"private") or string.find(string.lower(wait_location),"personal") then
      verbose_string = "private house"
      tp_location = "Estate Hall (Private)"
    elseif string.find(string.lower(wait_location),"apartment") then
      verbose_string = "apartment"
      tp_location = "Apartment"
    elseif string.find(string.lower(wait_location),"shared") then
      verbose_string = "shared estate"
      if string.find(string.lower(wait_location), "Shared Estate (Plot ") then
        tp_location = wait_location
      else
        tp_location = "Shared Estate "
      end
    end
    verbose("Returning to "..verbose_string..".")
    while not ( IsInZone(339) or IsInZone(340) or IsInZone(341) or IsInZone(641) or IsInZone(979) ) do
      if GetCharacterCondition(27, false) and not IsPlayerOccupied() then
        yield("/tp "..tp_location)
      else
        WaitReady()
      end
      yield("/wait 0.31")
      RunDiscard(2)
    end
    verbose("Arrived at "..verbose_string..". Entering.")
    yield("/automove on")
    yield("/wait 1.033")
    yield("/automove off")
    yield("/ays het")
    WaitReady(3, false)
    verbose("Inside "..verbose_string.." (hopefully)")
  end
end

WaitReady()

::AtWaitLocation::
::Desynth::
if is_desynth then
  yield("/tweaks e UiAdjustments@ExtendedDesynthesisWindow")
  verbose("Running desynthesis.")
  verbose("Do not touch the desynth window!")
  is_doing_desynth = true
  failed_click_tick = 0
  open_desynth_attempts = 0
  desynth_last_item = nil
  desynth_prev_item = nil
  is_clicked_desynth = false
  item_name = nil
  yield("/wait 0.1")
  while is_doing_desynth do
    verbose("Desynth is running...", true)
    verbose("Do not touch the desynth window!", true)
    if not IsAddonVisible("SalvageItemSelector") then
      verbose("Opening desynth window")
      yield("/generalaction desynthesis")
      open_desynth_attempts = open_desynth_attempts + 1
      if open_desynth_attempts>3 then
        is_doing_desynth = false
        is_clicked_desynth = false
        is_desynth = false
        desynth_last_item = nil
        desynth_prev_item = nil
        item_name = nil
        verbose("Tried too many times to open desynth, and it hasn't worked. Giving up and moving on.")
      end
    elseif desynth_prev_item~=nil and item_name and desynth_last_item==item_name and desynth_prev_item==item_name then
      verbose("Repeat item bug?")
      verbose("Closing desynth window")
      SafeCallback("SalvageItemSelector", true, -1)
      yield("/wait 1")
    elseif not IsAddonReady("SalvageItemSelector") then
      yield("/wait 0.541")
    elseif IsAddonVisible("SalvageDialog") then
      while not IsAddonReady("SalvageDialog") do yield("/wait 0.1") end
      --if GetNodeText("SalvageDialog",21)==item_name then
      if string.gsub(GetNodeText("SalvageDialog",19),"%D","")~="000" then
        SafeCallback("SalvageDialog", true, 13, true)
        SafeCallback("SalvageDialog", true, 0)
        is_clicked_desynth = false
      else
        verbose("Empty SalvageDialogue window!")
        verbose("Ending desynth!")
        is_doing_desynth = false
        SafeCallback("SalvageDialog", true, -1)
        SafeCallback("SalvageItemSelector", true, -1)
      end
    elseif IsAddonVisible("SalvageResult") then
      SafeCallback("SalvageResult", true, 1)
    elseif IsAddonVisible("SalvageAutoDialog") then
      is_clicked_desynth = false
      if string.sub(GetNodeText("SalvageAutoDialog", 27),1,1)=="0" then SafeCallback("SalvageAutoDialog", true, -1) end
    elseif GetCharacterCondition(39) then
      is_clicked_desynth = false
    elseif is_clicked_desynth then
      failed_click_tick = failed_click_tick + 1
      if failed_click_tick>4 then
        is_doing_desynth = false
        verbose("Desynth probably finished!")
        verbose("Closing desynth window")
        SafeCallback("SalvageItemSelector", true, -1)
        yield("/wait 2")
        failed_click_tick = 0
      end
    elseif IsNodeVisible("SalvageItemSelector",1,13) or IsNodeVisible("SalvageItemSelector",1,12,2) then
      verbose("Desynth finished!")
      is_doing_desynth = false
      SafeCallback("SalvageItemSelector", true, -1)
    else
      for i=1,20 do
        if string.gsub(GetNodeText("SalvageItemSelector", 3, 2, 8),"%W","")~="" then
          break
        else
          yield("/wait 0.09")
        end
      end
      for list=2, 16 do
        --item_name_raw = string.gsub(GetNodeText("SalvageItemSelector", 3, list, 8),"%W","")
        desynth_prev_item = desynth_last_item
        desynth_last_item = item_name
        --item_name = string.sub(item_name_raw, 3,-3)
        item_name = GetNodeText("SalvageItemSelector", 3, list, 8)
        if string.sub(GetNodeText("SalvageItemSelector", 3, 2, 2),-1,-1)==")" then
          item_level_raw = string.sub(GetNodeText("SalvageItemSelector", 3, list, 2),1,3)
        else
          item_level_raw = string.sub(GetNodeText("SalvageItemSelector", 3, list, 2),-3,-1)
          item_level_raw = string.gsub(item_level_raw,"%d+/","")
        end
        item_level = string.gsub(item_level_raw,"%D","")
        item_type = GetNodeText("SalvageItemSelector", 3, list, 5)
        if item_level=="1" and item_type=="Culinarian" then
          verbose("Desynthing: "..item_name)
          verbose("item_level: "..item_level, true)
          verbose("item_type: "..item_type, true)
          SafeCallback("SalvageItemSelector", true, 12, list-2)
          is_clicked_desynth = true
          break
        elseif list==16 then
          is_doing_desynth = false
          verbose("Desynth finished!")
          break
        end
      end
    end
    yield("/wait 0.540")
  end
  SafeCallback("SalvageItemSelector", true, -1)
end

::WrapUp::
RunDiscard()
verbose("You did a good job today!")
verbose("Points earned: "..points_earned)

::StartAR::
if not is_single_run then
  if fishing_character=="auto" then fishing_character = GetCharacterName(true) end
  if is_ar_while_waiting then
    verbose("Enabling AutoRetainer while waiting.")
    if ARRetainersWaitingToBeProcessed() then
      target_tick = 1
      while GetCharacterCondition(50, false) do
        if target_tick > 9 then
          break
        elseif string.lower(GetTargetName())~="summoning bell" then
          verbose("Finding summoning bell...")
          yield("/target Summoning Bell")
          target_tick = target_tick + 1
        elseif GetDistanceToTarget()>5 then
          yield("/lockon on")
          yield("/automove on")
        else
          yield("/automove off")
          yield("/interact")
        end
        yield("/lockon on")
        yield("/wait 0.511")
      end
      if GetCharacterCondition(50) then
        yield("/lockon off")
        yield("/ays e")
        while not IsAddonVisible("RetainerList") do yield("/wait 0.100") end
        yield("/wait 0.4")
      end
    end
    yield("/ays multi e")
  else
    verbose("Waiting for the next boat.")
  end
  goto MainWait
end