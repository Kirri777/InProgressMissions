local addon = _G.InProgressMissions
local GFT = addon.GFT

local function GetFollowerIndicator(item)
	if not item.numFollowers then return end
	local result = ""
	local id, info
	for i = 1, item.numFollowers do
		id = item.followers[i]
		info = nil
		if id and type(item.followerInfo) == "table" then
			info = item.followerInfo[id]
		elseif id then
			info = C_Garrison.GetFollowerInfo(id)
		end
		if info and info.quality ~= 4 and not info.isTroop then
			result = result..ITEM_QUALITY_COLORS[info.quality or 1].hex.._G.RANGE_INDICATOR..FONT_COLOR_CODE_CLOSE
		else
			result = result.._G.RANGE_INDICATOR
		end
	end
	return result
end

local function MissionButton_SetLayout(button, isTabProgress)
	if isTabProgress then
		button.Reward1:SetPoint("RIGHT", -68, 0)
		button.Status:SetPoint("BOTTOMRIGHT", -8, 3)
	else
		button.CompletedCheck:Hide()
		button.CompletedOverlay:Hide()
		button.NumFollowers:Hide()
		button.Reward1:SetPoint("RIGHT", -5, 0)
		button.Title:SetTextColor(unpack(addon.TITLE_COLOR_NORMAL))
		button.Level:SetTextColor(unpack(addon.TITLE_COLOR_NORMAL))
		button.BG:SetVertexColor(1, 1, 1)
	end
end

function addon:MissionButton_Update(button, item)
	local baseTime = GetServerTime()
	local stopUpdate = true

	if item.missionEndTime then
		item.isComplete = (item.missionEndTime - baseTime) < 0
	end

	local bgName
	if (item.isBuilding) then
		bgName = "GarrLanding-Building-"
		button.Status:SetText(GARRISON_LANDING_STATUS_BUILDING)
	elseif (item.followerTypeID == GFT.FollowerType_6_0_Boat) then
		bgName = "GarrLanding-ShipMission-"
	else
		bgName = "GarrLanding-Mission-"
		button.Status:SetText(nil)
	end
	button.Status:SetShown(item.isBuilding and not item.isComplete)

	bgName = bgName.."InProgress"

	button.Title:SetText(item.name)

	if (item.isComplete) then
		button.CompletedCheck:Show()
		button.CompletedOverlay:Show()
		if item.isBuilding then
			button.MissionType:SetText(GARRISON_LANDING_BUILDING_COMPLEATE)
		else
			button.MissionType:SetText(item.isAltMission and (item.charText or _G.UNKNOWN) or addon.playerNameText)
		end
		button.Title:SetWidth(290)
	else -- in progress
		button.CompletedCheck:Hide()
		button.CompletedOverlay:Hide()
		if (item.isBuilding) then
			button.MissionType:SetText(GARRISON_BUILDING_IN_PROGRESS.." - "..GARRISON_BUILDING_LEVEL_LABEL_TOOLTIP:format(item.buildingLevel))
			button.TimeLeft:SetText(item.timeLeft)
			button.TimeLeft:SetTextColor(unpack(addon.TIME_COLORS[4]))
		else
			button.MissionType:SetText(item.isAltMission and (item.charText or _G.UNKNOWN) or addon.playerNameText)
			local t = (item.missionEndTime or 0) - baseTime
			if t > 107999 then -- 30hr
				button.TimeLeft:SetFormattedText(addon.FORMAT_DURATION_DAYS, t / 86400)
			elseif t > 5459 then
				button.TimeLeft:SetFormattedText(addon.FORMAT_DURATION_HOURS, t / 3600)
			elseif t > 59 then
				button.TimeLeft:SetFormattedText(addon.FORMAT_DURATION_MINUTES, t / 60)
			else
				button.TimeLeft:SetFormattedText(addon.FORMAT_DURATION_SECONDS, t)
			end
			button.TimeLeft:SetTextColor(unpack(addon.TIME_COLORS[not t and 1 or t > 18000 and 2 or t > 5459 and 3 or t > 599 and 4 or t > 59 and 5 or 6]))
		end
		button.Title:SetWidth(322 - button.TimeLeft:GetWidth())
		stopUpdate = false
	end
	button.TimeLeft:SetShown(not item.isComplete)

	if item.followerTypeID == GFT.FollowerType_8_0_GarrisonFollower then
		button.Level:SetText(item.level)
	elseif item.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower then
		button.Level:SetText(nil)
	else
		button.Level:SetText(item.iLevel and item.iLevel > 0 and item.iLevel or item.followerTypeID ~= GFT.FollowerType_6_0_Boat and item.level or nil)
	end

	if item.typeAtlas then
		button.MissionTypeIcon:SetAtlas(item.typeAtlas)
	elseif item.typeIcon then
		button.MissionTypeIcon:SetTexture(item.typeIcon)
	else
		button.MissionTypeIcon:SetTexture(nil)
	end
	button.MissionTypeIcon:SetShown(not item.isBuilding and item.followerTypeID < GFT.FollowerType_9_0_GarrisonFollower)

	if item.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower then
		button.NumFollowers:Hide()
	else
		button.NumFollowers:SetText(GetFollowerIndicator(item))
		button.NumFollowers:Show()
	end

	button.EncounterIcon:SetShown(item.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower)
	if item.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower then
		if item.encounterIconInfo then
			button.EncounterIcon:SetEncounterInfo(item.encounterIconInfo)
		else
			button.EncounterIcon:SetEncounterInfo(C_Garrison.GetMissionEncounterIconInfo(item.missionID))
		end
	end

	button.BG:SetAtlas(bgName, true)
	if item.isAltMission then
		button.Title:SetTextColor(unpack(addon.TITLE_COLOR_ALT))
		button.Level:SetTextColor(unpack(addon.TITLE_COLOR_ALT))
	else
		button.Title:SetTextColor(unpack(addon.TITLE_COLOR_NORMAL))
		button.Level:SetTextColor(unpack(addon.TITLE_COLOR_NORMAL))
	end
	if item.followerTypeID == GFT.FollowerType_6_0_Boat then
		button.BG:SetVertexColor(0.9, 0.9, 1)
	else
		button.BG:SetVertexColor(1, 1, 1)
	end

	addon:Rewards_Update(button, item)
end

local function MissionButton_GetMission(button)
	return button:GetElementData()
end

local function MissionButton_OnShow(button)
	MissionButton_SetLayout(button, addon.GarrisonLandingPageReport.selectedTab == addon.GarrisonLandingPageReport.InProgress)
end

local function MissionButton_OnEnter(button, mouseButton)
	if addon.GarrisonLandingPageReport.selectedTab ~= addon.GarrisonLandingPageReport.InProgress then
		return GarrisonLandingPageReportMission_OnEnter(button, mouseButton)
	end

	local item = button:GetMission()
	if not item then return end
	if addon:SetupMissionInfoTooltip(item, button) then
		if button.UpdateTooltip then
			button.UpdateTooltip = nil
		else
			button.UpdateTooltip = MissionButton_OnEnter
		end
		GameTooltip:Show()
	end
end

local function MissionButton_OnClick(button, mouseButton)
	if mouseButton == "LeftButton" and IsModifiedClick("CHATLINK") then
		local item = button:GetMission()
		if not item then return end
		local missionLink = C_Garrison.GetMissionLink(item.missionID)
		if missionLink then
			ChatEdit_InsertLink(missionLink)
		end
	end
end

local function MissionButton_OnMouseUp(button, mouseButton)
	if addon.GarrisonLandingPageReport.selectedTab ~= addon.GarrisonLandingPageReport.InProgress then return end

	if mouseButton == "RightButton" then
		addon:CreateMenu()
		local anchor = addon.scrollBox
		local uiScale, x, y = _G.UIParent:GetEffectiveScale(), GetCursorPosition()
		ToggleDropDownMenu(1, nil, addon.menu, anchor:GetName(), x / uiScale - 35, y / uiScale - 5)
	end
end

function addon:MissionButtonReward_OnEnter(frame)
	if (frame.bonusAbilityID) then
		frame.UpdateTooltip = nil
		local tooltip = GarrisonBonusAreaTooltip
		GarrisonBonusArea_Set(tooltip.BonusArea, GARRISON_BONUS_EFFECT_TIME_ACTIVE, frame.bonusAbilityDuration, frame.bonusAbilityIcon, frame.bonusAbilityName, frame.bonusAbilityDescription)
		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT")
		tooltip:SetHeight(tooltip.BonusArea:GetHeight())
		tooltip:Show()
		return
	end

	local info = frame.info or frame
	if info then
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		frame.UpdateTooltip = function(f) addon:MissionButtonReward_OnEnter(f) end
		if info.itemLink then
			GameTooltip:SetHyperlink(info.itemLink)
		elseif info.itemID then
			GameTooltip:SetItemByID(info.itemID)
		elseif info.currencyID then
			if info.currencyID > 0 then
				GameTooltip:SetCurrencyByID(info.currencyID)
			else -- Money
				GameTooltip:SetText(info.title)
				GameTooltip:AddLine(GetMoneyString(info.quantity), 1, 1, 1)
				GameTooltip:Show()
			end
		else
			if info.title then
				GameTooltip:SetText(info.title)
			end
			if info.tooltip then
				GameTooltip:AddLine(info.tooltip, 1, 1, 1, true)
			end
			GameTooltip:Show()
		end
	end
end

function addon:MissionButtonReward_OnLeave(frame)
	frame.UpdateTooltip = nil
	GarrisonBonusAreaTooltip:Hide()
	GameTooltip:Hide()
end

function addon:MissionButton_OnLoad(button)
	button.MissionTypeBG = button:CreateTexture(nil, "BACKGROUND")
	button.MissionTypeBG:ClearAllPoints()
	button.MissionTypeBG:SetPoint("TOPLEFT", button.MissionType, -5, 4)
	button.MissionTypeBG:SetPoint("BOTTOMLEFT", button.MissionType, -5, -2)
	button.MissionTypeBG:SetWidth(130)
	button.MissionTypeBG:SetBlendMode("BLEND")
	button.MissionTypeBG:SetVertexColor(0, 0, 0, 0.6)
	for i, reward in ipairs(button.Rewards) do
		reward:SetScript("OnEnter", function(...) addon:MissionButtonReward_OnEnter(...) end)
		reward:SetScript("OnLeave", function(...) addon:MissionButtonReward_OnLeave(...) end)
	end
	addon:FlipTexture(button.MissionTypeBG)

	addon:CreateQuantityFont()
	for i, reward in ipairs(button.Rewards) do
		reward.Quantity:SetFontObject("GarrisonReportFontRewardQuantity")
		reward.Success:SetFontObject("GarrisonReportFontRewardQuantity")
	end

	button.GetMission = MissionButton_GetMission
	button:SetScript("OnShow", MissionButton_OnShow)
	button:SetScript("OnEnter", MissionButton_OnEnter)
	button:SetScript("OnLeave", function(...) addon:MissionButtonReward_OnLeave(...) end)
	button:SetScript("OnMouseUp", MissionButton_OnMouseUp)
	button:SetScript("OnClick", MissionButton_OnClick)
end
