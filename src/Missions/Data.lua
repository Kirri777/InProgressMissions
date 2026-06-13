---@diagnostic disable: undefined-field
local addon = _G.InProgressMissions
local GFT = addon.GFT

function addon:GetMissions(followerType, dest, sort)
	local isAutoCombatant = followerType == GFT.FollowerType_9_0_GarrisonFollower -- Shadowlands
	local temp = C_Garrison.GetInProgressMissions(followerType)
	if not temp then return end
	for k, mission in pairs(temp) do
		if type(mission) == "table" then
			---@diagnostic disable: inject-field
			mission.isAltMission = false
			mission.description = ""
			mission.charText = self.playerNameText.."-"..GetRealmName()
			mission.followerInfo = self:GetMissionFollowerAbilitiesInfo(mission)
			mission.successChance = C_Garrison.GetMissionSuccessChance(mission.missionID)
			if isAutoCombatant then
				mission.encounterIconInfo = C_Garrison.GetMissionEncounterIconInfo(mission.missionID)
			end
			---@diagnostic enable: inject-field
		end
	end
	if sort then
		table.sort(temp, type(sort) == "function" and sort or addon.CompareMissionTime)
	end
	for k, mission in ipairs(temp) do
		tinsert(dest, mission)
	end
end

function addon:GetMissionFollowerAbilitiesInfo(mission)
	local isAutoCombatant = mission.followerTypeID == GFT.FollowerType_9_0_GarrisonFollower -- Shadowlands
	local result = {}
	for i, id in ipairs(mission.followers) do
		local info = C_Garrison.GetFollowerInfo(id)
		if info then
			---@diagnostic disable: inject-field
			info.abilities = {}
			---@diagnostic enable: inject-field
			if isAutoCombatant then
				---@diagnostic disable: param-type-mismatch
				local spells = C_Garrison.GetFollowerAutoCombatSpells(info.followerID, info.level or 1)
				---@diagnostic enable: param-type-mismatch
				for k, spell in ipairs(spells or {}) do
					tinsert(info.abilities, 1, spell.icon)
				end
			else
				for k, ability in ipairs(C_Garrison.GetFollowerAbilities(info.followerID)) do
					tinsert(info.abilities, ability.id)
				end
			end
			result[id] = info
		end
	end
	return result
end

function addon:UpdateMissions()
	local garrisonType = C_Garrison.GetLandingPageGarrisonType()
	wipe(self.missions)
	if garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
		self:GetMissions(GFT.FollowerType_9_0_GarrisonFollower, self.missions, true)
	end
	if garrisonType == Enum.GarrisonType.Type_8_0_Garrison or IPMDB.enableBfaMissions or C_Garrison.IsPlayerInGarrison(Enum.GarrisonType.Type_8_0_Garrison) then
		self:GetMissions(GFT.FollowerType_8_0_GarrisonFollower, self.missions, true)
	end
	if garrisonType == Enum.GarrisonType.Type_7_0_Garrison or IPMDB.enableLegionMissions or C_Garrison.IsPlayerInGarrison(Enum.GarrisonType.Type_7_0_Garrison) then
		self:GetMissions(GFT.FollowerType_7_0_GarrisonFollower, self.missions, true)
	end
	if garrisonType == Enum.GarrisonType.Type_6_0_Garrison or IPMDB.enableGarrisonMissions or C_Garrison.IsPlayerInGarrison(Enum.GarrisonType.Type_6_0_Garrison) then
		self:GetMissions(GFT.FollowerType_6_0_Boat, self.missions, true)
		self:GetMissions(GFT.FollowerType_6_0_GarrisonFollower, self.missions, true)
	end
	self:UpdateInProgressTabText()
end

function addon:UpdateInProgressTabText()
	if self.GarrisonLandingPageReport then
		local text = self.GarrisonLandingPageReport.InProgress.Text
		text:SetText((_G.GARRISON_LANDING_IN_PROGRESS.." (%d)"):format(#self.missions, #self.altMissions))
	end
end

function addon:Refresh()
	if self.GarrisonLandingPageReport and self.GarrisonLandingPageReport:IsVisible() then
		self:GarrisonLandingPageReportList_UpdateItems()
	end
end
