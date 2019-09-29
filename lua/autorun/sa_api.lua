local API_BASE = "https://api.spaceage.online/v1"
local API_HEADERS = {}

SA.API = {}

local MakeUserAgent

local function CommonUserAgent(side)
	return "SpaceAge/GMod-" .. side .. " " .. game.GetIPAddress()
end

if SERVER then
	AddCSLuaFile()

	local apiConfig = SA.Config.Load("api", true)
	if apiConfig.auth then
		API_HEADERS.Authorization = apiConfig.auth
	end
	if apiConfig.url then
		API_BASE = apiConfig.url
	end

	MakeUserAgent = function()
		return CommonUserAgent("Server")
	end
else
	MakeUserAgent = function()
		return CommonUserAgent("Client")
	end
end

timer.Simple(1, function()
	API_HEADERS["Client-ID"] = MakeUserAgent()
end)

function SA.API.Request(url, method, reqBody, onok, onerror)
	local request = {
		failed = function(err)
			if not onerror then
				return
			end
			onerror(err)
		end,
		success = function(code, body, headers)
			if not onok then
				return
			end

			if body then
				body = util.JSONToTable(body)
			end
			onok(body, code)
		end,
		headers = API_HEADERS,
		method = method or "GET",
		url = API_BASE .. url,
		type = "application/json",
		body = reqBody and util.TableToJSON(reqBody) or nil
	}

	HTTP(request)
end

local bodyless = {"Get", "Head", "Delete", "Options"}
local bodyful = {"Post", "Patch", "Put"}

for _, v in pairs(bodyless) do
	local method = v:upper()
	SA.API[v] = function(url, onok, onerror)
		return SA.API.Request(url, method, nil, onok, onerror)
	end
end

for _, v in pairs(bodyful) do
	local method = v:upper()
	SA.API[v] = function(url, body, onok, onerror)
		return SA.API.Request(url, method, body, onok, onerror)
	end
end

local function MakePlayerURL(ply)
	return "/players/" .. ply:SteamID()
end

local function MakePlayerResURL(ply, res)
	return MakePlayerURL(ply) .. "/" .. res
end

local function MakePlayerResIDURL(ply, res, id)
	return MakePlayerResURL(ply, res) .. "/" .. id
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

-- Basic LIST calls (scoreboard style)
function SA.API.ListPlayers(onok, onerror)
	return SA.API.Get("/players", onok, onerror)
end

function SA.API.ListFactions(onok, onerror)
	return SA.API.Get("/factions", onok, onerror)
end

-- PLAYER functions
function SA.API.GetPlayer(ply, onok, onerror)
	local url = MakePlayerURL(ply)
	if SERVER then
		url = url .. "/full"
	end
	return SA.API.Get(url, onok, onerror)
end

function SA.API.UpsertPlayer(ply, onok, onerror)
	return SA.API.Put(url, ply.SAData, onok, onerror)
end

-- PLAYER -> APPLICATION functions
function SA.API.GetPlayerApplication(ply, onok, onerror)
	return SA.API.Get(MakePlayerResURL(ply, "application"), onok, onerror)
end

function SA.API.UpsertPlayerApplication(ply, body, onok, onerror)
	return SA.API.Put(MakePlayerResURL(ply, "application"), body, onok, onerror)
end

-- PLAYER -> GOODIE functions
function SA.API.GetPlayerGoodies(ply, onok, onerror)
	return SA.API.Get(MakePlayerResURL(ply, "goodies"), onok, onerror)
end

function SA.API.DeletePlayerGoodie(ply, id, onok, onerror)
	return SA.API.Get(MakePlayerResIDURL(ply, "goodies", id), onok, onerror)
end

-- FACTION -> APPLICATION functions
function SA.API.ListFactionApplications(faction, onok, onerror)
	return SA.API.Get(MakeFactionResURL(faction, "applications"), onok, onerror)
end

function SA.API.DeleteFactionApplication(faction, steamid, onok, onerror)
	return SA.API.Delete(MakeFactionResIDURL(faction, "applications", steamid), onok, onerror)
end

function SA.API.AcceptFactionApplication(faction, steamid, onok, onerror)
	return SA.API.Post(MakeFactionResIDURL(faction, "applications", steamid) .. "/accept", {}, onok, onerror)
end
