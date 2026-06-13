---@diagnostic disable: undefined-field
local addon = _G.InProgressMissions
local ADDON_NAME = "InProgressMissions"
local GARRISON_MISSION_ICON = 3257748

function addon:RegisterMinimapIcon()
	if self.minimapIcon then return end
	if not LibStub then return end
	if not IPMDB.showMinimap then return end

	local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
		type = "data source",
		text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE or "In Progress Missions",
		icon = GARRISON_MISSION_ICON,
		OnClick = function(_, button)
			if button == "RightButton" then
				addon:OpenSettings()
			else
				addon:OpenGarrisonPage()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("|cFF1ABC9CIn Progress Missions|r")
			tooltip:AddLine(" ")
			tooltip:AddLine("|cFFFFFFFFLeft Click:|r Open garrison report")
			tooltip:AddLine("|cFFFFFFFFRight Click:|r Open settings")
		end,
	})
	local icon = LibStub("LibDBIcon-1.0", true)

	if icon then
		if IPMDBicon == nil then
			IPMDBicon = {}
		end
		icon:Register(ADDON_NAME, miniButton, IPMDBicon)
		self.minimapIcon = icon.objects[ADDON_NAME]
	end
end

function addon:OpenGarrisonPage()
	if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsVisible() then
		HideUIPanel(_G.GarrisonLandingPage)
		return
	end

	local GarrisonID = C_Garrison.GetLandingPageGarrisonType()
	if GarrisonID >= Enum.GarrisonType.Type_6_0_Garrison then
		local covenantID = C_Covenants.GetActiveCovenantID()

		if covenantID and covenantID > 0 then
			ShowGarrisonLandingPage(_G.Enum.GarrisonType.Type_9_0_Garrison)
		else
			if GarrisonID >= _G.Enum.GarrisonType.Type_9_0_Garrison then
				GarrisonID = _G.Enum.GarrisonType.Type_8_0_Garrison
			end
			ShowGarrisonLandingPage(GarrisonID)
		end
	else
		for char, missions in pairs(IPMDB.profiles) do
			print("=====", (missions[1] and missions[1].charText) or char, "=====")
			for k, m in pairs(missions) do
				if type(m) == "table" then
					print(("[%03d] %s"):format(m.level, m.name), "-", date("%a,%H:%M", m.missionEndTime), (time() - m.missionEndTime) > 0 and "(".._G.COMPLETE..")" or "")
				end
			end
		end
	end
end

function addon:UpdateMinimapVisibility()
	local icon = LibStub("LibDBIcon-1.0", true)

	if not icon or not icon.objects[ADDON_NAME] then return end

	if IPMDB.showMinimap then
		icon:Show(ADDON_NAME)
	else
		icon:Hide(ADDON_NAME)
	end
end
