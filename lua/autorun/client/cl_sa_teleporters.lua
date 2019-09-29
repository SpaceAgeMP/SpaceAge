local SA_TeleportPanel = nil
local function DestroyTeleportPanel()
	if SA_TeleportPanel then
		SA_TeleportPanel:SetDeleteOnClose(true)
		SA_TeleportPanel:Close()
	end
end
DestroyTeleportPanel()
local SA_TeleList = {}
local SA_TeleportLocaLBox = nil
local SA_TeleKey = "NONE"

net.Receive("SA_HideTeleportPanel", function(len, ply)
	net.ReadBool()
	if not SA_TeleportPanel then return end
	gui.EnableScreenClicker(false)
	SA_TeleportPanel:SetVisible(false)
end)
local function RefreshTeleportPanel()
	if SA_TeleList and SA_TeleportLocaLBox then
		SA_TeleportLocaLBox:Clear()
		for k, v in pairs(SA_TeleList) do
			SA_TeleportLocaLBox:AddLine(v)
		end
	end
end

net.Receive("SA_TeleporterUpdate", function(len, ply)
	local iMax = net.ReadInt(16)
	SA_TeleList = {}
	for i = 1 , iMax do
		table.insert(SA_TeleList, net.ReadString())
	end
	RefreshTeleportPanel()
end)

local function CreateTeleportPanel()
	DestroyTeleportPanel()
	local ScrX = surface.ScreenWidth()
	local ScrY = surface.ScreenHeight()
	local BasePanel = vgui.Create("DFrame")
	BasePanel:SetPos((ScrX / 2) - 320, (ScrY / 2) - 243)
	BasePanel:SetSize(640, 486)
	BasePanel:SetTitle("Teleporter Form: " .. SA_TeleKey)
	BasePanel:SetDraggable(true)
	BasePanel:ShowCloseButton(false)
	BasePanel:SetDeleteOnClose(false)

	function BasePanel:Paint( w, h )
		draw.RoundedBoxOutlined(0, 0, 0, w, h, Color( 0, 0, 0, 120 ), SA_Term_BorderWid)
	end

	local TeleLBox = vgui.Create("DListView", BasePanel)
	TeleLBox:SetMultiSelect(false)
	TeleLBox:SetPos(20, 30)
	TeleLBox:AddColumn("Name")
	TeleLBox:SetSize(BasePanel:GetWide() - 40, 405)

	TeleLBox:SetDataHeight(28)

	function TeleLBox:Paint(w,h)
		draw.RoundedBoxOutlined(2,0,0,w,h,Color(255,255,255,50),2)
	end

	SA_TeleportLocaLBox = TeleLBox

	local AcceptButton = vgui.Create("DButton", BasePanel)
	AcceptButton:SetText("Teleport")
	AcceptButton:SetPos((BasePanel:GetWide() / 2) - 105, BasePanel:GetTall() - 45)
	AcceptButton:SetSize(100, 40)
	AcceptButton.DoClick = function()
		if SA_TeleportLocaLBox then
			local SelLine = SA_TeleportLocaLBox:GetSelectedLine()
			if SelLine then
				local SelPanel = SA_TeleportLocaLBox:GetLine(SelLine)
				if SelPanel then
					local SelText = SelPanel:GetValue(1)
					RunConsoleCommand("sa_teleporter_do", SelText)
				end
			end
		end
	end
	AcceptButton:SetFont("Trebuchet16")
	function AcceptButton:UpdateColours( skin )
		if ( not self:IsEnabled() )					then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
		if ( self:IsDown() || self.m_bSelected )	then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
		if ( self.Hovered )							then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end
		return self:SetTextStyleColor( Color(255,255,255,255) )
	end
	function AcceptButton:Paint( w, h )
		draw.RoundedBoxOutlined(2,0,0,w,h,Color(255,255,255,2),2)
		return false
	end
	SA_TeleportLocaLBox.DoDoubleClick = AcceptButton.DoClick

	local DenyButton = vgui.Create("DButton", BasePanel)
	DenyButton:SetText("Cancel")
	DenyButton:SetPos((BasePanel:GetWide() / 2) + 5, BasePanel:GetTall() - 45)
	DenyButton:SetSize(100, 40)
	DenyButton.DoClick = function()
		RunConsoleCommand("sa_teleporter_cancel")
	end
	DenyButton:SetFont("Trebuchet16")
	function DenyButton:UpdateColours( skin )
		if ( not self:IsEnabled() )					then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
		if ( self:IsDown() || self.m_bSelected )	then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
		if ( self.Hovered )							then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end
		return self:SetTextStyleColor( Color(255,255,255,255) )
	end
	function DenyButton:Paint( w, h )
		draw.RoundedBoxOutlined(2,0,0,w,h,Color(255,255,255,2),2)
		return false
	end

	BasePanel:SetVisible(false)
	SA_TeleportPanel = BasePanel
	RefreshTeleportPanel()
end
timer.Simple(0, CreateTeleportPanel)


net.Receive("SA_OpenTeleporter", function(len, ply)
	SA_TeleKey = net.ReadString()
	RunConsoleCommand("sa_teleporter_update")
	SA_TeleportPanel:SetTitle("Teleporter Form: " .. SA_TeleKey)
	gui.EnableScreenClicker(true)
	SA_TeleportPanel:SetVisible(true)
end)
