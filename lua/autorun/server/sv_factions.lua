local data, isok, merror

AddCSLuaFile("autorun/client/cl_sa_application.lua")

SA_FactionData = {}

local function SetFactionSpawn(...)
	local ent = {}
	for _,pos in ipairs({...}) do
		local entx = ents.Create("info_player_start")
		entx:SetPos(pos)
		entx:Spawn()
		entx.IsSpaceAge = true
		table.insert(ent,entx)
	end
	return ent
end
local function InitSAFactions()
	for _,v in pairs(ents.FindByClass("info_player_start")) do
		if v.IsSpaceAge then v:Remove() end
	end

	local mapname = string.lower(game.GetMap())
	if mapname == "sb_gooniverse" then
		SA_Factions[1][6] = SetFactionSpawn(			
			Vector(-10582.343750,-7122.343750,-8011.968750),
			Vector(-10599.000000,-7483.375000,-8011.968750),
			Vector(-10610.656250,-7735.750000,-8011.968750)
		)
		SA_Factions[2][6] = SetFactionSpawn(
			Vector(9640.250000,10959.062500,4652.000000),
			Vector(10621.593750,10793.406250,4652.031250),
			Vector(10224.375000,10891.750000,4651.375000)
		)
		SA_Factions[3][6] = SetFactionSpawn(
			Vector(3779.468750,-10047.125000,-1983.968750),
			Vector(3816.062500,-9695.156250,-1983.968750),
			Vector(3835.593750,-9507.312500,-1983.968750)
		)
		SA_Factions[4][6] = SetFactionSpawn(
			Vector(113.125000,794.843750,4660.031250),
			Vector(113.000000,714.718750,4660.031250),
			Vector(112.906250,647.562500,4660.031250)
		)
		SA_Factions[5][6] = SetFactionSpawn(
			Vector(-121.625000,-695.156250,4660.031250),
			Vector(-125.218750,-763.937500,4660.031250),
			Vector(-129.562500,-847.718750,4660.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r2l" then
		SA_Factions[1][6] = SetFactionSpawn(			
			Vector(7769.562500,-11401.250000,-8954.968750),
			Vector(7504.875000,-11396.343750,-8954.968750),
			Vector(7245.843750,-11400.531250,-8954.968750)
		)
		SA_Factions[2][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,400.031250),
			Vector(9417.656250,9998.156250,400.031250),
			Vector(9090.000000,9999.437500,400.031250)
		)
		SA_Factions[3][6] = SetFactionSpawn(
			Vector(10653.000000,11797.906250,-8822.750000),
			Vector(10700.468750,11856.687500,-8823.593750),
			Vector(10753.812500,11922.750000,-8824.5937)
		)
		SA_Factions[4][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,611.593750),
			Vector(9417.656250,9998.156250,611.593750),
			Vector(9090.000000,9999.437500,611.593750)
		)
		SA_Factions[5][6] = SetFactionSpawn(
			Vector(9596.812500,10761.187500,874.031250),
			Vector(9453.125000,10768.406250,874.031250),
			Vector(9260.718750,10778.031250,874.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r3" then
		SA_Factions[1][6] = SetFactionSpawn(			
			Vector(7769.562500,-11401.250000,-8954.968750),
			Vector(7504.875000,-11396.343750,-8954.968750),
			Vector(7245.843750,-11400.531250,-8954.968750)
		)
		SA_Factions[2][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,400.031250),
			Vector(9417.656250,9998.156250,400.031250),
			Vector(9090.000000,9999.437500,400.031250)
		)
		SA_Factions[3][6] = SetFactionSpawn(
			Vector(10653.000000,11797.906250,-8822.750000),
			Vector(10700.468750,11856.687500,-8823.593750),
			Vector(10753.812500,11922.750000,-8824.5937)
		)
		SA_Factions[4][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,611.593750),
			Vector(9417.656250,9998.156250,611.593750),
			Vector(9090.000000,9999.437500,611.593750)
		)
		SA_Factions[5][6] = SetFactionSpawn(
			Vector(9596.812500,10761.187500,874.031250),
			Vector(9453.125000,10768.406250,874.031250),
			Vector(9260.718750,10778.031250,874.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r3" then
		for _, v in pairs(SA_Factions) do
			v[6] = SetFactionSpawn(
				Vector(10864, 1078, 305),
				Vector(10864, 1178, 305),
				Vector(10864, 978, 305),
				Vector(10964, 1078, 305),
				Vector(10764, 1078, 305)
			)
		end
	end
	SA_Factions[6][6] = SA_Factions[5][6] //ALLIANCE
	//SA_Factions[8][6] = SA_Factions[5][6] //FAILED TO LOAD -- Already does this below...
	SA_Factions[7][6] = SA_Factions[5][6] //PMS FACTION
	
	SA_Factions[SA_MaxFaction+1][6] = SA_Factions[1][6]
end
timer.Simple(0,InitSAFactions)

local function LoadFactionResults(data, isok, merror)
	if isok and data then
		local allply = player.GetAll()
		for k,v in pairs(allply) do
			if not v.MayBePoked then allply[k] = nil end
		end
		for _,v in pairs(data) do
			local tbl = {}
			tbl.Credits = tonumber(v["bank"])
			tbl.Score = tonumber(v["score"])
			tbl.AddScore = tonumber(v["buyscore"])
			local fn = v["name"]
			SA_FactionData[fn] = tbl
			local xrs = tostring(tbl.Score)
			local xs = tostring(tbl.Score+tbl.AddScore)
			local xc = tostring(tbl.Credits)
			local xa = tostring(tbl.AddScore)
			for _,ply in pairs(allply) do
				umsg.Start("SA_FactionData",ply)
				umsg.String(fn)
				umsg.String(xs)
				if ply.UserGroup == fn then
					umsg.String(xc)
					umsg.String(xa)
					umsg.String(xrs)
				else
					umsg.String("-1")
					umsg.String("-1")
					umsg.String("-1")
				end
				umsg.End()
			end
		end
	end
end

timer.Create("SA_RefreshFactions",30,0,function(fact)
	if not fact then
		MySQL:Query("SELECT * FROM factions",LoadFactionResults)
	else
		MySQL:Query("SELECT * FROM factions WHERE name = '"..MySQL:Escape(fact).."'",LoadFactionResults)
	end
end)

local function SA_SetSpawnPos( ply )
	if ply.Loaded then
		local idx = ply.TeamIndex
		local islead = ply.IsLeader
		if (ply:IsVIP()) then
			--DO NOTHING!
		elseif islead then
			timer.Simple(2, function() if (ply and ply:IsValid()) then ply:SetModel(SA_Factions[idx][5]) end end)
		else
			timer.Simple(2, function() if (ply and ply:IsValid()) then ply:SetModel(SA_Factions[idx][4]) end end)
		end
		ply:SetTeam(idx)
		if SA_Factions[idx][6] then
			return table.Random(SA_Factions[idx][6])
		end
	else
		ply:SetTeam(SA_MaxFaction+1)
		if SA_Factions[1][6] then
			return table.Random(SA_Factions[SA_MaxFaction+1][6])
		end
	end
end
hook.Add("PlayerSelectSpawn","SA_ChooseSpawn",SA_SetSpawnPos)

local function SA_FriendlyFire(vic,atk)
	if ((vic.TeamIndex == atk.TeamIndex) and (GetConVarNumber("friendlyfire") == 0)) then
		return false
	else
		return true
	end
end
hook.Add("PlayerShouldTakeDamage","SA_FriendlyFire",SA_FriendlyFire)


--Chat Commands

local function DoApplyFactionResRes(data, isok, merror, ply, ffid, pltimexx)
	umsg.Start("sa_dodelapp")
		umsg.String(ply:SteamID())
	umsg.End()
	local toPlayers = {}
	for k, v in pairs(player.GetAll()) do 
 		if v.IsLeader then
			if v.TeamIndex == ffid then
				table.insert(toPlayers,v)
			end
		end
	end
	net.Start("sa_addapp")
		net.WriteString(ply:SteamID())
		net.WriteString(ply:GetName())
		net.WriteString(sat)
		net.WriteString(pltimexx)
		net.WriteInt(ply.TotalCredits)
	net.Send(toPlayers)
	ply:SendLua("CloseApply()")
end

local function DoApplyFactionRes(data, isok, merror, ply, steamid, plname, ffid, satx, cscore, pltimex, pltimexx)
	if isok and data and data[1] then
		MySQL:Query("UPDATE applications SET name = '"..plname.."', faction = '"..ffid.."', text = '"..satx.."', score = '"..cscore.."', playtime = '"..pltimex.."' WHERE steamid = '"..steamid.."'", DoApplyFactionResRes, ply, ffid, pltimexx)
	else
		MySQL:Query("INSERT INTO applications (steamid, name, faction, text, score, playtime) VALUES ('"..steamid.."','"..plname.."','"..ffid.."','"..satx.."','"..cscore.."','"..pltimex.."')", DoApplyFactionResRes, ply, ffid, pltimexx)
	end
end

local function SA_DoApplyFaction(len, ply) 
	local sat = net.ReadString()
	local forfaction = net.ReadString()
	satx = MySQL:Escape(sat)
	local ffid = 0
	for k, v in pairs(SA_Factions) do
		if (v[1] == forfaction) then
			ffid = k
			break
		end
	end
	if (ffid <= 1) then return end
	if (ffid >= 6) then return end
	local steamid = MySQL:Escape(ply:SteamID())
	local plname = MySQL:Escape(ply:GetName())

	local pltime = ply.Playtime
	local hrs = math.floor(pltime / 3600)
	local mins = math.floor((pltime % 3600) / 60)
	local secs = math.floor(pltime % 60)
	if mins < 10 then
		mins = "0"..mins
	end
	if secs < 10 then
		secs = "0"..secs
	end
	local pltimexx = hrs..":"..mins..":"..secs
	local pltimex = MySQL:Escape(pltimexx)

	local cscore = MySQL:Escape(ply.TotalCredits)
	MySQL:Query("SELECT steamid FROM applications WHERE steamid = '"..steamid.."'", DoApplyFactionRes, ply, steamid, plname, ffid, satx, cscore, pltimex)
end
net.Receive("sa_doapplyfaction",SA_DoApplyFaction)
--FA.RegisterDataStream("sa_doapplyfaction",0)

local function DoAcceptPlayerResRes(data, isok, merror, ply)
	ply:SendLua("CloseApply()")
end

local function DoAcceptPlayerRes(data, isok, merror, ply, app, appf, args)
	if (!isok) then return end
	for k, v in pairs(player.GetAll()) do 
 		if v.IsLeader then
			umsg.Start("sa_dodelapp",v)
				umsg.String(app['steamid'])
			umsg.End()
		elseif (v:SteamID() == app['steamid']) then
			v.TeamIndex = appf
			v.UserGroup = SA_Factions[appf][2]
			v.IsLeader = false
			v:Spawn()
			SA_Send_Main(v)
			SA_Send_FactionRes(v)
		end
	end
	MySQL:Query('UPDATE players SET groupname = "'..MySQL:Escape(SA_Factions[appf][2])..'", isleader = 0 WHERE steamid = "'..MySQL:Escape(args[1])..'"', DoAcceptPlayerResRes, ply)
end

local function DoAcceptPlayer(data, isok, merror, ply, args)
	if (!isok) then return end
	if (!data[1]) then return end
	local app = data[1]
	local appf = tonumber(app['faction'])
	if (appf != ply.TeamIndex) then return end
	MySQL:Query("DELETE FROM applications WHERE steamid = '"..MySQL:Escape(args[1]).."'", DoAcceptPlayerRes, ply, app, appf, args)
end

local function SA_DoAcceptPlayer(ply,cmd,args)
	if (#args != 1) then return end
	if(!ply.IsLeader) then return end
	MySQL:Query("SELECT steamid, faction FROM applications WHERE steamid = '"..MySQL:Escape(args[1]).."'", DoAcceptPlayer, ply, args)
end
concommand.Add("DoAcceptPlayer",SA_DoAcceptPlayer)

local function DoDenyPlayerResRes(data, isok, merror, ply, app)
	if (!isok) then return end
	for k, v in pairs(player.GetAll()) do 
 		if v.IsLeader then
			umsg.Start("sa_dodelapp",v)
				umsg.String(app['steamid'])
			umsg.End()
		end
	end
	ply:SendLua("CloseApply()")
end

local function DoDenyPlayerRes(data, isok, merror, ply, args)
	if (!isok) then return end
	if (!data[1]) then return end
	app = data[1]
	if (tonumber(app['faction']) != ply.TeamIndex) then return end
	MySQL:Query("DELETE FROM applications WHERE steamid = '"..MySQL:Escape(args[1]).."'", DoDenyPlayerResRes, ply, app)
end

local function SA_DoDenyPlayer(ply,cmd,args)
	if (#args != 1) then return end
	if(!ply.IsLeader) then return end
	MySQL:Query("SELECT steamid, faction FROM applications WHERE steamid = '"..MySQL:Escape(args[1]).."'", DoDenyPlayerRes, ply, args)
end
concommand.Add("DoDenyPlayer",SA_DoDenyPlayer)

function SA_GiveCreditsByName(ply,name,amt)
	v = SA_GetPlayerByName(name,nil)
	if v then
		return SA_GiveCredits(ply,v,amt)
	end
	return false
end

function SA_GiveCredits(ply,v,amt)
	if not (ply and v and ply:IsValid() and v:IsValid() and ply:IsPlayer() and v:IsPlayer()) then ply:AddHint("Invalid command parameters.", NOTIFY_CLEANUP, 5) return false end

	local amt = tonumber(amt)
	if not amt then ply:AddHint("Invalid command parameters.", NOTIFY_CLEANUP, 5) return false end
	local cred = tonumber(ply.Credits)
	if (amt <= 0) or (math.ceil(amt) != math.floor(amt)) then ply:AddHint("That is not a valid number.", NOTIFY_CLEANUP, 5) return false end
	if (amt > cred) then ply:AddHint("You do not have enough credits.", NOTIFY_CLEANUP, 5) return false end
	
	v.Credits = v.Credits + amt
	ply.Credits = ply.Credits - amt
	local num = AddCommasToInt(amt)
	ply:AddHint("You have given "..v:Name().." "..num.." credits.", NOTIFY_GENERIC, 5)
	v:AddHint(ply:Name().." has given you "..num.." credits.", NOTIFY_GENERIC, 5)
	SA_Send_CredSc(ply)
	SA_Send_CredSc(v)
	
	return true
end

SA_giveRequests = {}
function SA_ConfirmGiveCredits(ply,v,amt,func)
	local theID = ply:SteamID()
	if SA_giveRequests[theID] then return false end --No multiple requests to same user...
	SA_giveRequests[theID] = {ply,v,amt,func}
	umsg.Start("SA_OpenGiveQuery",ply)
		umsg.String(v:Name())
		umsg.Long(amt)
		umsg.String(theID)
	umsg.End()
	return true
end

local function SA_GiveRequestHandler(ply,cmd,args)
	if #args != 2 then return end
	local allowed = (args[1] == "allow")
	local theID = args[2]
	local theRequest = SA_giveRequests[theID]
	if not (theRequest and theRequest[1] == ply) then return end
	local func = theRequest[4]
	if func then func(theRequest,allowed) end
	local tmpRet = {}
	if allowed then tmpRet = SA_GiveCredits(theRequest[1],theRequest[2],theRequest[3]) end
	SA_giveRequests[theID] = nil
	return tmpRet
end
concommand.Add("sa_giverequest",SA_GiveRequestHandler)

local function SA_CmdGiveCredits(ply,cmd,args)
	SA_GiveCreditsByName(ply,args[1],args[2])
end
concommand.Add("sa_givecredits",SA_CmdGiveCredits)
