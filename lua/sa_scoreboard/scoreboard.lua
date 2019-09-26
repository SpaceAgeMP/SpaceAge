
include("player_row.lua")
include("player_frame.lua")

surface.CreateFont("SA_ScoreboardHeader", { font = "coolvetica", size = 32, weight = 500, antialias = true, shadow = false})
surface.CreateFont("SA_ScoreboardSubtitle", { font = "coolvetica", size = 22, weight = 500, antialias = true, shadow = false})
surface.CreateFont("SA_ScoreboardLogo", { font = "coolvetica", size = 60, weight = 800, antialias = false, shadow = true})

local texGradient 	= surface.GetTextureID("gui/center_gradient")
local texGradientDown = surface.GetTextureID("gui/gradient_down")

local PANEL = {}

function PANEL:Init()
	self.Hostname = vgui.Create("DLabel", self)
	self.Hostname:SetText(GetGlobalString("ServerName"))

	self.Description = vgui.Create("DLabel", self)
	self.Description:SetText(GAMEMODE.Name .. " - " .. GAMEMODE.Author)

	self.PlayerFrame = vgui.Create("SA_PlayerFrame", self)

	self.PlayerRows = {}

	self:UpdateScoreboard()

	timer.Create("SA_ScoreboardUpdater", 1, 0, function() self:UpdateScoreboard() end)

	self.lblPing = vgui.Create("DLabel", self)
	self.lblPing:SetText("Ping")

	self.lblScore = vgui.Create("DLabel", self)
	self.lblScore:SetText("Score")
end


function PANEL:AddPlayerRow(ply)
	local button = vgui.Create("SA_ScorePlayerRow", self.PlayerFrame:GetCanvas())
	button:SetPlayer(ply)
	self.PlayerRows[ ply ] = button
end

function PANEL:GetPlayerRow(ply)
	return self.PlayerRows[ ply ]
end

function PANEL:Paint()
	local x, y = self:GetSize()
	draw.RoundedBox(8, 0, 0, x, y, Color(100, 100, 100, 150))
	surface.SetTexture(texGradientDown)
	surface.SetDrawColor(Color(150, 150, 150, 200))
	surface.DrawTexturedRect(4, self.Description.y - 4, x - 8, y - self.Description.y - 4)
	surface.SetTexture(texGradient)
	draw.RoundedBox(4, 5, self.Description.y - 3, x - 10, self.Description:GetTall() + 5, Color(150, 150, 150, 200))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawTexturedRect(4, self.Description.y - 4, x - 8, self.Description:GetTall() + 8)

	draw.RoundedBox(4, 10, self.Description.y + self.Description:GetTall() + 6, x - 20, 12, Color(0, 255, 255, 50))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(0, 255, 0, 100)
	surface.DrawTexturedRect(10, self.Description.y + self.Description:GetTall() + 6, x - 20, 12)
	draw.RoundedBox(8, 4, 8, 100, 48, Color(200, 200, 200, 220))
	draw.SimpleText("SA", "SA_ScoreboardLogo", 52, 34, Color(50, 50, 50, 250), 1, 1)
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 100)
end

function PANEL:PerformLayout()

	self:SetSize(640, ScrH() * 0.95)

	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)

	self.Hostname:SizeToContents()
	self.Hostname:SetPos(100, 16)

	self.Description:SizeToContents()
	self.Description:SetPos(20, 64)

	self.PlayerFrame:SetPos(5, self.Description.y + self.Description:GetTall() + 20)
	self.PlayerFrame:SetSize(self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10)

	local y = 0

	local PlayerSorted = {}

	for k, v in pairs(self.PlayerRows) do
		table.insert(PlayerSorted, v)
	end

	table.sort(PlayerSorted, function (a , b) return a:HigherOrLower(b) end)

	for k, v in ipairs(PlayerSorted) do

		v:SetPos(0, y)
		v:SetSize(self.PlayerFrame:GetWide(), v:GetTall())

		self.PlayerFrame:GetCanvas():SetSize(self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall())
		y = y + v:GetTall() + 1
	end

	self.Hostname:SetText(GetGlobalString("ServerName"))

	self.lblPing:SizeToContents()
	self.lblScore:SizeToContents()

	self.lblPing:SetPos(self:GetWide() - 50 - self.lblPing:GetWide() / 2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.lblScore:SetPos(self:GetWide() - 50 * 4 - self.lblScore:GetWide() / 2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)

end

--[[---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------]]
function PANEL:ApplySchemeSettings()

	self.Hostname:SetFont("SA_ScoreboardHeader")
	self.Description:SetFont("SA_ScoreboardSubtitle")

	self.Hostname:SetFGColor(Color(0, 0, 0, 200))
	self.Description:SetFGColor(color_black)

	self.lblPing:SetFont("DefaultSmall")
	self.lblScore:SetFont("DefaultSmall")
	--self.lblDeaths:SetFont("DefaultSmall")

	self.lblPing:SetFGColor(Color(255, 255, 255, 100))
	self.lblScore:SetFGColor(Color(255, 255, 255, 100))
	--self.lblDeaths:SetFGColor(Color(255, 255, 255, 100))

end


function PANEL:UpdateScoreboard(force)

	if (not force and not self:IsVisible()) then return end

	for k, v in pairs(self.PlayerRows) do

		if (not k:IsValid()) then

			v:Remove()
			self.PlayerRows[ k ] = nil

		end

	end

	local PlayerList = player.GetAll()
	for id, pl in pairs(PlayerList) do

		if (not self:GetPlayerRow(pl)) then

			self:AddPlayerRow(pl)

		end

	end

	-- Always invalidate the layout so the order gets updated
	self:InvalidateLayout()

end

vgui.Register("SA_ScoreBoard", PANEL, "Panel")
