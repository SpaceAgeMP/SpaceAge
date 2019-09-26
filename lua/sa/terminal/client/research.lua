local PANEL = {}

local ResearchNameColor = Color(255, 255, 255, 255)
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
	self.UpgradeButton:SetPos(590, 38)
	self.UpgradeButton:SetSize(100, 28)
	self.UpgradeButton:SetText("Upgrade")
	self.UpgradeButton.DoClick = function()
		self:UpgradeCommand()
	end
end

function PANEL:SetDesc()
	local Desc = self.ResearchTbl.desc
	local reqtype = self.ResearchTbl.type
	local prereq = self.ResearchTbl.prereq
	if reqtype ~= "none" then
		local DescAdd = "\nRequires: "
		if reqtype == "unlock" then
			for k, v in pairs(prereq) do
				if v[1] == "faction" then
					DescAdd = DescAdd .. " (Faction: "
					for ke, ve in pairs(v[2]) do
						DescAdd = DescAdd .. SA.Factions.ToLong[ve] .. ", "
					end
					DescAdd = string.Left(DescAdd, string.len(DescAdd) - 1) .. ")"
				else
					local name = ""
					if self.ResearchTbl.name == v[1] then -- TODO: ???
						name = n.display
					end
					if name ~= "" then
						DescAdd = DescAdd .. " (" .. name .. ": " .. v[2] .. ")"
					end
				end
			end
		elseif reqtype == "perrank" then
			local cur = tonumber(self.CurrentRank)
			local max = tonumber(self.MaxRank)
			if cur < max then
				local offset = cur + 1
				local name = ""
				local level = 0
				local tbl = prereq[offset]
				if tbl and #tbl > 0 then
					for k, v in pairs(tbl) do
						if v[1] == "faction" then
							DescAdd = DescAdd .. " (Faction: "
							for ke, ve in pairs(v[2]) do
								DescAdd = DescAdd .. SA.Factions.ToLong[ve] .. ", "
							end
							DescAdd = string.Left(DescAdd, string.len(DescAdd) - 1) .. ")"
						else
							local name = ""
							if self.ResearchTbl.name == v[1] then -- TODO: ???
								name = n.display
							end
							if name ~= "" then
								DescAdd = DescAdd .. " (" .. name .. ": " .. v[2] .. ")"
							end
						end
					end
				end
				if name ~= "" then
					DescAdd = DescAdd .. " (" .. name .. ": " .. level .. ")"
				end
			end
		end
		if (DescAdd ~= "\nRequires: ") then
			Desc = Desc .. DescAdd
		end
	end
	self.ResearchDesc:SetText(Desc)
end

function PANEL:SetResearch(Research)
	self.ResearchName:SetText(Research.display)
	self.ResearchTbl = Research
	self.Image:SetImage("spaceage/" .. Research.image)
	self:Update(0)
end

function PANEL:Update(Rank, Cost)
	self.CurrentRank = Rank
	self.MaxRank = self.ResearchTbl.ranks
	self.ResearchRank:SetText("Rank: " .. Rank .. "/" .. self.MaxRank)
	self:SetDesc()
	if (Cost) then
		self.ResearchCost:SetText(Cost)
		if (Cost == "Max Rank") then
			self.UpgradeButton:SetDisabled(true)
		else
			self.UpgradeButton:SetDisabled(false)
		end
	end
end

function PANEL:Paint()
	draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), PanelColor)
	draw.RoundedBox(8, 585, 3, 104, 22, RankBackColor)
	draw.RoundedBox(8, 419, 3, 144, 22, CostBackColor)
	draw.RoundedBox(8, 3, 3, 390, 36, ImageBackColor)
	draw.RoundedBox(8, 3, 29, 580, 42, DescBackColor)
	draw.RoundedBox(8, 3, 3, 68, 68, ImageBackColor)
end

vgui.Register("SA_Terminal_Research", PANEL, "DPanel")
