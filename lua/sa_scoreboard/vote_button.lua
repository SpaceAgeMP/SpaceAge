
local PANEL = {}

PANEL.VoteName = "none"
PANEL.MaterialName = "exclamation"

function PANEL:Init()

	self.Label = vgui.Create("DLabel", self)
	self:ApplySchemeSettings()

end

function PANEL:DoClick()

	local ply = self:GetParent().Player
	if (!ply or !ply:IsValid() or ply == LocalPlayer()) then return end

	LocalPlayer():ConCommand("rateuser ".. ply:EntIndex().. " "..self.VoteName.."\n")

end

function PANEL:ApplySchemeSettings()

	self.Label:SetFont("Default")
	self.Label:SetFGColor(0, 0, 0, 150)
	self.Label:SetMouseInputEnabled(false)

end

function PANEL:PerformLayout()

	if (self:GetParent().Player and self:GetParent().Player:IsValid()) then
		self.Label:SetText(self:GetParent().Player:GetNetworkedInt("Rating."..self.VoteName, 0))
	end

	self.Label:SizeToContents()
	self.Label:SetPos((self:GetWide() - self.Label:GetWide()) / 2, self:GetTall() - self.Label:GetTall())

end

function PANEL:SetUp(mat, votename, nicename)

	self.MaterialName 	= mat
	self.VoteName 		= votename
	self.NiceName		= nicename

end

function PANEL:Paint()

	if (!self.Material) then
		self.Material = surface.GetTextureID("gui/silkicons/" .. self.MaterialName)
	end

	local bgColor = Color(0,0,0,10)

	if (self.Selected) then
		bgColor = Color(200, 200, 200, 255)
	elseif (self.Armed) then
		bgColor = Color(100, 100, 100, 255)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bgColor)

	local alpha = 200
	if (self.Armed) then alpha = 255 end

	surface.SetTexture(self.Material)
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.DrawTexturedRect(self:GetWide()/2 - 8, self:GetWide()/2 - 8, 16, 16)


	--draw.SimpleText(, "DefaultSmall", self:GetWide() / 2, 19, Color(0,0,0,100), TEXT_ALIGN_CENTER)

	return true

end

function PANEL:OnCursorEntered()
	self.TooltipText = self.NiceName
end

function PANEL:OnCursorExited()
	self.TooltipText = nil
end

vgui.Register("SA_SpawnMenuVoteButton", PANEL, "Button")
