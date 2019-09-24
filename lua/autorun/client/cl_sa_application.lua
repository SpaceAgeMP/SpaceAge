local AppPanel = nil

SA.Application = {}
SA.Application.Table = {}
SA.Application.Text = "Hi"
SA.Application.Faction = "Major Miners"

local CSelID = ""

local function SA_DoSetAppData(len, ply)
	SA.Application.Faction = net.ReadString()
	SA.Application.Text = net.ReadString()
	SA.Application.Refresh()
end
net.Receive("SA_DoSetApplicationData",SA_DoSetAppData)

local function SA_DoAddApp(len, ply)
	local steamid = net.ReadString()
	local name = net.ReadString()
	local text = net.ReadString()
	local playtime = net.ReadString()
	local score = net.ReadString()

	AppTable[steamid] = {name, text, playtime, SA.AddCommasToInt(score)}
	SA.Application.Refresh()
end
net.Receive("SA_DoAddApplication",SA_DoAddApp)

local function SA_DoDelApp(len, ply)
	AppTable[net.ReadString()] = nil
	SA.Application.Refresh()
end
net.Receive("SA_DoDeleteApplication",SA_DoDelApp)

local function SApp_ExtractSteamID(optiontext)
	local temp = string.Explode("|",optiontext)
	if #temp < 1 then return "" end
	return string.Trim(temp[#temp])
end

local function CreateAppGUI(BasePanel)
	local ScrX = surface.ScreenWidth()
	local ScrY = surface.ScreenHeight()
	local bPanelGiven = true
	if not BasePanel then
		bPanelGiven = false
		BasePanel = vgui.Create("DFrame")
		BasePanel:SetPos((ScrX / 2) - 320, (ScrY / 2) - 243)
		BasePanel:SetSize(640,486)
		BasePanel:SetTitle("Application Form")
		BasePanel:SetDraggable(true)
		BasePanel:ShowCloseButton(false)

		local CloseButton = vgui.Create( "DButton", BasePanel )
		CloseButton:SetText("X")
		CloseButton:SetPos(BasePanel:GetWide() - 25, 1)
		CloseButton:SetSize(20,20)
		CloseButton.DoClick = SA.Application.Close

		local BPanel = vgui.Create ("DPanel", BasePanel)
		BPanel:SetPos(0, 25)
		BPanel:SetSize(BasePanel:GetWide(), BasePanel:GetTall() - 25)
	end
	local plisleader = LocalPlayer():GetNWBool("isleader")

	local ApplyText = vgui.Create( "DTextEntry", BasePanel )

	if (not plisleader) then
		ApplyText:SetValue(SA.Application.Text)
	end

	ApplyText:SetMultiline(true)
	ApplyText:SetNumeric(false)
	ApplyText:SetEnterAllowed(true)

	if (not plisleader) then
		ApplyText:SetPos(20, 55)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 380)
		ApplyText:SetUpdateOnType(true)
		ApplyText.OnTextChanged = function()
			SA.Application.Text = ApplyText:GetValue()
		end
	else
		ApplyText:SetPos(20, 80)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 355)
		ApplyText:SetEditable(false)
	end

	local SelFCombo = vgui.Create("DMultiChoice", BasePanel)
	SelFCombo:SetEditable(false)
	SelFCombo:SetPos(20,30)
	SelFCombo:SetSize(BasePanel:GetWide() - 40, 20)
	if (not plisleader) then
		SelFCombo:AddChoice("Major Miners")
		SelFCombo:AddChoice("The Guild")
		SelFCombo:AddChoice("The Corporation")
		SelFCombo:AddChoice("Star Fleet")
		SelFCombo:ChooseOption(SA.Application.Faction)
		SelFCombo.OnSelect = function(index,value,data)
			SA.Application.Faction = data
		end
	else
		local PTimeLBL = vgui.Create("DLabel", BasePanel)
		PTimeLBL:SetPos(20, 55)
		PTimeLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		PTimeLBL:SetText("Playtime: NOTHING SELECTED")
		local ScoreLBL = vgui.Create("DLabel", BasePanel)
		ScoreLBL:SetPos(BasePanel:GetWide() / 2, 55)
		ScoreLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		ScoreLBL:SetText("Score: NOTHING SELECTED")

		local fValue = false
		for k, v in pairs(AppTable) do
			SelFCombo:AddChoice(v[1] .. " | " .. k)
			fValue = true
		end
		if (fValue) then
			SelFCombo:ChooseOptionID(1)
			CSelID = SApp_ExtractSteamID(SelFCombo:GetOptionText(1))
			if (CSelID and AppTable[CSelID]) then
				ApplyText:SetValue(AppTable[CSelID][2])
				PTimeLBL:SetText("Playtime: " .. AppTable[CSelID][3])
				ScoreLBL:SetText("Score: " .. AppTable[CSelID][4])
			end
		else
			CSelID = ""
		end
		SelFCombo.OnSelect = function(index,value,data)
			CSelID = SApp_ExtractSteamID(data)
			if (CSelID and AppTable[CSelID]) then
				ApplyText:SetValue(AppTable[CSelID][2])
				PTimeLBL:SetText("Playtime: " .. AppTable[CSelID][3])
				ScoreLBL:SetText("Score: " .. AppTable[CSelID][4])
			end
		end
	end

	if (not plisleader) then
		local ApplyButton = vgui.Create( "DButton", BasePanel )
		ApplyButton:SetText("Submit")
		ApplyButton:SetPos((BasePanel:GetWide() / 2) - 50, BasePanel:GetTall() - 45)
		ApplyButton:SetSize(100,40)
		ApplyButton.DoClick = DoApply
	else
		local AcceptButton = vgui.Create( "DButton", BasePanel )
		AcceptButton:SetText("Accept")
		AcceptButton:SetPos((BasePanel:GetWide() / 2) - 105, BasePanel:GetTall() - 45)
		AcceptButton:SetSize(100,40)
		AcceptButton.DoClick = function()
			if CSelID ~= "" and AppTable[CSelID] then
				RunConsoleCommand("sa_application_accept",CSelID)
			end
		end
		local DenyButton = vgui.Create( "DButton", BasePanel )
		DenyButton:SetText("Deny")
		DenyButton:SetPos((BasePanel:GetWide() / 2) + 5, BasePanel:GetTall() - 45)
		DenyButton:SetSize(100,40)
		DenyButton.DoClick = function()
			if CSelID ~= "" and AppTable[CSelID] then
				RunConsoleCommand("sa_application_deny",CSelID)
			end
		end
	end

	if not bPanelGiven then
		BasePanel:MakePopup()
		BasePanel:SetVisible(false)
		AppPanel = BasePanel
	end
end

function SA.Application.Start()
	CreateAppGUI()
	AppPanel:SetVisible(true)
	gui.EnableScreenClicker(true)
end

function SA.Application.Close()
	if AppPanel then
		AppPanel:SetVisible(false)
		AppPanel:Close()
		gui.EnableScreenClicker(false)
	end
end

function SA.Application.Do()
	net.Start("SA_DoApplyFaction")
		net.WriteString(SA.Application.Text)
		net.WriteString(SA.Application.Faction)
	net.SendToServer()
end
