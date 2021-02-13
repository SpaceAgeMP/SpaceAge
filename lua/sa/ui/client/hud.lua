local Color = Color
local draw = draw
local math = math
local net = net
local ScrH = ScrH
local ScrW = ScrW
local surface = surface
local team = team
local tostring = tostring

SA.REQUIRE("ui.functions")
local DrawTexturedRectRounded = SA.UI.DrawTexturedRectRounded

local alwaysshowtemp = CreateClientConVar("cl_alwaysshowtemperature", 0, true, false)
local drawHud = GetConVar("cl_drawhud")

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

local function LS_net_hook1()
	ls_habitat = net.ReadFloat()
	ls_air = net.ReadInt(32)
	ls_tmp = net.ReadInt(32)
	ls_coolant = net.ReadInt(32)
	ls_energy = net.ReadInt(32)
end

local function LS_net_hook2()
	ls_air = net.ReadInt(32)
end

local function CheckHookIn()
	if not ConVarExists("LS_Display_HUD") then
		return
	end
	RunConsoleCommand("LS_Display_HUD", "0")
	net.Receive("LS_umsg1", LS_net_hook1)
	net.Receive("LS_umsg2", LS_net_hook2)
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

local WeaponMaxAmmo = {
	weapon_pistol = 18,
	weapon_357 = 6,
	weapon_smg1 = 45,
	weapon_ar2 = 30,
	weapon_shotgun = 6,
	weapon_crossbow = 1,
	weapon_frag = 0,
	weapon_rpg = 0,
	weapon_crowbar = 0,
	weapon_stunstick = 0,
	weapon_physcannon = 0,
	weapon_physgun = 0
}

local function GetMaxAmmo(SWEP)
	if SWEP.Primary and SWEP.Primary.ClipSize then
		return SWEP.Primary.ClipSize
	end

	local MAmmo = WeaponMaxAmmo[SWEP:GetClass()]
	if MAmmo then return MAmmo end

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

local function DrawMeterSlantSection(slantAmount, width, height, xMax, yMax, yMaxCut, yMinCut)

	--remember gmod y axis is flipped if you go to change anything! variable names can be confusing, always think about y direction!

	local xMin = xMax - width
	local yMin = yMax - height



	-- if the top right point is less than  our current value (as a bar y position)
	local cutAmount = 0
	if ((yMin - slantAmount) < yMinCut) then
		cutAmount = math.abs(yMinCut-yMin)
	end

	-- this shouldn't happen, but just in case...
	if (cutAmount >= height) then
		return
	end

	draw.NoTexture()
	local slantSection = {
		-- top left, top right, bottom left, bottom right
		{x = xMin, y = yMin - slantAmount + cutAmount, u = 0, v = 1},
		{x = xMax, y = yMin + cutAmount, u = 1, v = 1},
		{x = xMax, y = yMax, u = 1, v = 0},
		{x = xMin, y = yMax - slantAmount, u = 0, v = 0}
	}

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

	local batteryColor = transparentDarkerGrey

	local batteryMeterColor = Color(255 * (1-(Value / 4000)), 255 * (Value / 4000), 0, 255)
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

	local heightWithGap = slantHei + gapSize

	local batMeterHei = MeterHei - batteryTipHei - batLineWid * 2

	-- take the modulus of the heightWithGap, that lets us know how much leftover height there is, take that height away.
	-- now when we divide by the heightWithGap we'll have the number of slants we need to draw
	local slantCount = (batMeterHei - (batMeterHei % heightWithGap)) / heightWithGap

	local bottomY = yPos + MeterHei - batLineWid / 2

	-- easiest start position is giving an xMin and yMax, that's the only spot that's on the bottom of the battery, so that's what the section drawing function uses
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
		draw.SimpleText(tostring(Perc * 100) .. " %", HUDFont, xPos + (MeterWid + batLineWid) / 2, yPos -12, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif SA_HUDBlink then
		draw.SimpleText("EMPTY", HUDFont, xPos + (MeterWid + batLineWid) / 2, yPos - 12, ValCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function SA_DrawHelmet(color)
	draw.NoTexture()
	local w = ScrW()

	-- draw fills
	surface.SetDrawColor(0, 0, 0, 160)
	surface.DrawRect(0, 0, w, 25)

	-- draw border
	surface.SetDrawColor(color)
	surface.DrawRect(0, 25, w, 5)
end

local function SA_DrawTopBar()
	local topBarSections = 5
	local lp = LocalPlayer()

	local yPos = 0
	--section width
	local sectionWid = ScrW() / topBarSections

	local section = {
		sectionWid * 1 - sectionWid / 2,
		sectionWid * 2 - sectionWid / 2,
		sectionWid * 3 - sectionWid / 2,
		sectionWid * 4 - sectionWid / 2,
		sectionWid * 5 - sectionWid / 2
	}

	local topBarFont = "ScoreboardDefault"

	draw.SimpleText("Name: " .. lp:Name(), topBarFont, section[1], yPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Faction: " .. team.GetName(lp:Team()), topBarFont, section[2], yPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	if not lp.sa_data then
		return
	end

	draw.SimpleText("Playtime: " .. lp.sa_data.formatted_playtime, topBarFont, section[3], yPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Score: " .. lp.sa_data.formatted_score, topBarFont, section[4], yPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.SimpleText("Credits: " .. lp.sa_data.formatted_credits, topBarFont, section[5], yPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local texGradR = surface.GetTextureID("vgui/gradient-r")
local texGradL = surface.GetTextureID("vgui/gradient-l")
local texGradD = surface.GetTextureID("vgui/gradient-d")
local texGradU = surface.GetTextureID("vgui/gradient-u")


local function SA_CustomHUDPaint()
	if drawHud:GetInt() == 0 then return end
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

	local healthHeightMult = 290
	local healthInset = 40
	if armor > 0 then
		healthHeightMult = 274
		healthInset = 56
	end

	local PlRelX = health / 100
	if PlRelX > 1 then PlRelX = 1 end
	local PlHeightX = math.max(PlRelX * healthHeightMult, 4)
	draw.RoundedBox(4, ScW - 70, (ScH - healthInset) - PlHeightX, 40, PlHeightX, HUDHealth)
	draw.SimpleText(health, HUDFont, ScW - 50, ScH - 38, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	if (armor > 0) then
		local ammoPlRelX = armor / 100
		if ammoPlRelX > 1 then ammoPlRelX = 1 end
		local ammoPlHeightX = math.max(ammoPlRelX * healthHeightMult, 4)
		draw.RoundedBox(2, ScW - 70, (ScH - healthInset) - ammoPlHeightX, 10, ammoPlHeightX, HUDArmor)
		draw.SimpleText(armor, HUDFont, ScW - 50, ScH - 54, HUDArmor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF HEALTH AND ARMOR

	--BEGIN OF AMMO
	local ammoHeightMult = 190
	local ammoInset = 40
	if secAmmo > 0 then
		ammoHeightMult = 174
		ammoInset = 56
	end
	local primAmmoX = SWEP:Clip1()
	if primMaxAmmo > 0 and primAmmoX > 0 then
		local OneAmmoH = (ammoHeightMult / primMaxAmmo) - 3
		surface.SetDrawColor(HUDAmmo1)
		for i = 1, primAmmoX, 1 do
			local primAmmoPlRelX = i / primMaxAmmo
			if primAmmoPlRelX > 1 then primAmmoPlRelX = 1 end
			local primAmmoPlHeightX = primAmmoPlRelX * ammoHeightMult
			surface.DrawRect(ScW - 132, (ScH - ammoInset) - primAmmoPlHeightX, 40, OneAmmoH)
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

		local Perc = math.Clamp(FairTemp_Mid / GlobalTemp_Max, 0, 1)
		local Wid = Perc * tempGaugeWid

		local tempX = ScW / 2 - tempGaugeWid / 2
		local tempY = ScrH() - 55

		local outlineW = 2

		--temp bar outline
		surface.SetDrawColor(black)
		draw.NoTexture()
		DrawTexturedRectRounded(tempX - outlineW, tempY + 5 - outlineW, tempGaugeWid + outlineW * 2 + 1, 20 + outlineW * 2, 4, 4, true, true, true, true)

		-- cool temp
		surface.SetDrawColor(coolTemp)
		draw.NoTexture()
		DrawTexturedRectRounded(tempX, tempY + 5, Wid, 20, 4, 4, true, false, true, false)

		-- hot temp
		surface.SetDrawColor(hotTemp)
		DrawTexturedRectRounded(tempX + Wid, tempY + 5, tempGaugeWid - Wid, 20, 4, 4, false, true, false ,true)

		local MinWid = math.Clamp(FairTemp_Min / GlobalTemp_Max, 0, 1) * tempGaugeWid
		local Perc2 = math.Clamp(FairTemp_Max / GlobalTemp_Max, 0, 1)
		local Wid2 = math.Clamp(Perc2 - Perc, 0, 1) * tempGaugeWid

		-- good temp

		surface.SetDrawColor(goodTemp)
		DrawTexturedRectRounded(tempX + MinWid, tempY + 5, Wid2-2, 20, 1, 3, true, true, true ,true)


		-- fade blue-red-green

		surface.SetDrawColor(green)
		surface.SetTexture(texGradR)
		surface.DrawTexturedRect(tempX + MinWid-1, tempY + 5, 5, 20)

		surface.SetTexture(texGradL)
		surface.DrawTexturedRect(tempX + MinWid + Wid2 -5, tempY + 5, 5, 20)

		--dark gradients
		surface.SetDrawColor(Color(0, 0, 0, 235))
		surface.SetTexture(texGradD)
		DrawTexturedRectRounded(tempX, tempY + 5, MinWid, 20, 4, 4, true, false, true, false)
		DrawTexturedRectRounded(MinWid + tempX + Wid2, tempY + 5, tempGaugeWid - MinWid - Wid2 + 1, 20, 4, 4, false, true, false ,true)

		DrawTexturedRectRounded(MinWid + tempX, tempY + 5, Wid2, 20, 2, 2, false, false, false, false)


		surface.SetTexture(texGradU)

		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 20)

		local XWid = math.Clamp(ls_tmp / GlobalTemp_Max, 0, 1) * tempGaugeWid
		local XWidX = math.min(XMinX + XWid, XMinX + tempGaugeWid-2)

		--surface.RoundedBoxTextued(cornerRadius, x, y, width, height, divisions)
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
			DrawLSBattery("Energy",ls_energy,ScH,ScW,HUDGrey,ColText)
		elseif ls_tmp > FairTemp_Max then
			BarNum = BarNum + 1
			DrawLSBar(BarNum, "Coolant", ls_coolant, ScH, ScW, HUDGrey, ColText)
		end
	end
end
hook.Add("HUDPaint", "SA_CustomHUDPaint", SA_CustomHUDPaint)
