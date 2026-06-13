local addon = _G.InProgressMissions
local ADDON_NAME = "InProgressMissions"
local TITLE_COLOR = "|cFF1ABC9C"

function addon:RegisterSettings()
	if not Settings then return end

	local category = Settings.RegisterVerticalLayoutCategory("|cFF1ABC9C" .. ADDON_NAME .. "|r", nil, nil, "InProgressMissionsSettingsCategory")
	if not category then return end

	local option = Settings.RegisterAddOnSetting(category,
		ADDON_NAME .. "_showMinimap",
		"showMinimap",
		IPMDB,
		type(true),
		"Show Minimap Button",
		true)
	option:SetValueChangedCallback(function(value)
		addon:UpdateMinimapVisibility()
	end)
	Settings.CreateCheckbox(category, option, "Show/hide minimap button")

	Settings.RegisterAddOnCategory(category)
	self.settingsCategory = category
end

function addon:OpenSettings()
	if not self.settingsCategory then return end
	local id = self.settingsCategory:GetID()
	if id then
		Settings.OpenToCategory(id)
	end
end
