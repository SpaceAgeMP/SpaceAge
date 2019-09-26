local alwaysshowtemp = CreateClientConVar("cl_alwaysshowtemperature", 0, true, false)

local function hidehud(name)
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CustFiremode" then
		return false
	end
end
hook.Add("HUDShouldDraw", "hidehud", hidehud)

local GlobalTemp_Min = 0
local GlobalTemp_Max = 600
local FairTemp_Min = 283
local FairTemp_Max = 308
local ls_habitat = 0
local ls_air = 0
local ls_tmp = 0
local ls_coolant = 0
local ls_energy = 0

-- this can't be changed right now
local tempGaugeWid = 390

local function LS_umsg_hook1(um)
	ls_habitat = um:ReadFloat()
	ls_air = um:ReadShort()
	ls_tmp = um:ReadShort()
	ls_coolant = um:ReadShort()
	ls_energy = um:ReadShort()
end

local function LS_umsg_hook2(um)
	ls_air = um:ReadShort()
end

local function CheckHookIn()
	if not ConVarExists("LS_Display_HUD") then
		return
	end
	RunConsoleCommand("LS_Display_HUD", "0")
	usermessage.Hook("LS_umsg1", LS_umsg_hook1)
	usermessage.Hook("LS_umsg2", LS_umsg_hook2)
	timer.Remove("SA_CheckHUDHookIn")
	print("SA HUD loaded...")
end
timer.Create("SA_CheckHUDHookIn", 1, 0, CheckHookIn)


surface.CreateFont("DefaultLarge", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
local HUDFont = "Default"

local SA_HUDBlink = true
timer.Create("SA_HUDBlink", 0.5, 0, function() SA_HUDBlink = not SA_HUDBlink end)

timer.Remove("SA_HealthBarRed")
local SA_HealthBarRed = 0
timer.Create("SA_HealthBarRed", 0.01, 0, function()
	if SA_HealthBarRed > 0 then
		SA_HealthBarRed = SA_HealthBarRed - 2
		if SA_HealthBarRed < 0 then SA_HealthBarRed = 0 end
	end
end)
local SA_LastHealth = 0

local WeaponMaxAmmo = {}
WeaponMaxAmmo.weapon_pistol = 18
WeaponMaxAmmo.weapon_357 = 6
WeaponMaxAmmo.weapon_smg1 = 45
WeaponMaxAmmo.weapon_ar2 = 30
WeaponMaxAmmo.weapon_shotgun = 6
WeaponMaxAmmo.weapon_crossbow = 1
WeaponMaxAmmo.weapon_frag = 0
WeaponMaxAmmo.weapon_rpg = 0
WeaponMaxAmmo.weapon_crowbar = 0
WeaponMaxAmmo.weapon_physcannon = 0
WeaponMaxAmmo.weapon_physgun = 0

local function GetMaxAmmo(SWEP)
	if SWEP.Primary and SWEP.Primary.ClipSize then
		return SWEP.Primary.ClipSize
	end

	local MAmmo = WeaponMaxAmmo[SWEP:GetClass()]
	if MAmmo then return MAmmo end

	LocalPlayer():ChatPrint("UNKOWN WEAPON: " .. SWEP:GetClass() .. "|" .. tostring(SWEP:Clip1()))

	return SWEP:Clip1()
end

local black = Color(0, 0, 0, 255)
local red = Color(255, 0, 0, 255)
local green = Color(0, 255, 0, 255)
local blue = Color(0, 0, 255, 255)
local yellow = Color(255, 255, 0, 255)
local orange = Color(255, 128, 0, 255)
local veryDarkGrey = Color(20, 20, 20, 255)
local transparentGrey = Color(70, 70, 70, 230)
local transparentDarkerGrey = Color(60, 60, 60, 230)

local function DrawLSBar(BarNum, CaptionX, Value, ScH, ScW, ColBack, ColText)
	local Caption = CAF.GetLangVar(CaptionX)
	local BarHei = 114
	local BarSpace = 24
	local BarWid = 30
	local Hei = (ScH - 30) - BarHei - 4
	local XMinX = ScW / 2 - tempGaugeWid / 2 - (BarWid + BarSpace) * BarNum - 12

	--draw.RoundedBox(4, xPos-8, yPos-40, MeterWid+22, MeterHei+12 + 40, ColBack)
	draw.RoundedBox(4, XMinX-8, Hei-32, BarWid + 16, BarHei + 12 + 30, ColBack)

	draw.RoundedBox(4, XMinX + 3, Hei + 6, BarWid-6, BarHei-6, transparentGrey)
	draw.SimpleText(Caption, HUDFont, XMinX + BarWid / 2-1, Hei -20, ColText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Perc = Value / 4000

	local ValCol = Color(255 * (1-Perc), 255 * Perc, 0, 255)

	if Value > 0 then
		local YHei = (BarHei-4)  * Perc
		YHei = math.max(YHei, 4)
		draw.RoundedBox(4, XMinX + 5, math.Round(Hei + 6 + BarHei - 4) - math.Round(YHei), BarWid-10, math.Round(YHei-4), ValCol)
		draw.SimpleText(tostring(math.Round(Perc * 100, 2)) .. " %", HUDFont, XMinX + BarWid / 2-1, Hei - 4, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		if (SA_HUDBlink) then
			draw.SimpleText("EMPTY", HUDFont, XMinX + BarWid / 2-1, Hei -4, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

local function DrawMeterSlantSection(_slantAmount, _width, _height, _xMax, _yMax, _yMaxCut, _yMinCut)

	--remember gmod y axis is flipped if you go to change anything! variable names can be confusing, always think about y direction!

	local xMin = _xMax - _width
	local yMin = _yMax - _height

	-- if the lowest point of this is higher than our current value (as a bar y position), dont draw it at all
	if (_yMax >= _yMinCut) then
		--return
	end

	draw.NoTexture()
	local slantSection = {}


	-- if the top right point is less than  our current value (as a bar y position)
	local cutAmount = 0
	if ((yMin - _slantAmount) < _yMinCut) then
		cutAmount = math.abs(_yMinCut-yMin)
	end

	-- this shouldn't happen, but just in case...
	if (cutAmount >= _height) then
		return
	end

	-- top left, top right, bottom left, bottom right
	table.insert(slantSection, {x = xMin, y = yMin - _slantAmount + cutAmount, u = 0, v = 1})
	table.insert(slantSection, {x = _xMax, y = yMin + cutAmount, u = 1, v = 1})
	table.insert(slantSection, {x = _xMax, y = _yMax, u = 1, v = 0})
	table.insert(slantSection, {x = xMin, y = _yMax - _slantAmount, u = 0, v = 0})

	surface.DrawPoly(slantSection)


end

local function DrawLSBattery(CaptionX, Value, ScH, ScW, ColBack, ColText)

	--remember gmod y axis is flipped if you go to change anything! variable names can be confusing, always think about y direction!

	local Caption = CAF.GetLangVar(CaptionX)
	local MeterHei = 100
	local MeterWid = 30
	local batteryTipHei = 10
	local batteryTipWid = 16

	-- the width of the lines drawn
	local batLineWid = 6

	local yPos = (ScH - MeterHei) - 40
	local xPos = (ScW / 2) + (tempGaugeWid / 2) + MeterWid + 20


	local ValCol = Color(255 * (1-(Value / 4000)), 255 * (Value / 4000), 0, 255)

	local batteryColor = transparentDarkerGrey

	draw.RoundedBox(4, xPos-8, yPos-40, MeterWid + 22, MeterHei + 16 + 40, ColBack)

	local batteryMeterColor = ValCol
	-- vert - draw the sides of the battery, move them down and size them to compensate for the tip of the battery graphic

	draw.RoundedBoxEx(4, xPos, yPos + batteryTipHei, batLineWid, MeterHei - batteryTipHei, batteryColor, true, false, false, false)
	draw.RoundedBoxEx(4, xPos + MeterWid, yPos + batteryTipHei, batLineWid, MeterHei - batteryTipHei, batteryColor, false, true, false, false)

	-- horiz - draw the lines leading to the tip

	local edgeLength = (MeterWid / 2 - batteryTipWid / 2)

	draw.RoundedBoxEx(4, xPos + batLineWid, yPos + batteryTipHei, edgeLength, batLineWid, batteryColor, false, false, false, true)
	draw.RoundedBoxEx(4, xPos + edgeLength + batteryTipWid, yPos + batteryTipHei, edgeLength, batLineWid, batteryColor, false, false, true, false)


	-- vert - draw the sides of the tip
	draw.RoundedBoxEx(4, xPos + edgeLength, yPos, batLineWid, batteryTipHei, batteryColor, true, false, false, false)
	draw.RoundedBoxEx(4, xPos + edgeLength + batteryTipWid, yPos, batLineWid, batteryTipHei, batteryColor, false, true, false, false)

	-- horiz - draw the top of the tip
	draw.RoundedBoxEx(4, xPos + edgeLength + batLineWid, yPos, batteryTipWid-batLineWid, batLineWid, batteryColor)

	-- horiz - draw the bottom of the battery
	draw.RoundedBoxEx(4, xPos, yPos + MeterHei, MeterWid + batLineWid, batLineWid, batteryColor)


	--function DrawVerticalBrokenMeter(_gapSize, _xMin, _yMax, _vbWid, _vbHei, _meterMax, _curValue)

	local slantAmount = 4
	local slantHei = 14
	local slantWid = MeterWid - batLineWid * 2
	local gapSize = 4

	local heightWithGap = slantHei + gapSize

	local batMeterHei = MeterHei - batteryTipHei - batLineWid * 2

	-- take the modulus of the heightWithGap, that lets us know how much leftover height there is, take that height away.
	-- now when we divide by the heightWithGap we'll have the number of slants we need to draw
	local slantCount = (batMeterHei - (batMeterHei % heightWithGap)) / heightWithGap

	local bottomY = yPos + MeterHei - batLineWid / 2

	-- easiest start position is giving an xMin and yMax, that's the only spot that's on the bottom of the battery, so that's what the section drawing function uses
	--print(slantCount)
	surface.SetDrawColor(batteryMeterColor)
	for slantNum = 0, slantCount-1 do
		local ratio = (batMeterHei / 4000)
		local heightCap = bottomY - math.Round(Value * ratio)

		DrawMeterSlantSection(slantAmount, slantWid, slantHei, xPos + MeterWid - batLineWid / 2, bottomY - slantNum * heightWithGap, bottomY, heightCap)
	end


	-- draw bottom slant if value isn't 0 (or somethin)
	-- draw broken meter slant section polys

	draw.SimpleText(Caption, HUDFont, xPos + (MeterWid + batLineWid) / 2, yPos - 30, ColText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Perc = Value / 4000

	local ValCol = Color(255 * (1-Perc), 255 * Perc, 0, 255)

	if Value > 0 then
		local XWid = (MeterWid - 154)  * Perc
		XWid = math.max(XWid, 4)
		--draw.RoundedBox(4, xPos + 150, yPos + 4, XWid, MeterHei - 8, ValCol)
		draw.SimpleText(tostring(Perc * 100) .. " %", HUDFont, xPos + (MeterWid + batLineWid) / 2, yPos -12, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		if (SA_HUDBlink) then
			draw.SimpleText("EMPTY", HUDFont, xPos + (MeterWid + batLineWid) / 2, yPos - 12, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

local function SA_CustomHUDPaint()
	if GetConVarNumber("cl_drawhud") == 0 then return end
	local lp = LocalPlayer()
	local health = lp:Health()
	local armor = lp:Armor()
	if not lp:Alive() then return end

	local SWEP = lp:GetActiveWeapon()
	if not (SWEP and SWEP.IsValid and SWEP:IsValid()) then return end
	if SWEP:GetClass() == "gmod_camera" then return end

	local ScH = ScrH()
	local ScW = ScrW()

	local primAmmo = lp:GetAmmoCount(SWEP:GetPrimaryAmmoType())
	local secAmmo = lp:GetAmmoCount(SWEP:GetSecondaryAmmoType())
	local primMaxAmmo = GetMaxAmmo(SWEP)

	if health < SA_LastHealth then
		SA_HealthBarRed = 255
	end
	SA_LastHealth = health

	local HUDGrey = Color(0, 0, 0, 225)
	local HUDHealth = Color(SA_HealthBarRed, 255-SA_HealthBarRed, 0, 255)
	local HUDArmor = red
	local HUDAmmo1 = yellow
	local HUDAmmo2 = orange

	draw.RoundedBox(4, ScW - 80, ScH - 340, 60, 320, HUDGrey)
	if primMaxAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 240, 60, 220, HUDGrey)
	elseif primAmmo > 0 and secAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 60, 60, 40, HUDGrey)
	elseif primAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 40, 60, 20, HUDGrey)
	end

	--BEGIN OF HEALTH AND ARMOR

	local HeightMul = 290
	local Inset = 40
	if armor > 0 then
		HeightMul = 274
		Inset = 56
	end

	local PlRelX = health / 100
	if PlRelX > 1 then PlRelX = 1 end
	local PlHeightX = math.max(PlRelX * HeightMul, 4)
	draw.RoundedBox(4, ScW - 70, (ScH - Inset) - PlHeightX, 40, PlHeightX, HUDHealth)
	draw.SimpleText(health, HUDFont, ScW - 50, ScH - 38, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	if (armor > 0) then
		local PlRelX = armor / 100
		if PlRelX > 1 then PlRelX = 1 end
		local PlHeightX = math.max(PlRelX * HeightMul, 4)
		draw.RoundedBox(2, ScW - 70, (ScH - Inset) - PlHeightX, 10, PlHeightX, HUDArmor)
		draw.SimpleText(armor, HUDFont, ScW - 50, ScH - 54, HUDArmor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF HEALTH AND ARMOR

	--BEGIN OF AMMO
	local HeightMul = 190
	local Inset = 40
	if secAmmo > 0 then
		HeightMul = 174
		Inset = 56
	end
	local primAmmoX = SWEP:Clip1()
	if primMaxAmmo > 0 and primAmmoX > 0 then
		local OneAmmoH = (HeightMul / primMaxAmmo) - 3
		surface.SetDrawColor(HUDAmmo1)
		for i = 1, primAmmoX, 1 do
			local PlRelX = i / primMaxAmmo
			if PlRelX > 1 then PlRelX = 1 end
			local PlHeightX = PlRelX * HeightMul
			surface.DrawRect(ScW - 132, (ScH - Inset) - PlHeightX, 40, OneAmmoH)
		end
	end
	if primAmmo > 0 or secAmmo > 0 or primAmmoX > 0 then
		draw.SimpleText(primAmmo, HUDFont, ScW - 112, ScH - 38, HUDAmmo1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	if secAmmo > 0 then
		draw.SimpleText(secAmmo, HUDFont, ScW - 112, ScH - 54, HUDAmmo2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF AMMO

	local ls_current_unhabitable
	if ls_habitat < 5 then
		ls_current_unhabitable = true
	else
		if ls_tmp <= 0 then
			ls_current_unhabitable = false
		else
			if ls_tmp < FairTemp_Min then
				ls_current_unhabitable = true
			elseif ls_tmp > FairTemp_Max then
				ls_current_unhabitable = true
			else
				ls_current_unhabitable = false
			end
		end
	end

	--BEGIN OF TEMPERATURE
	if ls_current_unhabitable or alwaysshowtemp:GetBool() then
		local tempUnit = " K"

		local FairTemp_Mid = (FairTemp_Min + FairTemp_Max) / 2

		local coolTemp = blue
		local hotTemp = red
		local goodTemp = green

		-- draw background box

		local XMinX = (ScW - 388) / 2
		--draw.RoundedBox(6, XMinX - 26 - 8, ScH - 126, 440 + 16, 94, HUDGrey)

		local mainPanelWid = 600
		local leftOffset = 40
		--draw.RoundedBox(6, ScW/2-mainPanelWid/2-leftOffset, ScH - 185, mainPanelWid+leftOffset, 170, HUDGrey)

		local Perc = math.Clamp(FairTemp_Mid / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid
		--draw.RoundedBox(4, (ScW - tempGaugeWid) / 2, ScH - 90 + 5, Wid, 40, coolTemp)
		--draw.RoundedBox(4, Wid + XMinX, ScH - 90 + 5, tempGaugeWid - Wid, 40, hotTemp)

		local outlineW = 2

		--temp bar outline
		surface.SetDrawColor(black)
		draw.NoTexture()
		surface.DrawTexturedRectRounded((ScW - tempGaugeWid) / 2 - outlineW, ScH - 90 + 5 - outlineW, tempGaugeWid + outlineW * 2 + 1, 20 + outlineW * 2, 4, 4, true, true, true, true)

		-- cool temp
		surface.SetDrawColor(coolTemp)
		draw.NoTexture()
		surface.DrawTexturedRectRounded((ScW - tempGaugeWid) / 2, ScH - 90 + 5, Wid, 20, 4, 4, true, false, true, false)

		-- hot temp
		surface.SetDrawColor(hotTemp)
		surface.DrawTexturedRectRounded(Wid + XMinX, ScH - 90 + 5, tempGaugeWid - Wid, 20, 4, 4, false, true, false , true)


		local Perc = math.Clamp(FairTemp_Min / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid
		local Perc2 = math.Clamp(FairTemp_Max / GlobalTemp_Max, 0, 1)
		local Wid2 = math.Clamp(Perc2 - Perc, 0, 1) * tempGaugeWid

		-- good temp

		surface.SetDrawColor(goodTemp)
		surface.DrawTexturedRectRounded(XMinX + Wid, ScH - 90 + 5, Wid2-2, 20, 1, 3, true, true, true , true)


		-- fade blue-red-green

		surface.SetDrawColor(green)
		surface.SetTexture(surface.GetTextureID("vgui/gradient-r"))
		surface.DrawTexturedRect(XMinX + Wid - 3, ScH - 90 + 5, 5, 20)

		surface.SetTexture(surface.GetTextureID("vgui/gradient-l"))
		surface.DrawTexturedRect(XMinX + Wid + Wid2-2, ScH - 90 + 5, 5, 20)



		--dark gradients
		surface.SetDrawColor(Color(0, 0, 0, 235))
		surface.SetTexture(surface.GetTextureID("vgui/gradient-d"))
		surface.DrawTexturedRectRounded((ScW - tempGaugeWid) / 2, ScH - 90 + 5, Wid, 20, 4, 4, true, false, true, false)
		surface.DrawTexturedRectRounded(Wid + XMinX + Wid2-1, ScH - 90 + 5, tempGaugeWid - Wid - Wid2 + 1, 20, 4, 4, false, true, false , true)

		surface.DrawTexturedRectRounded(Wid + XMinX-1, ScH - 90 + 5, Wid2, 20, 2, 2, false, false, false, false)


		surface.SetTexture(surface.GetTextureID("vgui/gradient-u"))
		surface.DrawTexturedRectRounded((ScW - tempGaugeWid) / 2, ScH - 90 + 5, Wid, 20, 4, 4, true, false, true, false)
		surface.DrawTexturedRectRounded(Wid + XMinX + Wid2-1, ScH - 90 + 5, tempGaugeWid - Wid - Wid2 + 1, 20, 4, 4, false, true, false , true)

		surface.DrawTexturedRectRounded(Wid + XMinX-1, ScH - 90 + 5, Wid2, 20, 2, 2, false, false, false, false)

		--surface.SetTexture(textSlider)
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 20)

		local Perc = math.Clamp(ls_tmp / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid
		local XWidX = XMinX + Wid

		--surface.RoundedBoxTextued(cornerRadius, x, y, width, height, divisions)
		surface.DrawTexturedRect(XWidX-1, ScH - 98, 2, 34)
		--surface.DrawTexturedRect(XWidX - 8+4, ScH - 98, 2, 34)
		surface.DrawTexturedRect(XWidX-1, ScH - 98, 6, 10)

		local xMyTemp = goodTemp
		if ls_tmp < FairTemp_Min then xMyTemp = coolTemp
		elseif ls_tmp > FairTemp_Max then xMyTemp = hotTemp end


		-- temperature texts

		draw.SimpleTextOutlined(tostring(ls_tmp) .. tempUnit, "ScoreboardDefault", XWidX-3, ScH - 122, xMyTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)

		draw.SimpleTextOutlined(tostring(GlobalTemp_Min) .. tempUnit, "Default", XMinX, ScH - 55, coolTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)
		draw.SimpleTextOutlined(tostring(GlobalTemp_Max) .. tempUnit, "Default", XMinX + 380, ScH - 55, hotTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)



	end
	--END OF TEMPERATURE

	local BarNum = 0
	local ColText = yellow
	if ls_current_unhabitable or lp:WaterLevel() > 2 then
		BarNum = BarNum + 1
		DrawLSBar(BarNum, "Air", ls_air, ScH, ScW, HUDGrey, ColText)
		if ls_tmp < FairTemp_Min then
			BarNum = BarNum + 1
			DrawLSBattery("Energy", ls_energy, ScH, ScW, HUDGrey, ColText)
		elseif ls_tmp > FairTemp_Max then
			BarNum = BarNum + 1
			DrawLSBar(BarNum, "Coolant", ls_coolant, ScH, ScW, HUDGrey, ColText)
		end
	end
end
hook.Add("HUDPaint", "SA_CustomHUDPaint", SA_CustomHUDPaint)
