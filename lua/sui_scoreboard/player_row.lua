include("player_infocard.lua")

--checking for utime for the hours
utimecheck = false


--checking for ulib for the team names
ulibcheck = false
if file.Exists("ulib/cl_init.lua", "LUA") then
	ulibcheck = true
end

local texGradient = surface.GetTextureID("gui/center_gradient")

/*local texRatings = {}
texRatings['none'] 		= surface.GetTextureID("gui/silkicons/user")
texRatings['smile'] 		= surface.GetTextureID("gui/silkicons/emoticon_smile")
texRatings['lol'] 		= surface.GetTextureID("gui/silkicons/emoticon_smile")
texRatings['gay'] 		= surface.GetTextureID("gui/gmod_logo")
texRatings['stunter'] 	= surface.GetTextureID("gui/inv_corner16")
texRatings['god'] 		= surface.GetTextureID("gui/gmod_logo")
texRatings['curvey'] 		= surface.GetTextureID("gui/corner16")
texRatings['best_landvehicle']	= surface.GetTextureID("gui/faceposer_indicator")
texRatings['best_airvehicle'] 		= surface.GetTextureID("gui/arrow")
texRatings['naughty'] 	= surface.GetTextureID("gui/silkicons/exclamation")
texRatings['friendly']	= surface.GetTextureID("gui/silkicons/user")
texRatings['informative']	= surface.GetTextureID("gui/info")
texRatings['love'] 		= surface.GetTextureID("gui/silkicons/heart")
texRatings['artistic'] 	= surface.GetTextureID("gui/silkicons/palette")
texRatings['gold_star'] 	= surface.GetTextureID("gui/silkicons/star")
texRatings['builder'] 	= surface.GetTextureID("gui/silkicons/wrench")

surface.GetTextureID("gui/silkicons/emoticon_smile")*/

local PANEL = {}

function PANEL:Paint(w, h)
	if not IsValid(self.Player) then
		self:Remove()
		SCOREBOARD:InvalidateLayout()
		return
	end

	local color = Color(100, 100, 100, 255)

	if self.Armed then
		color = Color(125, 125, 125, 255)
	end

	if self.Selected then
		color = Color(125, 125, 125, 255)
	end

	if self.Player:Team() == TEAM_CONNECTING then
		color = Color(100, 100, 100, 155)
	elseif IsValid(self.Player) then
		if self.Player:Team() == TEAM_UNASSIGNED then
			color = Color(100, 100, 100, 255)
		else
			color = team.GetColor(self.Player:Team())
		end
	elseif self.Player:IsAdmin() then
		color = Color(255, 155, 0, 255)
	end

	if self.Player == LocalPlayer() then
		color = team.GetColor(self.Player:Team())
	end

	if self.Open or self.Size ~= self.TargetSize then
		draw.RoundedBox(4, 18, 16, w - 36, h - 16, color)
		draw.RoundedBox(4, 20, 16, w - 40, h - 16 - 2, Color(225, 225, 225, 150))

		surface.SetTexture(texGradient)
		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawTexturedRect(20, 16, w - 40, h - 18)
	end

	draw.RoundedBox(4, 18, 0, w - 36, 20, color)

	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 150)
	surface.DrawTexturedRect(0, 0, w - 36, 20)

	/*surface.SetTexture(self.texRating)
	surface.SetDrawColor(255, 255, 255, 255)
	-- surface.DrawTexturedRect(20, 4, 16, 16)
	surface.DrawTexturedRect(56, 3, 16, 16)*/

	return true
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self.infoCard:SetPlayer(ply)
	self:UpdatePlayerData()
	self.imgAvatar:SetPlayer(ply)
end

function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid(ply) then return end

	self.lblName:SetText(ply:Nick())
	if ulibcheck then
		local teamName = team.GetName(ply:Team())
		if ply:GetNWBool("isleader") then
			teamName = teamName .. " [Leader]"
		end
		self.lblTeam:SetText(teamName)
	end
	if utimecheck then self.lblHours:SetText(math.floor(ply:GetUTimeTotalTime() / 3600)) end
	self.lblHealth:SetText(ply:Health())
	self.lblFrags:SetText(ply:Frags())
	self.lblDeaths:SetText(ply:Deaths())
	self.lblPing:SetText(ply:Ping())

	local k = ply:Frags()
	local d = ply:Deaths()
	local kdr = "--   "
	if d ~= 0 then
	   kdr = k / d
	   local y, z = math.modf(kdr)
	   z = string.sub(z, 1, 5)
	   if y ~= 0 then kdr = string.sub(y + z, 1, 5) else kdr = z end
	   kdr = kdr .. ":1"
	   if k == 0 then kdr = k .. ":" .. d end
	end

	self.lblRatio:SetText(kdr)

end

function PANEL:Init()
	self.Size = 20
	self:OpenInfo(false)

	self.infoCard	= vgui.Create("suiscoreplayerinfocard", self)

	self.lblName 	= vgui.Create("DLabel", self)
	if ulibcheck then self.lblTeam 	= vgui.Create("DLabel", self) end
	if utimecheck then  self.lblHours 	= vgui.Create("DLabel", self) end
	self.lblHealth 	= vgui.Create("DLabel", self)
	self.lblFrags 	= vgui.Create("DLabel", self)
	self.lblDeaths 	= vgui.Create("DLabel", self)
	self.lblRatio 	= vgui.Create("DLabel", self)
	self.lblPing 	= vgui.Create("DLabel", self)
	self.lblPing:SetText("9999")

	self.btnAvatar = vgui.Create("DButton", self)
	self.btnAvatar.DoClick = function() self.Player:ShowProfile() end

	self.imgAvatar = vgui.Create("AvatarImage", self.btnAvatar)

	--If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled(false)
	if ulibcheck then self.lblTeam:SetMouseInputEnabled(false) end
	if utimecheck then self.lblHours:SetMouseInputEnabled(false) end
	self.lblHealth:SetMouseInputEnabled(false)
	self.lblFrags:SetMouseInputEnabled(false)
	self.lblDeaths:SetMouseInputEnabled(false)
	self.lblRatio:SetMouseInputEnabled(false)
	self.lblPing:SetMouseInputEnabled(false)
	self.imgAvatar:SetMouseInputEnabled(false)
end

function PANEL:ApplySchemeSettings()
	self.lblName:SetFont("suiscoreboardplayername")
	if ulibcheck then self.lblTeam:SetFont("suiscoreboardplayername") end
	if utimecheck then self.lblHours:SetFont("suiscoreboardplayername") end
	self.lblHealth:SetFont("suiscoreboardplayername")
	self.lblFrags:SetFont("suiscoreboardplayername")
	self.lblDeaths:SetFont("suiscoreboardplayername")
	self.lblRatio:SetFont("suiscoreboardplayername")
	self.lblPing:SetFont("suiscoreboardplayername")

	self.lblName:SetTextColor(color_black)
	if ulibcheck then self.lblTeam:SetTextColor(color_black) end
	if utimecheck then self.lblHours:SetTextColor(color_black) end
	self.lblHealth:SetTextColor(color_black)
	self.lblFrags:SetTextColor(color_black)
	self.lblDeaths:SetTextColor(color_black)
	self.lblRatio:SetTextColor(color_black)
	self.lblPing:SetTextColor(color_black)
end

function PANEL:DoClick()
	if self.Open then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end
	self:OpenInfo(not self.Open)
end

function PANEL:OpenInfo(open)
	if open then
		self.TargetSize = 154
	else
		self.TargetSize = 20
	end
	self.Open = open
end

function PANEL:Think()
	if self.Size ~= self.TargetSize then
		self.Size = math.Approach(self.Size, self.TargetSize, (math.abs(self.Size - self.TargetSize) + 1) * 10 * FrameTime())
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end

	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

function PANEL:PerformLayout(w, h)
	self:SetSize(w, self.Size)

	self.btnAvatar:SetPos(21, 2)
	self.btnAvatar:SetSize(16, 16)

	self.imgAvatar:SetSize(16, 16)

	self.lblName:SizeToContents()
	if ulibcheck then self.lblTeam:SizeToContents() end
	if utimecheck then self.lblHours:SizeToContents() end
	self.lblHealth:SizeToContents()
	self.lblFrags:SizeToContents()
	self.lblDeaths:SizeToContents()
	self.lblRatio:SizeToContents()
	self.lblPing:SizeToContents()
	self.lblPing:SetWide(100)

	self.lblName:SetPos(60, 2)

	local parentWidth = self:GetParent():GetWide()

	if utimecheck then self.lblHours:SetPos(parentWidth - 45 * 13.7 - 6, 2) end
	if ulibcheck then self.lblTeam:SetPos(parentWidth - 45 * 10.2 - 6, 2) end
	self.lblHealth:SetPos(parentWidth - 45 * 5.4 - 6, 2)
	self.lblFrags:SetPos(parentWidth - 45 * 4.4 - 6, 2)
	self.lblDeaths:SetPos(parentWidth - 45 * 3.4 - 6, 2)
	self.lblRatio:SetPos(parentWidth - 45 * 2.4 - 6, 2)
	self.lblPing:SetPos(parentWidth - 45 - 6, 2)

	if self.Open or self.Size ~= self.TargetSize then
		self.infoCard:SetVisible(true)
		self.infoCard:SetPos(18, self.lblName:GetTall() + 27)
		self.infoCard:SetSize(w - 36, h - self.lblName:GetTall() + 5)
	else
		self.infoCard:SetVisible(false)
	end
end

function PANEL:HigherOrLower(row)
	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end

	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() < row.Player:Team()
	end

	if (self.Player:Frags() == row.Player:Frags()) then

		return self.Player:Deaths() < row.Player:Deaths()

	end

	return self.Player:Frags() > row.Player:Frags()
end

vgui.Register("suiscoreplayerrow", PANEL, "DButton")
