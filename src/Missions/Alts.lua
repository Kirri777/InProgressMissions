---@diagnostic disable: undefined-field
local addon = _G.InProgressMissions
local GFT = addon.GFT

local function GetCharName(charText)
	local name, realm = charText:match("([^%p]+)|?r?-?(.*)", 11)
	return name or _G.UNKNOWN, realm or _G.FRIENDS_LIST_REALM
end

function addon.CompareMissionName(m1, m2)
	local name1, realm1 = GetCharName(m1.charText)
	local name2, realm2 = GetCharName(m2.charText)
	if name1 == name2 then
		if realm1 == realm2 then
			if m1.missionEndTime == m2.missionEndTime then
				return m1.name < m2.name
			else
				return (m1.missionEndTime or 0) < (m2.missionEndTime or 0)
			end
		else
			return realm1 < realm2
		end
	else
		return name1 < name2
	end
end

function addon.CompareMissionTime(m1, m2)
	if (m1.followerTypeID == m2.followerTypeID) and (m1.followerTypeID > GFT.FollowerType_6_0_Boat) then
		if (m1.missionEndTime or 0) == (m2.missionEndTime or 0) then
			return addon.CompareMissionName(m1, m2)
		else
			return (m1.missionEndTime or 0) < (m2.missionEndTime or 0)
		end
	elseif (m1.followerTypeID < GFT.FollowerType_7_0_GarrisonFollower) and (m2.followerTypeID < GFT.FollowerType_7_0_GarrisonFollower) then
		return (m1.missionEndTime or 0) < (m2.missionEndTime or 0)
	else
		return m1.followerTypeID > m2.followerTypeID
	end
end

function addon:UpdateAltMissions()
	self.altMissions = wipe(self.altMissions or {})
	for name, missions in pairs(IPMDB.profiles) do
		if name ~= self.profileName and not IPMDB.ignores[name] then
			for i, mission in ipairs(missions) do
				mission.followerTypeID = mission.followerTypeID or 0
				if mission.followerTypeID >= GFT.FollowerType_9_0_GarrisonFollower or
					(mission.followerTypeID == GFT.FollowerType_8_0_GarrisonFollower and IPMDB.enableBfaMissions) or
					(mission.followerTypeID == GFT.FollowerType_7_0_GarrisonFollower and IPMDB.enableLegionMissions) or
					(mission.followerTypeID < GFT.FollowerType_7_0_GarrisonFollower and IPMDB.enableGarrisonMissions) then
					if type(mission) == "table" and type(mission.charText) == "string" then
						tinsert(self.altMissions, mission)
					end
				end
			end
		end
	end
	table.sort(self.altMissions, IPMDB.sortMethod == "time" and addon.CompareMissionTime or addon.CompareMissionName)
	self:UpdateInProgressTabText()
end

function addon:OrderHallAddonExists()
	for k, v in pairs(self.ORDERHALL_ADDONS) do
		if v then
			return true
		end
	end
end
