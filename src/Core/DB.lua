local addon = _G.InProgressMissions

function addon:InitDB()
	if type(IPMDB) ~= "table" then
		IPMDB = {}
	end
	if IPMDB.enableGarrisonMissions == nil then
		IPMDB.enableGarrisonMissions = true
	end
	if IPMDB.enableLegionMissions == nil then
		IPMDB.enableLegionMissions = IPMDB.enableGarrisonMissions
	end
	if IPMDB.enableBfaMissions == nil then
		IPMDB.enableBfaMissions = IPMDB.enableLegionMissions
	end
	-- if IPMDB.improveCovenantMissionUI == nil then
	-- 	IPMDB.improveCovenantMissionUI = false
	-- end
	if type(IPMDB.profiles) ~= "table" then
		IPMDB.profiles = {}
	end
	if type(IPMDB.ignores) ~= "table" then
		IPMDB.ignores = {}
	end
	if type(IPMDB.profiles[self.profileName]) ~= "table" then
		IPMDB.profiles[self.profileName] = {}
	end
end

function addon:SaveInProgressMissions()
	self.saved = true
	self:InitDB()
	if C_Garrison.GetLandingPageGarrisonType() == 0 then
		IPMDB.profiles[self.profileName] = nil
		return
	end
	local profile = wipe(IPMDB.profiles[self.profileName])
	self:GetMissions(self.GFT.FollowerType_9_0_GarrisonFollower, profile)
	if self.delayedSave then
		self.delayedSave = nil
	elseif not next(profile) then
		self.delayedSave = true
		self:QueueSaveInProgressMissions(1.0)
	end
	self:GetMissions(self.GFT.FollowerType_8_0_GarrisonFollower, profile)
	self:GetMissions(self.GFT.FollowerType_7_0_GarrisonFollower, profile)
	self:GetMissions(self.GFT.FollowerType_6_0_Boat, profile)
	self:GetMissions(self.GFT.FollowerType_6_0_GarrisonFollower, profile)
	if not next(profile) then
		IPMDB.profiles[self.profileName] = nil
	end
end

function addon:QueueSaveInProgressMissions(value)
	if not self.missionUpdated then
		self.missionUpdated = true
		C_Timer.After(value or 0.5, function()
			addon.missionUpdated = false
			addon:SaveInProgressMissions()
			addon:Refresh()
		end)
	end
end
