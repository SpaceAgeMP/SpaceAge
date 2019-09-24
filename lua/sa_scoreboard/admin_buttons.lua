
local PANEL = {}

function PANEL:DoClick()

	if (not self:GetParent().Player or LocalPlayer() == self:GetParent().Player) then return end

	self:DoCommand(self:GetParent().Player)
	timer.Simple(0.1, function() SA.ScoreBoard:UpdateScoreboard() end)

end

function PANEL:Paint()

	local bgColor = Color(0,0,0,10)

	if (self.Selected) then
		bgColor = Color(0, 200, 255, 255)
	elseif (self.Armed) then
		bgColor = Color(255, 255, 0, 255)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bgColor)

	draw.SimpleText(self.Text, "DefaultSmall", self:GetWide() / 2, self:GetTall() / 2, Color(0,0,0,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true

end


vgui.Register("SA_SpawnMenuAdminButton", PANEL, "Button")

PANEL = {}
PANEL.Text = "Kick"

function PANEL:DoCommand(ply)
	RunConsoleCommand("fa", "kick", ply:Name(), "(Reason not given)")
end

vgui.Register("SA_PlayerKickButton", PANEL, "SA_SpawnMenuAdminButton")



PANEL = {}
PANEL.Text = "PermBan"

function PANEL:DoCommand(ply)
	RunConsoleCommand("fa", "ban", ply:Name(), 0, "(Reason not given)")
end

vgui.Register("SA_PlayerPermBanButton", PANEL, "SA_SpawnMenuAdminButton")


PANEL = {}
PANEL.Text = "1hr Ban"

function PANEL:DoCommand(ply)
	RunConsoleCommand("fa", "ban", ply:Name(), 60, "(Reason not given)")
end

vgui.Register("SA_PlayerBanButton", PANEL, "SA_SpawnMenuAdminButton")


