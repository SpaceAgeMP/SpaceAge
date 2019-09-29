local ResourceIcons = {}

local function RegisterResourceIcon(name, icon)
	ResourceIcons[name] = "spaceage/" .. icon
end

RegisterResourceIcon("ore", "res_icon_solid.png")
RegisterResourceIcon("metals", "res_icon_solid.png")
RegisterResourceIcon("carbon dioxide", "res_icon_gas.png")
RegisterResourceIcon("water", "res_icon_liquid.png")
RegisterResourceIcon("hydrogen", "res_icon_gas.png")
RegisterResourceIcon("nitrogen", "res_icon_gas.png")
RegisterResourceIcon("terracrystal", "res_icon_crystal.png")
RegisterResourceIcon("oxygen", "res_icon_gas.png")
RegisterResourceIcon("valuable minerals", "res_icon_valuableminerals.png")
RegisterResourceIcon("dark matter", "res_icon_solid.png")
RegisterResourceIcon("permafrost", "res_icon_solid.png")
RegisterResourceIcon("hydrogen isotopes", "res_icon_isotope.png")
RegisterResourceIcon("helium isotopes", "res_icon_isotope.png")
RegisterResourceIcon("strontium clathrates", "res_icon_crystal.png")
RegisterResourceIcon("nitrogen isotopes", "res_icon_isotope.png")
RegisterResourceIcon("oxygen isotopes", "res_icon_isotope.png")
RegisterResourceIcon("liquid ozone", "res_icon_liquid.png")
RegisterResourceIcon("steam", "res_icon_gas.png")
RegisterResourceIcon("liquid nitrogen", "res_icon_liquid.png")
RegisterResourceIcon("energy", "res_icon_energy.png")
RegisterResourceIcon("heavy water", "res_icon_liquid.png")
RegisterResourceIcon("tiberium", "res_icon_crystal.png")

local PANEL = {}

local ResourceNameColor = Color(255, 255, 255, 255)
local ResourceAmountColor = Color(200, 200, 200, 255)

local PanelColor = Color(100, 100, 100, 255)
local ImageBackColor = Color(25, 25, 25, 255)

local HASH = ""
function SA.SetResourceItemPanelHash(xhas)
	HASH = xhas
end

function PANEL:Init()
	self.Image = vgui.Create("DImage", self)
	self.Image:SetPos(5, 5)
	self.Image:SetSize(32, 32)

	self.ResourceName = vgui.Create("DLabel", self)
	self.ResourceName:SetPos(43, 1)
	self.ResourceName:SetSize(160, 22)
	self.ResourceName:SetContentAlignment(7)
	self.ResourceName:SetText("Unnamed")
	self.ResourceName:SetFont("Trebuchet20")
	self.ResourceName:SetColor(ResourceNameColor)

	self.ResourceAmount = vgui.Create("DLabel", self)
	self.ResourceAmount:SetPos(25, 23)
	self.ResourceAmount:SetSize(170, 20)
	self.ResourceAmount:SetText("Amount: 0")
	self.ResourceAmount:SetContentAlignment(6)
	self.ResourceAmount:SetFont("Trebuchet18")
	self.ResourceAmount:SetColor(ResourceAmountColor)

	self.ResourceAmount:SetMouseInputEnabled(false)
	self.ResourceName:SetMouseInputEnabled(false)
	self.Image:SetMouseInputEnabled(false)
	self:SetMouseInputEnabled(true)

	self.Location = nil
end

function PANEL:SetResource(name, amount, capacity)
	self.ResourceName:SetText(tostring(name))
	self.Image:SetImage(ResourceIcons[string.lower(tostring(name))] or "spaceage/sa_research_icon")
	self.RName = name
	if amount then self:SetAmount(amount, capacity) end
end

function PANEL:SetAmount(amount, capacity)
	amount = math.floor(amount)
	if not capacity then
		self.ResourceAmount:SetText(SA.AddCommasToInt(amount))
	else
		capacity = math.floor(capacity)
		self.ResourceAmount:SetText(SA.AddCommasToInt(amount) .. " / " .. SA.AddCommasToInt(capacity))
	end
	self.RAmount = math.floor(amount)
	if capacity then capacity = math.floor(capacity) end
	self.RCapacity = capacity
end

function PANEL:SetLocation(loc)
	self.Location = loc
end

function PANEL:OnMousePressed(mcode)
	if SA_TermDraggedElement then return end
	if mcode ~= MOUSE_LEFT and mcode ~= MOUSE_RIGHT then return end

	local t = self:GetParent()
	local x, y = self:GetPos()
	local xt, yt
	while not t.SA_IsTerminalGUI do
		xt, yt = t:GetPos()
		x = x + xt
		y = y + yt
		t = t:GetParent()
	end
	local item = vgui.Create("SA_Terminal_Resource", t)
	item:SetPos(x, y)
	item:SetSize(220, 42)
	item:SetLocation(self.Location)
	item:SetResource(self.RName, self.RAmount)
	item:SetAlpha(128)
	item.MCode = mcode
	item.BCPosX, item.BCPosY = self:CursorPos()
	function item:OnCursorMoved(cpx, cpy)
		local px, py = self:GetPos()
		px = px + (cpx - self.BCPosX)
		py = py + (cpy - self.BCPosY)
		self:SetPos(px, py)
	end
	function item:OnMouseReleased(itemMouseCode)
		if itemMouseCode ~= self.MCode then self:QuitThis() return end
		local cx, cy = self:CursorPos()
		local ix, iy = self:GetPos()
		cx = cx + ix
		cy = cy + iy
		if cy >= 160 and cy <= 588 then
			local tl = nil
			if cx >= 45 and cx <= 275 then
				tl = "temp"
			elseif cx >= 290 and cx <= 520 then
				tl = "perm"
			elseif cx >= 535 and cx <= 765 then
				tl = "ship"
			end
			if not tl or tl == self.Location then
				self:QuitThis()
				return
			end
			self.ToLocation = tl
		end
		if itemMouseCode == MOUSE_RIGHT then
			function self:OnCursorExited()
			end
			function self:OnCursorMoved()
			end
			self.ResourceAmount:Remove()
			self.ResourceAmount = vgui.Create("DNumberWang", self)
			self.ResourceAmount:SetPos(103, 24)
			self.ResourceAmount:SetSize(90, 16)
			self.ResourceAmount:SetMin(0)
			self.ResourceAmount:SetMax(self.RAmount)
			self.ResourceAmount:SetDecimals(0)
			local OKB = vgui.Create("DButton", self)
			OKB:SetPos(194, 24)
			OKB:SetSize(20, 16)
			OKB:SetText("OK")
			function OKB:DoClick()
				local pp = self:GetParent()
				pp.RAmount = math.floor(pp.ResourceAmount:GetValue())
				pp:TransferStuff()
			end
			local AMTT = vgui.Create("DLabel", self)
			AMTT:SetPos(43, 23)
			AMTT:SetSize(50, 20)
			AMTT:SetContentAlignment(4)
			AMTT:SetFont("Trebuchet18")
			AMTT:SetColor(ResourceNameColor)
			AMTT:SetText("Amount")
		else
			self:TransferStuff()
		end
	end
	function item:TransferStuff()
		RunConsoleCommand("sa_move_resource", self.Location, self.ToLocation, self.RName, self.RAmount, HASH)
		self:QuitThis()
	end
	function item:QuitThis()
		SA_TermDraggedElement = nil
		self:MouseCapture(false)
		self:Remove()
	end
	item:MouseCapture(true)
	SA_TermDraggedElement = item
end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, PanelColor)
	draw.RoundedBox(8, 3, 3, 214, 20, ImageBackColor)
	draw.RoundedBox(8, 3, 3, 36, 36, ImageBackColor)
end

vgui.Register("SA_Terminal_Resource", PANEL, "DPanel")
