local AppPanel = nil

require("supernet")

local defaultText = "Hi"
local defaultFaction = "miners"

SA.Application = {}
SA.Application.Table = {}

local function InitSelfApplication()
	if not SA.Application.Me then
		SA.Application.Me = {}
	end
	if not SA.Application.Me.Text then
		SA.Application.Me.Text = defaultText
	end
	if not SA.Application.Me.FactionName then
		SA.Application.Me.FactionName = defaultFaction
	end
end
InitSelfApplication()

local function SA_Applications_Player(ply, data)
	SA.Application.Me = data
	InitSelfApplication()
	SA.Application.Refresh()
end
supernet.Hook("SA_Applications_Player", SA_Applications_Player)

local function SA_Applications_Faction(ply, data)
	SA.Application.Table = data
	SA.Application.Refresh()
end
supernet.Hook("SA_Applications_Faction", SA_Applications_Faction)

local ApplyText, PTimeLBL, ScoreLBL, SelFCombo, SelAppIndex

function SA.Application.Refresh()
	if not (PTimeLBL and ScoreLBL and ApplyText and SelFCombo) then return end

	local plisleader = LocalPlayer():GetNWBool("isleader")

	if plisleader then
		local fValue = false
		SelFCombo:Clear()
		for k, v in pairs(SA.Application.Table) do
			SelFCombo:AddChoice(v.Player.Name .. " | " .. v.SteamID)
			fValue = true
		end
		if fValue then
			SelFCombo:ChooseOptionID(1)
		end
	else
		SelFCombo:ChooseOption(SA.Factions.ToLong[SA.Application.Me.FactionName])
		ApplyText:SetValue(SA.Application.Me.Text)
	end
end

function SA.Application.CreateGUI(BasePanel)
	local ScrX = surface.ScreenWidth()
	local ScrY = surface.ScreenHeight()
	local bPanelGiven = true
	if not BasePanel then
		bPanelGiven = false
		BasePanel = vgui.Create("DFrame")
		BasePanel:SetPos((ScrX / 2) - 320, (ScrY / 2) - 243)
		BasePanel:SetSize(640, 486)
		BasePanel:SetTitle("Application Form")
		BasePanel:SetDraggable(true)
		BasePanel:ShowCloseButton(false)

		local CloseButton = vgui.Create("DButton", BasePanel)
		CloseButton:SetText("X")
		CloseButton:SetPos(BasePanel:GetWide() - 25, 1)
		CloseButton:SetSize(20, 20)
		CloseButton.DoClick = SA.Application.Close

		local BPanel = vgui.Create ("DPanel", BasePanel)
		BPanel:SetPos(0, 25)
		BPanel:SetSize(BasePanel:GetWide(), BasePanel:GetTall() - 25)
	end
	local plisleader = LocalPlayer():GetNWBool("isleader")

	ApplyText = vgui.Create("DTextEntry", BasePanel)

	if not plisleader then
		ApplyText:SetValue(SA.Application.Me.Text or defaultText)
	end

	ApplyText:SetMultiline(true)
	ApplyText:SetNumeric(false)
	ApplyText:SetEnterAllowed(true)

	SelFCombo = vgui.Create("DComboBox", BasePanel)
	--SelFCombo:SetEditable(false)
	SelFCombo:SetPos(15, 60)
	SelFCombo:SetSize(BasePanel:GetWide() - 40, 20)

	if not plisleader then
		ApplyText:SetPos(15, 85)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 410)
		ApplyText:SetUpdateOnType(true)
		ApplyText.OnTextChanged = function()
			SA.Application.Me.Text = ApplyText:GetValue()
		end

		SelFCombo:AddChoice("Major Miners")
		SelFCombo:AddChoice("The Guild")
		SelFCombo:AddChoice("The Corporation")
		SelFCombo:AddChoice("Star Fleet")

		function SelFCombo:OnSelect(index, value, data)
			SA.Application.Me.FactionName = SA.Factions.ToShort[value] or defaultFaction
		end

		SelFCombo:ChooseOption(SA.Factions.ToLong[SA.Application.Me.FactionName or defaultFaction])

		local ApplyButton = vgui.Create("DButton", BasePanel)
		ApplyButton:SetText("Submit")
		ApplyButton:SetPos((BasePanel:GetWide() / 2) - 50, BasePanel:GetTall() - 85)
		ApplyButton:SetSize(100, 40)
		ApplyButton.DoClick = SA.Application.Do
	else
		ApplyText:SetPos(15, 110)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 385)
		ApplyText:SetEditable(false)

		PTimeLBL = vgui.Create("DLabel", BasePanel)
		PTimeLBL:SetPos(20, 85)
		PTimeLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		PTimeLBL:SetText("Playtime: NOTHING SELECTED")
		ScoreLBL = vgui.Create("DLabel", BasePanel)
		ScoreLBL:SetPos(BasePanel:GetWide() / 2, 85)
		ScoreLBL:SetSize((BasePanel:GetWide() / 2) - 30, 20)
		ScoreLBL:SetText("Score: NOTHING SELECTED")

		function SelFCombo:OnSelect(index, value, data)
			SelAppIndex = index
			if not index then
				return
			end
			ApplyText:SetValue(SA.Application.Table[index].Text)
			PTimeLBL:SetText("Playtime: " .. SA.FormatTime(SA.Application.Table[index].Player.Playtime))
			ScoreLBL:SetText("Score: " .. SA.Application.Table[index].Player.TotalCredits)
		end

		local fValue = false
		for k, v in pairs(SA.Application.Table) do
			SelFCombo:AddChoice(v.Player.Name .. " | " .. v.SteamID)
			fValue = true
		end
		if fValue then
			SelFCombo:ChooseOptionID(1)
		end

		local AcceptButton = vgui.Create("DButton", BasePanel)
		AcceptButton:SetText("Accept")
		AcceptButton:SetPos((BasePanel:GetWide() / 2) - 105, BasePanel:GetTall() - 85)
		AcceptButton:SetSize(100, 40)
		AcceptButton.DoClick = function()
			local app = SA.Application.Table[SelAppIndex]
			if app then
				RunConsoleCommand("sa_application_accept", app.SteamID)
			end
		end
		local DenyButton = vgui.Create("DButton", BasePanel)
		DenyButton:SetText("Deny")
		DenyButton:SetPos((BasePanel:GetWide() / 2) + 5, BasePanel:GetTall() - 85)
		DenyButton:SetSize(100, 40)
		DenyButton.DoClick = function()
			local app = SA.Application.Table[SelAppIndex]
			if app then
				RunConsoleCommand("sa_application_deny", app.SteamID)
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
		net.WriteString(SA.Application.Me.Text)
		net.WriteString(SA.Application.Me.FactionName)
	net.SendToServer()
end
