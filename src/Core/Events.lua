local addon = _G.InProgressMissions
local ADDON_NAME = "InProgressMissions"
local events = addon.events

function events:ADDON_LOADED(event, name, ...)
	if name == "Blizzard_GarrisonUI" then
		self:Init()
	elseif name == ADDON_NAME then
		if _G.GarrisonLandingPageReportList then
			self:Init()
		end
		self:RegisterSettings()
	elseif name == "Blizzard_OrderHallUI" then
		-- self:HookOrderHallMissionFrame()
	elseif name and self.ORDERHALL_ADDONS[name] ~= nil then
		self.ORDERHALL_ADDONS[name] = true
	end
end

function events:GARRISON_MISSION_STARTED(event, ...)
	self:QueueSaveInProgressMissions()
end

function events:GARRISON_MISSION_COMPLETE_RESPONSE(event, ...)
	self:QueueSaveInProgressMissions()
end

function events:GARRISON_MISSION_LIST_UPDATE(event, ...)
	self:QueueSaveInProgressMissions()
end

function events:PLAYER_LOGIN(event, ...)
	self:UnregisterEvent(event)
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	C_Timer.After(5, function()
		if not self.saved then
			self:SaveInProgressMissions()
		end
	end)
	C_Timer.After(3, function()
		addon:RegisterMinimapIcon()
	end)
end

function events:PLAYER_ENTERING_WORLD(event, ...)
	for k, v in pairs(self.ORDERHALL_ADDONS) do
		self.ORDERHALL_ADDONS[k] = C_AddOns.IsAddOnLoaded(k)
	end
end

function addon:HandleSlashCommand(msg)
	if not msg or msg:len() == 0 then
		addon:OpenGarrisonPage()
	else
		msg = msg:lower()
		print(YELLOW_FONT_COLOR:WrapTextInColorCode("["..ADDON_NAME.."]"), ORANGE_FONT_COLOR:WrapTextInColorCode("Unknown command:"), msg)
	end
end

function addon:Init()
	self.GarrisonLandingPageReport = _G.GarrisonLandingPageReport
	self.GarrisonLandingPageReportList = _G.GarrisonLandingPageReportList
	self.missions = {}
	self:InitDB()
	self.TIME_COLORS = {
		{RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b}, -- ERROR
		{0.55, 0.55, 0.55}, -- DARK(VERY LONG)
		{0.8, 0.8, 0.76}, -- NORMAL
		{GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b}, -- GREEN(MEDIUM)
		{YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b}, -- YELLOW(SHORT)
		{ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b}, -- ORANGE(VERY SHORT)
	}
	self:UpdateAltMissions()

	self:CreateMenu()
	self.GarrisonLandingPageReport:HookScript("OnHide", function()
		addon:HideMenu()
		wipe(addon.missions)
		StaticPopup_Hide(ADDON_NAME.."_CONFIRM_RESET")
	end)

	-- Hook 2: Catch direct ShowUIPanel/SetAttribute path (used by ElvUI)
	-- by intercepting the OnShow script before Blizzard tries to create
	-- covenant soulbind/renown UI without a covenant
	local originalOnShow = _G.GarrisonLandingPage:GetScript("OnShow")
	_G.GarrisonLandingPage:SetScript("OnShow", function(self, ...)
		if self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison then
			local covenantID = C_Covenants.GetActiveCovenantID()
			if not covenantID or covenantID == 0 then
				self:Hide()
				return
			end
		end
		if originalOnShow then
			originalOnShow(self, ...)
		end
	end)

	self.scrollBox = self.GarrisonLandingPageReportList.ScrollBox

	self:GarrisonLandingPageReport_SetElementInitializer()
	_G.GarrisonLandingPageReportList_InitButton = function(...) addon:MissionButton_Update(...) end
	_G.GarrisonLandingPageReportList_Update = function(...) addon:GarrisonLandingPageReportList_Update(...) end
	_G.GarrisonLandingPageReportList_UpdateItems = function(...) addon:GarrisonLandingPageReportList_UpdateItems(...) end

	self.scrollBox:HookScript("OnShow", function(...) addon:UpdateItemInfoHandler(...) end)
	self.scrollBox:HookScript("OnHide", function(...) addon:UpdateItemInfoHandler(...) end)
	addon:UpdateItemInfoHandler()

	self.GarrisonLandingPageReportList.ScrollBox:HookScript("OnMouseUp", function(frame, button)
		if button == "RightButton" then
			addon:GarrisonLandingPageReportList_OnMouseUp(frame, button)
		end
	end)

	self:HookCovenantMissionFrame()

	self.Init = function() end
end

function addon:GarrisonLandingPageReportList_OnMouseUp(frame, button)
	if button == "RightButton" then
		addon:CreateMenu()
		local anchor = addon.scrollBox
		local uiScale, x, y = _G.UIParent:GetEffectiveScale(), GetCursorPosition()
		ToggleDropDownMenu(1, nil, addon.menu, anchor:GetName(), x / uiScale - 35, y / uiScale - 5)
	end
end

-- Register all events from the events table (after all files are loaded)
for event, func in pairs(addon.events) do
	if type(func) == "function" then
		addon.frame:RegisterEvent(event)
	end
end
