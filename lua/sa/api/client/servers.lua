SA.REQUIRE("api.main")

local serverList = {}
local serverIndexedList = {}

function SA.API.GetServerList()
	return serverIndexedList
end

function SA.API.GetServerByIndex(idx)
	return serverIndexedList[idx]
end

function SA.API.GetServerByName(name)
	return serverList[name]
end

local function MkPlayerMap()
	local res = {}
	for _, ply in pairs(player.GetHumans()) do
		table.insert(res, {
			faction_name = SA.Factions.GetByPlayer(ply).name,
			is_faction_leader = ply:GetNWBool("isleader"),
			name = ply:Nick(),
			playtime = 0,
			score = tonumber(ply:GetNWString("score")),
			steamid = ply:SteamID(),
		})
	end
	return res
end

local function SA_API_RefreshServerList()
	local name = SA.API.GetServerName()
	if (not name) or name == "" then
		timer.Simple(0.1, function()
			SA_API_RefreshServerList()
		end)
		return
	end

	SA.API.ListServers(function(data, code)
		if code ~= 200 or not data then
			return
		end

		serverList = {}

		for k, srv in pairs(data) do
			srv.idx = k
			serverList[srv.name] = srv
		end

		serverIndexedList = data

		local selfServer = SA.API.GetServerByName(name)
		if name then
			if not selfServer then
				selfServer = {
					idx = #serverIndexedList + 1,
					name = name,
					location = "N/A",
				}
				selfServer.players = MkPlayerMap()
				serverList[name] = selfServer
				table.insert(serverIndexedList, selfServer)
			end

			selfServer.isself = true
			selfServer.map = game.GetMap()
			selfServer.ipport = game.GetIPAddress()
			selfServer.online = true
		end
	end)
end

local function SA_PeriodicServerListRefresh()
	SA_API_RefreshServerList(function()
		timer.Simple(60, SA_PeriodicServerListRefresh)
	end)
end
SA_PeriodicServerListRefresh()
