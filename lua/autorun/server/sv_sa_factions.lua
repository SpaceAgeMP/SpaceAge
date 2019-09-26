AddCSLuaFile("autorun/client/cl_sa_application.lua")

local SA_FactionData = {}

local function SetFactionSpawn(...)
	local ent = {}
	for _, pos in ipairs({...}) do
		local entx = ents.Create("info_player_start")
		entx:SetPos(pos)
		entx:Spawn()
		entx.IsSpaceAge = true
		table.insert(ent, entx)
	end
	return ent
end
local function InitSAFactions()
	for _, v in pairs(ents.FindByClass("info_player_start")) do
		if v.IsSpaceAge then v:Remove() end
	end

	local mapname = string.lower(game.GetMap())
	if mapname == "sb_gooniverse" then
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(-10582.343750, -7122.343750, -8011.968750),
			Vector(-10599.000000, -7483.375000, -8011.968750),
			Vector(-10610.656250, -7735.750000, -8011.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9640.250000, 10959.062500, 4652.000000),
			Vector(10621.593750, 10793.406250, 4652.031250),
			Vector(10224.375000, 10891.750000, 4651.375000)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(3779.468750, -10047.125000, -1983.968750),
			Vector(3816.062500, -9695.156250, -1983.968750),
			Vector(3835.593750, -9507.312500, -1983.968750)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(113.125000, 794.843750, 4660.031250),
			Vector(113.000000, 714.718750, 4660.031250),
			Vector(112.906250, 647.562500, 4660.031250)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(-121.625000, -695.156250, 4660.031250),
			Vector(-125.218750, -763.937500, 4660.031250),
			Vector(-129.562500, -847.718750, 4660.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r2l" then
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(7769.562500, -11401.250000, -8954.968750),
			Vector(7504.875000, -11396.343750, -8954.968750),
			Vector(7245.843750, -11400.531250, -8954.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9749.156250, 9996.843750, 400.031250),
			Vector(9417.656250, 9998.156250, 400.031250),
			Vector(9090.000000, 9999.437500, 400.031250)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(10653.000000, 11797.906250, -8822.750000),
			Vector(10700.468750, 11856.687500, -8823.593750),
			Vector(10753.812500, 11922.750000, -8824.5937)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(9749.156250, 9996.843750, 611.593750),
			Vector(9417.656250, 9998.156250, 611.593750),
			Vector(9090.000000, 9999.437500, 611.593750)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(9596.812500, 10761.187500, 874.031250),
			Vector(9453.125000, 10768.406250, 874.031250),
			Vector(9260.718750, 10778.031250, 874.031250)
		)
	elseif mapname == "sb_forlorn_sb3_r3" then
		SA.Factions.Table[1][6] = SetFactionSpawn(
			Vector(7769.562500, -11401.250000, -8954.968750),
			Vector(7504.875000, -11396.343750, -8954.968750),
			Vector(7245.843750, -11400.531250, -8954.968750)
		)
		SA.Factions.Table[2][6] = SetFactionSpawn(
			Vector(9749.156250, 9996.843750, 400.031250),
			Vector(9417.656250, 9998.156250, 400.031250),
			Vector(9090.000000, 9999.437500, 400.031250)
		)
		SA.Factions.Table[3][6] = SetFactionSpawn(
			Vector(10653.000000, 11797.906250, -8822.750000),
			Vector(10700.468750, 11856.687500, -8823.593750),
			Vector(10753.812500, 11922.750000, -8824.5937)
		)
		SA.Factions.Table[4][6] = SetFactionSpawn(
			Vector(9749.156250, 9996.843750, 611.593750),
			Vector(9417.656250, 9998.156250, 611.593750),
			Vector(9090.000000, 9999.437500, 611.593750)
		)
		SA.Factions.Table[5][6] = SetFactionSpawn(
			Vector(9596.812500, 10761.187500, 874.031250),
			Vector(9453.125000, 10768.406250, 874.031250),
			Vector(9260.718750, 10778.031250, 874.031250)
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

	SA.Factions.Table[SA.Factions.Max + 1][6] = SA.Factions.Table[1][6]
end
timer.Simple(0, InitSAFactions)

local function LoadFactionResults(body, code)
	-- TODO
	if isok and data then
		local allply = player.GetAll()
		for k, v in pairs(allply) do
			if not v.MayBePoked then allply[k] = nil end
		end
		for _, v in pairs(data) do
			local tbl = {}
			tbl.Credits = tonumber(v.bank)
			tbl.Score = tonumber(v.score)
			tbl.AddScore = tonumber(v.buyscore)
			local fn = v.name
			SA_FactionData[fn] = tbl
			local xrs = tostring(tbl.Score)
			local xs = tostring(tbl.Score + tbl.AddScore)
			local xc = tostring(tbl.Credits)
			local xa = tostring(tbl.AddScore)
			for _, ply in pairs(allply) do
				net.Start("SA_FactionData")
					net.WriteString(fn)
					net.WriteString(xs)
					if ply.SAData.FactionName == fn then
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

timer.Create("SA_RefreshFactions", 30, 0, function()
	SA.API.Get("/factions", LoadFactionResults)
end)

local function SA_SetSpawnPos(ply)
	if ply.SAData and ply.SAData.Loaded then
		local idx = ply:Team()
		local islead = ply.SAData.IsFactionLeader
		if ply:IsVIP() then
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
		ply:SetTeam(SA.Factions.Max + 1)
		if SA.Factions.Table[1][6] then
			return table.Random(SA.Factions.Table[SA.Factions.Max + 1][6])
		end
	end
end
hook.Add("PlayerSelectSpawn", "SA_ChooseSpawn", SA_SetSpawnPos)

local function SA_FriendlyFire(vic, atk)
	if not vik:IsPlayer() or not atk:IsPlayer() then
		return true
	end

	if ((vic:Team() == atk:Team()) and (GetConVarNumber("sa_friendlyfire") == 0)) then
		return false
	else
		return true
	end
end
hook.Add("PlayerShouldTakeDamage", "SA_FriendlyFire", SA_FriendlyFire)


--Chat Commands

local function DoApplyFactionResRes(ply, ffid, code)
	if code > 299 then
		return
	end

	local toPlayers = {}
	for k, v in pairs(player.GetAll()) do
		if v.SAData.IsFactionLeader and v:Team() == ffid then
			table.insert(toPlayers, v)
		end
	end
	table.insert(toPlayers, ply)
	net.Start("SA_RefreshApplications")
		net.WriteBool(true)
		net.WriteString(ply:SteamID())
	net.Send(toPlayers)
	if not ply.SAData.IsFactionLeader then
		net.Start("SA_RefreshApplications")
			net.WriteBool(false)
			net.WriteString(ply:SteamID())
		net.Send(ply)
	end
	ply:SendLua("SA.Application.Close()")
end

local function SA_DoApplyFaction(len, ply)
	local text = net.ReadString()
	local faction = net.ReadString()

	local ffid = 0
	for k, v in pairs(SA.Factions.Table) do
		if (v[1] == faction) then
			ffid = k
			break
		end
	end
	if ffid < SA.Factions.ApplyMin then return end
	if ffid > SA.Factions.ApplyMax then return end

	SA.API.Put("/players/" .. ply:SteamID() .. "/application", {
		Text = text,
		FactionName = faction,
	}, function(body, status) DoApplyFactionResRes(ply, ffid, status) end, function() DoApplyFactionResRes(ply, ffid, 500) end)
end
net.Receive("SA_DoApplyFaction", SA_DoApplyFaction)
--FA.RegisterDataStream("SA_DoApplyFaction", 0)

local function SA_DoAcceptPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.SAData.IsFactionLeader then return end

	local steamId = args[1]
	local factionName = ply.SAData.FactionName
	local factionId = ply:Team()
	local trgPly = player.GetBySteamID(steamId)

	SA.API.Post("/faction/" .. factionName .. "/applications/" .. steamId .. "/accept", {}, function(body, code)
		net.Start("SA_RefreshApplications")
			net.WriteBool(true)
			net.WriteString(steamId)
		net.Send(ply)
		net.Start("SA_RefreshApplications")
			net.WriteBool(false)
			net.WriteString(sid)
		net.Send(trgPly)

		if code > 299 then
			return
		end

		if not trgPly then
			return
		end

		trgPly:SetTeam(factionId)
		trgPly.SAData.FactionName = factionName
		trgPly.SAData.IsFactionLeader = false
		trgPly:Spawn()
		SA.SendCreditsScore(trgPly)
	end, function(err)
		net.Start("SA_RefreshApplications")
			net.WriteBool(true)
			net.WriteString(steamId)
		net.Send(ply)
		net.Start("SA_RefreshApplications")
			net.WriteBool(false)
			net.WriteString(sid)
		net.Send(trgPly)
	end)
end
concommand.Add("sa_application_accept", SA_DoAcceptPlayer)

local function SA_DoDenyPlayer(ply, cmd, args)
	if (#args ~= 1) then return end
	if (not ply.SAData.IsFactionLeader) then return end

	local steamId = args[1]
	local factionName = ply.SAData.FactionName
	local trgPly = player.GetBySteamID(steamId)

	SA.API.Delete("/faction/" .. factionName .. "/applications/" .. steamId, nil, function(body, code)
		net.Start("SA_RefreshApplications")
			net.WriteBool(true)
			net.WriteString(steamId)
		net.Send(ply)
		net.Start("SA_RefreshApplications")
			net.WriteBool(false)
			net.WriteString(sid)
		net.Send(trgPly)
	end, function(err)
		net.Start("SA_RefreshApplications")
			net.WriteBool(true)
			net.WriteString(steamId)
		net.Send(ply)
		net.Start("SA_RefreshApplications")
			net.WriteBool(false)
			net.WriteString(sid)
		net.Send(trgPly)
	end)
end
concommand.Add("sa_application_deny", SA_DoDenyPlayer)
