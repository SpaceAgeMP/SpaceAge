local function DestroyTeleportPanel()
	if SA_TeleportPanel then
		SA_TeleportPanel:SetDeleteOnClose(true)
		SA_TeleportPanel:Close()
	end
end
DestroyTeleportPanel()
SA_TeleList = {}
SA_TeleportPanel = nil
SA_TeleportLocaLBox = nil
SA_TeleKey = "NONE"

usermessage.Hook("SA_HideTeleportPanel",function(um)
	um:ReadBool()
	if not SA_TeleportPanel then return end
	gui.EnableScreenClicker(false)
	SA_TeleportPanel:SetVisible(false)
end)
local function RefreshTeleportPanel()
	if SA_TeleList and SA_TeleportLocaLBox then
		SA_TeleportLocaLBox:Clear()
		for k,v in pairs(SA_TeleList) do
			SA_TeleportLocaLBox:AddLine(v)
		end
	end
end

usermessage.Hook("SA_TeleUpdate",function(msg)
	local iMax = msg:ReadShort()
	local i = nil
	SA_TeleList = {}
	for i=1,iMax,1 do
		table.insert(SA_TeleList,msg:ReadString())
	end
	RefreshTeleportPanel()
end)

local function CreateTeleportPanel()
	DestroyTeleportPanel()
	local ScrX = surface.ScreenWidth()
	local ScrY = surface.ScreenHeight()
	local BasePanel = vgui.Create("DFrame")
	BasePanel:SetPos((ScrX / 2) - 320, (ScrY / 2) - 243)
	BasePanel:SetSize(640,486)
	BasePanel:SetTitle("Teleporter Form: "..SA_TeleKey)
	BasePanel:SetDraggable(true)
	BasePanel:ShowCloseButton(false)
	BasePanel:SetDeleteOnClose(false)

	local TeleLBox = vgui.Create("DListView", BasePanel)
	TeleLBox:SetMultiSelect(false)
	TeleLBox:SetPos(20,30)
	TeleLBox:AddColumn("Name")
	TeleLBox:SetSize(BasePanel:GetWide() - 40,405)
	
	SA_TeleportLocaLBox = TeleLBox
	
	local AcceptButton = vgui.Create( "DButton", BasePanel )
	AcceptButton:SetText("Teleport")
	AcceptButton:SetPos((BasePanel:GetWide() / 2) - 105, BasePanel:GetTall() - 45)
	AcceptButton:SetSize(100,40)
	AcceptButton.DoClick = function()
		if SA_TeleportLocaLBox then
			local SelLine = SA_TeleportLocaLBox:GetSelectedLine()
			if SelLine then
				local SelPanel = SA_TeleportLocaLBox:GetLine(SelLine)
				if SelPanel then
					local SelText = SelPanel:GetValue(1)
					RunConsoleCommand("sadoteleport",SelText)
				end
			end
		end
	end
	SA_TeleportLocaLBox.DoDoubleClick = AcceptButton.DoClick
	local DenyButton = vgui.Create( "DButton", BasePanel )
	DenyButton:SetText("Cancel")
	DenyButton:SetPos((BasePanel:GetWide() / 2) + 5, BasePanel:GetTall() - 45)
	DenyButton:SetSize(100,40)
	DenyButton.DoClick = function()
		RunConsoleCommand("sacancelteleport")
	end
	BasePanel:SetVisible(false)
	SA_TeleportPanel = BasePanel
	RefreshTeleportPanel()
end
timer.Simple(0,CreateTeleportPanel)


usermessage.Hook("SA_OpenTeleporter",function(msg)
	SA_TeleKey = msg:ReadString()
	RunConsoleCommand("sateleporterupdate")
	SA_TeleportPanel:SetTitle("Teleporter Form: "..SA_TeleKey)
	gui.EnableScreenClicker(true)
	SA_TeleportPanel:SetVisible(true)
end)