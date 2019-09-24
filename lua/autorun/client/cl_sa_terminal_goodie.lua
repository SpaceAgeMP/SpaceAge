if not TERMLOADER then return end

local PANEL = {}

local GoodieNameColor = Color(255,255,255,255)
local GoodieDescColor = Color(200,200,200,255)
local DescBackColor = Color(50,50,50,255)

local PanelColor = Color(100,100,100,255)
local ImageBackColor = Color(25,25,25,255)

function PANEL:Init()
	self.Image = vgui.Create("DImage",self)
	self.Image:SetPos(5,5)
	self.Image:SetSize(64,64)

	self.GoodieName = vgui.Create("DLabel",self)
	self.GoodieName:SetPos(79,5)
	self.GoodieName:SetSize(310,22)
	self.GoodieName:SetContentAlignment(5)
	self.GoodieName:SetText("")
	self.GoodieName:SetFont("Trebuchet22")
	self.GoodieName:SetColor(GoodieNameColor)

	self.GoodieDesc = vgui.Create("DLabel",self)
	self.GoodieDesc:SetPos(79,30)
	self.GoodieDesc:SetSize(500,38)
	self.GoodieDesc:SetText("")
	self.GoodieDesc:SetFont("Trebuchet18")
	self.GoodieDesc:SetColor(GoodieDescColor)

	self.UseButton = vgui.Create("DButton",self)
	self.UseButton:SetPos(590,38)
	self.UseButton:SetSize(100,28)
	self.UseButton:SetText("Activate")
	self.UseButton.DoClick = function()
		RunConsoleCommand("sa_goodies_use",tostring(self.GoodieID))
	end
end

function PANEL:SetNameDescID(intid,goodieid)
	intid = SA.Goodies[intid]
	self.GoodieName:SetText(intid.name)
	self.GoodieDesc:SetText(intid.desc)
	self.GoodieID = goodieid
	self.Image:SetImage("spaceage/" .. intid.image)
end

function PANEL:Paint()
	draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),PanelColor)
	draw.RoundedBox(8,3,3,390,36,ImageBackColor)
	draw.RoundedBox(8,3,29,580,42,DescBackColor)
	draw.RoundedBox(8,3,3,68,68,ImageBackColor)
end

vgui.Register("SA_Terminal_Goodie", PANEL, "DPanel")
