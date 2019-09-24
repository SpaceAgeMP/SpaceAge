include("shared.lua")

require("supernet")

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.allowDraw = false

local SA_PosColors = { Color(255,255,0,255), Color(128,128,128,255), Color(128,50,0,255) }

local statsAllowDraw = false
local SA_StatsTable = {}

function ENT:Initialize()
	self.scrollPos = 0
	self.doScroll = false
	self.scrollAgainTimer = false
	self.scrollSpeed = -1
	self.linesSeen = true
	self.allowDraw = true
end

function ENT:Draw()
	self:DrawModel()
	if (not self.allowDraw) then return true end
	--if (not statsAllowDraw) then return true end --Nah, well, we still draw while refreshing, flashes get annoying
	--nighteagle screen vector rotation and positioning legacy code
	local OF = 0
	local OU = 0
	local OR = 0
	local Res = 0
	local RatioX = 0

	if (WireGPU_Monitors[self:GetModel()]) and (WireGPU_Monitors[self:GetModel()].OF) then
		OF = WireGPU_Monitors[self:GetModel()].OF
		OU = WireGPU_Monitors[self:GetModel()].OU
		OR = WireGPU_Monitors[self:GetModel()].OR
		Res = WireGPU_Monitors[self:GetModel()].RS
		RatioX = WireGPU_Monitors[self:GetModel()].RatioX
	else
		OF = 0
		OU = 0
		OR = 0
		Res = 1
		RatioX = 1
	end

	local ang = self:GetAngles()
	local rot = Vector(-90,90,0)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), 	rot.z)

	local pos = self:GetPos()+(self:GetForward()*OF)+(self:GetUp()*OU)+(self:GetRight()*OR)
	if self.doScroll then
		self.scrollPos = self.scrollPos + self.scrollSpeed
	elseif not self.scrollAgainTimer then
		timer.Simple(3,function()
			self.doScroll = 1
			self.scrollAgainTimer = false
		end)
		self.scrollAgainTimer = true
	end

	cam.Start3D2D(pos,ang,Res)
		local w = 512
		local h = 512
		local x = -w/2
		local y = -h/2

		local WhiteColor = Color(255, 255, 255, 255)

		local ySpace = 35

		local justOffset = (w / 3)

		local xColumns = { (x + justOffset - 45) / RatioX, (x + justOffset - 5) / RatioX, (x + justOffset + 200) / RatioX, (x + justOffset + 330) / RatioX }

		--add changable backround colour some time.
		surface.SetDrawColor(0,0,0,255)

		surface.DrawRect(x,y,w/RatioX,h)

		local imax = table.maxn(SA_StatsTable)
		local i = 0
		if imax > 0 then
			for i=0,imax+1 do
				local lowLinePos = y + 107 + ((i-1) * ySpace)
				local linePos = lowLinePos + self.scrollPos
				if linePos <= (y+h) and linePos >= ((y + 117) - ySpace) then
					if i > imax then
						self.doScroll = false
						self.scrollSpeed = 1
					elseif i < 1 then
						self.doScroll = false
						self.scrollSpeed = -1
					end
					if SA_StatsTable[i] then
						local FactionColor = SA_StatsTable[i]["factioncolor"]
						local PosColor = WhiteColor
						if ( SA_PosColors[i] ) then PosColor = SA_PosColors[i] end
						draw.DrawText(tostring(i), "textScreenfont10", xColumns[1], linePos, PosColor, 0)
						draw.DrawText(SA_StatsTable[i]["name"], "textScreenfont10", xColumns[2], linePos, FactionColor, 0)
						draw.DrawText(SA_StatsTable[i]["score"], "textScreenfont10", xColumns[3], linePos, PosColor, 0)
					end
				end
			end
		end

		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(x,y,w/RatioX,123)

		local headerY = y + 117 - ySpace

		draw.DrawText("Player Name", "textScreenfont10", xColumns[2], headerY, WhiteColor, 0)
		draw.DrawText("Score", "textScreenfont10", xColumns[3], headerY, WhiteColor, 0)


		draw.DrawText("SpaceAge - Leaderboard", "textScreenfont5", justOffset + 45, y + 7, WhiteColor,  1)

	cam.End3D2D()
	Wire_Render(self)
end

local SA_MaxNameLength = 24
local SA_PlayersToShow = 30

local function SA_ReceiveStatsUpdate(ply, decoded)
	statsAllowDraw = false

	for i, v in pairs(decoded) do
		SA_StatsTable[i] = {}
		SA_StatsTable[i]["name"] = string.Left(v["name"],SA_MaxNameLength)
		SA_StatsTable[i]["score"] = SA.AddCommasToInt(v["score"])
		local tempColor = SA.Factions.Colors[v["groupname"]]
		if (not tempColor) then tempColor = Color(255,100,0,255) end
		SA_StatsTable[i]["factioncolor"] = tempColor
		tempColor = Color(255,255,255,255)
		if tcredits < 0 then tempColor = Color(255,0,0,255) end
		if tcredits > 0 then tempColor = Color(0,255,0,255) end
		SA_StatsTable[i]["statscolor"] = tempColor
	end

	statsAllowDraw = true
end
supernet.Hook("SA_StatsUpdate",SA_ReceiveStatsUpdate)

function ENT:IsTranslucent()
	return true
end
