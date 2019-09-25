AddCSLuaFile("autorun/client/cl_sa_terminal.lua")
AddCSLuaFile("sa/terminal/client/research.lua")
AddCSLuaFile("sa/terminal/client/resource.lua")
AddCSLuaFile("sa/terminal/client/goodies.lua")

require("supernet")

local HASH = tostring(math.random(1000000,9999999))
if SecureRandomString then
	HASH = SecureRandomString(32)
end
print("SA security hash: ", HASH)

SA.Terminal = {}

local SA_UpdateInfo

local RefinedResources = {{},{},{},{}}
local PriceTable = {}
local BuyPriceTable = {}
local TempStorage = {}
local PermStorage = {}

local function AddRefineRes(res,rarity)
	table.insert(RefinedResources[rarity],res)
end
AddRefineRes("metals",1)
AddRefineRes("carbon dioxide",1)
AddRefineRes("water",1)
AddRefineRes("hydrogen",2)
AddRefineRes("nitrogen",2)
AddRefineRes("terracrystal",2)
AddRefineRes("oxygen",2)
AddRefineRes("valuable minerals",3)
AddRefineRes("dark matter",4)
AddRefineRes("permafrost",4)

local function AddResourcePrice(res,price)
	table.insert(PriceTable,{res,price})
end
AddResourcePrice("Valuable Minerals",3.127)
AddResourcePrice("Metals",0.738)
AddResourcePrice("Terracrystal",1.492)
AddResourcePrice("Dark Matter",2.762)
AddResourcePrice("Permafrost",2.113)

AddResourcePrice("Hydrogen Isotopes",6750)
AddResourcePrice("Helium Isotopes",4500)
AddResourcePrice("Strontium Clathrates",9000)
AddResourcePrice("Nitrogen Isotopes",2700)
AddResourcePrice("Oxygen Isotopes",2610)
AddResourcePrice("Liquid Ozone",5400)


local function AddResourceBuyPrice(res,price)
	table.insert(BuyPriceTable,{res,price})
end
AddResourceBuyPrice("Oxygen",2.5)
AddResourceBuyPrice("Nitrogen",0.5)
AddResourceBuyPrice("Carbon Dioxide",0.9)
AddResourceBuyPrice("Hydrogen",0.8)
AddResourceBuyPrice("Energy",1.0)
AddResourceBuyPrice("Water",3.0)


local StationPos = Vector(0,0,0)
local StationSize = 0
local RD = CAF.GetAddon("Resource Distribution")

local function InitSATerminal()
	local mapname = string.lower(game:GetMap())
	if mapname == "gm_galactic_rc1" then
		StationPos = Vector(-8896,10192,768)
		StationSize = 1024
	elseif mapname == "sb_forlorn_sb3_r2l" then
		StationPos = Vector(9447,9824,461)
		StationSize = 2650
	elseif mapname == "sb_forlorn_sb3_r3" then
		StationPos = Vector(9447,9824,461)
		StationSize = 2650
	elseif mapname == "sb_new_worlds_2" then
		StationPos = Vector(-8253,-9771,-11041)
		StationSize = 3000
	elseif mapname == "sb_gooniverse" then
		StationSize = 1130
		StationPos = Vector(2,-1,4620)
	elseif mapname == "sb_lostinspace_rc4" then
		StationSize = 4200
		StationPos = Vector(-8996,8636,-6500)
	elseif mapname == "sb_wuwgalaxy_fix" then
		StationSize = 2750
		StationPos = Vector(8348,4520,7271)
	elseif mapname == "gm_flatgrass" then
		StationSize = 256
		StationPos = Vector(740, 0, 0)
	end
	RD.AddProperResourceName("valuable minerals","Valuable Minerals")
	RD.AddProperResourceName("dark matter","Dark Matter")
	RD.AddProperResourceName("terracrystal","Terracrystal")
	RD.AddProperResourceName("permafrost","Permafrost")
	RD.AddProperResourceName("ore","Ore")
	RD.AddProperResourceName("tiberium","Tiberium")
	RD.AddProperResourceName("metals","Metals")
end
timer.Simple(0,InitSATerminal)

function SA.Terminal.GetStationPos()
	return StationPos
end

function SA.Terminal.GetStationSize()
	return StationSize
end

local function SendHash(ply)
	timer.Simple(5,function()
		net.Start("SA_LoadHash")
			net.WriteString(HASH)
		net.Send(ply)
	end)
end
hook.Add("PlayerInitialSpawn","SA_SendHash",SendHash)

local function UpdateCapacity(ply)
	local maxcap = ply.SAData.StationStorage.Capacity
	local uid = ply:UniqueID()
	local count = 0
	for k,v in pairs(PermStorage[uid]) do
		count = count + v
	end
	ply.SAData.StationStorage.Remaining = maxcap - count
end

function SA.Terminal.SetupStorage(ply, tbl)
	local uid = ply:UniqueID()
	if not TempStorage[uid] then
		TempStorage[uid] = {}
	end
	if tbl then
		PermStorage[uid] = tbl
	end
	if not PermStorage[uid] then
		PermStorage[uid] = {}
	end
	UpdateCapacity(ply)
end

function SA.Terminal.GetPermStorage(ply)
	local uid = ply:UniqueID()
	return PermStorage[uid]
end

local function SA_CanReset(ply)
	local Researches = SA.Research.Get()
	for _,vv in pairs(Researches) do
		for _,v in pairs(vv) do
			if SA.Research.GetFromPlayer(ply, v.name) < v.resetreq then return false end
		end
	end
	return true
end

local function SA_SelectNode(ply,cmd,args)
	local NetID = tonumber(args[1])
	if not NetID then return end
	for k,v in pairs(ents.FindByClass("resource_node")) do
		if (SA.PP.GetOwner(v) == ply and NetID == v:GetNWInt("netid")) then
			ply.SelectedNode = v
			SA_UpdateInfo(ply)
			break
		end
	end
end
concommand.Add("sa_terminal_select_node",SA_SelectNode)

local function SA_SelectedNode(ply)
	--Use the node the player selected.
	if SA.ValidEntity(ply.SelectedNode) and SA.PP.GetOwner(ply.SelectedNode) == ply then
		local dist = StationPos:Distance(ply.SelectedNode:GetPos())
		if dist < StationSize and ply.SelectedNode:GetClass() == "resource_node" then
			return ply.SelectedNode
		end
	end

	--No Specific node, select first in range.
	for k,v in pairs(ents.FindByClass("resource_node")) do
		if (SA.PP.GetOwner(v) == ply) and (StationPos:Distance(v:GetPos()) < StationSize) then
			return v
		end
	end
end

local function SA_UpdateNodeSelection(ply)
	local SelectedNode = SA_SelectedNode(ply)
	local SelectedID = 0

	local Nodes = {}
	for k,v in pairs(ents.FindByClass("resource_node")) do
		if (SA.PP.GetOwner(v) == ply) and (StationPos:Distance(v:GetPos()) < StationSize) then
			local NetID = v:GetNWInt("netid")
			table.insert(Nodes,NetID)
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
		for k,v in pairs(Nodes) do
			net.WriteInt(v, 16)
			if (SelectedID == v) then
				Selected = k
			end
		end
		net.WriteInt(Selected, 16)
	net.Send(ply)
end

local function SA_GetResource(ply,res)
	local SelNode = SA_SelectedNode(ply)
	if (SA.ValidEntity(SelNode)) then
		local count = RD.GetNetResourceAmount(SelNode.netid, res)
		if count > 0 then
			return count, SelNode.netid
		end
	end
	return 0
end

local function SA_FindCapacity(ply,res)
	local SelNode = SA_SelectedNode(ply)
	if (SA.ValidEntity(SelNode)) then
		local capacity = RD.GetNetNetworkCapacity(SelNode.netid, res)
		if (capacity > 0) then
			return capacity, SelNode.netid
		end
	end
	return 0
end

local function SA_SupplyResource(ply, res, num)
	local SelNode = SA_SelectedNode(ply)
	if (SA.ValidEntity(SelNode)) then
		RD.SupplyNetResource(SelNode.netid, res, num)
	end
	return 0
end

local function SA_GetShipResources(ply)
	local SelNode = SA_SelectedNode(ply)
	if (SA.ValidEntity(SelNode)) then
		local tbl = RD.GetNetTable(SelNode.netid).resources
		return tbl, SelNode.netid
	end
	return {}
end

local function SA_GetTempStorage(ply)
	local uid = ply:UniqueID()
	for k,v in pairs(TempStorage[uid]) do
		if v <= 0 then
			TempStorage[uid][k] = nil
		end
	end
	return TempStorage[uid]
end

local function SA_GetPermStorage(ply)
	local uid = ply:UniqueID()
	for k,v in pairs(PermStorage[uid]) do
		if v <= 0 then
			PermStorage[uid][k] = nil
		end
	end
	return PermStorage[uid]
end

function SA.Terminal.SetVisible(ply,status)
	net.Start("SA_Terminal_SetVisible")
		net.WriteBool(status)
	net.Send(ply)
end

local function SA_CloseTerminal(ply)
	if ply.AtTerminal then
		SA.SaveUser(ply)
	end
	SA.Terminal.SetVisible(ply,false)
	ply:Freeze(false)
	ply.AtTerminal = false
end
concommand.Add("sa_terminal_close",SA_CloseTerminal)

local function SA_InfoSent(ply)
	ply.SendingTermUp = false
end

SA_UpdateInfo = function(ply,CanPass)
	--This will prevent it from updating if multiple terminal commands are executed in the same tick.
	if type(CanPass) == "string" or type(CanPass) == "table" or not CanPass then
		timer.Create("SA_UpdateTerminalInfo_Delay",0.03,1, function() SA_UpdateInfo(ply, true) end)
		return
	end

	--Break out if they should not be recieving a terminal update.
	if (ply.SendingTermUp or not ply.MayBePoked or not ply.AtTerminal or ply.IsAFK) then return end

	--Send the player a list of nodes within range.
	SA_UpdateNodeSelection(ply)

	local uid = ply:UniqueID()
	local TempStorageU = SA_GetTempStorage(ply)

	local orecount = SA_GetResource(ply,"ore")
	local tempore = TempStorageU.ore

	local PermStorageU = SA_GetPermStorage(ply)
	local ShipStorageU = SA_GetShipResources(ply)

	net.Start("SA_TerminalUpdateSmall")
		net.WriteInt(orecount or 0, 32)
		net.WriteInt(tempore or 0, 32)
	net.Send(ply)

	local ResTabl = {}
	for k,v in pairs(TempStorageU) do
		local price = 0
		for l,n in pairs(PriceTable) do
			if string.lower(k) == string.lower(n[1]) then
				price = n[2]
				break
			end
		end
		if ply.SAData.FactionName == "corporation" or ply.SAData.FactionName == "alliance" then
			price = math.ceil((price * 1.33) * 1000) / 1000
		elseif ply.SAData.FactionName == "starfleet" then
			price = math.ceil((price * 1.11) * 1000) / 1000
		end
		ResTabl[k] = {v,tostring(price)}
	end

	local Researches = SA.Research.Get()
	local ResearchGroups = SA.Research.GetGroups()

	local ResTabl2 = {}

	for _,RGroup in pairs(ResearchGroups) do
		for k,v in pairs(Researches[RGroup]) do
			ResTabl2[k] = {RGroup,k,SA.Research.GetFromPlayer(ply, v.name),ply.SAData.FactionName}
		end
	end

	local DevVars = {0,0,0}
	if ply:GetLevel() >= 3 then
		DevVars = {SA.Tiberium.MaxCrystalCount,SA.Tiberium.CrystalRadius,SA.Asteroids.MaxCount}
	end

	ply.SendingTermUp = true
	supernet.Send(ply, "SA_TerminalUpdate", {
		ResTabl,
		math.floor(ply.SAData.StationStorage.Remaining),
		math.floor(ply.SAData.StationStorage.Capacity),
		PermStorageU,
		ShipStorageU,
		BuyPriceTable,
		ResTabl2,
		SA_CanReset(ply),
		ply.SAData.Research.GlobalMultiplier,
		DevVars,
	}, function() SA_InfoSent(ply) end)
end
concommand.Add("sa_terminal_update",SA_UpdateInfo)

local function SA_UpdateGoodies(data, isok, merror, ply)
	if not SA.ValidEntity(ply) then return end
	if not isok then ply.SendingGoodieUp = false end
	ply.Goodies = {}
	for _,v in pairs(data) do
		ply.Goodies[v["id"]] = SA.Goodies[v["intid"]]
	end
	supernet.Send(ply, "SA_GoodieUpdate", data, function() ply.SendingGoodieUp = false end)
end

local function SA_RequestUpdateGoodies(ply)
	if ply.SendingGoodieUp then return end
	ply.SendingGoodieUp = true
	local sid = ply:SteamID()
	if not SA.MySQL:Query("SELECT id,intid FROM goodies WHERE steamid='" .. SA.MySQL:Escape(sid) .. "'", SA_UpdateGoodies, ply) then
		ply.SendingGoodieUp = false
	end
end
concommand.Add("sa_goodies_update",SA_RequestUpdateGoodies)

local function SA_UseGoodie(ply,cmd,args)
	local id = tonumber(args[1])
	local goodie = ply.Goodies[id]
	if not goodie then return end

	ply.Goodies[id] = nil

	goodie.func(ply)

	--FA.SA.MySQL.SavePlayer(ply)
	SA.SaveUser(ply)

	SA.MySQL:Query("DELETE FROM goodies WHERE id='" .. SA.MySQL:Escape(id) .. "'",function() SA_RequestUpdateGoodies(ply) end)
end
concommand.Add("sa_goodies_use",SA_UseGoodie)

local function SA_RefineOre(ply,cmd,args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[1]
	if CHECK ~= HASH then return end
	local uid = ply:UniqueID()
	local ShipOre, netid = SA_GetResource(ply,"ore")
	local TempOre = TempStorage[uid]["ore"] or 0
	local orecount = ShipOre + TempOre
	if orecount > 0 then
		for k,v in pairs(RefinedResources) do
			local num = table.Count(v)
			for l,n in pairs(v) do
				local rarity = (5 - k) / 10
				local modifier = math.random(80,120) / 100
				local yield = (orecount / num) * modifier * rarity
				local count = TempStorage[uid][n] or 0
				TempStorage[uid][n] = count + yield
			end
		end
		RD.ConsumeNetResource(netid,"ore",orecount)
		TempStorage[uid]["ore"] = 0
	end
	SA_UpdateInfo(ply)
end
concommand.Add("sa_refine_ore",SA_RefineOre)

local function SA_MarketSell(ply,cmd,args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 2 then return end
	local CHECK = args[3]
	if CHECK ~= HASH then return end
	local uid = ply:UniqueID()
	local num = tonumber(args[2])
	if num <= 0 then return end
	local amount = 0
	local index = 0
	local selling = 0
	for k,v in pairs(TempStorage[uid]) do
		if (string.lower(k) == string.lower(args[1])) then
			amount = v
			index = k
		end
	end
	if (num > amount) then
		selling = amount
	else
		selling = num
	end
	if (selling > 0) then
		for k,v in pairs(PriceTable) do
			if string.lower(v[1]) == string.lower(args[1]) then
				local count = math.ceil(selling * v[2])
				if ply.SAData.FactionName == "corporation" or ply.SAData.FactionName == "alliance" then
					count = math.ceil(count * 1.33)
				elseif ply.SAData.FactionName == "starfleet" then
					count = math.ceil(count * 1.11)
				end
				ply.SAData.Credits = ply.SAData.Credits + count
				ply.SAData.TotalCredits = ply.SAData.TotalCredits + count
				TempStorage[uid][index] = amount - selling
			end
		end
	end
	SA.SendCreditsScore(ply)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_market_sell",SA_MarketSell)

local function SA_MarketBuy(ply,cmd,args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 2 then return end
	local CHECK = args[3]
	if CHECK ~= HASH then return end
	local uid = ply:UniqueID()
	local num = tonumber(args[2])
	if num <= 0 then return end
	local index = 0
	local buying = 0
	local price = 0
	local pricepu = 0
	for k,v in pairs(BuyPriceTable) do
		if (string.lower(v[1]) == string.lower(args[1])) then
			pricepu = v[2]
			index = string.lower(v[1])
		end
	end
	if (pricepu <= 0) then return end
	price = math.ceil(num * pricepu)
	if (price > tonumber(ply.SAData.Credits)) then
		buying = math.floor(tonumber(ply.SAData.Credits) / pricepu)
		price = tonumber(ply.SAData.Credits)
	else
		buying = num
	end
	if (buying > 0) then
		local bought = false
		for k,v in pairs(TempStorage[uid]) do
			if string.lower(k) == index then
				ply.SAData.Credits = ply.SAData.Credits - price
				TempStorage[uid][k] = v + buying
				bought = true
			end
		end
		if (not bought) then
			ply.SAData.Credits = ply.SAData.Credits - price
			TempStorage[uid][index] = buying
		end
	end
	SA.SendCreditsScore(ply)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_market_buy",SA_MarketBuy)

local function SA_MoveResource(ply,cmd,args,notagain)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	if #args < 4 then return end
	local uid = ply:UniqueID()
	local from = string.lower(args[1])
	local to = string.lower(args[2])
	local res = args[3]
	local num = tonumber(args[4])
	local CHECK = args[5]
	if CHECK ~= HASH then return end
	if num <= 0 then return end
	local maxamt = 0
	if (from == "temp") then
		maxamt = TempStorage[uid][res]
	elseif (from == "perm") then
		maxamt = PermStorage[uid][res]
	elseif (from == "ship") then
		maxamt, netid = SA_GetResource(ply,res)
	end
	if (not maxamt) or maxamt == 0 then
		if notagain and tostring(notagain) == "reallynotagain" then return end
		args[3] = string.lower(args[3])
		SA_MoveResource(ply,cmd,args,"reallynotagain")
		return
	end
	local tomove = 0
	if num > maxamt then
		tomove = maxamt
	else
		tomove = num
	end
	if (to == "temp") then
		local count = TempStorage[uid][res] or 0
		TempStorage[uid][res] = count + tomove
	elseif (to == "perm") then
		local count = PermStorage[uid][res] or 0
		if tomove > ply.SAData.StationStorage.Remaining then
			tomove = ply.SAData.StationStorage.Remaining
		end
		PermStorage[uid][res] = math.floor(count + tomove)
	elseif (to == "ship") then
		local shipcap = SA_FindCapacity(ply,res) or 0
		local maxshi = shipcap - SA_GetResource(ply,res)
		if tomove > maxshi then
			tomove = maxshi
		end
		SA_SupplyResource(ply, res, tomove)
	end
	if (from == "temp") then
		TempStorage[uid][res] = TempStorage[uid][res] - tomove
	elseif (from == "perm") then
		PermStorage[uid][res] = PermStorage[uid][res] - tomove
	elseif (from == "ship") then
		RD.ConsumeNetResource(netid, res, tomove)
	end
	UpdateCapacity(ply)
	SA_UpdateInfo(ply)
end
concommand.Add("sa_move_resource",SA_MoveResource)

local function SA_BuyPermStorage(ply,cmd,args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[2]
	if CHECK ~= HASH then return end
	local credits = tonumber(ply.SAData.Credits)
	local maxcap = ply.SAData.StationStorage.Capacity
	local amt = tonumber(args[1])
	if amt <= 0 then return end
	local cost = amt * 10
	if credits >= cost then
		ply.SAData.Credits = credits - cost
		ply.SAData.StationStorage.Capacity = maxcap + amt
		UpdateCapacity(ply)
		SA.SendCreditsScore(ply)
		SA_UpdateInfo(ply)
	end
end
concommand.Add("sa_buy_perm_storage",SA_BuyPermStorage)

local function SA_Research(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local Researches = SA.Research.Get()
	local ResearchGroups = SA.Research.GetGroups()
	local res = args[1]
	local CHECK = args[2]
	if CHECK ~= HASH then return end
	local Research = nil
	for _,RGroup in pairs(ResearchGroups) do
		for k,v in pairs(Researches[RGroup]) do
			if (k == res) then
				Research = v
				break
			end
		end
		if (Research) then
			break
		end
	end
	if not Research then return end

	local cur = SA.Research.GetFromPlayer(ply, Research.name)
	local cap = Research["ranks"]
	if (cap ~= 0) and cap == cur then
		return
	end
	if (Research["faction"] and #Research["faction"] > 0) then
		if not table.HasValue(Research["faction"],ply.SAData.FactionName) then
			return
		end
	end
	if (Research["type"] ~= "none") then
		local prereq = Research["prereq"]
		local reqtype = Research["type"]
		if reqtype == "unlock" then
			for k,v in pairs(prereq) do
				if v[1] == "faction" then
					if not table.HasValue(v[2],ply.SAData.FactionName) then
						return
					end
				elseif ply[v[1]] < v[2] then
					return
				end
			end
		elseif reqtype == "perrank" then
			local idx = cur + 1
			local tbl = Research["prereq"][idx]
			if tbl and #tbl > 0 then
				for k,v in pairs(tbl) do
					if v[1] == "faction" then
						if not table.HasValue(v[2],ply.SAData.FactionName) then
							return
						end
					elseif SA.Research.GetFromPlayer(ply, v[1]) < v[2] then
						return
					end
				end
			end
		end
	end
	local cost = Research["cost"]
	local inc = Research["costinc"] / 100
	local devl = ply.SAData.Research.GlobalMultiplier
	local cred = tonumber(ply.SAData.Credits)
	local total = cost + (cost * inc) * cur
	total = total * (devl * devl)

	if ply.SAData.FactionName == "legion" or ply.SAData.FactionName == "alliance" then
		total = math.ceil(total * 0.66)
	elseif ply.SAData.FactionName == "starfleet" then
		total = math.ceil(total * 0.88)
	end

	if cred >= total then
		SA.Research.SetToPlayer(ply, Research.name, cur + 1)
		ply.SAData.Credits = ply.SAData.Credits - total
		SA_UpdateInfo(ply)
		local retro = Research["classes"]
		for l,b in pairs(retro) do
			for k,v in pairs(ents.FindByClass(b)) do
				if (SA.PP.GetOwner(v) == ply) then
					v:CalcVars(ply)
				end
			end
		end
	end
	SA.SendCreditsScore(ply)
end
concommand.Add("sa_buy_research",SA_Research)

local function SA_ResetMe(ply, cmd, args)
	if not ply.AtTerminal then return end
	if ply.IsAFK then return end
	local CHECK = args[1]
	if CHECK ~= HASH then return end

	if ply.SAData.Research.GlobalMultiplier >= 5 then return end

	local devlim = ply.SAData.Research.GlobalMultiplier
	local cost = 5000000000 * (devlim * devlim)
	if ply.SAData.Credits < cost then return end

	if not SA_CanReset(ply) then return end

	ply.SAData.Credits = ply.SAData.Credits - cost
	ply.SAData.Research.GlobalMultiplier = ply.SAData.Research.GlobalMultiplier + 1

	SA_UpdateInfo(ply)
	SA.SendCreditsScore(ply)
end
concommand.Add("sa_advance_level",SA_ResetMe)

local function SA_DevSetVar(ply, cmd, args)
	if not (ply and ply:IsValid() and ply:IsAdmin()) then return end
	if #args < 2 then return end
	local varid = tonumber(args[1])
	local cval = tonumber(args[2])
	if varid <= 0 or cval <= 0 then return end
	local varname = "UNKOWN"
	if varid == 1 then
		if SA.Tiberium.MaxCrystalCount == cval then return end
		SA.Tiberium.MaxCrystalCount = cval
		varname = "max. concurrent tiberium crystals per tower"
	elseif varid == 2 then
		if SA.Tiberium.CrystalRadius == cval then return end
		SA.Tiberium.CrystalRadius = cval
		varname = "max. radius of tiberium crystals around tower"
	elseif varid == 3 then
		if SA.Asteroids.MaxCount == cval then return end
		SA.Asteroids.MaxCount = cval
		varname = "max. concurrent asteroid count"
	end
	SystemSendMSG(ply, "changed " .. varname .. " to " .. tostring(cval))
end
concommand.Add("sa_dev_set_var",SA_DevSetVar)

local function CheckCanDevice(ply,tr,mode)
	if (mode == "mining_laser_sa") then
		local lvl = ply.SAData.Research.OreLaserLevel
		local sel = ply:GetActiveWeapon()["Tool"]["mining_laser_sa"]:GetClientInfo("type")
		if sel == "sa_mining_laser_ii" then
			if lvl < 1 then
				ply:AddHint("You must have Rank 1 Mining Theory to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "sa_mining_laser_iii" then
			if lvl < 2 then
				ply:AddHint("You must have Rank 2 Mining Theory to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "sa_mining_laser_iv" then
			if lvl < 3 then
				ply:AddHint("You must have Rank 3 Mining Theory to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "sa_mining_laser_v" then
			if lvl < 4 then
				ply:AddHint("You must have Rank 4 Mining Theory to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "sa_mining_laser_vi" then
			if ply.SAData.FactionName ~= "miners" and ply.SAData.FactionName ~= "alliance" then
				ply:AddHint("You must be in Major Miners or The Alliance to use this!", NOTIFY_CLEANUP, 5)
				return false
			elseif lvl < 5 then
				ply:AddHint("You must have Rank 5 Mining Theory to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
		local lvl = ply.SAData.Research.IceLaserLevel
		if sel == "ice_mining_laser_2" then
			if lvl < 1 then
				ply:AddHint("You must have Rank 1 ICE Lasers to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "ice_mining_laser_3" then
			if lvl < 2 then
				ply:AddHint("You must have Rank 2 ICE Lasers to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
		local lvl = ply.SAData.Research.IceRefineryLevel
		if sel == "ice_refinery_imrpoved" then
			if lvl < 1 then
				ply:AddHint("You must have Rank 1 ICE Refineries to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "ice_refinery_advanced" then
			if lvl < 2 then
				ply:AddHint("You must have Rank 2 ICE Refineries to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
		local lvl = ply.SAData.Research.TiberiumDrillLevel
		if sel == "sa_mining_drill_ii" then
			if ply.SAData.FactionName ~= "legion" and ply.SAData.FactionName ~= "alliance" then
				ply:AddHint("You must be in The Legion or The Alliance to use this!", NOTIFY_CLEANUP, 5)
				return false
			elseif lvl < 1 then
				ply:AddHint("You must have Rank 1 Tiberium Drills to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
	elseif (mode == "mining_storage") then
		local lvl = ply.SAData.Research.OreStorageLevel
		local sel = ply:GetActiveWeapon()["Tool"]["mining_storage"]:GetClientInfo("type")
		local sel2 = ply:GetActiveWeapon()["Tool"]["mining_storage"]:GetClientInfo("model")
		if sel == "ore_storage_ii" then
			if lvl < 1 then
				ply:AddHint("You must have Rank 1 Ore Management to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "ore_storage_iii" then
			if lvl < 2 then
				ply:AddHint("You must have Rank 2 Ore Management to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "ore_storage_iv" then
			if lvl < 3 then
				ply:AddHint("You must have Rank 3 Ore Management to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "ore_storage_v" then
			if ply.SAData.FactionName ~= "starfleet" and ply.SAData.FactionName ~= "miners" and ply.SAData.FactionName ~= "alliance" then
				ply:AddHint("You must be in Star Fleet or Major Miners or The Alliance to use this!", NOTIFY_CLEANUP, 5)
				return false
			elseif lvl < 4 then
				ply:AddHint("You must have Rank 4 Ore Management to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "storage_ice" then
			local lvl = ply.SAData.Research.IceRawStorageLevel
			local reqLvl = SA.Ice.GetLevelForStorageModel(sel2)
			if not reqLvl then return false end
			if lvl < reqLvl then
				ply:AddHint("You must have Rank " .. reqLvl .. " ICE Storages to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		elseif sel == "storage_ice_product" then
			local lvl = ply.SAData.Research.IceProductStorageLevel
			local reqLvl = SA.Ice.GetLevelForProductStorageModel(sel2)
			if not reqLvl then return false end
			if lvl < reqLvl then
				ply:AddHint("You must have Rank " .. reqLvl .. " ICE Product Storages to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
		local lvl = ply.SAData.Research.TiberiumStorageLevel
		if (sel == "tiberium_storage_ii" or sel == "tiberium_storage") and (SA.ValidEntity(tr.Entity) and tr.Entity:GetClass() == "tiberium_storage_holder") then return false end
		if sel == "tiberium_storage_ii" then
			if ply.SAData.FactionName ~= "legion" and ply.SAData.FactionName ~= "alliance" then
				ply:AddHint("You must be in The Legion or The Alliance to use this!", NOTIFY_CLEANUP, 5)
				return false
			elseif lvl < 1 then
				ply:AddHint("You must have Rank 1 Tiberium Storages to use this!", NOTIFY_CLEANUP, 5)
				return false
			end
		end
	elseif (mode == "rta_device") then
		if ply.SAData.Research.RTA < 1 then
			ply:AddHint("You must have Remote Terminal Access to use this!", NOTIFY_CLEANUP, 5)
			return false
		end
	elseif (mode == "terraforming") then
		if sel == "sa_terraformer" and ply.SAData.TotalCredits < 100000000 then
			ply:AddHint("You need to have at least 100000000 Score to use this!", NOTIFY_CLEANUP, 5)
			return false
		elseif ply.SAData.TotalCredits < 1000000 then
			ply:AddHint("You need to have at least 1000000 Score to use this!", NOTIFY_CLEANUP, 5)
			return false
		end
	end
end
hook.Add("CanTool","SA_MiningToolCanTool", CheckCanDevice)
