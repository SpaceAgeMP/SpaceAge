AddCSLuaFile("autorun/client/cl_sa_application.lua")

local SA_FactionData = {}

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
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(-10582.343750,-7122.343750,-8011.968750),
			Vector(-10599.000000,-7483.375000,-8011.968750),
			Vector(-10610.656250,-7735.750000,-8011.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9640.250000,10959.062500,4652.000000),
			Vector(10621.593750,10793.406250,4652.031250),
			Vector(10224.375000,10891.750000,4651.375000)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(3779.468750,-10047.125000,-1983.968750),
			Vector(3816.062500,-9695.156250,-1983.968750),
			Vector(3835.593750,-9507.312500,-1983.968750)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(113.125000,794.843750,4660.031250),
			Vector(113.000000,714.718750,4660.031250),
			Vector(112.906250,647.562500,4660.031250)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(-121.625000,-695.156250,4660.031250),
			Vector(-125.218750,-763.937500,4660.031250),
			Vector(-129.562500,-847.718750,4660.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r2l" then
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(7769.562500,-11401.250000,-8954.968750),
			Vector(7504.875000,-11396.343750,-8954.968750),
			Vector(7245.843750,-11400.531250,-8954.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,400.031250),
			Vector(9417.656250,9998.156250,400.031250),
			Vector(9090.000000,9999.437500,400.031250)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(10653.000000,11797.906250,-8822.750000),
			Vector(10700.468750,11856.687500,-8823.593750),
			Vector(10753.812500,11922.750000,-8824.5937)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,611.593750),
			Vector(9417.656250,9998.156250,611.593750),
			Vector(9090.000000,9999.437500,611.593750)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(9596.812500,10761.187500,874.031250),
			Vector(9453.125000,10768.406250,874.031250),
			Vector(9260.718750,10778.031250,874.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r3" then
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(7769.562500,-11401.250000,-8954.968750),
			Vector(7504.875000,-11396.343750,-8954.968750),
			Vector(7245.843750,-11400.531250,-8954.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,400.031250),
			Vector(9417.656250,9998.156250,400.031250),
			Vector(9090.000000,9999.437500,400.031250)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(10653.000000,11797.906250,-8822.750000),
			Vector(10700.468750,11856.687500,-8823.593750),
			Vector(10753.812500,11922.750000,-8824.5937)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(9749.156250,9996.843750,611.593750),
			Vector(9417.656250,9998.156250,611.593750),
			Vector(9090.000000,9999.437500,611.593750)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(9596.812500,10761.187500,874.031250),
			Vector(9453.125000,10768.406250,874.031250),
			Vector(9260.718750,10778.031250,874.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r3" then
		for _, v in pairs(SA.Factions.Table) do
			v[6] = SetFactionSpawn(
				Vector(10864, 1078, 305),
				Vector(10864, 1178, 305),
				Vector(10864, 978, 305),
				Vector(10964, 1078, 305),
				Vector(10764, 1078, 305)
			)
		end
	end
	SA.Factions.Table[6][6] = SA.Factions.Table[5][6] --ALLIANCE
	--SA.Factions.Table[8][6] = SA.Factions.Table[5][6] --FAILED TO LOAD -- Already does this below...

	SA.Factions.Table[SA.Factions.Max + 1][6] = SA.Factions.Table[1][6]
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
			local xs = tostring(tbl.Score + tbl.AddScore)
			local xc = tostring(tbl.Credits)
			local xa = tostring(tbl.AddScore)
			for _,ply in pairs(allply) do
				net.Start("SA_FactionData")
					net.WriteString(fn)
					net.WriteString(xs)
					if ply.UserGroup == fn then
						net.WriteString(xc)
						net.WriteString(xa)
						net.WriteString(xrs)
					else
						net.WriteString("-1")
						net.WriteString("-1")
						net.WriteString("-1")
					end
				net.Send(ply)
			end
		end
	end
end

timer.Create("SA_RefreshFactions",30,0,function(fact)
	if not fact then
		SA.MySQL:Query("SELECT * FROM factions",LoadFactionResults)
	else
		SA.MySQL:Query("SELECT * FROM factions WHERE name = '" .. SA.MySQL:Escape(fact) .. "'",LoadFactionResults)
	end
end)

local function SA_SetSpawnPos( ply )
	if ply.Loaded then
		local idx = ply.TeamIndex
		local islead = ply.IsLeader
		if (ply:IsVIP()) then
			--DO NOTHING!
		elseif islead then
			timer.Simple(2, function() if (ply and ply:IsValid()) then ply:SetModel(SA.Factions.Table[idx][5]) end end)
		else
			timer.Simple(2, function() if (ply and ply:IsValid()) then ply:SetModel(SA.Factions.Table[idx][4]) end end)
		end
		ply:SetTeam(idx)
		if SA.Factions.Table[idx][6] then
			return table.Random(SA.Factions.Table[idx][6])
		end
	else
		ply:SetTeam(SA.Factions.Max+1)
		if SA.Factions.Table[1][6] then
			return table.Random(SA.Factions.Table[SA.Factions.Max+1][6])
		end
	end
end
hook.Add("PlayerSelectSpawn","SA_ChooseSpawn",SA_SetSpawnPos)

local function SA_FriendlyFire(vic,atk)
	if ((vic.TeamIndex == atk.TeamIndex) and (GetConVarNumber("sa_friendlyfire") == 0)) then
		return false
	else
		return true
	end
end
hook.Add("PlayerShouldTakeDamage","SA_FriendlyFire",SA_FriendlyFire)


--Chat Commands

local function DoApplyFactionResRes(data, isok, merror, ply, ffid, pltimexx)
	net.Start("SA_DoDeleteApplication")
		net.WriteString(ply:SteamID())
	net.Send()
	local toPlayers = {}
	for k, v in pairs(player.GetAll()) do
 		if v.IsLeader then
			if v.TeamIndex == ffid then
				table.insert(toPlayers,v)
			end
		end
	end
	net.Start("SA_AddApplication")
		net.WriteString(ply:SteamID())
		net.WriteString(ply:GetName())
		net.WriteString(sat)
		net.WriteString(pltimexx)
		net.WriteInt(ply.TotalCredits)
	net.Send(toPlayers)
	ply:SendLua("SA.Application.Close()")
end

local function DoApplyFactionRes(data, isok, merror, ply, steamid, plname, ffid, satx, cscore, pltimex, pltimexx)
	if isok and data and data[1] then
		SA.MySQL:Query("UPDATE applications SET name = '" .. plname .. "', faction = '" .. ffid .. "', text = '" .. satx .. "', score = '" .. cscore .. "', playtime = '" .. pltimex .. "' WHERE steamid = '" .. steamid .. "'", DoApplyFactionResRes, ply, ffid, pltimexx)
	else
		SA.MySQL:Query("INSERT INTO applications (steamid, name, faction, text, score, playtime) VALUES ('" .. steamid .. "','" .. plname .. "','" .. ffid .. "','" .. satx .. "','" .. cscore .. "','" .. pltimex .. "')", DoApplyFactionResRes, ply, ffid, pltimexx)
	end
end

local function SA_DoApplyFaction(len, ply)
	local sat = net.ReadString()
	local forfaction = net.ReadString()
	satx = SA.MySQL:Escape(sat)
	local ffid = 0
	for k, v in pairs(SA.Factions.Table) do
		if (v[1] == forfaction) then
			ffid = k
			break
		end
	end
	if (ffid <= 1) then return end
	if (ffid >= 6) then return end
	local steamid = SA.MySQL:Escape(ply:SteamID())
	local plname = SA.MySQL:Escape(ply:GetName())

	local pltime = ply.Playtime
	local hrs = math.floor(pltime / 3600)
	local mins = math.floor((pltime % 3600) / 60)
	local secs = math.floor(pltime % 60)
	if mins < 10 then
		mins = "0" .. mins
	end
	if secs < 10 then
		secs = "0" .. secs
	end
	local pltimexx = hrs .. ":" .. mins .. ":" .. secs
	local pltimex = SA.MySQL:Escape(pltimexx)

	local cscore = SA.MySQL:Escape(ply.TotalCredits)
	SA.MySQL:Query("SELECT steamid FROM applications WHERE steamid = '" .. steamid .. "'", DoApplyFactionRes, ply, steamid, plname, ffid, satx, cscore, pltimex)
end
net.Receive("SA_DoApplyFaction",SA_DoApplyFaction)
--FA.RegisterDataStream("SA_DoApplyFaction",0)

local function DoAcceptPlayerResRes(data, isok, merror, ply)
	ply:SendLua("SA.Application.Close()")
end

local function DoAcceptPlayerRes(data, isok, merror, ply, app, appf, args)
	if (!isok) then return end
	for k, v in pairs(player.GetAll()) do
 		if v.IsLeader then
			net.Start("SA_DoDeleteApplication")
				net.WriteString(app['steamid'])
			net.Send(v)
		elseif (v:SteamID() == app['steamid']) then
			v.TeamIndex = appf
			v.UserGroup = SA.Factions.Table[appf][2]
			v.IsLeader = false
			v:Spawn()
			SA.SendCreditsScore(v)
			SA_Send_FactionRes(v)
		end
	end
	SA.MySQL:Query('UPDATE players SET groupname = "' .. SA.MySQL:Escape(SA.Factions.Table[appf][2]) .. '", isleader = 0 WHERE steamid = "' .. SA.MySQL:Escape(args[1]) .. '"', DoAcceptPlayerResRes, ply)
end

local function DoAcceptPlayer(data, isok, merror, ply, args)
	if (!isok) then return end
	if (!data[1]) then return end
	local app = data[1]
	local appf = tonumber(app['faction'])
	if (appf ~= ply.TeamIndex) then return end
	SA.MySQL:Query("DELETE FROM applications WHERE steamid = '" .. SA.MySQL:Escape(args[1]) .. "'", DoAcceptPlayerRes, ply, app, appf, args)
end

local function SA_DoAcceptPlayer(ply,cmd,args)
	if (#args ~= 1) then return end
	if(!ply.IsLeader) then return end
	SA.MySQL:Query("SELECT steamid, faction FROM applications WHERE steamid = '" .. SA.MySQL:Escape(args[1]) .. "'", DoAcceptPlayer, ply, args)
end
concommand.Add("sa_application_accept",SA_DoAcceptPlayer)

local function DoDenyPlayerResRes(data, isok, merror, ply, app)
	if (!isok) then return end
	for k, v in pairs(player.GetAll()) do
 		if v.IsLeader then
			net.Start("SA_DoDeleteApplication")
				net.WriteString(app['steamid'])
			net.Send(v)
		end
	end
	ply:SendLua("SA.Application.Close()")
end

local function DoDenyPlayerRes(data, isok, merror, ply, args)
	if (!isok) then return end
	if (!data[1]) then return end
	app = data[1]
	if (tonumber(app['faction']) ~= ply.TeamIndex) then return end
	SA.MySQL:Query("DELETE FROM applications WHERE steamid = '" .. SA.MySQL:Escape(args[1]) .. "'", DoDenyPlayerResRes, ply, app)
end

local function SA_DoDenyPlayer(ply,cmd,args)
	if (#args ~= 1) then return end
	if(!ply.IsLeader) then return end
	SA.MySQL:Query("SELECT steamid, faction FROM applications WHERE steamid = '" .. SA.MySQL:Escape(args[1]) .. "'", DoDenyPlayerRes, ply, args)
end
concommand.Add("sa_application_deny",SA_DoDenyPlayer)
