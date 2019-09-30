local PANEL = {}

function PANEL:DoClick()

	if (!self:GetParent().Player or LocalPlayer() == self:GetParent().Player) then return end

	self:DoCommand(self:GetParent().Player)
	timer.Simple(0.1, SuiScoreBoard.UpdateScoreboard())

end

function PANEL:Paint(w, h)

	local bgColor = Color(200,200,200,100)

	if (self.Selected) then
		bgColor = Color(135, 135, 135, 100)
	elseif (self.Armed) then
		bgColor = Color(175, 175, 175, 100)
	end

	draw.RoundedBox(4, 0, 0, w, h, bgColor)

	draw.SimpleText(self.Text, "DefaultSmall", w / 2, h / 2, Color(0,0,0,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true

end


vgui.Register("suispawnmenuadminbutton", PANEL, "Button")


PANEL = {}
PANEL.Text = "Kick"

function PANEL:DoCommand(ply)

	LocalPlayer():ConCommand("kickid " .. ply:UserID() .. " Kicked By " .. LocalPlayer():Nick() .. "\n")

end

vgui.Register("suiplayerkickbutton", PANEL, "suispawnmenuadminbutton")

PANEL = {}
PANEL.Text = "PermBan"

function PANEL:DoCommand(ply)

	LocalPlayer():ConCommand("banid 0 " .. self:GetParent().Player:UserID() .. "\n")
	LocalPlayer():ConCommand("kickid " .. ply:UserID() .. " Permabanned By " .. LocalPlayer():Nick() .. "\n")

end

vgui.Register("suiplayerpermbanbutton", PANEL, "suispawnmenuadminbutton")


PANEL = {}
PANEL.Text = "1hr Ban"

function PANEL:DoCommand(ply)

	LocalPlayer():ConCommand("banid 60 " .. self:GetParent().Player:UserID() .. "\n")
	LocalPlayer():ConCommand("kickid " .. ply:UserID() .. " Banned for 1 hour By " .. LocalPlayer():Nick() .. "\n")

end

vgui.Register("suiplayerbanbutton", PANEL, "suispawnmenuadminbutton")
