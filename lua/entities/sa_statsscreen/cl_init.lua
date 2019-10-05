include("shared.lua")

require("supernet")

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.allowDraw = false

local SA_PosColors = { Color(255, 255, 0, 255), Color(128, 128, 128, 255), Color(128, 50, 0, 255) }

function ENT:Initialize()
	self.scrollPos = 0
	self.doScroll = false
	self.scrollAgainTimer = false
	self.scrollSpeed = -1
	self.linesSeen = true
	self.allowDraw = true
end

local white = Color(255, 255, 255, 255)

function ENT:Draw()
	self:DrawModel()
	if (not self.allowDraw) then return true end

	local OF = 0
	local OU = 0
	local OR = 0
	local Res = 0
	local RatioX = 0

	local monEntry = WireGPU_Monitors[self:GetModel()]
	if (monEntry and monEntry.OF) then
		OF = monEntry.OF
		OU = monEntry.OU
		OR = monEntry.OR
		Res = monEntry.RS
		RatioX = monEntry.RatioX
	else
		OF = 0
		OU = 0
		OR = 0
		Res = 1
		RatioX = 1
	end

	local ang = self:GetAngles()
	local rot = Vector(-90, 90, 0)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), 	rot.z)

	local pos = self:GetPos() + (self:GetForward() * OF) + (self:GetUp() * OU) + (self:GetRight() * OR)
	if self.doScroll then
		self.scrollPos = self.scrollPos + self.scrollSpeed
	elseif not self.scrollAgainTimer then
		timer.Simple(3, function()
			self.doScroll = 1
			self.scrollAgainTimer = false
		end)
		self.scrollAgainTimer = true
	end

	cam.Start3D2D(pos, ang, Res)
		local w = 512
		local h = 512
		local x = -w / 2
		local y = -h / 2

		local ySpace = 35

		local justOffset = (w / 3)

		local xColumns = { (x + justOffset - 45) / RatioX, (x + justOffset - 5) / RatioX, (x + justOffset + 200) / RatioX, (x + justOffset + 330) / RatioX }

		--add changable backround colour some time.
		surface.SetDrawColor(0, 0, 0, 255)

		surface.DrawRect(x, y, w / RatioX, h)

		local imax = table.maxn(SA.StatsTable)
		if imax > 0 then
			for i = 0, imax + 1 do
				local lowLinePos = y + 107 + ((i-1) * ySpace)
				local linePos = lowLinePos + self.scrollPos
				if linePos <= (y + h) and linePos >= ((y + 117) - ySpace) then
					if i > imax then
						self.doScroll = false
						self.scrollSpeed = 1
					elseif i < 1 then
						self.doScroll = false
						self.scrollSpeed = -1
					end
					if SA.StatsTable[i] then
						local FactionColor = SA.StatsTable[i].FactionColor
						local PosColor = white
						if (SA_PosColors[i]) then PosColor = SA_PosColors[i] end
						draw.DrawText(tostring(i), "textScreenfont10", xColumns[1], linePos, PosColor, 0)
						draw.DrawText(SA.StatsTable[i].name, "textScreenfont10", xColumns[2], linePos, FactionColor, 0)
						draw.DrawText(SA.StatsTable[i].score, "textScreenfont10", xColumns[3], linePos, PosColor, 0)
					end
				end
			end
		end

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x, y, w / RatioX, 123)

		local headerY = y + 117 - ySpace

		draw.DrawText("Player Name", "textScreenfont10", xColumns[2], headerY, WhiteColor, 0)
		draw.DrawText("Score", "textScreenfont10", xColumns[3], headerY, WhiteColor, 0)


		draw.DrawText("SpaceAge - Leaderboard", "textScreenfont5", justOffset + 45, y + 7, WhiteColor,  1)

	cam.End3D2D()
	Wire_Render(self)
end

function ENT:IsTranslucent()
	return true
end
