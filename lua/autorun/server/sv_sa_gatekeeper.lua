local FactionCache = {}

local function SA_GK_PlayerCheck(sid64, ip, svPassword, pass, name)
	if svPassword ~= "" and pass ~= svPassword then
		return false, "Wrong password"
	end

	local sa_faction_only = GetConVar("sa_faction_only")
	if not sa_faction_only:GetBool() then
		return
	end

	if not sid64 then
		return false, "Sorry, internal error (Error 0x0)"
	end

	local sid = util.SteamIDFrom64(sid64)
	if not FactionCache[sid] then
		return false, "You don't meet the requirements for this server!"
	end
end
hook.Add("CheckPassword", "SA_GK_PlayerCheck", SA_GK_PlayerCheck)

local function RefreshCacheDone(data, isok, err)
	table.Empty(FactionCache)
	for k, v in pairs(data) do
		FactionCache[v.steamid] = true
	end
	Msg("Gatekeeper cache loaded\n")
end
local function RefreshCache()
	local sa_faction_only = GetConVar("sa_faction_only")
	if not sa_faction_only:GetBool() then return end
	local isok, err = SA.MySQL:Query("SELECT steamid FROM players WHERE groupname ~= 'freelancer' AND score >= 100000000", RefreshCacheDone)
	if not isok then
		Msg("Error loading gatekeeper cache: " .. tostring(err) .. "\n")
		return
	end
	Msg("Loading gatekeeper cache .. .\n")
end
timer.Create("SA_FactionCacheRefresh", 60, 0, RefreshCache)
timer.Create("SA_FirstFactionCacheRefresh", 0.01, 1, RefreshCache)
