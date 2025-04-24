local SA_MaxNameLength = 24

SA.StatsTable = SA.StatsTable or {}

local function sa_info_msg_credsc()
	local ply = LocalPlayer()
	if not ply.sa_data then
		ply.sa_data = {}
	end

	local c = net.ReadString()
	local sc = ply:GetNWString("score")
	ply.sa_data.credits = tonumber(c)
	ply.sa_data.score = tonumber(sc)
	ply.sa_data.playtime = net.ReadUInt(32)
	ply.sa_data.prestige_level = net.ReadUInt(32)

	ply.sa_data.formatted_credits = SA.AddCommasToInt(c)
	ply.sa_data.formatted_score = SA.AddCommasToInt(sc)
	ply.sa_data.formatted_playtime = SA.FormatTime(ply.sa_data.playtime)
end
net.Receive("SA_SendBasicInfo", sa_info_msg_credsc)

timer.Create("SA_IncPlayTime", 1, 0, function()
	local ply = LocalPlayer()
	if not ply.sa_data then
		return
	end
	ply.sa_data.playtime = ply.sa_data.playtime + 1
	ply.sa_data.formatted_playtime = SA.FormatTime(ply.sa_data.playtime)

	local sc = ply:GetNWString("score")
	local scn = tonumber(sc)
	if scn ~= ply.sa_data.score then
		ply.sa_data.score = scn
		ply.sa_data.formatted_score = SA.AddCommasToInt(sc)
	end
end)

local function SA_ReceiveStatsUpdate(body, code)
	if code ~= 200 then
		return
	end

	SA.StatsTable = {}
	for i, v in pairs(body) do
		local newEntry = {}
		newEntry.name = string.Left(v.name, SA_MaxNameLength)
		newEntry.score = SA.AddCommasToInt(v.score)
		local fact = SA.Factions.GetByName(v.faction_name)
		newEntry.faction_color = fact.color
		newEntry.info = v

		table.insert(SA.StatsTable, newEntry)
	end

	hook.Run("SA_StatsUpdate", SA.StatsTable)
end
local function SA_RequestStatsUpdate()
	SA.API.ListPlayers(SA_ReceiveStatsUpdate)
end
timer.Create("SA_StatsUpdater", 30, 0, SA_RequestStatsUpdate)
timer.Simple(2, SA_RequestStatsUpdate)
