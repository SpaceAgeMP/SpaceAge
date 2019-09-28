AddCSLuaFile("autorun/client/cl_sa_application.lua")

require("supernet")
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
	if mapname == "sb_gooniverse" or mapname == "sb_gooniverse_v4" then
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
	elseif mapname == "sb_forlorn_sb3_r2l" or mapname == "sb_forlorn_sb3_r3" then
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
	if code ~= 200 then
		return
	end

	local allply = player.GetAll()
	for k, v in pairs(allply) do
		if not v.MayBePoked then allply[k] = nil end
	end

	for _, faction in pairs(body) do
		local tbl = {}
		tbl.Credits = tonumber(faction.Credits)
		tbl.Score = tonumber(faction.TotalCredits)
		tbl.AddScore = 0
		local fn = faction.FactionName
		SA_FactionData[fn] = tbl

		for _, ply in pairs(allply) do
			if not ply then continue end
			net.Start("SA_FactionData")
				net.WriteString(fn)
				net.WriteString(tbl.Score)
				if ply.SAData.FactionName == fn then
					net.WriteString(tbl.Credits)
				else
					net.WriteString("-1")
				end
			net.Send(ply)
		end
	end
end

timer.Create("SA_RefreshFactions", 30, 0, function()
	SA.API.Get("/factions", LoadFactionResults)
end)

local function SA_SetSpawnPos(ply)
	if ply.SAData and ply.SAData.Loaded then
		local idx = ply:Team()
		if not ply:IsVIP() then
			local modelIdx = 4
			if ply.SAData.IsFactionLeader then
				modelIdx = 5
			end
			timer.Simple(2, function() if (ply and ply:IsValid()) then ply:SetModel(SA.Factions.Table[idx][modelIdx]) end end)
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
	if not vic:IsPlayer() or not atk:IsPlayer() then
		return true
	end

	if ((vic:Team() == atk:Team()) and (GetConVarNumber("sa_friendlyfire") == 0)) then
		return false
	else
		return true
	end
end
hook.Add("PlayerShouldTakeDamage", "SA_FriendlyFire", SA_FriendlyFire)

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
	SA.Factions.RefreshApplications(toPlayers)
	ply:SendLua("SA.Application.Close()")
end

local function SA_DoApplyFaction(len, ply)
	local text = net.ReadString()
	local faction = net.ReadString()

	local ffid = 0
	for k, v in pairs(SA.Factions.Table) do
		if (v[2] == faction) then
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

local function SA_DoAcceptPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.SAData.IsFactionLeader then return end

	local steamId = args[1]
	local factionName = ply.SAData.FactionName
	local factionId = ply:Team()
	local trgPly = player.GetBySteamID(steamId)

	SA.API.Post("/factions/" .. factionName .. "/applications/" .. steamId .. "/accept", {}, function(body, code)
		SA.Factions.RefreshApplications({ply,trgPly})

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
		SA.SendBasicInfo(trgPly)
	end, function(err)
		SA.Factions.RefreshApplications({ply,trgPly})
	end)
end
concommand.Add("sa_application_accept", SA_DoAcceptPlayer)

local function SA_DoDenyPlayer(ply, cmd, args)
	if (#args ~= 1) then return end
	if (not ply.SAData.IsFactionLeader) then return end

	local steamId = args[1]
	local factionName = ply.SAData.FactionName
	local trgPly = player.GetBySteamID(steamId)

	SA.API.Delete("/factions/" .. factionName .. "/applications/" .. steamId, function(body, code)
		SA.Factions.RefreshApplications({ply,trgPly})
	end, function(err)
		SA.Factions.RefreshApplications({ply,trgPly})
	end)
end
concommand.Add("sa_application_deny", SA_DoDenyPlayer)

function SA.Factions.RefreshApplications(plys)
	if not plys then
		plys = player.GetHumans()
	end
	if plys.IsPlayer and plys:IsPlayer() then
		plys = {plys}
	end

	for _, xply in pairs(plys) do
		local ply = xply
		local retry = function() timer.Simple(5, function() SA.Factions.RefreshApplications(ply) end) end
		if ply.SAData.IsFactionLeader then
			SA.API.Get("/factions/" .. ply.SAData.FactionName .. "/applications", function(body, code)
				if code == 404 then
					supernet.Send(ply, "SA_Applications_Faction", {})
					return
				end
				if code ~= 200 then
					return retry()
				end
				supernet.Send(ply, "SA_Applications_Faction", body)
			end, retry)
		else
			SA.API.Get("/players/" .. ply:SteamID() .. "/application", function(body, code)
				if code == 404 then
					supernet.Send(ply, "SA_Applications_Player", {})
					return
				end
				if code ~= 200 then
					return retry()
				end
				supernet.Send(ply, "SA_Applications_Player", body)
			end, retry)
		end
	end
end
