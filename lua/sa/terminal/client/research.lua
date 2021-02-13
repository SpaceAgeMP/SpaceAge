local PANEL = {}

local ResearchNameColor = color_white
local ResearchDescColor = Color(200, 200, 200, 255)
local DescBackColor = Color(50, 50, 50, 255)
local ResearchRankColor = Color(0, 150, 0, 255)
local RankBackColor = Color(75, 75, 75, 255)
local ResearchCostColor = Color(200, 125, 50, 255)
local CostBackColor = Color(50, 50, 50, 255)

local PanelColor = Color(100, 100, 100, 255)
local ImageBackColor = Color(25, 25, 25, 255)

function PANEL:Init()
	self.Image = vgui.Create("DImage", self)
	self.Image:SetPos(5, 5)
	self.Image:SetSize(64, 64)

	self.ResearchName = vgui.Create("DLabel", self)
	self.ResearchName:SetPos(79, 5)
	self.ResearchName:SetSize(310, 22)
	self.ResearchName:SetContentAlignment(5)
	self.ResearchName:SetText("")
	self.ResearchName:SetFont("Trebuchet22")
	self.ResearchName:SetColor(ResearchNameColor)

	self.ResearchDesc = vgui.Create("DLabel", self)
	self.ResearchDesc:SetPos(79, 30)
	self.ResearchDesc:SetSize(500, 38)
	self.ResearchDesc:SetText("")
	self.ResearchDesc:SetFont("Trebuchet18")
	self.ResearchDesc:SetColor(ResearchDescColor)

	self.ResearchRank = vgui.Create("DLabel", self)
	self.ResearchRank:SetPos(585, 5)
	self.ResearchRank:SetSize(100, 18)
	self.ResearchRank:SetContentAlignment(5)
	self.ResearchRank:SetText("Rank: 0/0")
	self.ResearchRank:SetFont("Trebuchet18")
	self.ResearchRank:SetColor(ResearchRankColor)

	self.ResearchCost = vgui.Create("DLabel", self)
	self.ResearchCost:SetPos(421, 5)
	self.ResearchCost:SetSize(140, 18)
	self.ResearchCost:SetContentAlignment(5)
	self.ResearchCost:SetText("Cost: 0")
	self.ResearchCost:SetFont("Trebuchet18")
	self.ResearchCost:SetColor(ResearchCostColor)

	self.UpgradeButton = vgui.Create("DButton", self)
	self.UpgradeButton:SetPos(590, 28)
	self.UpgradeButton:SetSize(100, 18)
	self.UpgradeButton:SetText("Upgrade")
	self.UpgradeButton.DoClick = function()
		self:UpgradeCommand()
	end

	self.UpgradeAllButton = vgui.Create("DButton", self)
	self.UpgradeAllButton:SetPos(590, 48)
	self.UpgradeAllButton:SetSize(100, 18)
	self.UpgradeAllButton:SetText("Upgrade All")
	self.UpgradeAllButton.DoClick = function()
		self:UpgradeAllCommand()
	end
end

function PANEL:CheckCost(SA_TermError)
	local ply = LocalPlayer()
	if not (ply.sa_data and ply.sa_data.credits) then
		return true
	end

	if ply.sa_data.credits < self.Cost then
		SA_TermError("You do not have enough credits for this research")
		return false
	end

	return true
end

function PANEL:SetResearch(Research)
	self.ResearchName:SetText(Research.display)
	self.ResearchTbl = Research
	self.Image:SetImage("spaceage/" .. Research.image)
	self:Update()
end

function PANEL:Update()
	self.ResearchDesc:SetText(self.ResearchTbl.desc)

	local ply = LocalPlayer()
	if not (ply.sa_data and ply.sa_data.research) then
		self.CurrentRank = 0
		self.FulfilledReqs = {}
		self.MissingReqs = {}
		return
	end

	self.CurrentRank = SA.Research.GetFromPlayer(ply, self.ResearchTbl.name)

	self.MaxRank = self.ResearchTbl.ranks
	self.ResearchRank:SetText("Rank: " .. self.CurrentRank .. "/" .. self.MaxRank)

	local ok, cost, missingReqs, fulfilledReqs = SA.Research.GetNextInfo(ply, self.ResearchTbl, false)
	if cost <= 0 then
		self.ResearchCost:SetText("Max rank")
	else
		self.ResearchCost:SetText(SA.AddCommasToInt(cost))
	end

	self.Cost = cost

	self.UpgradeButton:SetDisabled(not ok)
	self.UpgradeAllButton:SetDisabled(not ok)

	self:SetTooltipPanelOverride("SA_Terminal_Research_Tooltip")

	self.MaxedOut = cost <= 0
	self.FulfilledReqs = fulfilledReqs
	self.MissingReqs = missingReqs
end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, PanelColor)
	draw.RoundedBox(8, 585, 3, 104, 22, RankBackColor)
	draw.RoundedBox(8, 419, 3, 144, 22, CostBackColor)
	draw.RoundedBox(8, 3, 3, 390, 36, ImageBackColor)
	draw.RoundedBox(8, 3, 29, 580, 42, DescBackColor)
	draw.RoundedBox(8, 3, 3, 68, 68, ImageBackColor)
end

vgui.Register("SA_Terminal_Research", PANEL, "DPanel")
