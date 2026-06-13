local addon = _G.InProgressMissions
local GFT = addon.GFT

function addon:GarrisonMissionFrameMissionButton_SetExpiresText(button, info)
	if self:OrderHallAddonExists() then return end

	local text = self.buttonText[button] or self:CreateButtonText(button)
	if info then
		local expire = not info.inProgress and info.offerEndTime and RAID_INSTANCE_EXPIRES:format(info.offerTimeRemaining) or nil
		if info.xp then
			expire = self:QualityColorText(GARRISON_REWARD_XP_FORMAT:format(info.xp), 1).." "..(expire or "")
		end
		text:SetText(expire)
		text:Show()
	else
		text:Hide()
	end
end

function addon:HookOrderHallMissionFrame()
	if _G.OrderHallMissionFrameMissionsListScrollFrame and not self.OrderHallMissionsScrollFrame then
		self.OrderHallMissionsScrollFrame = _G.OrderHallMissionFrameMissionsListScrollFrame
		hooksecurefunc(_G.OrderHallMissionFrame.MissionTab.MissionList, "Update", function()
			MissionsScrollFrame_SetExpiresText(self.OrderHallMissionsScrollFrame)
		end)
	end
end

function addon:HookBFAMissionFrame()
	if _G.BFAMissionFrameMissionsListScrollFrame and not self.BFAMissionsScrollFrame then
		self.BFAMissionsScrollFrame = _G.BFAMissionFrameMissionsListScrollFrame
		hooksecurefunc(_G.BFAMissionFrame.MissionTab.MissionList, "Update", function()
			MissionsScrollFrame_SetExpiresText(self.BFAMissionsScrollFrame)
		end)
	end
end

local function CovenantMissionFrameMissionsButton_OnEnter(button)
	local item = button:GetElementData()
	if not item then return end

	_G.CovenantMissionButton_OnEnter(button)

	if item.inProgress or item.canBeCompleted then
		if addon:SetupMissionInfoTooltip(item) then
			GameTooltip:Show()
		end
	end
end

local function CovenantMissionFrameMissionButtonRewards_SetStyle(button, item)
	local rAnchor
	for j, reward in ipairs(button.Rewards) do
		if reward:IsShown() then
			reward:SetScale(0.75)
			reward:ClearAllPoints()
			if j == 1 then
				reward:SetPoint("RIGHT", button, "RIGHT", -30, 0)
			elseif rAnchor then
				reward:SetPoint("RIGHT", rAnchor, "LEFT", 10, 0)
			end
			rAnchor = reward
		end
	end
	local expireText = addon.buttonText[button]
	if expireText then
		expireText:ClearAllPoints()
		expireText:SetPoint("BOTTOM", 0, 7)
		if rAnchor then
			expireText:SetPoint("RIGHT", rAnchor, "LEFT", -2, 0)
		else
			expireText:SetPoint("RIGHT", button, "RIGHT", -35, 0)
		end
	end
end

local function CovenantMissionFrameMissionButton_SetStyle(button, item)
	button:SetHeight(addon.COVENANTMISSION_BUTTONHEIGHT)
	button.ButtonBG:ClearAllPoints()
	button.ButtonBG:SetPoint("TOPLEFT", 0, 0)
	button.ButtonBG:SetPoint("BOTTOMRIGHT", 0, 0)
	button.Highlight:ClearAllPoints()
	button.Highlight:SetPoint("TOPLEFT", 0, 0)
	button.Highlight:SetPoint("BOTTOMRIGHT", 0, 0)
	button.Level:ClearAllPoints()
	button.Level:SetPoint("CENTER", button, "LEFT", 40, 0)
	button.Level:SetScale(0.9)
	button.EncounterIcon:ClearAllPoints()
	button.EncounterIcon:SetPoint("CENTER", button, "LEFT", 110, 0)
	button.EncounterIcon:SetScale(0.8)
	button.Title:SetScale(0.9)
	button.Summary:SetScale(0.85)
	button:SetScript("OnEnter", CovenantMissionFrameMissionsButton_OnEnter)
end

do -- CovenantMissionFrame Smooth Scroll
	local SCROLL_MULTIPLIER = 4
	local SCROLL_MAX = 9
	local function CovenantMissionFrame_OnMouseWheel(self, delta, ...)
		if delta == 1 or delta == -1 then
			delta = SCROLL_MULTIPLIER * delta
		end
		delta = (self.scrollBar.doScroll or 0) + delta
		if delta > SCROLL_MAX then delta = SCROLL_MAX end
		if delta < -SCROLL_MAX then delta = -SCROLL_MAX end
		self.scrollBar.doScroll = delta
	end

	local function CovenantMissionFrameScrollBar_OnUpdate(self, _, doubleScroll)
		if not self.doScroll or self.doScroll == 0 then return end
		if self.doScroll > 0 then
			HybridScrollFrame_OnMouseWheel(addon.CovenantMissionsScrollFrame, 1)
			self.doScroll = self.doScroll - 1
		else
			HybridScrollFrame_OnMouseWheel(addon.CovenantMissionsScrollFrame, -1)
			self.doScroll = self.doScroll + 1
		end
		if not doubleScroll and abs(self.doScroll) > SCROLL_MULTIPLIER then
			return CovenantMissionFrameScrollBar_OnUpdate(self, nil, true)
		end
	end

	function addon:CovenantMissionFrame_EnableSmoothScroll()
		self.CovenantMissionsScrollFrame.scrollBar:SetValueStep(9)
		self.CovenantMissionsScrollFrame.stepSize = 9
		self.CovenantMissionsScrollFrame:SetScript("OnMouseWheel", CovenantMissionFrame_OnMouseWheel)
		self.CovenantMissionsScrollFrame.scrollBar:SetScript("OnUpdate", CovenantMissionFrameScrollBar_OnUpdate)
		self.CovenantMissionsScrollFrame:HookScript("OnHide", function(self) self.scrollBar.doScroll = 0 end)
	end
end

local function CovenantMissionFrame_ShowMission(frame, info)
	for i, button in ipairs(addon.CovenantMissionRewards) do
		local reward = info.rewards[i]
		button.info = reward
		if reward then
			button:SetMouseMotionEnabled(true)
			button:SetAlpha(1)
			button.iconBorder:Hide()
			if reward.itemID then
				local name, _, rarity, _, _, _, _, _, _, icon = GetItemInfo(reward.itemLink or reward.itemID)
				button.icon:SetTexture(icon)
				local color = BAG_ITEM_QUALITY_COLORS[rarity] or BAG_ITEM_QUALITY_COLORS[1]
				button.iconBorder:SetVertexColor(color.r, color.g, color.b)
				button.iconBorder:Show()
			elseif reward.currencyID and reward.currencyID > 0 then
				local currencyName, currencyTexture, currencyQuantity, currencyQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.currencyID, reward.quantity, reward.title, reward.icon, nil)
				button.icon:SetTexture(currencyTexture)
				local color = BAG_ITEM_QUALITY_COLORS[currencyQuality] or BAG_ITEM_QUALITY_COLORS[1]
				button.iconBorder:SetVertexColor(color.r, color.g, color.b)
				button.iconBorder:Show()
			else
				button.icon:SetTexture(reward.icon or nil)
			end
		else
			button:SetMouseMotionEnabled(false)
			button:SetAlpha(0)
		end
	end
end

function addon:CovenantMissionAddRewardsIcons()
	if not _G.CovenantMissionFrame.MissionTab.MissionPage then return end
	self.CovenantMissionPage = _G.CovenantMissionFrame.MissionTab.MissionPage
	local titleText = self.CovenantMissionPage.Stage.Title
	self.CovenantMissionRewards = {}
	local reward
	reward = CreateFrame("Frame", nil, self.CovenantMissionPage.Stage.MouseOverTitleFrame)
	reward:SetScript("OnEnter", function(frame) addon:MissionButtonReward_OnEnter(frame) end)
	reward:SetScript("OnLeave", function(frame) addon:MissionButtonReward_OnLeave(frame) end)
	reward:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 0, -6)
	reward:SetSize(20, 20)
	reward.icon = reward:CreateTexture(nil, "ARTWORK", nil, 6)
	reward.icon:SetAllPoints()
	reward.iconBorder = reward:CreateTexture(nil, "ARTWORK", nil, 7)
	reward.iconBorder:SetAllPoints()
	reward.iconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
	self.CovenantMissionRewards[1] = reward
	reward = CreateFrame("Frame", nil, self.CovenantMissionPage.Stage.MouseOverTitleFrame)
	reward:SetScript("OnEnter", function(frame) addon:MissionButtonReward_OnEnter(frame) end)
	reward:SetScript("OnLeave", function(frame) addon:MissionButtonReward_OnLeave(frame) end)
	reward:SetPoint("BOTTOMRIGHT", self.CovenantMissionRewards[1], "BOTTOMLEFT", -3, 0)
	reward:SetSize(20, 20)
	reward.icon = reward:CreateTexture(nil, nil, nil, 6)
	reward.icon:SetAllPoints()
	reward.iconBorder = reward:CreateTexture(nil, "ARTWORK", nil, 7)
	reward.iconBorder:SetAllPoints()
	reward.iconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
	self.CovenantMissionRewards[2] = reward
end

function addon:HookCovenantMissionFrame()
	if _G.CovenantMissionFrame then
		if IPMDB.improveCovenantMissionUI or IPMDB.improveCovenantMissionUI == nil then
			local function InitializedFrame(_, button, elementData)
				if not button.ipm then
					button.ipm = true
					CovenantMissionFrameMissionButton_SetStyle(button, elementData)
				end
				addon:GarrisonMissionFrameMissionButton_SetExpiresText(button, elementData)
				CovenantMissionFrameMissionButtonRewards_SetStyle(button, elementData)
			end
			_G.CovenantMissionFrameMissions.ScrollBox:RegisterCallback("OnInitializedFrame", InitializedFrame, addon)

			local view = _G.CovenantMissionFrameMissions.ScrollBox:GetView()
			view.elementExtent = addon.COVENANTMISSION_BUTTONHEIGHT

			_G.CovenantMissionFrameMissions.ScrollBox.wheelPanScalar = 1.5
			_G.CovenantMissionFrameMissions.ScrollBar.wheelPanScalar = 1.5
		end
		self:CovenantMissionAddRewardsIcons()
		hooksecurefunc(_G.CovenantMissionFrame, "ShowMission", CovenantMissionFrame_ShowMission)
	end
end
