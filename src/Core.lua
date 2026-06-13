---@diagnostic disable: undefined-field
local ADDON_NAME, addon = ...
_G[ADDON_NAME] = addon

addon.frame = addon.frame or CreateFrame("Frame", nil, _G.WorldFrame)
addon.events = addon.events or {}

-- Constants
addon.MISSION_BUTTON_HEIGHT = 37
addon.MISSION_ICON_SIZE = addon.MISSION_BUTTON_HEIGHT - 4
addon.MISSION_REWARD_SIZE = addon.MISSION_BUTTON_HEIGHT * 0.78
addon.COVENANTMISSION_BUTTONHEIGHT = 64

addon.FORMAT_DURATION_DAYS = _G.GARRISON_DURATION_DAYS:gsub("([^|]*)|4[^:]+:([^;]+);(.*)", "%1%2%3"):gsub("%%d", "%%.1f")
addon.FORMAT_DURATION_HOURS = _G.GARRISON_DURATION_HOURS:gsub("([^|]*)|4[^:]+:([^;]+);(.*)", "%1%2%3"):gsub("%%d", "%%.1f")
addon.FORMAT_DURATION_MINUTES = _G.GARRISON_DURATION_MINUTES
addon.FORMAT_DURATION_SECONDS = _G.GARRISON_DURATION_SECONDS
addon.FORMAT_TOOLTIP_LEVEL = _G.GARRISON_MISSION_LEVEL_TOOLTIP or _G.GARRISON_BUILDING_LEVEL_LABEL_TOOLTIP
addon.FORMAT_TOOLTIP_ITEMLEVEL = _G.GARRISON_MISSION_LEVEL_ITEMLEVEL_TOOLTIP

addon.FORMAT_ICONINTEXT = "|T%s:0:0:0:0:64:64:5:59:5:59|t"
addon.FORMAT_LEVEL = "[%d]"
addon.FORMAT_REWARDNUMS = "%.1f"
addon.FORMAT_REWARD_DIFFICULTY = ITEM_QUALITY_COLORS[2].hex.." (%s)"..FONT_COLOR_CODE_CLOSE

addon.FOLLOWER_XP_THRESHOLD = 5000

addon.TITLE_COLOR_NORMAL = {0.93, 0.93, 0.9}
addon.TITLE_COLOR_ALT = {0.65, 0.65, 0.55}

addon.ORDERHALL_ADDONS = {
	["GarrisonMissionManager"] = false,
	["OrderHallCommander"] = false,
	["RENovate"] = false,
}

-- Globals
addon.GFT = Enum.GarrisonFollowerType
addon.GarrisonLandingPageReport = nil
addon.GarrisonLandingPageReportList = nil
addon.TIME_COLORS = nil
addon.buttonText = {}

-- Events table stored on addon for cross-file access
addon.events = addon.events or {}

-- Player info
addon.profileName = UnitName("player").."-"..GetRealmName()
local colorStr = RAID_CLASS_COLORS[select(2, UnitClass("player")) or "WARRIOR"].colorStr
addon.playerNameText = "|c"..colorStr..UnitName("player").."|r"

-- Text constants
addon.TEXT_LEGION_MISSIONS = _G.EXPANSION_NAME6.." ".._G.GARRISON_MISSIONS
addon.TEXT_BFA_MISSIONS = _G.EXPANSION_NAME7.." ".._G.GARRISON_MISSIONS

-- Slash commands
SlashCmdList[ADDON_NAME] = function(msg) addon:HandleSlashCommand(msg) end
_G["SLASH_"..ADDON_NAME.."1"] = "/ipm"
_G["SLASH_"..ADDON_NAME.."2"] = "/inprogressmissions"

-- Event dispatch
addon.frame:SetScript("OnEvent", function(self, event, ...)
	local handler = addon.events[event]
	if handler then
		handler(addon, event, ...)
	end
end)

function addon:RegisterEvent(event, handler)
	handler = handler or addon.events[event] or addon[event]
	if handler then
		addon.events[event] = handler
		addon.frame:RegisterEvent(event)
	end
end

function addon:UnregisterEvent(event)
	addon.frame:UnregisterEvent(event)
end
