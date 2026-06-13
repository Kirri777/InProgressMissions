local addon = _G.InProgressMissions

function addon:GarrisonLandingPageReport_SetElementInitializer()
	local view = self.GarrisonLandingPageReportList.ScrollBox:GetView()
	view:GetPadding():SetRight(self.GarrisonLandingPageReportList.ScrollBar:GetWidth())
	view.elementExtent = nil
	view:SetElementInitializer("GarrisonLandingPageReportMissionTemplateIPM", function(button, elementData)
		if self.GarrisonLandingPageReport.selectedTab == self.GarrisonLandingPageReport.InProgress then
			self:MissionButton_Update(button, elementData)
		else
			GarrisonLandingPageReportList_InitButtonAvailable(button, elementData)
			if _G.MasterPlan then
				button.Status:Hide()
			else
				local reward = (button.Reward3:IsShown() and button.Reward3) or (button.Reward2:IsShown() and button.Reward2) or (button.Reward1:IsShown() and button.Reward1)
				button.Status:SetPoint("BOTTOMRIGHT", reward, "BOTTOMLEFT", -4, 0)
				button.Status:SetText(elementData.offerEndTime and RAID_INSTANCE_EXPIRES:format(elementData.offerTimeRemaining) or nil)
				button.Status:Show()
			end
		end
	end)
end

function addon:GarrisonLandingPageReportList_Update(fullUpdate)
	local items = self.GarrisonLandingPageReportList.items
	if not items then return end

	if #items == 0 then
		local emptyMissionText = _G.GarrisonLandingPage.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison and COVENANT_MISSIONS_EMPTY_IN_PROGRESS or GARRISON_EMPTY_IN_PROGRESS_LIST
		self.GarrisonLandingPageReportList.EmptyMissionText:SetText(emptyMissionText)
	else
		self.GarrisonLandingPageReportList.EmptyMissionText:SetText(nil)
	end

	local dataProvider = self.scrollBox:GetDataProvider()
	if fullUpdate or not dataProvider or #items ~= dataProvider:GetSize() then
		dataProvider = CreateDataProvider(items)
		self.scrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
	else
		for _, button in pairs(self.scrollBox:GetView():GetFrames()) do
			self:MissionButton_Update(button, button:GetMission())
		end
	end
end

function addon:GarrisonLandingPageReportList_UpdateItems()
	self:UpdateMissions()
	local isTabProgress = self.GarrisonLandingPageReport.selectedTab == self.GarrisonLandingPageReport.InProgress
	if not isTabProgress then
		self:HideMenu()
	end

	local garrTypeID = _G.GarrisonLandingPage.garrTypeID
	if not garrTypeID then return end
	local followerType = GetPrimaryGarrisonFollowerType(garrTypeID)
	local availableMissions = followerType and C_Garrison.GetAvailableMissions(followerType)
	self.GarrisonLandingPageReportList.AvailableItems = availableMissions and GarrisonLandingPageReportMission_FilterOutCombatAllyMissions(availableMissions) or {}
	Garrison_SortMissions(self.GarrisonLandingPageReportList.AvailableItems)

	local items = self.GarrisonLandingPageReportList.items or {}
	wipe(items)
	for _, mission in ipairs(self.missions) do
		tinsert(items, CopyTable(mission, true))
	end
	for _, mission in ipairs(self.altMissions) do
		mission.isAltMission = true
		tinsert(items, CopyTable(mission, true))
	end
	self.GarrisonLandingPageReportList.items = items

	local availableString = garrTypeID == Enum.GarrisonType.Type_9_0_Garrison and COVENANT_MISSIONS_AVAILABLE or GARRISON_LANDING_AVAILABLE
	self.GarrisonLandingPageReport.Available.Text:SetFormattedText(availableString, #self.GarrisonLandingPageReportList.AvailableItems)

	if (self.GarrisonLandingPageReport.selectedTab == self.GarrisonLandingPageReport.InProgress) then
		self:GarrisonLandingPageReportList_Update(true)
	else
		GarrisonLandingPageReportList_UpdateAvailable()
	end
end

function addon:UpdateItemInfoHandler(...)
	if self.scrollBox:IsVisible() then
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	end
end

function addon:GET_ITEM_INFO_RECEIVED(event, ...)
	if not self.GarrisonLandingPageReport:IsShown() then return end
	local items
	local selectedTab = self.GarrisonLandingPageReport.selectedTab
	if selectedTab == self.GarrisonLandingPageReport.InProgress then
		items = self.GarrisonLandingPageReportList.items
	elseif selectedTab == self.GarrisonLandingPageReport.Available then
		items = self.GarrisonLandingPageReportList.AvailableItems
	end
	if not items then return end

	for _, button in pairs(self.scrollBox:GetView():GetFrames()) do
		self:Rewards_Update(button, button:GetMission())
	end
end
