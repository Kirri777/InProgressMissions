local addon = _G.InProgressMissions

local function Reward_Update(Reward, info)
	Reward.Quantity:Hide()
	Reward.IconBorder:Hide()
	Reward.Success:Hide()
	Reward.bonusAbilityID = info.bonusAbilityID
	Reward.title = nil
	Reward.tooltip = nil
	Reward.itemID = nil
	Reward.itemLink = nil
	Reward.currencyID = nil
	Reward.currencyQuantity = nil
	if (info.itemID or info.itemLink) then
		Reward.itemID = info.itemID
		Reward.itemLink = info.itemLink
		local itemTexture = select(10, GetItemInfo(info.itemID))
		Reward.Icon:SetTexture(itemTexture)
		if (info.quantity > 1) then
			Reward.Quantity:SetText(info.quantity)
			Reward.Quantity:Show()
		else
			local quality, itemLevel = select(3, GetItemInfo(info.itemLink or info.itemID))
			if (itemLevel and itemLevel > 500) then
				Reward.Quantity:SetText(ITEM_QUALITY_COLORS[quality].hex..itemLevel..FONT_COLOR_CODE_CLOSE)
				Reward.Quantity:Show()
			end
		end
		local quality = select(3, GetItemInfo(info.itemLink or info.itemID))
		local c = BAG_ITEM_QUALITY_COLORS[quality] or BAG_ITEM_QUALITY_COLORS[1]
		Reward.IconBorder:SetVertexColor(c.r, c.g, c.b)
		Reward.IconBorder:Show()
	else
		Reward.Icon:SetTexture(info.icon)
		Reward.title = info.title
		if (info.currencyID and info.quantity) then
			if (info.currencyID == 0) then
				Reward.tooltip = GetMoneyString(info.quantity)
				Reward.Quantity:SetText(BreakUpLargeNumbers(math.floor(info.quantity / COPPER_PER_GOLD)))
				Reward.Quantity:Show()
			else
				Reward.currencyID = info.currencyID
				Reward.tooltip = info.tooltip
				Reward.currencyQuantity = info.quantity
				local currencyName, currencyTexture, currencyQuantity, currencyQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(info.currencyID, info.quantity, info.title, info.icon, nil)
				Reward.tooltip = BreakUpLargeNumbers(info.quantity).." |T"..currencyTexture..":0:0:0:-1|t "
				Reward.Quantity:SetText(info.quantity)
				local c = BAG_ITEM_QUALITY_COLORS[currencyQuality]
				if c then
					Reward.IconBorder:SetVertexColor(c.r, c.g, c.b)
					Reward.IconBorder:Show()
				end
				Reward.Quantity:Show()
			end
		elseif (info.bonusAbilityID) then
			Reward.bonusAbilityID = info.bonusAbilityID
			Reward.bonusAbilityDuration = info.duration
			Reward.bonusAbilityIcon = info.icon
			Reward.bonusAbilityName = info.name
			Reward.bonusAbilityDescription = info.description
			Reward.duration = info.duration
			Reward.icon = info.icon
			Reward.name = info.name
			Reward.description = info.description
		else
			Reward.tooltip = info.tooltip
			if (info.followerXP) then
				Reward.Quantity:SetText(ITEM_QUALITY_COLORS[info.followerXP >= addon.FOLLOWER_XP_THRESHOLD and 2 or 1].hex..addon:FormatRewardNumbers(info.followerXP)..FONT_COLOR_CODE_CLOSE)
				Reward.Quantity:Show()
			end
		end
	end
end

function addon:Rewards_Update(button, item)
	local rewardIndex = 0
	if item.overmaxRewards and item.hasBonusEffect then
		if item.successChance and item.successChance > 100 then
			for rewardId, reward in pairs(item.overmaxRewards) do
				rewardIndex = rewardIndex + 1
				local Reward = button.Rewards[rewardIndex]
				Reward_Update(Reward, reward)
				Reward.Success:SetFormattedText("%d%%", item.successChance - 100)
				Reward.Success:Show()
				Reward:Show()
			end
		end
	end
	if item.rewards then
		for rewardId, reward in pairs(item.rewards) do
			rewardIndex = rewardIndex + 1
			local Reward = button.Rewards[rewardIndex]
			Reward_Update(Reward, reward)
			Reward:Show()
		end
	end
	for i = (rewardIndex + 1), #button.Rewards do
		button.Rewards[i]:Hide()
	end
	return rewardIndex
end
