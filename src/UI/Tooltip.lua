local addon = _G.InProgressMissions
local GFT = addon.GFT

local function AddRewardText(item, rewardType)
	for id, reward in pairs(item[rewardType]) do
		if (reward.quality) then
			GameTooltip:AddLine(addon:QualityColorText(reward.title or _G.UNKNOWN, reward.quality + 1))
		elseif (reward.itemID) then
			local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID)
			if itemName then
				itemName = addon:MakeIcon(itemTexture, addon:QualityColorText(itemName, itemQuality))
				local quantity = reward.quantity and reward.quantity > 1 and FLAG_COUNT_TEMPLATE:format(reward.quantity) or ""
				if quantity then
					itemName = itemName.." "..quantity
				end
				GameTooltip:AddLine(itemName, 1, 1, 1)
			end
		elseif (reward.followerXP) then
			GameTooltip:AddLine(addon:QualityColorText(GARRISON_REWARD_XP_FORMAT:format(BreakUpLargeNumbers(reward.followerXP)), reward.followerXP >= addon.FOLLOWER_XP_THRESHOLD and 2 or 1))
		elseif (reward.currencyID and reward.quantity) then
			if (reward.currencyID == 0) then
				GameTooltip:AddLine(GetMoneyString(reward.quantity), 1, 1, 1)
			else
				local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(reward.currencyID)
				if currencyInfo then
					GameTooltip:AddLine(addon:MakeIcon(currencyInfo.icon)..addon:QualityColorText(" "..currencyInfo.name.." ", currencyInfo.quality or 1)..FLAG_COUNT_TEMPLATE:format(reward.quantity), 1, 1, 1)
				else
					GameTooltip:AddLine(_G.UNKNOWN.." ".._G.CURRENCY.." ("..reward.currencyID..") "..FLAG_COUNT_TEMPLATE:format(reward.quantity), 1, 1, 1)
				end
			end
		else
			GameTooltip:AddLine(reward.title, 1, 1, 1)
		end
	end
end

function addon:SetupMissionInfoTooltip(item, anchorFrame)
	if _G.CovenantMissionFrame and _G.CovenantMissionFrameFollowers:IsVisible() then
		return
	end

	if anchorFrame then
		GameTooltip:SetOwner(anchorFrame, "ANCHOR_BOTTOMRIGHT", 2, anchorFrame:GetHeight() * 2)
		GameTooltip:ClearLines()
	else
		GameTooltip:ClearLines()
	end

	if (item.isBuilding) then
		GameTooltip:SetText(item.name)
		GameTooltip:AddLine(string.format(GARRISON_BUILDING_LEVEL_LABEL_TOOLTIP, item.buildingLevel), 1, 1, 1)
		if(item.isComplete) then
			GameTooltip:AddLine(COMPLETE, 1, 1, 1)
		else
			GameTooltip:AddLine(tostring(item.timeLeft), 1, 1, 1)
		end
		GameTooltip:Show()
		return
	end

	local isAutoCombatant = item.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower -- Shadowlands

	GameTooltip:SetText(item.isComplete and ERR_QUEST_OBJECTIVE_COMPLETE_S:format(item.name) or item.name)

	local color = item.isRare and ITEM_QUALITY_COLORS[3] or ITEM_QUALITY_COLORS[1]
	if isAutoCombatant then
		GameTooltip:AddLine(format(addon.FORMAT_TOOLTIP_LEVEL, item.missionScalar), color.r, color.g, color.b)
	elseif item.followerTypeID == GFT.FollowerType_6_0_Boat then
		-- No level display for boats
	else
		if item.iLevel and item.iLevel > 0 then
			GameTooltip:AddLine(format(addon.FORMAT_TOOLTIP_ITEMLEVEL, item.level, item.iLevel), color.r, color.g, color.b)
		elseif item.level then
			GameTooltip:AddLine(format(addon.FORMAT_TOOLTIP_LEVEL, item.level), color.r, color.g, color.b)
		end
	end

	if item.isComplete then
		if item.missionEndTime then
			GameTooltip:AddLine(DATE_COMPLETED:format(date("%a,%H:%M", item.missionEndTime)), 1, 1, 1)
		end
	else
		if item.missionEndTime then
			GameTooltip:AddLine(COMPLETE..": "..date("%a,%H:%M", item.missionEndTime), 1, 1, 1)
		end
	end

	local successChance = item.successChance or item.missionID and C_Garrison.GetMissionSuccessChance(item.missionID)

	if next(item.rewards) then
		GameTooltip:AddLine(" ")
		local caption = REWARDS
		if not isAutoCombatant and successChance then
			caption = caption..(" (%d%%)"):format(math.min(successChance, 100))
		end
		GameTooltip:AddLine(caption)
		AddRewardText(item, "rewards")

		if item.overmaxRewards and next(item.overmaxRewards) and item.hasBonusEffect then
			local caption = BONUS_REWARDS
			if successChance and successChance > 100 then
				caption = caption..(" (%d%%)"):format(successChance - 100)
			end
			GameTooltip:AddLine(caption)
			AddRewardText(item, "overmaxRewards")
		end
	end

	if (item.followers ~= nil) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(isAutoCombatant and _G.COVENANT_MISSIONS_FOLLOWERS or item.followerTypeID == GFT.FollowerType_6_0_Boat and _G.GARRISON_SHIPYARD_FOLLOWERS or _G.GARRISON_FOLLOWERS)
		local id, info
		local leftText, rightText
		local icon
		local followerInfo = item.followerInfo or addon:GetMissionFollowerAbilitiesInfo(item)
		for i = 1, #(item.followers) do
			id = item.followers[i]
			info = type(followerInfo) == "table" and followerInfo[id] or nil
			if type(info) == "table" then
				leftText = nil
				rightText = nil
				if isAutoCombatant then
					leftText = addon:MakeIcon(info.portraitIconID)..addon:QualityColorText(addon.FORMAT_LEVEL:format(info.level), info.quality or 2).." "..info.name
					for i, icon in ipairs(info.abilities) do
						rightText = addon:AddIcon(rightText, icon)
					end
				elseif (info.followerTypeID >= GFT.FollowerType_7_0_GarrisonFollower) and info.abilities then
					leftText = addon:MakeIcon(info.portraitIconID)
					if info.isTroop then
						leftText = leftText.." "..addon:QualityColorText(info.name, info.quality)
					else
						if info.iLevel then
							leftText = leftText..addon:QualityColorText(addon.FORMAT_LEVEL:format(info.iLevel), info.quality or 2)
						end
						leftText = addon:AddIcon(leftText, C_Garrison.GetFollowerAbilityIcon(info.abilities[1]), info.name)
					end
					for i = 2, 6 do
						if info.abilities[i] then
							icon = C_Garrison.GetFollowerAbilityIcon(info.abilities[i])
							if icon then
								rightText = addon:AddIcon(rightText, icon)
							end
						end
					end
				elseif info.followerTypeID == GFT.FollowerType_6_0_Boat then
					leftText = ""
					if type(info.abilities) == "table" then
						for k, abilityID in ipairs(info.abilities) do
							if C_Garrison.GetFollowerAbilityIsTrait(abilityID) then
								leftText = leftText..addon:MakeIcon(C_Garrison.GetFollowerAbilityIcon(abilityID))
							else
								rightText = addon:AddIcon(rightText, C_Garrison.GetFollowerAbilityIcon(abilityID))
							end
						end
					end
					leftText = leftText.." "..addon:QualityColorText(info.name, info.quality or 2)
				else
					leftText = addon:MakeIcon(info.portraitIconID)..addon:QualityColorText(addon.FORMAT_LEVEL:format(info.iLevel or info.level or 0), info.quality or 2).." "..info.name
					if type(info.abilities) == "table" then
						for k, abilityID in ipairs(info.abilities) do
							if type(abilityID) == "number" and not C_Garrison.GetFollowerAbilityIsTrait(abilityID) then
								rightText = addon:MakeIcon(select(3, C_Garrison.GetFollowerAbilityCounterMechanicInfo(abilityID)), rightText)
							end
						end
					end
				end
				GameTooltip:AddDoubleLine(leftText or _G.UNKNOWN, rightText or "", 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddLine(_G.UNKNOWN.."."..id, 1, 1, 1)
			end
		end
	end
	return true
end
