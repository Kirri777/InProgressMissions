local addon = _G.InProgressMissions

function addon:RegisterMinimapIcon()
	if self.minimapIcon then return end
	if UnitLevel("player") >= 70 then
		return true
	end
	local GarrisonID = C_Garrison.GetLandingPageGarrisonType()
	if GarrisonID ~= Enum.GarrisonType.Type_9_0_Garrison then return end
	if ExpansionLandingPage and (not ExpansionLandingPage:IsOverlayApplied()) then return end
	local covenantID = C_Covenants.GetActiveCovenantID()
	local covenantIcons = {[1] = 3257748, [2] = 3257751, [3] = 3257750, [4] = 3257749}
	local textureID = covenantIcons[covenantID or 0]
	if not textureID then return end
	if not LibStub then return end

	local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("IPM", {
		type = "data source",
		text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
		icon = textureID,
		OnClick = function(self, button)
			local covenantID = C_Covenants.GetActiveCovenantID()
			if covenantID and covenantID > 0 then
				ShowGarrisonLandingPage(Enum.GarrisonType.Type_9_0_Garrison)
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine(_G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE)
		end,
	})
	local icon = LibStub("LibDBIcon-1.0", true)
	if icon then
		if IPMDBicon == nil then
			IPMDBicon = {}
		end
		icon:Register("IPM", miniButton, IPMDBicon)
		self.minimapIcon = icon.objects["IPM"]
	end
	return true
end
