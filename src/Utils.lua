local addon = _G.InProgressMissions

function addon:FormatRewardNumbers(value)
	if value > 999 then
		value = self.FORMAT_REWARDNUMS:format(value / 1000)
		if string.sub(value, -2) == ".0" then
			value = string.sub(value, 1, -3)
		end
		value = value.."k"
	end
	return value
end

function addon:MakeIcon(icon, rightText)
	local result = self.FORMAT_ICONINTEXT:format(icon or 134400)
	if rightText then
		return result.." "..rightText
	else
		return result
	end
end

function addon:AddIcon(text1, icon, text2)
	if text1 then
		return text1.." "..self:MakeIcon(icon, text2)
	else
		return self:MakeIcon(icon, text2)
	end
end

function addon:QualityColorText(text, quality)
	if quality then
		return ITEM_QUALITY_COLORS[quality].hex..text..FONT_COLOR_CODE_CLOSE
	else
		return text
	end
end

function addon:FlipTexture(texture, horizontal)
	local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = texture:GetTexCoord()
	if horizontal then
		texture:SetTexCoord(URx, URy, LRx, LRy, ULx, ULy, LLx, LLy)
	else
		texture:SetTexCoord(LLx, LLy, ULx, ULy, LRx, LRy, URx, URy)
	end
end

function addon:CreateQuantityFont()
	if not _G.GarrisonReportFontRewardQuantity then
		local font = CreateFont("GarrisonReportFontRewardQuantity")
		local name, height, flags = _G.NumberFontNormalSmall:GetFont()
		if flags then
			local t = {}
			for w in string.gmatch(flags, "%s*(%a+),?") do
				if w ~= "MONOCHROME" then tinsert(t, w) end
			end
			flags = table.concat(t, ", ")
		end
		font:SetFont(name, 11.5, flags)
	end
end

function addon:CreateButtonText(button)
	local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("BOTTOMRIGHT", -70, 9)
	text:SetJustifyH("RIGHT")
	self.buttonText[button] = text
	return text
end
