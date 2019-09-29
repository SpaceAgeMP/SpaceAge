AddCSLuaFile("autorun/client/cl_sa_application.lua")

require("supernet")
local SA_FactionData = {}

local function SetFactionSpawn(tbl)
	local ent = {}
	for _, pos in ipairs(tbl) do
		local entx = ents.Create("info_player_start")
		entx:SetPos(Vector(unpack(pos)))
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

	local spawns = SA.Config.Load("faction_spawns")
	if not spawns then
		return
	end

	for name, fSpawns in pairs(spawns) do
		SA.Factions.Table[SA.Factions.IndexByShort[name]][6] = SetFactionSpawn(fSpawns)
	end
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
	SA.API.ListFactions(LoadFactionResults)
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

	if ((vic:Team() == atk:Team()) and not GetConVar("sa_friendlyfire"):GetBool()) then
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

	SA.API.UpsertPlayerApplication(ply, {
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

	SA.API.AcceptFactionApplication(factionName, steamId, function(body, code)
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

	SA.API.DeleteFactionApplication(factionName, steamId, function(body, code)
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
			SA.API.ListFactionApplications(ply.SAData.FactionName, function(body, code)
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
			SA.API.GetPlayerApplication(ply, function(body, code)
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
