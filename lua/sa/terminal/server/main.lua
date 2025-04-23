SA.REQUIRE("random")
SA.REQUIRE("config")

require("supernet")

local HASH = SA.Random.String(32)
print("SA security hash: ", HASH)

SA.Terminal = SA.Terminal or {}

local SA_UpdateInfo

local RefinedResources = {{}, {}, {}, {}}
local PriceTable = {}
local BuyPriceTable = {}
local TempStorage = {}

local function AddRefineRes(res, rarity)
	table.insert(RefinedResources[rarity], res)
end
AddRefineRes("metals", 1)
AddRefineRes("carbon dioxide", 1)
AddRefineRes("water", 1)
AddRefineRes("hydrogen", 2)
AddRefineRes("nitrogen", 2)
AddRefineRes("terracrystal", 2)
AddRefineRes("oxygen", 2)
AddRefineRes("valuable minerals", 3)
AddRefineRes("dark matter", 4)
AddRefineRes("permafrost", 4)

local function AddResourcePrice(res, price)
	PriceTable[res] = price
end
AddResourcePrice("valuable minerals", 3.127)
AddResourcePrice("metals", 0.738)
AddResourcePrice("terracrystal", 1.492)
AddResourcePrice("dark matter", 2.762)
AddResourcePrice("permafrost", 2.113)

AddResourcePrice("hydrogen isotopes", 6750)
AddResourcePrice("helium isotopes", 4500)
AddResourcePrice("strontium clathrates", 9000)
AddResourcePrice("nitrogen isotopes", 2700)
AddResourcePrice("oxygen isotopes", 2610)
AddResourcePrice("carbon isotopes", 5400)


local function AddResourceBuyPrice(res, price)
	BuyPriceTable[res] = price
end
AddResourceBuyPrice("oxygen", 2.5)
AddResourceBuyPrice("nitrogen", 0.5)
AddResourceBuyPrice("carbon dioxide", 0.9)
AddResourceBuyPrice("hydrogen", 0.8)
AddResourceBuyPrice("energy", 1.0)
AddResourceBuyPrice("water", 3.0)

local StationPos = Vector(0, 0, 0)
local StationSize = 0

local function InitSATerminal()
	local config = SA.Config.Load("terminals")
	if config then
		StationPos = Vector(unpack(config.Station.Position))
		StationSize = config.Station.Size
	end
end
timer.Simple(0, InitSATerminal)

function SA.Terminal.GetStationPos()
	return StationPos
end

function SA.Terminal.GetStationSize()
	return StationSize
end

local function SendHash(ply)
	net.Start("SA_LoadHash")
		net.WriteString(HASH)
	net.Send(ply)
end
hook.Add("PlayerFullLoad", "SA_SendHash", SendHash)

local function UpdateCapacity(ply)
	local maxcap = ply.sa_data.station_storage.capacity
	local count = 0
	for k, v in pairs(ply.sa_data.station_storage.contents) do
		count = count + v
	end
	ply.sa_data.station_storage.remaining = maxcap - count
end

function SA.Terminal.SetupStorage(ply)
	local uid = ply:SteamID()
	if not TempStorage[uid] then
		TempStorage[uid] = {}
	end
	UpdateCapacity(ply)
end

function SA.Terminal.GetPermStorage(ply)
	local contents = ply.sa_data.station_storage.contents
	for k, v in pairs(contents) do
		if v <= 0 then
			contents[k] = nil
		end
	end
	return contents
end

local function SA_CanReset(ply)
	local researches = SA.Research.Get()
	for _, v in pairs(researches) do
		if SA.Research.GetFromPlayer(ply, v.name) < v.resetreq then return false end
	end
	return true
end

local function SA_SelectNode(ply, cmd, args)
	local NetID = tonumber(args[1])
	if not NetID then return end
	for k, v in pairs(ents.FindByClass("resource_node")) do
		if v:CPPIGetOwner() == ply and NetID == v.netid then
			ply.SelectedNode = v
			SA_UpdateInfo(ply)
			break
		end
	end
end
concommand.Add("sa_terminal_select_node", SA_SelectNode)

local function SA_SelectedNode(ply)
	--Use the node the player selected.
	if IsValid(ply.SelectedNode) and ply.SelectedNode:CPPIGetOwner() == ply then
		local dist = StationPos:Distance(ply.SelectedNode:GetPos())
		if dist < StationSize and ply.SelectedNode:GetClass() == "resource_node" then
			return ply.SelectedNode
		end
	end

	--No Specific node, select first in range.
	for k, v in pairs(ents.FindByClass("resource_node")) do
		if v:CPPIGetOwner() == ply and StationPos:Distance(v:GetPos()) < StationSize then
			return v
		end
	end
end

local function SA_UpdateNodeSelection(ply)
	local SelectedNode = SA_SelectedNode(ply)
	local SelectedID = 0

	local Nodes = {}
	for k, v in pairs(ents.FindByClass("resource_node")) do
		if v:CPPIGetOwner() == ply and StationPos:Distance(v:GetPos()) < StationSize then
			local NetID = v.netid
			table.insert(Nodes, NetID)
			if (SelectedNode == v) then
				SelectedID = NetID
			end
		end
	end

	table.sort(Nodes)

	local Selected = 0
	local Count = table.Count(Nodes)
	net.Start("SA_NodeSelectionUpdate")
		net.WriteInt(Count, 16)
		for k, v in pairs(Nodes) do
			net.WriteInt(v, 16)
			if (SelectedID == v) then
				Selected = k
			end
		end
		net.WriteInt(Selected, 16)
	net.Send(ply)
end

local function SA_GetResource(ply, res)
	local SelNode = SA_SelectedNode(ply)
	if (IsValid(SelNode)) then
		local count = SA.RD.GetNetResourceAmount(SelNode.netid, res)
		if count > 0 then
			return count, SelNode.netid
		end
	end
	return 0
end

local function SA_FindCapacity(ply, res)
	local SelNode = SA_SelectedNode(ply)
	if (IsValid(SelNode)) then
		local capacity = SA.RD.GetNetNetworkCapacity(SelNode.netid, res)
		if (capacity > 0) then
			return capacity, SelNode.netid
		end
	end
	return 0
end

local function SA_SupplyResource(ply, res, num)
	local SelNode = SA_SelectedNode(ply)
	if (IsValid(SelNode)) then
		SA.RD.SupplyNetResource(SelNode.netid, res, num, 293)
	end
	return 0
end

local function SA_GetShipResources(ply)
	local SelNode = SA_SelectedNode(ply)
	if (IsValid(SelNode)) then
		local tbl = SA.RD.GetNetTable(SelNode.netid).resources
		return tbl, SelNode.netid
	end
	return {}
end

local function SA_GetTempStorage(ply_or_uid)
	if type(ply_or_uid) ~= "string" then
		ply_or_uid = ply_or_uid:SteamID()
	end
	if not TempStorage[ply_or_uid] then
		TempStorage[ply_or_uid] = {}
	end
	for k, v in pairs(TempStorage[ply_or_uid]) do
		if v <= 0 then
			TempStorage[ply_or_uid][k] = nil
		end
	end
	return TempStorage[ply_or_uid]
end

function SA.Terminal.AddTempStorage(ply_or_uid, res, amount)
	local storage = SA_GetTempStorage(ply_or_uid)
	local count = storage[res] or 0
	storage[res] = count + amount
end

function SA.Terminal.SetVisible(ply, status)
	net.Start("SA_Terminal_SetVisible")
		net.WriteBool(status)
	net.Send(ply)
end

function SA.Terminal.Open(ply, ent)
	if ply.AtTerminal then
		return
	end
	ply.AtTerminal = true
	ply.AtTerminalEnt = ent
	SA.Terminal.SetVisible(ply, true)
	ply:Freeze(true)
	ply:ConCommand("sa_terminal_update")
end

local function SA_CloseTerminal(ply)
	SA.Terminal.SetVisible(ply, false)
	if not ply.AtTerminal then
		return
	end
	SA.SaveUser(ply)
	ply:Freeze(false)
	ply.AtTerminal = false
	ply.AtTerminalEnt = nil
end
concommand.Add("sa_terminal_close", SA_CloseTerminal)

local function SA_InfoSent(ply)
	ply.SendingTermUp = false
end

SA_UpdateInfo = function(ply, CanPass)
	--This will prevent it from updating if multiple terminal commands are executed in the same tick.
	if type(CanPass) == "string" or type(CanPass) == "table" or not CanPass then
		timer.Create("SA_UpdateTerminalInfo_Delay", 0.03, 1, function() SA_UpdateInfo(ply, true) end)
		return
	end

	--Break out if they should not be recieving a terminal update.
	if (ply.SendingTermUp or not ply.MayBePoked or not ply.AtTerminal or ply.IsAFK) then return end

	--Send the player a list of nodes within range.
	SA_UpdateNodeSelection(ply)

	local TempStorageU = SA_GetTempStorage(ply)

	local PermStorageU = SA.Terminal.GetPermStorage(ply)
	local ShipStorageU = SA_GetShipResources(ply)

	local ResTabl = {}
	for k, v in pairs(TempStorageU) do
		local price = PriceTable[k] or 0
		if ply.sa_data.faction_name == "corporation" then
			price = math.ceil((price * 1.33) * 1000) / 1000
		end
		ResTabl[k] = {v, tostring(price)}
	end

	ply.SendingTermUp = true
	supernet.Send(ply, "SA_TerminalUpdate", {
		ResTabl,
		math.floor(ply.sa_data.station_storage.remaining),
		math.floor(ply.sa_data.station_storage.capacity),
		PermStorageU,
		ShipStorageU,
		BuyPriceTable,
		ply.sa_data.research,
		SA_CanReset(ply),
		ply.sa_data.advancement_level,
	}, function() SA_InfoSent(ply) end)
end
concommand.Add("sa_terminal_update", SA_UpdateInfo)

local function SA_RefineOre(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[1]
	if CHECK ~= HASH then return end
	local uid = ply:SteamID()
	local ShipOre, netid = SA_GetResource(ply, "ore")
	local TempOre = TempStorage[uid].ore or 0
	local orecount = ShipOre + TempOre
	if orecount > 0 then
		-- TODO: Is this good?
		for k, v in pairs(RefinedResources) do
			local num = table.Count(v)
			for l, n in pairs(v) do
				local rarity = (5 - k) / 10
				local modifier = math.random(80, 120) / 100
				local yield = (orecount / num) * modifier * rarity
				local count = TempStorage[uid][n] or 0
				TempStorage[uid][n] = count + yield
			end
		end
		SA.RD.ConsumeNetResource(netid, "ore", orecount)
		TempStorage[uid].ore = 0
	end
	SA_UpdateInfo(ply)
end
concommand.Add("sa_refine_ore", SA_RefineOre)

local function SA_MarketSell(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 2 then return end
	local CHECK = args[3]
	if CHECK ~= HASH then return end
	local uid = ply:SteamID()
	local num = tonumber(args[2])
	if num <= 0 then return end

	local index = args[1]
	local amount = TempStorage[uid][index] or 0

	local selling
	if num > amount then
		selling = amount
	else
		selling = num
	end

	if selling < 1 then
		return
	end

	local price = PriceTable[index] or 0
	if price <= 0 then
		return
	end

	local credits = math.ceil(selling * price)
	if ply.sa_data.faction_name == "corporation" then
		credits = math.ceil(credits * 1.33)
	end
	TempStorage[uid][index] = amount - selling
	ply:RewardCredits(credits)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_market_sell", SA_MarketSell)

local function SA_MarketBuy(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 2 then return end
	local CHECK = args[3]
	if CHECK ~= HASH then return end
	local uid = ply:SteamID()
	local num = tonumber(args[2])
	if num <= 0 then return end

	local index = args[1]
	local buying
	local price
	local pricepu = BuyPriceTable[index] or 0
	if (pricepu <= 0) then return end
	price = math.ceil(num * pricepu)
	if (price > tonumber(ply.sa_data.credits)) then
		buying = math.floor(tonumber(ply.sa_data.credits) / pricepu)
		price = tonumber(ply.sa_data.credits)
	else
		buying = num
	end
	if buying > 0 then
		local v = TempStorage[uid][index]
		if v then
			TempStorage[uid][index] = v + buying
		else
			TempStorage[uid][index] = buying
		end
		ply.sa_data.credits = ply.sa_data.credits - price
	end
	SA.SendBasicInfo(ply)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_market_buy", SA_MarketBuy)

local function SA_MoveResource(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 4 then return end
	local uid = ply:SteamID()
	local from = string.lower(args[1])
	local to = string.lower(args[2])
	local res = args[3]
	local num = tonumber(args[4])
	local CHECK = args[5]
	if to == from then return end
	if CHECK ~= HASH then return end
	if num <= 0 then return end
	local maxamt = 0
	local netid
	if (from == "temp") then
		maxamt = TempStorage[uid][res]
	elseif (from == "perm") then
		maxamt = ply.sa_data.station_storage.contents[res]
	elseif (from == "ship") then
		maxamt, netid = SA_GetResource(ply, res)
	end
	if (not maxamt) or maxamt == 0 then
		return
	end
	local tomove
	if num > maxamt then
		tomove = maxamt
	else
		tomove = num
	end
	if (to == "temp") then
		local count = TempStorage[uid][res] or 0
		TempStorage[uid][res] = count + tomove
	elseif (to == "perm") then
		local count = ply.sa_data.station_storage.contents[res] or 0
		if tomove > ply.sa_data.station_storage.remaining then
			tomove = ply.sa_data.station_storage.remaining
		end
		ply.sa_data.station_storage.contents[res] = math.floor(count + tomove)
	elseif (to == "ship") then
		local shipcap = SA_FindCapacity(ply, res) or 0
		local maxshi = shipcap - SA_GetResource(ply, res)
		if tomove > maxshi then
			tomove = maxshi
		end
		SA_SupplyResource(ply, res, tomove)
	end
	if (from == "temp") then
		TempStorage[uid][res] = TempStorage[uid][res] - tomove
	elseif (from == "perm") then
		ply.sa_data.station_storage.contents[res] = ply.sa_data.station_storage.contents[res] - tomove
	elseif (from == "ship") then
		SA.RD.ConsumeNetResource(netid, res, tomove)
	end
	UpdateCapacity(ply)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_move_resource", SA_MoveResource)

local function SA_BuyPermStorage(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[2]
	if CHECK ~= HASH then return end
	local credits = tonumber(ply.sa_data.credits)
	local maxcap = ply.sa_data.station_storage.capacity
	local amt = tonumber(args[1])
	if amt <= 0 then return end
	local cost = amt * 10
	if credits >= cost then
		ply.sa_data.credits = credits - cost
		ply.sa_data.station_storage.capacity = maxcap + amt
		UpdateCapacity(ply)
		SA.SendBasicInfo(ply)
		SA_UpdateInfo(ply)
	end
end
concommand.Add("sa_buy_perm_storage", SA_BuyPermStorage)

local function SA_Research_Int(ply, Research)
	local cred = ply.sa_data.credits
	local cur = SA.Research.GetFromPlayer(ply, Research.name)
	local targetLevel = cur + 1

	local ok, total = SA.Research.GetLevelInfo(ply, Research, true, targetLevel)
	if not ok or cred < total then
		return
	end

	SA.Research.SetToPlayer(ply, Research.name, targetLevel)
	ply.sa_data.credits = ply.sa_data.credits - total
	return true
end

local function SA_Buy_Research_Cmd(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local res = args[1]
	local limit = tonumber(args[2])
	local CHECK = args[3]
	if CHECK ~= HASH then return end
	if limit < 1 then return end

	local research = SA.Research.GetByName(res)
	if not research then
		return
	end

	local ok = false
	while SA_Research_Int(ply, research) do
		ok = true
		limit = limit - 1
		if limit < 1 then
			break
		end
	end
	if not ok then return end

	SA_UpdateInfo(ply)
	for l, b in pairs(research.classes) do
		for k, v in pairs(ents.FindByClass(b)) do
			if v:CPPIGetOwner() == ply then
				v:CalcVars(ply)
			end
		end
	end
	SA.SendBasicInfo(ply)
end

concommand.Add("sa_buy_research", SA_Buy_Research_Cmd)

local function SA_ResetMe(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[1]
	if CHECK ~= HASH then return end

	if ply.sa_data.advancement_level >= 5 then return end

	local devlim = ply.sa_data.advancement_level
	local cost = 5000000000 * (devlim * devlim)
	if ply.sa_data.credits < cost then return end

	if not SA_CanReset(ply) then return end

	ply.sa_data.credits = ply.sa_data.credits - cost
	ply.sa_data.advancement_level = ply.sa_data.advancement_level + 1
	ply.sa_data.research = {}
	SA.Research.InitPlayer(ply)

	SA_UpdateInfo(ply)
	SA.SendBasicInfo(ply)
end
concommand.Add("sa_advance_level", SA_ResetMe)

local function SA_ResetMeHarder(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[1]
	if CHECK ~= HASH then return end

	if ply.sa_data.advancement_level < 5 then return end

	if not SA_CanReset(ply) then return end

	local data = ply.sa_data
	data.credits = 0
	data.advancement_level = 1
	data.prestige_level = data.prestige_level + 1
	data.research = {}
	data.station_storage = {
		capacity = 0,
		remaining = 0,
		contents = {},
	}
	SA.Research.InitPlayer(ply)

	local uid = ply:SteamID()
	TempStorage[uid] = {}

	SA_UpdateInfo(ply)
	SA.SendBasicInfo(ply)
	SA_CloseTerminal(ply)

	for k, v in pairs(ents.GetAll()) do
		if v:CPPIGetOwner() == ply then
			v:Remove()
		end
	end
	ply:Kill()
end
concommand.Add("sa_prestige_level", SA_ResetMeHarder)
