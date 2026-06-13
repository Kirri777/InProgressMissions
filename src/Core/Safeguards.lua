-- Safeguard against Blizzard error when opening covenant landing page
-- on a character without a covenant (triggered by ElvUI etc.)
-- Hook 1: Intercept ShowGarrisonLandingPage calls
local originalShowGarrisonLandingPage = _G.ShowGarrisonLandingPage
_G.ShowGarrisonLandingPage = function(garrisonType, ...)
	if garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
		local covenantID = C_Covenants.GetActiveCovenantID()
		if not covenantID or covenantID == 0 then
			local altType = C_Garrison.GetLandingPageGarrisonType()
			if altType ~= Enum.GarrisonType.Type_9_0_Garrison and altType ~= 0 then
				return originalShowGarrisonLandingPage(altType, ...)
			end
			return
		end
	end
	return originalShowGarrisonLandingPage(garrisonType, ...)
end
