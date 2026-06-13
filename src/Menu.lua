local addon = _G.InProgressMissions
local ADDON_NAME = "InProgressMissions"

function addon:HideMenu()
	if _G.UIDROPDOWNMENU_OPEN_MENU == addon.menu then
		CloseDropDownMenus()
	end
end

local function IgnoreProfile_OnClick(self, name, arg2, checked)
	addon:HideMenu()

	if name then
		IPMDB.ignores[name] = not checked or nil
		addon:UpdateAltMissions()
		addon:Refresh()
	end
end

local function SortMethod_OnClick(self, name)
	addon:HideMenu()

	if name then
		IPMDB.sortMethod = name
		addon:UpdateAltMissions()
		addon:Refresh()
	end
end

local function ResetProfiles()
	IPMDB.sortMethod = nil
	wipe(IPMDB.ignores)
	wipe(IPMDB.profiles)
	addon:UpdateAltMissions()
	addon:Refresh()
end

local function Reset_OnClick(self)
	if not _G.StaticPopupDialogs[ADDON_NAME.."_CONFIRM_RESET"] then
		_G.StaticPopupDialogs[ADDON_NAME.."_CONFIRM_RESET"] = {
			text = CONFIRM_CONTINUE,
			button1 = _G.YES,
			button2 = _G.CANCEL,
			OnAccept = ResetProfiles,
			hideOnEscape = true,
			timeout = 30,
			whileDead = true,
		}
	end
	StaticPopup_Show(ADDON_NAME.."_CONFIRM_RESET")
end

local function ToggleGarrisonMissions(self)
	IPMDB.enableGarrisonMissions = not IPMDB.enableGarrisonMissions
	addon:UpdateAltMissions()
	addon:Refresh()
end

local function ToggleLegionMissions(self)
	IPMDB.enableLegionMissions = not IPMDB.enableLegionMissions
	addon:UpdateAltMissions()
	addon:Refresh()
end

local function ToggleBfaMissions(self)
	IPMDB.enableBfaMissions = not IPMDB.enableBfaMissions
	addon:UpdateAltMissions()
	addon:Refresh()
end

function addon:CreateMenu()
	if self.menu then return end
	self.menu = CreateFrame("Frame", ADDON_NAME.."DropDownList")
	self.menu.displayMode = "MENU"
	local info = {}

	self.menu.initialize = function(self, level)
		if not level then return end
		GameTooltip:Hide()
		wipe(info)
		if level == 1 then
			info.isTitle = true
			info.text = "In Progress Missions"
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.isTitle = nil
			info.checked = nil
			info.notCheckable = true

			info.text = _G.RAID_FRAME_SORT_LABEL
			info.hasArrow = true
			info.value = "submenuSort"
			info.keepShownOnClick = true
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = nil

			info.text = _G.IGNORE
			info.hasArrow = true
			info.value = "submenuIgnore"
			info.keepShownOnClick = true
			UIDropDownMenu_AddButton(info, level)
			info.hasArrow = nil

			info.keepShownOnClick = nil

			info.isTitle = true
			info.text = _G.UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.isTitle = nil
			info.disabled = nil
			info.notClickable = nil

			info.notCheckable = nil
			info.isNotRadio = true
			info.text = addon.TEXT_BFA_MISSIONS
			info.func = ToggleBfaMissions
			info.checked = IPMDB.enableBfaMissions and true or nil
			UIDropDownMenu_AddButton(info, level)

			info.notCheckable = nil
			info.isNotRadio = true
			info.text = addon.TEXT_LEGION_MISSIONS
			info.func = ToggleLegionMissions
			info.checked = IPMDB.enableLegionMissions and true or nil
			UIDropDownMenu_AddButton(info, level)

			info.notCheckable = nil
			info.isNotRadio = true
			info.text = _G.GARRISON_MISSIONS_TITLE
			info.func = ToggleGarrisonMissions
			info.checked = IPMDB.enableGarrisonMissions and true or nil
			UIDropDownMenu_AddButton(info, level)

			info.notCheckable = true
			info.text = _G.RESET
			info.func = Reset_OnClick
			UIDropDownMenu_AddButton(info, level)

			info.text = _G.CLOSE
			info.func = addon.HideMenu
			UIDropDownMenu_AddButton(info, level)

		elseif level == 2 then
			info.disabled = nil
			info.isTitle = nil
			info.notCheckable = nil
			if UIDROPDOWNMENU_MENU_VALUE == "submenuSort" then
				info.isNotRadio = nil

				info.text = _G.CHARACTER_NAME_PROMPT
				info.func = SortMethod_OnClick
				info.checked = (IPMDB.sortMethod == "name" or IPMDB.sortMethod == nil) and true or nil
				info.arg1 = "name"
				UIDropDownMenu_AddButton(info, level)

				info.text = _G.CLOSES_IN
				info.func = SortMethod_OnClick
				info.checked = IPMDB.sortMethod == "time" and true or nil
				info.arg1 = "time"
				UIDropDownMenu_AddButton(info, level)
			elseif UIDROPDOWNMENU_MENU_VALUE == "submenuIgnore" then
				info.isNotRadio = true

				for name, profile in pairs(IPMDB.profiles) do
					if profile[1] then
						info.text = profile[1].charText or name
						info.func = IgnoreProfile_OnClick
						info.checked = IPMDB.ignores[name] and true or nil
						info.arg1 = name
						UIDropDownMenu_AddButton(info, level)
					end
				end
			end
		end
	end
end
