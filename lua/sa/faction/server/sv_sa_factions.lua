SA_REQUIRE("config")

local SA_FactionData = {}

local function SA_RefreshApplications(ply1, ply2)
	local plys
	if ply1 and ply2 then
		plys = {ply1, ply2}
	elseif ply1 then
		plys = ply1
	elseif ply2 then
		plys = ply2
	else
		return
	end

	net.Start("SA_Applications_Refresh")
	net.Send(plys)
end

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
		tbl.credits = tonumber(faction.credits) or -1
		tbl.score = tonumber(faction.score) or -1
		local fn = faction.faction_name
		SA_FactionData[fn] = tbl

		for _, ply in pairs(allply) do
			if not ply then continue end
			net.Start("SA_FactionData")
				net.WriteString(fn)
				net.WriteString(faction.score or "-1")
				if ply.sa_data.faction_name == fn then
					net.WriteString(faction.credits or "-1")
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
	if ply.sa_data and ply.sa_data.loaded then
		local idx = ply:Team()
		if not ply:IsVIP() then
			local modelIdx = 4
			if ply.sa_data.is_faction_leader then
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

	for k, v in pairs(player.GetAll()) do
		if v.sa_data.is_faction_leader and v:Team() == ffid then
			plyLeader = v
			break
		end
	end
	SA_RefreshApplications(ply, plyLeader)
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
		text = text,
		faction_name = faction,
	}, function(_body, status) DoApplyFactionResRes(ply, ffid, status) end)
end
net.Receive("SA_DoApplyFaction", SA_DoApplyFaction)

local function SA_DoAcceptPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local factionName = ply.sa_data.faction_name
	local trgPly = player.GetBySteamID(steamId)

	SA.API.AcceptFactionApplication(factionName, steamId, function(_body, code)
		SA_RefreshApplications(ply, trgPly)

		-- TODO: Reload player on error codes
		if code > 299 then
			return
		end

		if not trgPly then
			return
		end

		trgPly:AssignFaction(factionName)
	end)
end
concommand.Add("sa_application_accept", SA_DoAcceptPlayer)

local function SA_DoDenyPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local factionName = ply.sa_data.faction_name
	local trgPly = player.GetBySteamID(steamId)

	SA.API.DeleteFactionApplication(factionName, steamId, function(_body, _code)
		SA_RefreshApplications(ply, trgPly)
	end)
end
concommand.Add("sa_application_deny", SA_DoDenyPlayer)

local function SA_DoKickPlayer(ply, cmd, args)
	if args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local trgPly = player.GetBySteamID(steamId)

	if not trgPly or not trgPly:IsValid() or trgPly == ply or trgPly.sa_data.is_faction_leader or trgPly.sa_data.faction_name ~= ply.sa_data.faction_name then
		return
	end

	trgPly:AssignFaction("freelancer")
end
concommand.Add("sa_faction_kick", SA_DoKickPlayer)
