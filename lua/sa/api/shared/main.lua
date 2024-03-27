SA.REQUIRE("config")
if CLIENT then
	SA.REQUIRE("misc.player_loaded")
end

SA.API = SA.API or {}

local JWT_IN_RENEWAL = true

local MakeUserAgent

local function GetIPPortAndOk()
	local ip = game.GetIPAddress()
	if ip:find("0.0.0.0", 1, true) then
		return false, ip
	end
	return true, ip
end

local function CommonUserAgent(side, id)
	local ipOk, ip = GetIPPortAndOk()
	return "SpaceAge/GMod-" .. side .. " " .. ip .. " " .. id, ipOk
end

local apiConfig = SA.Config.Load("api", true) or {}
apiConfig.url = apiConfig.url or "https://api.spaceage.mp/v2"

if SERVER then
	MakeUserAgent = function()
		return CommonUserAgent("Server", "")
	end
else
	MakeUserAgent = function()
		local sid = LocalPlayer():SteamID()
		local sidOk = true
		if not sid or sid == "STEAM_0:0:0" or sid == "" then
			sid = "N/A"
			sidOk = false
		end
		local res, ok = CommonUserAgent("Client", sid)
		return res, ok and sidOk
	end
end

local clientID = CommonUserAgent("N/A", "N/A")

local function TryMakeUserAgent()
	local pcallOk, res, isOk = pcall(MakeUserAgent)
	if pcallOk then
		clientID = res
	end
	return pcallOk and isOk
end

local function TryMakeUserAgentTimer()
	local ok = TryMakeUserAgent()
	if ok then
		print("API Client-ID stabilized!")
		timer.Remove("SA_API_Make_ClientID")
	end
end
timer.Create("SA_API_Make_ClientID", 1, 0, TryMakeUserAgentTimer)
TryMakeUserAgentTimer()

local requestQueue = {}
local requestInProgress = nil

local failureCount = 0
local backoffTimings = {1, 5, 10, 15, 30}
local httpTimeout = 30
local backoffMax = backoffTimings[#backoffTimings]

local processNextRequest
local setRequestParams

local function requeueRequest(request)
	if requestInProgress == request then
		requestInProgress = nil
	end

	if request.done then
		return
	end
	request.done = true

	timer.Remove("SA_API_HTTPTimeout")

	if request.options.oneshot then
		if request.callback then
			request.callback(nil, 599)
		end
		processNextRequest()
		return
	end

	failureCount = failureCount + 1

	local timing = backoffTimings[failureCount] or backoffMax

	local newRequest = {
		http = request.http,
		options = request.options,
		callback = request.callback,
		done = false
	}

	setRequestParams(newRequest)
	print("Requeueing ", newRequest.http.url, newRequest.http.method, " for ", timing, " seconds after ", failureCount, " failures")

	timer.Simple(timing, function()
		table.insert(requestQueue, newRequest)
		processNextRequest()
	end)
end

processNextRequest = function()
	if requestInProgress and not requestInProgress.done then
		return
	end
	local request = table.remove(requestQueue, 1)
	if not request then
		return
	end

	requestInProgress = request
	HTTP(request.http)

	timer.Create("SA_API_HTTPTimeout", httpTimeout, 1, function()
		print("Request ", request.http.url, request.http.method, " failed with timeout")
		requeueRequest(request)
	end)
end

local function successRequest(request)
	if requestInProgress == request then
		requestInProgress = nil
	end
	if request.done then
		return
	end
	request.done = true

	failureCount = 0

	timer.Remove("SA_API_HTTPTimeout")

	timer.Simple(0, processNextRequest)
end

function SA.API.GetHTTPHeaders(noauth)
	local headers = {}
	if not noauth then
		if apiConfig.serverToken then
			headers.Authorization = "Server " .. apiConfig.serverToken
		else
			headers.Authorization = apiConfig.auth
		end
	end
	headers["Client-ID"] = clientID or "N/A"
	return headers
end

setRequestParams = function(request)
	local callback = request.callback
	request.http.headers = SA.API.GetHTTPHeaders(request.options.noauth)

	request.http.failure = function(err)
		print("Request ", request.http.url, request.http.method, " failed with error ", err)
		requeueRequest(request)
	end

	request.http.success = function(code, body, _headers)
		if code > 499 or (code == 401 and JWT_IN_RENEWAL) then
			print("Request ", request.http.url, request.http.method, " failed with code ", code)
			return requeueRequest(request)
		end

		successRequest(request)

		if not callback then
			return
		end

		if body then
			body = util.JSONToTable(body)
		end

		callback(body, code)
	end
end

function SA.API.Request(url, method, reqBody, options, callback)
	if not options then
		options = {}
	end

	local httprequest = {
		method = method or "GET",
		url = apiConfig.url .. url,
		type = "application/json",
		body = reqBody and util.TableToJSON(reqBody) or nil
	}

	local request = {
		http = httprequest,
		options = options,
		callback = callback,
		done = false
	}
	setRequestParams(request)

	table.insert(requestQueue, request)

	processNextRequest()
end

-- Request generate helper functions
local bodyless = {"Get", "Head", "Delete", "Options"}
local bodyful = {"Post", "Patch", "Put"}

for _, v in pairs(bodyless) do
	local method = v:upper()
	SA.API[v] = function(url, callback, options)
		return SA.API.Request(url, method, nil, options, callback)
	end
end

for _, v in pairs(bodyful) do
	local method = v:upper()
	SA.API[v] = function(url, body, callback, options)
		return SA.API.Request(url, method, body, options, callback)
	end
end

local function MakePlayerURL(ply)
	return "/players/" .. ply:SteamID()
end

local function MakePlayerResURL(ply, res)
	return MakePlayerURL(ply) .. "/" .. res
end

local function MakeFactionURL(faction)
	return "/factions/" .. faction
end

local function MakeFactionResURL(faction, res)
	return MakeFactionURL(faction) .. "/" .. res
end

local function MakeFactionResIDURL(faction, res, id)
	return MakeFactionResURL(faction, res) .. "/" .. id
end

local OPTIONS_NOAUTH = { noauth = true }
local OPTIONS_ONESHOT = { oneshot = true }

-- Basic LIST calls (scoreboard style)
function SA.API.ListPlayers(callback)
	return SA.API.Get("/players", callback, OPTIONS_NOAUTH)
end

function SA.API.ListBannedPlayers(callback)
	return SA.API.Get("/players/banned", callback, OPTIONS_NOAUTH)
end

function SA.API.ListFactions(callback)
	return SA.API.Get("/factions", callback, OPTIONS_NOAUTH)
end

-- PLAYER functions
function SA.API.GetPlayer(ply, callback)
	return SA.API.Get(MakePlayerURL(ply), callback, OPTIONS_NOAUTH)
end

function SA.API.GetPlayerFull(ply, callback)
	return SA.API.Get(MakePlayerResURL(ply, "full"), callback)
end

function SA.API.UpsertPlayer(ply, callback)
	return SA.API.Put(MakePlayerURL(ply), ply.sa_data, callback, OPTIONS_ONESHOT)
end

function SA.API.BanPlayer(steamid, reason, admin, callback)
	return SA.API.Post("/players/" .. steamid .. "/ban", {
		ban_reason = reason,
		banned_by = admin,
	}, callback)
end

-- PLAYER -> APPLICATION functions
function SA.API.GetPlayerApplication(ply, callback)
	return SA.API.Get(MakePlayerResURL(ply, "application"), callback)
end

function SA.API.UpsertPlayerApplication(ply, body, callback)
	return SA.API.Put(MakePlayerResURL(ply, "application"), body, callback)
end

-- FACTION -> APPLICATION functions
function SA.API.ListFactionApplications(faction, callback)
	return SA.API.Get(MakeFactionResURL(faction, "applications"), callback)
end

function SA.API.DeleteFactionApplication(faction, steamid, callback)
	return SA.API.Delete(MakeFactionResIDURL(faction, "applications", steamid), callback)
end

function SA.API.AcceptFactionApplication(faction, steamid, callback)
	return SA.API.Post(MakeFactionResIDURL(faction, "applications", steamid) .. "/accept", {}, callback)
end

-- SERVER functions
function SA.API.ListServers(callback)
	return SA.API.Get("/servers", callback, OPTIONS_NOAUTH)
end

function SA.API.GetServerName()
	return GetGlobalString("sa_server_name")
end

-- Player auth handling
if SERVER then
	function SA.API.GetServerToken()
		return apiConfig.serverToken
	end

	local function SA_API_MakePlayerJWT(ply, callback)
		return SA.API.Post(MakePlayerResURL(ply, "jwt"), {}, callback)
	end

	local function SA_API_MakePlayerTokenCMD(ply)
		SA_API_MakePlayerJWT(ply, function (data)
			net.Start("SA_PlayerJWT")
				net.WriteString(data.token)
				net.WriteInt(data.expiry, 32)
				net.WriteInt(data.valid_time, 32)
			net.Send(ply)
		end)
	end

	concommand.Add("sa_api_player_maketoken", SA_API_MakePlayerTokenCMD)

	local function MkPlayerMap()
		local res = {}
		for _, ply in pairs(player.GetHumans()) do
			table.insert(res, ply:SteamID())
		end
		return res
	end

	local function SA_API_Pingback()
		local ipportOk, ipport = GetIPPortAndOk()
		if not ipportOk then
			ipport = nil
		end

		local hidden = apiConfig.hidden or false
		if hidden then
			ipport = "127.0.0.1:27015"
		end

		return SA.API.Put("/servers/self", {
			players = MkPlayerMap(),
			maxplayers = game.MaxPlayers(),
			map = game.GetMap(),
			ipport = ipport,
			hidden = hidden,
		}, function (data, code)
			if code ~= 200 or not data then
				return
			end
			SA.API.SetOwnInfo(data)
		end, OPTIONS_ONESHOT)
	end
	timer.Create("SA_API_Pingback", 5, 0, SA_API_Pingback)
	timer.Simple(0, SA_API_Pingback)
end

if CLIENT then
	local APIAuthReady = false
	local function SA_API_RenewPlayerJWT()
		JWT_IN_RENEWAL = true
		RunConsoleCommand("sa_api_player_maketoken")
	end
	net.Receive("SA_PlayerJWT", function(len, ply)
		apiConfig.auth = "Client " .. net.ReadString()
		net.ReadInt(32) -- expiry
		local validTime = net.ReadInt(32)
		JWT_IN_RENEWAL = false
		if not APIAuthReady then
			APIAuthReady = true
			hook.Run("SA_API_AuthReady")
		end
		timer.Remove("SA_RenewJWT")
		timer.Create("SA_RenewJWT", validTime / 2, 1, SA_API_RenewPlayerJWT)
	end)

	SA.RunOnLoaded("SA_API_RenewPlayerJWT_Initial", SA_API_RenewPlayerJWT)
end
