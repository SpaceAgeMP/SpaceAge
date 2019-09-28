local PANEL = {}

PANEL.VoteName = "none"
PANEL.MaterialName = "exclamation"

function PANEL:Init()

	self.Label = vgui.Create("DLabel", self)
	self:ApplySchemeSettings()
	self:SetCursor("hand")

end

function PANEL:DoClick()

	local ply = self:GetParent().Player
	if (!ply or !ply:IsValid() or ply == LocalPlayer()) then return end

	LocalPlayer():ConCommand("sui_rateuser " .. ply:EntIndex() .. " " .. self.VoteName .. "\n")

end

function PANEL:ApplySchemeSettings()

	self.Label:SetFont("suiscoreboardcardinfo")
	self.Label:SetTextColor(Color(0, 0, 0, 150))
	self.Label:SetMouseInputEnabled(false)

end

function PANEL:PerformLayout(w, h)

	if IsValid(self:GetParent().Player) then
		self.Label:SetText(self:GetParent().Player:GetNWInt("SuiRating." .. self.VoteName, 0))
	end

	self.Label:SizeToContents()
	self.Label:SetPos((w - self.Label:GetWide()) / 2, h - self.Label:GetTall())

end

function PANEL:SetUp(mat, votename, nicename)

	self.MaterialName 	= mat
	self.VoteName 		= votename
	self.NiceName		= nicename
	self:SetTooltip(self.NiceName)

end

function PANEL:Paint(w,h)

	if (!self.Material) then
		self.Material = Material(self.MaterialName)
	end

	local bgColor = Color(200,200,200,100)

	if (self.Selected) then
		bgColor = Color(135, 135, 135, 100)
	elseif (self.Armed) then
		bgColor = Color(175, 175, 175, 100)
	end

	draw.RoundedBox(4, 0, 0, w, h, bgColor)

	local alpha = 225
	if (self.Armed) then alpha = 255 end

	surface.SetMaterial(self.Material)

	if (self.VoteName == "best_airvehicle") then
		surface.SetDrawColor(100, 100, 255, alpha)
		surface.DrawTexturedRect(w / 2 - 8, w / 2 - 8, 16, 16)
	elseif (self.VoteName == "lol") then
		surface.SetDrawColor(255, 155, 0, alpha)
		surface.DrawTexturedRect(w / 2 - 8, w / 2 - 8, 16, 16)
	elseif (self.VoteName == "best_landvehicle") then
		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawTexturedRect(w / 2 - 12, w / 2 - 12, 24, 24)
	elseif (self.VoteName == "god") then
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawTexturedRect(w / 2 - 13, w / 2 - 8, 26, 26)
	elseif (self.VoteName == "gay") then
		surface.SetDrawColor(255, 0, 215, alpha)
		surface.DrawTexturedRect(w / 2 - 13, w / 2 - 8, 26, 26)
	else
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawTexturedRect(w / 2 - 8, w / 2 - 8, 16, 16)
	end

	//draw.SimpleText(, "DefaultSmall", w / 2, 19, Color(0,0,0,100), TEXT_ALIGN_CENTER)

	return true

end

local TooltipText = nil

function PANEL:OnCursorEntered()
	TooltipText = self.NiceName
end

function PANEL:OnCursorExited()
	TooltipText = nil
end


vgui.Register("suispawnmenuvotebutton", PANEL, "Button")


local _GetTooltipText = GetTooltipText
function GetTooltipText()
	if (TooltipText) then return TooltipText end

	return _GetTooltipText()
end
