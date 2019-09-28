include("admin_buttons.lua")
include("vote_button.lua")

local PANEL = {}

function PANEL:Init()
	self.InfoLabels = {}
	self.InfoLabels[1] = {}
	self.InfoLabels[2] = {}
	self.InfoLabels[3] = {}

	self.btnMute = vgui.Create("suispawnmenuadminbutton", self)

	/*self.btnKick = vgui.Create("suiplayerkickbutton", self)
	self.btnBan = vgui.Create("suiplayerbanbutton", self)
	self.btnPBan = vgui.Create("suiplayerpermbanbutton", self)*/

	self.VoteButtons = {}

	self.VoteButtons[5] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[5]:SetUp("icon16/wrench.png", "builder", "Good at building!")

	self.VoteButtons[4] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[4]:SetUp("icon16/star.png", "gold_star", "Wow! Gold star for you!")

	self.VoteButtons[3] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[3]:SetUp("icon16/palette.png", "artistic", "This player is artistic!")

	self.VoteButtons[2] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[2]:SetUp("icon16/heart.png", "love", "I love this player!")

	self.VoteButtons[1] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[1]:SetUp("icon16/emoticon_smile.png", "smile", "I like this player!")


	self.VoteButtons[10] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[10]:SetUp("gui/corner16", "curvey", "This player is great with curves")

	self.VoteButtons[9] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[9]:SetUp("gui/faceposer_indicator", "best_landvehicle", "This player is awesome with land vehicles")

	self.VoteButtons[8] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[8]:SetUp("icon16/arrow_up.png", "best_airvehicle", "This player is awesome with air vehicles")

	self.VoteButtons[7] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[7]:SetUp("gui/inv_corner16", "stunter", "Wow! you can do amazing Stunts!")

	self.VoteButtons[6] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[6]:SetUp("gui/gmod_logo", "god", "You are my GOD!")


	self.VoteButtons[15] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[15]:SetUp("icon16/emoticon_smile.png", "lol", "LOL! You are funny!")

	self.VoteButtons[14] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[14]:SetUp("icon16/information.png", "informative", "This player is very informative!")

	self.VoteButtons[13] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[13]:SetUp("icon16/user.png", "friendly", "This player is very friendly!")

	self.VoteButtons[12] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[12]:SetUp("icon16/exclamation.png", "naughty", "This player is naughty!")

	self.VoteButtons[11] = vgui.Create("suispawnmenuvotebutton", self)
	self.VoteButtons[11]:SetUp("gui/gmod_logo", "gay", "This player is GAY!")

end

surface.CreateFont("suiscoreboardcardinfo", {
	font = "DefaultSmall",
	size = 12,
	weight = 0
})

function PANEL:SetInfo(column, k, v)
	if (not v or v == "") then v = "N/A" end

	if (not self.InfoLabels[column][k]) then
		self.InfoLabels[column][k] = {}
		self.InfoLabels[column][k].Key = vgui.Create("DLabel", self)
		self.InfoLabels[column][k].Value = vgui.Create("DLabel", self)
		self.InfoLabels[column][k].Key:SetText(k)
		self.InfoLabels[column][k].Key:SetTextColor(Color(0, 0, 0, 255))
		self.InfoLabels[column][k].Key:SetFont("suiscoreboardcardinfo")
		self:InvalidateLayout()
	end

	self.InfoLabels[column][k].Value:SetText(v)
	self.InfoLabels[column][k].Value:SetTextColor(Color(0, 0, 0, 255))
	self.InfoLabels[column][k].Value:SetFont("suiscoreboardcardinfo")
	return true
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self:UpdatePlayerData()
end

function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid(ply) then return end
	self:SetInfo(1, "Props:", ply:GetCount("props") or 0)
	self:SetInfo(1, "HoverBalls:", ply:GetCount("hoverballs") or 0)
	self:SetInfo(1, "Thrusters:", ply:GetCount("thrusters") or 0)
	self:SetInfo(1, "Balloons:", ply:GetCount("balloons") or 0)
	self:SetInfo(1, "Buttons:", ply:GetCount("buttons") or 0)
	self:SetInfo(1, "Dynamite:", ply:GetCount("dynamite") or 0)
	self:SetInfo(1, "SENTs:", ply:GetCount("sents") or 0)

	self:SetInfo(2, "Ragdolls:", ply:GetCount("ragdolls") or 0)
	self:SetInfo(2, "Effects:", ply:GetCount("effects") or 0)
	self:SetInfo(2, "Vehicles:", ply:GetCount("vehicles") or 0)
	self:SetInfo(2, "Npcs:", ply:GetCount("npcs") or 0)
	self:SetInfo(2, "Emitters:", ply:GetCount("emitters") or 0)
	self:SetInfo(2, "Lamps:", ply:GetCount("lamps") or 0)
	self:SetInfo(2, "Spawners:", ply:GetCount("spawners") or 0)

	if self.Muted == nil or self.Muted ~= ply:IsMuted() then
		self.Muted = ply:IsMuted()
		if self.Muted then
			self.btnMute.Text = "Unmute"
		else
			self.btnMute.Text = "Mute"
		end

		self.btnMute.DoClick = function() ply:SetMuted(not self.Muted) end
	end

	self:InvalidateLayout()
end

function PANEL:ApplySchemeSettings()
	for _k, column in pairs(self.InfoLabels) do
		for k, v in pairs(column) do
			v.Key:SetTextColor(Color(50, 50, 50, 255))
			v.Value:SetTextColor(Color(80, 80, 80, 255))
		end
	end
end

function PANEL:Think()
	if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end
	self.PlayerUpdate = CurTime() + 0.25

	self:UpdatePlayerData()
end

function PANEL:PerformLayout(w, h)
	local x = 5

	for column, column in pairs(self.InfoLabels) do
		local y = 0
		local RightMost = 0

		for k, v in pairs(column) do
			v.Key:SetPos(x, y)
			v.Key:SizeToContents()

			v.Value:SetPos(x + 60 , y)
			v.Value:SizeToContents()

			y = y + v.Key:GetTall() + 2

			RightMost = math.max(RightMost, v.Value.x + v.Value:GetWide())
		end

		//x = RightMost + 10
		if (x < 100) then
		x = x + 205
		else
		x = x + 115
		end
	end

	if self.Player == LocalPlayer() then
		self.btnMute:SetVisible(false)
	else
		self.btnMute:SetVisible(true)
		self.btnMute:SetSize(46, 20)
		self.btnMute:SetPos(w - 175, 0)
	end

	for k, v in ipairs(self.VoteButtons) do
		v:InvalidateLayout()
		if k < 6 then
			v:SetPos(w - k * 25, 0)
		elseif k < 11 then
			v:SetPos(w - (k-5) * 25, 36)
		else
			v:SetPos(w- (k-10) * 25, 72)
		end
		v:SetSize(20, 32)
	end
end

function PANEL:Paint(w, h)
	return true
end

vgui.Register("suiscoreplayerinfocard", PANEL, "Panel")
