SA.Terminal = {}

include("sa/terminal/client/research.lua")
include("sa/terminal/client/resource.lua")
include("sa/terminal/client/goodies.lua")

require("supernet")

local SA_FactionData = {}
local ResearchPanels = {}
local term_info = {}
local SA_Term_StationCap = 0
local SA_Term_StationMax = 0
local SA_DevLimitLevel = 1

if (SA_Term_GUI ~= nil) then
	SA_Term_GUI:SetVisible(false)
	gui.EnableScreenClicker(false)
	RunConsoleCommand("sa_terminal_close")
else
	SA_Term_GUI = nil
end

local SA_Term_GoodieList
local SA_Term_StatList
local SA_Term_MarketBuy
local SA_Term_MarketSell
local SA_Term_TempStorage
local SA_Term_PermStorage
local SA_Term_ShipStorage
local SA_UpgradeLevelButton
local SA_ApplyText
local SA_SelFCombo
local SA_AppBasePanel
local SA_MaxCrystalCount
local SA_CrystalRadius
local SA_Max_Roid_Count

local textBackgroundExtraWidth = 15
local function GetTextBackgroundWidth(_font, _text)
	surface.SetFont( _font )
	return select(1,surface.GetTextSize( _text )) + textBackgroundExtraWidth
end

surface.CreateFont("ServerHUDFontS", { font = "Arial", size = 22, weight = 700, antialias = true, shadow = false})

local ScrX = surface.ScreenWidth()
local ScrY = surface.ScreenHeight()
local HASH = ""

local function SA_RefreshStatsList(isAuto)
	if isAuto then timer.Simple(30, function() SA_RefreshStatsList(true) end) end
	if not SA_Term_StatList then return end
	SA_Term_StatList:OpenURL("https://stats.spaceage.online/?ingame=1&rand=" .. tostring(CurTime()))
end

local function SA_RecvFactionData(len, ply)
	local fn = net.ReadString()
	local tbl = {}
	tbl.Score = tonumber(net.ReadString())
	tbl.Credits = tonumber(net.ReadString())
	tbl.AddScore = tonumber(net.ReadString())
	tbl.RealScore = tonumber(net.ReadString())
	SA_FactionData[fn] = tbl
end
net.Receive("SA_FactionData", SA_RecvFactionData)

local SA_ErrorText = ""
local SA_ErrorAlpha = 0

local function SA_TermError(ErrText)
	SA_ErrorText = ErrText
	SA_ErrorAlpha = 150
end

local function SA_DevSetVal(vnum,vval)
	RunConsoleCommand("sa_dev_set_var",vnum,tonumber(vval:GetValue()))
end

function SA.Application.Refresh()
	if not (SA_AppBasePanel and SA_PTimeLBL and SA_ScoreLBL and SA_ApplyText and SA_SelFCombo) then return end
	local plisleader = LocalPlayer():GetNWBool("isleader")

	if plisleader then
		local fValue = false
		SA_SelFCombo:Clear()
		for k, v in pairs(AppTable) do
			SA_SelFCombo:AddChoice(v[1] .. " | " .. k)
			fValue = true
		end
		if (fValue) then
			SA_SelFCombo:ChooseOptionID(1)
			CSelID = SApp_ExtractSteamID(SA_SelFCombo:GetOptionText(1))
			if (CSelID and AppTable[CSelID]) then
				SA_ApplyText:SetValue(AppTable[CSelID][2])
				SA_PTimeLBL:SetText("Playtime: " .. AppTable[CSelID][3])
				SA_ScoreLBL:SetText("Score: " .. AppTable[CSelID][4])
			end
		else
			CSelID = ""
			SA_ApplyText:SetValue("")
			SA_PTimeLBL:SetText("Playtime: NOTHING SELECTED")
			SA_ScoreLBL:SetText("Score: NOTHING SELECTED")
		end
	else
		SA_SelFCombo:ChooseOption(SA.Application.Faction)
		SA_ApplyText:SetValue(SA.Application.Text)
	end
end

local function CreateTerminalGUI()

	local guiSizeX,guiSizeY = SA_Term_GUI:GetSize()

	if not LocalPlayer():GetNWBool("isloaded") then
		return
	end
	timer.Remove("SA_RecreateTermGUI")
	if SA_Term_GUI and SA_Term_GUI.Close then
		SA_Term_GUI:SetDeleteOnClose(true)
		SA_Term_GUI:Close()
	end

	local font = "ServerHUDFontS"
	surface.SetFont(font)
	local BasePanel = vgui.Create( "DFrame" )
	local x = ScrX / 2
	local y = ScrY / 2
	BasePanel:SetPos(x - 400, y - 350)
	BasePanel:SetSize(800, 700)
	BasePanel:SetTitle("Terminal v3, Powered by Intel Pentium IV 3.2 GHz Processor!")
	BasePanel:SetDraggable(true)
	BasePanel:ShowCloseButton(false)
	BasePanel:SetBackgroundBlur(true)

	SA_Term_GUI = BasePanel
	SA_Term_GUI.SA_IsTerminalGUI = true

	local CloseButton = vgui.Create("DButton", BasePanel)
	CloseButton:SetText("Close Terminal")
	CloseButton:SetPos(370,660)
	CloseButton:SetSize(90,30)
	CloseButton.DoClick = function()
		RunConsoleCommand("sa_terminal_close")
	end

	local NodeSelect = vgui.Create("DComboBox", BasePanel)
	NodeSelect:SetPos(25,665)
	NodeSelect:SetSize(120,20)
	--NodeSelect:SetEditable(false)

	local function UpdateNodeSelect(len, ply)
		NodeSelect:Clear()
		NodeSelect.Nodes = {}

		NodeSelect:AddChoice("Node Selection")
		NodeSelect:AddChoice("--------------")

		local count = net.ReadInt(16)
		for K = 1, count do
			local NetID = net.ReadInt(16)
			local Name = "Network " .. NetID
			NodeSelect.Nodes[Name] = NetID
			NodeSelect:AddChoice(Name)
		end
		NodeSelect.Selected = net.ReadInt(16) + 2
		if (NodeSelect.Selected > 2) then
			NodeSelect:ChooseOptionID(NodeSelect.Selected)
		else
			NodeSelect:ChooseOptionID(1)
		end
	end
	net.Receive("SA_NodeSelectionUpdate",UpdateNodeSelect)

	function NodeSelect:OnSelect(ID,Name,Data)
		if (ID <= 2) then return end
		if (ID == self.Selected) then return end
		local NetID = self.Nodes[Name]
		if (NetID > 0) then
			RunConsoleCommand("sa_terminal_select_node",NetID)
		end
	end

	local StatTab = vgui.Create ( "DPanel" )
	StatTab:SetPos(5,25)
	StatTab:SetSize(790,625)
	StatTab.Paint = function()
		local text = "Stats"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local StatsList = vgui.Create ( "HTML",StatTab )
	StatsList:SetPos(30,70)
	StatsList:SetSize(730,500)


	local GoodieTab = vgui.Create ( "DPanel" )
	GoodieTab:SetPos(5,25)
	GoodieTab:SetSize(790,625)
	GoodieTab.Paint = function()
		local text = "Goodies"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local GoodieList = vgui.Create ( "DPanelList",GoodieTab )
	GoodieList:SetPos(30,70)
	GoodieList:SetSize(730,500)
	GoodieList:SetSpacing(5)
	GoodieList:EnableVerticalScrollbar(true)

	SA_Term_GoodieList = GoodieList

	local Tabs = vgui.Create( "DPropertySheet", BasePanel )
	Tabs:SetPos(5,25)
	Tabs:SetSize(790,625)

	SA_Term_StatList = StatsList

	SA.Application.Refresh(true)

	local MarketTab = vgui.Create ( "DPanel" )
	MarketTab:SetPos(5,25)
	MarketTab:SetSize(790,625)
	MarketTab.Paint = function()

		local text = "Market"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		draw.RoundedBox(6,30,70,730,240,Color(90,90,90,255))
		draw.RoundedBox(6,30,330,730,240,Color(90,90,90,255))
		draw.RoundedBox(6,580,90,150,30,Color(50,50,50,255))
		draw.SimpleText("Sell Resources",font,655,105,Color(255,255,255,255),1,1)
		draw.RoundedBox(6,580,350,150,30,Color(50,50,50,255))
		draw.SimpleText("Buy Resources",font,655,365,Color(255,255,255,255),1,1)
	end

	local MarkSell = vgui.Create ( "DListView",MarketTab )
	MarkSell:SetPos(50,90)
	MarkSell:SetSize(500,200)
	MarkSell:SetMultiSelect(true)
	MarkSell:AddColumn("Resource")
	MarkSell:AddColumn("Amount")
	MarkSell:AddColumn("Price")

	SA_Term_MarketSell = MarkSell

	local SellAmount = vgui.Create("DTextEntry",MarketTab)
	SellAmount:SetPos(610,195)
	SellAmount:SetSize(90,30)
	SellAmount:AllowInput(false)
	SellAmount:SetValue("0")
	SellAmount:SetNumeric(true)

	local SellButton = vgui.Create("DButton",MarketTab)
	SellButton:SetPos(600,250)
	SellButton:SetSize(110,30)
	SellButton:SetText("Sell")
	SellButton.DoClick = function()
		local Amount = tonumber(SellAmount:GetValue())
		if (Amount < 0) then
			SA_TermError("You cannot sell negatives!")
			return
		elseif (Amount == 0) then
			Amount = 999999999999  --Sell ALL
		end

		local Selected = SA_Term_MarketSell:GetSelected()
		if table.Count(Selected) <= 0 then
			SA_TermError("Please pick the resource(s) you wish to sell.")
			return
		end
		for _,Line in pairs(Selected) do
			local Type = Line:GetValue(1)
			RunConsoleCommand("sa_market_sell",Type,Amount,HASH)
		end
	end

	local MarkBuy = vgui.Create ( "DListView",MarketTab )
	MarkBuy:SetPos(50,350)
	MarkBuy:SetSize(500,200)
	MarkBuy:SetMultiSelect(false)
	MarkBuy:AddColumn("Resource")
	MarkBuy:AddColumn("Price")


	SA_Term_MarketBuy = MarkBuy

	local BuyAmount = vgui.Create("DTextEntry",MarketTab)
	BuyAmount:SetPos(610,455)
	BuyAmount:SetSize(90,30)
	BuyAmount:AllowInput(false)
	BuyAmount:SetValue("0")
	BuyAmount:SetNumeric(true)

	local BuyButton = vgui.Create("DButton",MarketTab)
	BuyButton:SetPos(600,510)
	BuyButton:SetSize(110,30)
	BuyButton:SetText("Buy")
	BuyButton.DoClick = function()
		local Amount = tonumber(BuyAmount:GetValue())
		if ((not Amount) or (Amount <= 0)) then
			SA_TermError("Please input a number to buy!")
			return
		end
		local tmpX = SA_Term_MarketBuy:GetLine(SA_Term_MarketBuy:GetSelectedLine())
		if not tmpX then
			SA_TermError("Please pick a resource to buy!")
			return
		end
		local Type = tmpX:GetValue(1)
		RunConsoleCommand("sa_market_buy",Type,Amount,HASH)
	end

	local ResourceTab = vgui.Create ( "DPanel" )
	ResourceTab:SetPos(5,25)
	ResourceTab:SetSize(790,625)
	ResourceTab.Paint = function()
		local text = "Resources"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		draw.RoundedBox(6,30,70,240,500,Color(90,90,90,255))
		draw.RoundedBox(6,275,70,240,500,Color(90,90,90,255))
		draw.RoundedBox(6,520,70,240,500,Color(90,90,90,255))

		draw.RoundedBox(4,35,75,230,40,Color(50,50,50,255))
		draw.SimpleText("Temporary / Market",font,150,90+7,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.RoundedBox(4,280,75,230,40,Color(50,50,50,255))
		draw.SimpleText("Station",font,395,82+5,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("(" .. tostring(SA_Term_StationCap) .. " / " .. tostring(SA_Term_StationMax) .. ")","Trebuchet18",395,97+8,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.RoundedBox(4,525,75,230,40,Color(50,50,50,255))
		draw.SimpleText("Ship / Selected Node",font,640,90+5,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local TempStore = vgui.Create("DPanelList",ResourceTab)
	TempStore:SetPos(35,110)
	TempStore:SetSize(230,418)
	TempStore:EnableVerticalScrollbar(true)
	TempStore:SetSpacing(5)
	TempStore:SetPadding(5)

	local PermStore = vgui.Create("DPanelList",ResourceTab)
	PermStore:SetPos(280,110)
	PermStore:SetSize(230,418)
	PermStore:EnableVerticalScrollbar(true)
	PermStore:SetSpacing(5)
	PermStore:SetPadding(6)

	local ShipStore = vgui.Create("DPanelList",ResourceTab)
	ShipStore:SetPos(525,110)
	ShipStore:SetSize(230,418)
	ShipStore:EnableVerticalScrollbar(true)
	ShipStore:SetSpacing(5)
	ShipStore:SetPadding(5)

	local RefineButton = vgui.Create("DButton",ResourceTab)
	RefineButton:SetPos(35,533)
	RefineButton:SetSize(230,30)
	RefineButton:SetText("Refine Ore")

	local RefineButton1 = vgui.Create("DButton",ResourceTab)
	RefineButton1:SetPos(525,533)
	RefineButton1:SetSize(230,30)
	RefineButton1:SetText("Refine Ore")

	RefineButton.DoClick = function()
		RunConsoleCommand("sa_refine_ore",HASH)
	end
	RefineButton1.DoClick = RefineButton.DoClick

	local BuyStorageAmt = vgui.Create ("DTextEntry",ResourceTab)
	BuyStorageAmt:SetPos(410,538)
	BuyStorageAmt:SetSize(100,20)
	BuyStorageAmt:SetNumeric(true)
	BuyStorageAmt:SetValue(5000)

	local BuyStorageButton = vgui.Create("DButton",ResourceTab)
	BuyStorageButton:SetPos(280,533)
	BuyStorageButton:SetSize(125,30)
	BuyStorageButton:SetText("Buy Station Storage")

	BuyStorageButton.DoClick = function()
		RunConsoleCommand("sa_buy_perm_storage",BuyStorageAmt:GetValue(),HASH)
	end

	SA_Term_TempStorage = TempStore
	SA_Term_PermStorage = PermStore
	SA_Term_ShipStorage = ShipStore

	local ResearchTab = vgui.Create ( "DPanel" )
	ResearchTab:SetPos(5,25)
	ResearchTab:SetSize(790,625)
	ResearchTab.Paint = function()
		draw.RoundedBox(4,355,10,80,30,Color(50,50,50,255))
		draw.RoundedBox(16,25,450,520,100,Color(50,50,50,255))
		draw.RoundedBox(16,590,450,165,100,Color(50,50,50,255))

		local text = "Research"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local UpgradeLevelButton = vgui.Create( "DButton", ResearchTab )
	UpgradeLevelButton:SetPos(155,555)
	UpgradeLevelButton:SetSize(500,30)
	UpgradeLevelButton:SetText("Upgrade Level")
	UpgradeLevelButton:SetDisabled(true)
	UpgradeLevelButton.DoClick = function() Derma_Query("Do you really want to upgrade? You will lose all your current researches!","Confirm","Yes",function() RunConsoleCommand("sa_advance_level",HASH) end,"No",function() end) end
	SA_UpgradeLevelButton = UpgradeLevelButton

	local SubResearchTab = vgui.Create( "DPropertySheet", ResearchTab )
	SubResearchTab:SetPos(25,60)
	SubResearchTab:SetSize(730,490)

	local Researches = SA.Research.Get()
	local ResearchGroups = SA.Research.GetGroups()

	for _,RGroup in pairs(ResearchGroups) do
		if not ResearchPanels[RGroup] then
			ResearchPanels[RGroup] = {}
		end
		local GroupPanel = vgui.Create( "DPanel" )
		GroupPanel:SetPos(5,5)
		GroupPanel:SetSize(720,444)
		GroupPanel.Paint = function() end

		local GroupList = vgui.Create( "DPanelList",GroupPanel )
		GroupList:SetPos(5,5)
		GroupList:SetSize(710,434)
		GroupList:EnableVerticalScrollbar(true)
		GroupList:SetSpacing(5)

		local tbl = {}
		for k,v in pairs(Researches[RGroup]) do
			tbl[v["pos"]] = k
		end

		for k,v in pairs(tbl) do
			local ResearchData = Researches[RGroup][v]
			local ResearchPanel = vgui.Create("SA_Terminal_Research")
			ResearchPanel:SetSize(700,74)
			ResearchPanel:SetResearch(ResearchData)
			ResearchPanel.UpgradeCommand = function()
				RunConsoleCommand("sa_buy_research",v,HASH)
			end
			ResearchPanels[RGroup][v] = ResearchPanel
			GroupList:AddItem(ResearchPanel)
		end
		SubResearchTab:AddSheet( RGroup, GroupPanel, "VGUI/application-monitor", false, false, RGroup )
	end

	local ApplicationTab = vgui.Create ( "DPanel" )
	ApplicationTab:SetPos(5,25)
	ApplicationTab:SetSize(790,625)
	ApplicationTab.Paint = function()
		local text = "Application"
		local width = GetTextBackgroundWidth(font, text)
		draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
		draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local plisleader = LocalPlayer():GetNWBool("isleader")

	local ApplyText = vgui.Create( "DTextEntry", ApplicationTab )
	ApplyText:SetMultiline(true)
	ApplyText:SetNumeric(false)
	ApplyText:SetEnterAllowed(true)

	SA_ApplyText = ApplyText

	if (not plisleader) then
		ApplyText:SetPos(15, 85)
		ApplyText:SetSize(ApplicationTab:GetWide() - 40, 410)
		ApplyText:SetUpdateOnType(true)
		ApplyText.OnTextChanged = function()
			SA.Application.Text = ApplyText:GetValue()
		end
	else
		ApplyText:SetPos(15, 110)
		ApplyText:SetSize(BasePanel:GetWide() - 40, 385)
		ApplyText:SetEditable(false)
	end

	local SelFCombo = vgui.Create("DComboBox", ApplicationTab)
	--SelFCombo:SetEditable(false)
	SelFCombo:SetPos(15,60)
	SelFCombo:SetSize(ApplicationTab:GetWide() - 40, 20)

	SA_SelFCombo = SelFCombo

	if (not plisleader) then
		SelFCombo:AddChoice("Major Miners")
		SelFCombo:AddChoice("The Legion")
		SelFCombo:AddChoice("The Corporation")
		SelFCombo:AddChoice("Star Fleet")

		SelFCombo.OnSelect = function(index,value,data)
			SA.Application.Faction = data
		end

		local ClearButton = vgui.Create( "DButton", ApplicationTab )
		ClearButton:SetText("Clear")
		ClearButton:SetPos((ApplicationTab:GetWide() / 2) + 5, ApplicationTab:GetTall() - 85)
		ClearButton:SetSize(100,40)

		ClearButton.DoClick = function()
			SA.Application.Text = "Hi"
			SA.Application.Faction = "Major Miners"
			SA.Application.Refresh()
		end

		local ApplyButton = vgui.Create( "DButton", ApplicationTab )
		ApplyButton:SetText("Submit")
		ApplyButton:SetPos((ApplicationTab:GetWide() / 2) - 105, ApplicationTab:GetTall() - 85)
		ApplyButton:SetSize(100,40)

		ApplyButton.DoClick = SA.Application.Do

	else

		local PTimeLBL = vgui.Create("DLabel", ApplicationTab)
		PTimeLBL:SetPos(20, 85)
		PTimeLBL:SetSize((ApplicationTab:GetWide() / 2) - 30, 20)
		PTimeLBL:SetText("Playtime: NOTHING SELECTED")

		SA_PTimeLBL = PTimeLBL

		local ScoreLBL = vgui.Create("DLabel", ApplicationTab)
		ScoreLBL:SetPos(ApplicationTab:GetWide() / 2, 85)
		ScoreLBL:SetSize((ApplicationTab:GetWide() / 2) - 30, 20)
		ScoreLBL:SetText("Score: NOTHING SELECTED")

		SA_ScoreLBL = ScoreLBL

		SelFCombo.OnSelect = function(index,value,data)
		CSelID = SApp_ExtractSteamID(data)
			if (CSelID and AppTable[CSelID]) then
				ApplyText:SetValue(AppTable[CSelID][2])
				PTimeLBL:SetText("Playtime: " .. AppTable[CSelID][3])
				ScoreLBL:SetText("Score: " .. AppTable[CSelID][4])
			end
		end

		local AcceptButton = vgui.Create( "DButton", ApplicationTab )
		AcceptButton:SetText("Accept")
		AcceptButton:SetPos((ApplicationTab:GetWide() / 2) - 105, ApplicationTab:GetTall() - 85)
		AcceptButton:SetSize(100,40)
		AcceptButton.DoClick = function()
			if CSelID ~= "" and AppTable[CSelID] then
				RunConsoleCommand("sa_application_accept",CSelID)
			end
		end
		local DenyButton = vgui.Create( "DButton", ApplicationTab )
		DenyButton:SetText("Deny")
		DenyButton:SetPos((ApplicationTab:GetWide() / 2) + 5, ApplicationTab:GetTall() - 85)
		DenyButton:SetSize(100,40)
		DenyButton.DoClick = function()
			if CSelID ~= "" and AppTable[CSelID] then
				RunConsoleCommand("sa_application_deny",CSelID)
			end
		end
	end


	SA_AppBasePanel = ApplicationTab

	local DeveloperTab = nil

	if LocalPlayer():IsSuperAdmin() then
		DeveloperTab = vgui.Create ( "DPanel" )
		DeveloperTab:SetPos(5,25)
		DeveloperTab:SetSize(790,625)
		DeveloperTab.Paint = function()
			local text = "Development"
			local width = GetTextBackgroundWidth(font, text)
			draw.RoundedBox(4,guiSizeX/2-width/2,10,width,30,Color(50,50,50,255))
			draw.SimpleText(text,font,guiSizeX/2,25,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		SA_MaxCrystalCount = vgui.Create("DTextEntry", DeveloperTab)
		SA_MaxCrystalCount:SetText("0")
		SA_MaxCrystalCount:SetEditable(true)
		SA_MaxCrystalCount:SetPos(270,60)
		SA_MaxCrystalCount:SetSize(100, 20)

		local SA_MaxCrystalCount_LBL = vgui.Create("DLabel", DeveloperTab)
		SA_MaxCrystalCount_LBL:SetText("Maximum Crystals per Tower:")
		SA_MaxCrystalCount_LBL:SetPos(15,60)
		SA_MaxCrystalCount_LBL:SetSize(250, 20)

		SA_CrystalRadius = vgui.Create("DTextEntry", DeveloperTab)
		SA_CrystalRadius:SetText("0")
		SA_CrystalRadius:SetEditable(true)
		SA_CrystalRadius:SetPos(270,85)
		SA_CrystalRadius:SetSize(100, 20)

		local SA_CrystalRadius_LBL = vgui.Create("DLabel", DeveloperTab)
		SA_CrystalRadius_LBL:SetText("Maximum Radius of Crystals around Tower:")
		SA_CrystalRadius_LBL:SetPos(15,85)
		SA_CrystalRadius_LBL:SetSize(250, 20)

		SA_Max_Roid_Count = vgui.Create("DTextEntry", DeveloperTab)
		SA_Max_Roid_Count:SetText("0")
		SA_Max_Roid_Count:SetEditable(true)
		SA_Max_Roid_Count:SetPos(270,110)
		SA_Max_Roid_Count:SetSize(100, 20)

		local SA_Max_Roid_Count_LBL = vgui.Create("DLabel", DeveloperTab)
		SA_Max_Roid_Count_LBL:SetText("Maximum Asteroids:")
		SA_Max_Roid_Count_LBL:SetPos(15,110)
		SA_Max_Roid_Count_LBL:SetSize(250, 20)

		local ResetPlanetsButton = vgui.Create( "DButton", DeveloperTab )
		ResetPlanetsButton:SetText("Reset Planets")
		ResetPlanetsButton:SetPos(15, 215)
		ResetPlanetsButton:SetSize(150,40)
		ResetPlanetsButton.DoClick = function()
			RunConsoleCommand("sa_restart_environment")
		end

		local ResetRoidsButton = vgui.Create( "DButton", DeveloperTab )
		ResetRoidsButton:SetText("Respawn Asteroids")
		ResetRoidsButton:SetPos(15, 260)
		ResetRoidsButton:SetSize(150,40)
		ResetRoidsButton.DoClick = function()
			RunConsoleCommand("sa_respawn_asteroids")
		end

		local RemoveCrystalsButton = vgui.Create( "DButton", DeveloperTab )
		RemoveCrystalsButton:SetText("Respawn all Crystals")
		RemoveCrystalsButton:SetPos(15, 305)
		RemoveCrystalsButton:SetSize(150,40)
		RemoveCrystalsButton.DoClick = function()
			RunConsoleCommand("sa_respawn_crystals")
		end

		local NewAutospawnButton = vgui.Create( "DButton", DeveloperTab )
		NewAutospawnButton:SetText("Respawn all SpaceAge Stuff")
		NewAutospawnButton:SetPos(15, 350)
		NewAutospawnButton:SetSize(150,40)
		NewAutospawnButton.DoClick = function()
			RunConsoleCommand("sa_autospawn_run")
		end

		local RestartServerButton = vgui.Create( "DButton", DeveloperTab )
		RestartServerButton:SetText("Restart Server")
		RestartServerButton:SetPos(215, 215)
		RestartServerButton:SetSize(150,40)
		RestartServerButton.DoClick = function()
			RunConsoleCommand("RestartServer")
		end

		local RemoveErrorsButton = vgui.Create( "DButton", DeveloperTab )
		RemoveErrorsButton:SetText("Remove ERRORs")
		RemoveErrorsButton:SetPos(215, 260)
		RemoveErrorsButton:SetSize(150,40)
		RemoveErrorsButton.DoClick = function()
			RunConsoleCommand("fa","removeerrors")
		end

		local ChangeButton = vgui.Create( "DButton", DeveloperTab )
		ChangeButton:SetText("Apply")
		ChangeButton:SetPos((DeveloperTab:GetWide() / 2) - 105, 140)
		ChangeButton:SetSize(100,40)
		ChangeButton.DoClick = function()
			SA_DevSetVal(1,SA_MaxCrystalCount)
			SA_DevSetVal(2,SA_CrystalRadius)
			SA_DevSetVal(3,SA_Max_Roid_Count)
		end
		local CancelButton = vgui.Create( "DButton", DeveloperTab )
		CancelButton:SetText("Cancel")
		CancelButton:SetPos((DeveloperTab:GetWide() / 2) + 5, 140)
		CancelButton:SetSize(100,40)
		CancelButton.DoClick = function()
			RunConsoleCommand("sa_terminal_update")
		end
	end

	SA.Application.Refresh()

	Tabs:AddSheet( "Stats", StatTab, "VGUI/application-monitor", false, false, "Statistics" )
	Tabs:AddSheet( "Market", MarketTab, "VGUI/balance", false, false, "Marketplace" )
	Tabs:AddSheet( "Resources", ResourceTab, "VGUI/box", false, false, "Storage" )
	Tabs:AddSheet( "Research", ResearchTab, "VGUI/blueprint", false, false, "Research" )
	Tabs:AddSheet( "Application", ApplicationTab, "VGUI/auction-hammer-gavel", false, false, "Application" )
	Tabs:AddSheet( "Goodies", GoodieTab, "VGUI/box", false, false, "Goodies" )


	if DeveloperTab then
		Tabs:AddSheet( "Development", DeveloperTab, "VGUI/bank", false, false, "Development" )
	end

	BasePanel:MakePopup()
	BasePanel:SetVisible(false)
end
timer.Create("SA_RecreateTermGUI", 1, 0, CreateTerminalGUI)

local function SA_DrawTerminalError()
	if (SA_ErrorAlpha > 0) then
		local TermX, TermY = SA_Term_GUI:GetPos()
		TermX = TermX + 395
		TermY = TermY + 65
		surface.SetFont("ServerHUDFontS")
		local Wide,Tall = surface.GetTextSize(SA_ErrorText)
		TermX = TermX - Wide / 2
		TermY = TermY - Tall / 2
		draw.WordBox(8,TermX,TermY,SA_ErrorText,"ServerHUDFontS",Color(200,0,0,SA_ErrorAlpha),Color(255,255,255,SA_ErrorAlpha))
		SA_ErrorAlpha = SA_ErrorAlpha - FrameTime() * 50
	end
end
hook.Add("PostRenderVGUI","SA_DrawTerminalError",SA_DrawTerminalError)

local function SA_RefreshGoodiesRecv(ply, decoded)
	if not SA_Term_GoodieList then return end

	SA_Term_GoodieList:Clear()
	local goodie
	for _,v in pairs(decoded) do
		goodie = vgui.Create("SA_Terminal_Goodie")
		goodie:SetSize(700,74)
		goodie:SetNameDescID(v["intid"],v["id"])
		SA_Term_GoodieList:AddItem(goodie)
	end
end
supernet.Hook("SA_GoodieUpdate", SA_RefreshGoodiesRecv)

local function sa_terminal_msg(len, ply)
	local active = net.ReadBool()
	if active then
		SA.Application.Refresh()
		if not SA_Term_GUI then
			CreateTerminalGUI()
			if not SA_Term_GUI then
				RunConsoleCommand("sa_close_terminal")
				return
			end
		end
	end
	SA_Term_GUI:SetVisible(active)
	gui.EnableScreenClicker(active)
end
net.Receive("SA_Terminal_SetVisible", sa_terminal_msg)

local function CleanString(str)
	local implode = {}
	local splode = string.Explode(" ",str)
	for k,v in pairs(splode) do
		local lead = string.upper(string.sub(v,1,1))
		local trail = string.sub(v,2)
		implode[k] = lead .. trail
	end
	local cleaned = string.Implode(" ",implode)
	return cleaned
end

local function sa_term_update1(len, ply)
	term_info.orecount = SA.AddCommasToInt(net.ReadInt(32))
	term_info.tempore = SA.AddCommasToInt(net.ReadInt(32))
end
net.Receive("SA_TerminalUpdateSmall", sa_term_update1)

local function sa_term_update(ply, tbl)
	local ResTabl = tbl[1]
	local capacity = tbl[2]
	local maxcap = tbl[3]
	local PermStorage = tbl[4]
	local ShipStorage = tbl[5]
	local BuyPriceTable = tbl[6]
	local ResTabl2 = tbl[7]
	local canReset = tbl[8]
	local lv = tbl[9]
	local devVars = tbl[10]

	if lv >= 5 then canReset = false end
	SA_DevLimitLevel = lv

	if SA_UpgradeLevelButton then
		SA_UpgradeLevelButton:SetDisabled(not canReset)
		SA_UpgradeLevelButton:SetText("Advance Level (current: " .. tostring(lv) .. " / 5) [Price: " .. SA.AddCommasToInt(5000000000 * (lv * lv)) .. "]")
	end


	SA_Term_TempStorage:Clear()
	SA_Term_MarketSell:Clear()
	for k,v in pairs(ResTabl) do
		local name = CleanString(k)
		local value = SA.AddCommasToInt(v[1])
		local price = v[2]
		local item = vgui.Create("SA_Terminal_Resource")
		item:SetSize(220,42)
		item:SetLocation("temp")
		item:SetResource(name,v[1])
		SA_Term_TempStorage:AddItem(item)
		SA_Term_MarketSell:AddLine(name,value,price)
	end

	SA_Term_PermStorage:Clear()
	SA_Term_StationCap = SA.AddCommasToInt(capacity)
	SA_Term_StationMax = SA.AddCommasToInt(maxcap)

	for k,v in pairs(PermStorage) do
		local name = CleanString(tostring(k))
		local item = vgui.Create("SA_Terminal_Resource")
		item:SetSize(220,42)
		item:SetLocation("perm")
		item:SetResource(name,v)
		SA_Term_PermStorage:AddItem(item)
	end
	SA_Term_ShipStorage:Clear()
	for k,v in pairs(ShipStorage) do
		local name = CleanString(k)
		if math.floor(v.value) > 0 and math.floor(v.maxvalue) > 0 then
			local item = vgui.Create("SA_Terminal_Resource")
			item:SetSize(220,42)
			item:SetLocation("ship")
			item:SetResource(name,v.value,v.maxvalue)
			SA_Term_ShipStorage:AddItem(item)
		end
	end

	SA_Term_MarketBuy:Clear()
	for k,v in pairs(BuyPriceTable) do
		local name = CleanString(v[1])
		local price = v[2]
		SA_Term_MarketBuy:AddLine(name,price)
	end

	local Researches = SA.Research.Get()

	for k,v in pairs(ResTabl2) do
		local resgroup = v[1]
		local resname = v[2]
		local rank = v[3]
		local group = v[4]

		local cost = ""
		local val = Researches[resgroup][resname]

		local ranks = val["ranks"]
		if (ranks == rank) and (ranks ~= 0) then
			cost = "Max Rank"
		else
			local base = val["cost"]
			local inc = base * (val["costinc"] / 100)
			local total = base + (inc * rank)
			total = total * (SA_DevLimitLevel * SA_DevLimitLevel)
			if group == "legion" or group == "alliance" then
				total = math.ceil(total * 0.75)
			elseif group == "starfleet" then
				total = math.ceil(total * 0.9175)
			end
			cost = "Cost: " .. SA.AddCommasToInt(total)
		end
		ResearchPanels[resgroup][resname]:Update(rank,cost)
	end

	if SA_MaxCrystalCount and SA_CrystalRadius and SA_Max_Roid_Count then
		SA_MaxCrystalCount:SetText(devVars[1])
		SA_CrystalRadius:SetText(devVars[2])
		SA_Max_Roid_Count:SetText(devVars[3])
	end
end
supernet.Hook("SA_TerminalUpdate", sa_term_update)

local function SetHash(len, ply)
	HASH = net.ReadString()
	SA.SetResourceItemPanelHash(HASH)
end
net.Receive("SA_LoadHash", SetHash)
