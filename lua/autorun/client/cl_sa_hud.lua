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
	local BarHei = 80
	local BarSpace = 32
	local BarWid = 18
	local Hei = (ScH - 15) - BarHei - 4
	local XMinX = ScW / 2 - tempGaugeWid / 2 - (BarWid + BarSpace) * BarNum - 54

	--draw.RoundedBox(4, xPos-8, yPos-40, MeterWid+22, MeterHei+12 + 40, ColBack)
	--draw.RoundedBox(4, XMinX-8, Hei-32, BarWid + 16, BarHei + 12 + 30, ColBack)

	draw.RoundedBox(4, XMinX + 3, Hei + 6, BarWid-6, BarHei-6, transparentGrey)
	draw.SimpleText(Caption, HUDFont, XMinX + BarWid / 2-1, Hei -20, ColText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Perc = Value / 4000

	local ValCol = Color(255 * (1-Perc), 255 * Perc, 0, 255)

	if Value > 0 then
		local YHei = (BarHei-10)  * Perc
		YHei = math.max(YHei,4)
		draw.RoundedBoxEx(4, XMinX + 6, math.Round(Hei + BarHei - 2) - math.Round(YHei), BarWid-12, math.Round(YHei), ValCol, true, true, true, true)
		draw.SimpleText(tostring(math.Round(Perc * 100,2)) .. " %", HUDFont, XMinX + BarWid / 2-1, Hei - 4, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	local MeterHei = 80-14
	local MeterWid = 30
	local batteryTipHei = 10
	local batteryTipWid = 16

	-- the width of the lines drawn
	local batLineWid = 6

	local slantAmount = 4
	local slantHei = 7
	local slantWid = MeterWid - batLineWid * 2
	local gapSize = 4

	local yPos = (ScH - MeterHei) - 25
	local xPos = (ScW / 2) + (tempGaugeWid / 2) + MeterWid + 40


	local ValCol = Color(255 * (1-(Value / 4000)), 255 * (Value / 4000), 0, 255)

	local batteryColor = transparentDarkerGrey

	--draw.RoundedBox(4, xPos-8, yPos-40, MeterWid + 22, MeterHei + 16 + 40, ColBack)

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

--_dipWidth
   --|--------------|--

--LineYPos--\              /-------          --
        -----\            /-----             | _dipHeight
        ------\__________/-----             --

    --|----------|--
--_dipPlateu


local function DrawScreenLineWithDip(_lineYPos, _lineWidth, _dipHeight, _dipWidth, _dipPlateu, _isOutline, _isBottom)

	local healthAreaOffsetH = 210
	local healthAreaOffsetW = 110

--surface.DrawLine(0, 1,1119,1120)
	if (not _isBottom) then
		_isBottom = false
	end

	if (not _isOutline) then
		_isOutline = false
	end

	local leftSide = {}
	-- left to right top of line
	--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
	table.insert(leftSide, {x = 0, y = _lineYPos})
	table.insert(leftSide, {x = ScrW()/2-_dipWidth/2, y = _lineYPos})

	table.insert(leftSide, {x = ScrW()/2-_dipWidth/2, y = _lineYPos + _lineWidth})
	table.insert(leftSide, {x = 0, y = _lineYPos + _lineWidth})

	local leftSlope = {}
	-- left to right top of line
	--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
	table.insert(leftSlope, {x = ScrW()/2-_dipWidth/2, y = _lineYPos})
	table.insert(leftSlope, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipHeight})
	table.insert(leftSlope, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipHeight + _lineWidth})
	table.insert(leftSlope, {x = ScrW()/2-_dipWidth/2, y = _lineYPos + _lineWidth})

	local plateu = {}

	table.insert(plateu, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipHeight})
	table.insert(plateu, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipHeight})

	table.insert(plateu, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipHeight + _lineWidth})
	table.insert(plateu, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipHeight + _lineWidth})


	local rightSlope = {}
	-- left to right top of line
	--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
	table.insert(rightSlope, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipHeight})
	table.insert(rightSlope, {x = ScrW()/2+_dipWidth/2, y = _lineYPos})
	table.insert(rightSlope, {x = ScrW()/2+_dipWidth/2, y = _lineYPos + _lineWidth})
	table.insert(rightSlope, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipHeight + _lineWidth})

	local rightSide = {}
	local rightSideRight = ScrW()
	if (_isBottom) then
		rightSideRight = rightSideRight - healthAreaOffsetW
	end
	-- left to right top of line
	--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
	table.insert(rightSide, {x = ScrW()/2+_dipWidth/2, y = _lineYPos})
	table.insert(rightSide, {x = rightSideRight, y = _lineYPos})
	table.insert(rightSide, {x = rightSideRight, y = _lineYPos+ _lineWidth})
	table.insert(rightSide, {x = ScrW()/2+_dipWidth/2, y = _lineYPos + _lineWidth})

	surface.DrawPoly(leftSlope)
	surface.DrawPoly(leftSide)
	surface.DrawPoly(plateu)
	surface.DrawPoly(rightSlope)
	surface.DrawPoly(rightSide)

	if (_isBottom == true) then

		local healthAreaLeft = {}
		-- left to right top of line
		--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
		table.insert(healthAreaLeft, {x = ScrW() - healthAreaOffsetW, y = _lineYPos + _lineWidth})
		table.insert(healthAreaLeft, {x = ScrW() - healthAreaOffsetW, y = _lineYPos - healthAreaOffsetH})
		table.insert(healthAreaLeft, {x = ScrW() - healthAreaOffsetW + _lineWidth, y = _lineYPos - healthAreaOffsetH})
		table.insert(healthAreaLeft, {x = ScrW() - healthAreaOffsetW + _lineWidth, y = _lineYPos + _lineWidth})

		surface.DrawPoly(healthAreaLeft)

		if (_isOutline) then
			local healthAreaTop = {}
			-- left to right top of line
			--surface.DrawLine(0, _lineYPos,ScrW()/2-_dipWidth/2, _lineYPos)
			table.insert(healthAreaTop, {x = ScrW() - healthAreaOffsetW + _lineWidth, y = _lineYPos - healthAreaOffsetH})
			table.insert(healthAreaTop, {x = ScrW(), y = _lineYPos - healthAreaOffsetH})
			table.insert(healthAreaTop, {x = ScrW(), y = _lineYPos - healthAreaOffsetH + _lineWidth})
			table.insert(healthAreaTop, {x = ScrW() - healthAreaOffsetW + _lineWidth, y = _lineYPos - healthAreaOffsetH + _lineWidth})

			surface.DrawPoly(healthAreaTop)
		end

	end


	--table.insert(stylizedLinePoly, {x = 0, y = _lineYPos})
	--table.insert(stylizedLinePoly, {x = ScrW()/2-_dipWidth/2, y = _lineYPos})
	--table.insert(stylizedLinePoly, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipPlateu})
	--table.insert(stylizedLinePoly, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipPlateu})
	--table.insert(stylizedLinePoly, {x = ScrW()/2+_dipWidth/2, y = _lineYPos})
	--table.insert(stylizedLinePoly, {x = ScrW(), y = _lineYPos})

	-- left to right bottom of line
	--table.insert(stylizedLinePoly, {x = ScrW(), y = _lineYPos + _lineWidth})
	--table.insert(stylizedLinePoly, {x = ScrW()/2+_dipWidth/2, y = _lineYPos + _lineWidth})
	--table.insert(stylizedLinePoly, {x = ScrW()/2+_dipPlateu/2, y = _lineYPos + _dipPlateu + _lineWidth})
	--table.insert(stylizedLinePoly, {x = ScrW()/2-_dipPlateu/2, y = _lineYPos + _dipPlateu + _lineWidth})
	--table.insert(stylizedLinePoly, {x = ScrW()/2-_dipWidth/2, y = _lineYPos + _lineWidth})
	--table.insert(stylizedLinePoly, {x = 0, y = _lineYPos + _lineWidth})

	--print("--")
	--PrintTable(stylizedLinePoly)
	--surface.DrawCircle(ScrW()/2,ScrH()/2,20,255,255,255)





	--surface.DrawLine(0, 0,220,220)

end

--local function surface.drawLineThick(_lineX2, _lineY2, _lineX2, _lineY2, _thickness)
--	table.insert(stylizedLinePoly, {x = 0, y = _lineYPos})
--end

local function SA_DrawHelmet(color)
	-- draw fills
	surface.SetDrawColor( 0, 0, 0, 160 )
	draw.NoTexture()

	DrawScreenLineWithDip(ScrH()-160, 200, 60, 600, 300, false, true)
	DrawScreenLineWithDip(-171, 200, 40, 600, 300)


	-- draw border
	surface.SetDrawColor( color )
	draw.NoTexture()
	DrawScreenLineWithDip(ScrH()-160, 5, 60, 600, 300, true, true)
	DrawScreenLineWithDip(24, 5, 40, 600, 300)
end

local credits = "LOADING"
local totalCredits = "LOADING"
local playtime = 0
local formattedPlaytime = "LOADING"
local function sa_info_msg_credsc(len, ply)
	credits = SA.AddCommasToInt(net.ReadString())
	totalCredits = SA.AddCommasToInt(net.ReadString())
	playtime = net.ReadInt(32)
	formattedPlaytime = SA.FormatTime(playtime)
end
net.Receive("SA_SendBasicInfo", sa_info_msg_credsc)
timer.Create("SA_IncPlayTime", 1, 0, function()
	playtime = playtime + 1
	formattedPlaytime = SA.FormatTime(playtime)
end)

local function SA_DrawTopBar()
	local topBarSections = 6
	local ScH = ScrH()
	local lp = LocalPlayer()

	local yPos = 0
	--section width
	local sectionWid = ScrW()/topBarSections

	local section = {
		sectionWid*1 - sectionWid/2,
		sectionWid*2 - sectionWid/2,
		sectionWid*3 - sectionWid/2,
		sectionWid*4 - sectionWid/2,
		sectionWid*5 - sectionWid/2,
		sectionWid*6 - sectionWid/2
	}

	local topBarFont = "ScoreboardDefault"



	draw.SimpleText("Name: " .. lp:Name(), topBarFont, section[1], yPos, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Playtime: " .. formattedPlaytime, topBarFont, section[5], yPos, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Score: " .. totalCredits, topBarFont, section[6], yPos, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.SimpleText("Faction: " .. team.GetName(LocalPlayer():Team()), topBarFont, ScrW()/2, yPos+8, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Credits: " .. credits, topBarFont, ScrW()/2, yPos+26+8, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

end

local function SA_CustomHUDPaint()
	if GetConVarNumber("cl_drawhud") == 0 then return end
	SA_DrawHelmet(team.GetColor(LocalPlayer():Team()))
	SA_DrawTopBar()

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

		local tempX = ScW/2 - tempGaugeWid/2
		local tempY = ScrH() - 55
		--draw.RoundedBox(4, (ScW - tempGaugeWid) / 2, tempY + 5, Wid, 40, coolTemp)
		--draw.RoundedBox(4, Wid + XMinX, tempY + 5, tempGaugeWid - Wid, 40, hotTemp)

		local outlineW = 2

		--temp bar outline
		surface.SetDrawColor(black)
		draw.NoTexture()
		surface.DrawTexturedRectRounded( tempX - outlineW, tempY + 5 - outlineW, tempGaugeWid + outlineW * 2 + 1, 20 + outlineW * 2, 4, 4, true, true, true, true)

		-- cool temp
		surface.SetDrawColor(coolTemp)
		draw.NoTexture()
		surface.DrawTexturedRectRounded( tempX, tempY + 5, Wid, 20, 4, 4, true, false, true, false)

		-- hot temp
		surface.SetDrawColor(hotTemp)
		surface.DrawTexturedRectRounded( tempX + Wid, tempY + 5, tempGaugeWid - Wid, 20, 4, 4, false, true, false ,true )


		local Perc = math.Clamp(FairTemp_Min / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid
		local Perc2 = math.Clamp(FairTemp_Max / GlobalTemp_Max, 0, 1)
		local Wid2 = math.Clamp(Perc2 - Perc, 0, 1) * tempGaugeWid

		-- good temp

		surface.SetDrawColor(goodTemp)
		surface.DrawTexturedRectRounded(tempX + Wid, tempY + 5, Wid2-2, 20, 1, 3, true, true, true ,true )


		-- fade blue-red-green

		surface.SetDrawColor(green)
		surface.SetTexture(surface.GetTextureID("vgui/gradient-r"))
		surface.DrawTexturedRect(tempX + Wid-1, tempY + 5, 5, 20)

		surface.SetTexture(surface.GetTextureID("vgui/gradient-l"))
		surface.DrawTexturedRect(tempX + Wid + Wid2 -5, tempY + 5, 5, 20)



		--dark gradients
		surface.SetDrawColor(Color(0, 0, 0, 235))
		surface.SetTexture(surface.GetTextureID("vgui/gradient-d"))
		surface.DrawTexturedRectRounded( tempX, tempY + 5, Wid, 20, 4, 4, true, false, true, false)
		surface.DrawTexturedRectRounded( Wid + tempX + Wid2, tempY + 5, tempGaugeWid - Wid - Wid2 + 1, 20, 4, 4, false, true, false ,true )

		surface.DrawTexturedRectRounded( Wid + tempX, tempY + 5, Wid2, 20, 2, 2, false, false, false, false)


		surface.SetTexture(surface.GetTextureID("vgui/gradient-u"))
		--surface.DrawTexturedRectRounded( tempX, tempY + 5, Wid, 20, 4, 4, true, false, true, false)
		--surface.DrawTexturedRectRounded( Wid + tempX + Wid2-1, tempY + 5, tempGaugeWid - Wid - Wid2 + 1, 20, 4, 4, false, true, false ,true )

		--surface.DrawTexturedRectRounded( Wid + tempX, tempY + 5, Wid2, 20, 2, 2, false, false, false, false)

		--surface.SetTexture(textSlider)
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 20)

		local Perc = math.Clamp(ls_tmp / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid
		local XWidX = math.min(XMinX + Wid, XMinX + tempGaugeWid-2)

		--surface.RoundedBoxTextued( cornerRadius, x, y, width, height, divisions )
		surface.DrawTexturedRect(XWidX, tempY - 8, 2, 34)
		--surface.DrawTexturedRect(XWidX - 8+4, ScH - 98, 2, 34)
		surface.DrawTexturedRect(XWidX, tempY - 8, 6, 10)

		local xMyTemp = goodTemp
		if ls_tmp < FairTemp_Min then xMyTemp = coolTemp
		elseif ls_tmp > FairTemp_Max then xMyTemp = hotTemp end


		-- temperature texts

		draw.SimpleTextOutlined(tostring(ls_tmp) .. tempUnit, "ScoreboardDefault", XWidX-3, tempY-32, xMyTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)

		draw.SimpleTextOutlined(tostring(GlobalTemp_Min) .. tempUnit, "Default", tempX, tempY + 35, coolTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)
		draw.SimpleTextOutlined(tostring(GlobalTemp_Max) .. tempUnit, "Default", tempX + 380, tempY + 35, hotTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0, veryDarkGrey)



	end
	--END OF TEMPERATURE

	local BarNum = 0
	local ColText = yellow
	if ls_current_unhabitable or lp:WaterLevel() > 2 then
		BarNum = BarNum + 1
		DrawLSBar(BarNum, "Air", ls_air, ScH, ScW, HUDGrey, ColText)
		if ls_tmp < FairTemp_Min then
			BarNum = BarNum + 1
			DrawLSBattery("Energy",ls_energy,ScH,ScW,HUDGrey,ColText)
		elseif ls_tmp > FairTemp_Max then
			BarNum = BarNum + 1
			DrawLSBar(BarNum, "Coolant", ls_coolant, ScH, ScW, HUDGrey, ColText)
		end
	end
end
hook.Add("HUDPaint", "SA_CustomHUDPaint", SA_CustomHUDPaint)
