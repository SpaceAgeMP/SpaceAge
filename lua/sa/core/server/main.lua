SA.REQUIRE("config")
SA.REQUIRE("faction.main")

local function SetupConvars(name, default, flags)
	if not ConVarExists(name) then
		return CreateConVar(name, default, flags)
	end
	return GetConVar(name)
end
local autoSaveTimeCVar = SetupConvars("sa_autosave_time", "0")
local autoSpanwerEnabled = SetupConvars("sa_autospawner", "1")
SetupConvars("sa_friendlyfire", "0")
SetupConvars("sa_pirating", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED })

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:AssignFaction(name, cb)
	local old_name = self.sa_data.faction_name

	local fact = SA.Factions.GetByName(name or self.sa_data.faction_name)
	if fact.is_invalid then
		fact = SA.Factions.GetDefault()
	end

	self:SetTeam(fact.index)
	self.sa_data.faction_name = fact.name

	if name then
		self:Spawn()
		SA.SendBasicInfo(self)
	end

	if self.sa_data.faction_name ~= old_name then
		self.sa_data.is_faction_leader = false
		SA.SaveUser(self)
	end
end

local function SA_AddSAData(ply)
	if not ply.sa_data then
		ply.sa_data = {}
	end
	local data = ply.sa_data
	data.name = ply:Nick()
	if data.credits == nil then
		data.credits = 0
	end
	if data.playtime == nil then
		data.playtime = 0
	end
	if data.score == nil then
		data.score = 0
	end
	if data.is_faction_leader == nil then
		data.is_faction_leader = false
	end
	data.loaded = false
	if data.station_storage == nil then
		data.station_storage = {}
	end
	if data.station_storage.capacity == nil then
		data.station_storage.capacity = 0
	end
	if data.station_storage.remaining == nil then
		data.station_storage.remaining = 0
	end
	if data.station_storage.contents == nil then
		data.station_storage.contents = {}
	end
	if data.faction_name == nil then
		data.faction_name = SA.Factions.GetError().name
	end
	if data.research == nil then
		data.research = {}
	end
	if data.group == nil then
		data.group = "user"
	end
	if data.is_banned == false then
		data.is_banned = nil
	end
	SA.Research.InitPlayer(ply)
	if data.advancement_level == nil or data.advancement_level <= 0 then
		data.advancement_level = 1
	end
end

local function SA_IsValidSteamID(sid, allowzero)
	if not sid or sid == "" or sid == "STEAM_ID_PENDING" then
		return false
	end
	return true
end

local function LoadRes(ply, body, code)
	print("Loaded:", ply:Name(), code)
	if code == 200 then
		ply.sa_data = body
		SA_AddSAData(ply)
		ply.sa_data.loaded = true
		SA.Terminal.SetupStorage(ply)
		ply:AssignFaction()
	else
		ply.sa_data = {}
		SA_AddSAData(ply)
		ply.sa_data.faction_name = SA.Factions.GetDefault().name
		ply.sa_data.loaded = code == 404
		SA.Terminal.SetupStorage(ply)
		ply:AssignFaction()
		SA.SaveUser(ply)
	end
	ply.sa_data.available = true

	if ply.sa_data.is_banned then
		ply:Kick("Banned: " .. ply.sa_data.ban_reason or "N/A")
		return
	end

	ply:SetNWBool("isleader", ply.sa_data.is_faction_leader)

	ply:SetNWBool("isloaded", true)
	if ply.sa_data.available and ply.HasAlreadySpawned then
		ply:Spawn()
		SA.Teleporter.TriggerOnJoin(ply)
	end

	if ply.MayBePoked then
		SA.SendBasicInfo(ply)
	end

	ULib.ucl.addUser(ply:SteamID(), {}, {}, ply.sa_data.group)

	if not SA.API.IsServerHidden() then
		SA.Central.SendChatRaw(ply, SA.Central.COLOR_NOTIFY_BLUE, " joined the server")
	end
end

local function SA_InitSpawn(ply)
	SA.GiveCredits.Remove(ply)
	ply.IsAFK = false
	ply.MayBePoked = false

	local sid = ply:SteamID()
	if not SA_IsValidSteamID(sid, true) then
		print("Skip loading because bad SteamID: ", ply:Name(), sid)
		return
	end
	print("Loading: ", ply:Name(), sid)

	SA_AddSAData(ply)
	SA.Terminal.SetupStorage(ply)
	ply:AssignFaction()

	SA.API.GetPlayerFull(ply, function(body, code) LoadRes(ply, body, code) end)
end
hook.Add("PlayerAuthed", "SA_LoadPlayer", SA_InitSpawn)

local function SA_PlayerFullLoad(ply)
	ply.MayBePoked = true
	if ply.sa_data and ply.sa_data.available then
		SA.SendBasicInfo(ply)
		SA.Teleporter.TriggerOnJoin(ply)
	end
end
hook.Add("PlayerFullLoad", "SA_LoadPlayerSendData", SA_PlayerFullLoad)

local function SA_MapCleanInitialize()
	local entityToRemove = SA.Config.Load("remove_entities")
	if not entityToRemove then
		return
	end

	if entityToRemove.Classes then
		for _, cls in pairs(entityToRemove.Classes) do
			for _, ent in pairs(ents.FindByClass(cls)) do
				ent:Remove()
			end
		end
	end
end

local function SA_AddMapResources()
	local mapResources = SA.Config.Load("resources")
	if not mapResources then
		return
	end

	for _, res in pairs(mapResources) do
		resource.AddFile(res)
	end
end

hook.Add("Initialize", "SA_MapCleanInitialize", function()
	SA_AddMapResources()
	timer.Simple(5, SA_MapCleanInitialize)
end)

timer.Create("SA_PlayTimeTracker", 1, 0, function()
	for _, ply in pairs(player.GetHumans()) do
		if ply.sa_data and ply.sa_data.available then
			ply.sa_data.playtime = ply.sa_data.playtime + 1
		end
	end
end)

function SA.SaveUser(ply, dontsaverd)
	local sid = ply:SteamID()
	if not ply.sa_data or not SA_IsValidSteamID(sid) then
		return false
	end
	if not ply.sa_data.loaded then
		if ply.sa_data.available then
			ply:ChatPrint("Warning! Your profile has failed to load! Progress will not be saved!")
		end
		return false
	end

	ply.sa_data.name = ply:Nick()
	ply.sa_data.station_storage.contents = SA.Terminal.GetPermStorage(ply)
	SA.API.UpsertPlayer(ply)

	if not dontsaverd then
		SA.SaveSystem.Save(ply)
	end

	return true
end

local function DisconnectedUser(ply)
	SA.SaveUser(ply)
	if not SA.API.IsServerHidden() then
		SA.Central.SendChatRaw(ply, SA.Central.COLOR_NOTIFY_BLUE, " left the server")
	end
end
hook.Add("PlayerDisconnected", "SA_Save_Disconnect", DisconnectedUser)

function SA.SaveAllUsers()
	local autoSaveTime = autoSaveTimeCVar:GetInt()
	if autoSaveTime > 0 then
		timer.Adjust("SA_Autosave", autoSaveTime * 60)
		for _, v in ipairs(player.GetHumans()) do
			SA.SaveUser(v, true)
		end
		SA.Planets.Save()
		SA.SaveSystem.SaveAll()
	end
end
timer.Create("SA_Autosave", 60, 0, SA.SaveAllUsers)
concommand.Add("sa_save_players", function(ply) if not IsValid(ply) or ply:IsAdmin() then SA.SaveAllUsers() end end)

local function SA_Autospawner(ply)
	if not autoSpanwerEnabled:GetBool() then
		return
	end

	for k, v in ipairs(ents.GetAll()) do
		if v.RealAutospawned == true then
			if v.SASound then v.SASound:Stop() end
			v:Remove()
		end
	end

	local autospawn2 = SA.Config.Load("autospawn2")

	if autospawn2 then
		for k, v in pairs(autospawn2) do
			local spawn = ents.Create(v.class)
			if not IsValid(spawn) then
				print("Could not create: " .. v.class)
				continue
			end

			spawn:SetPos(Vector(v.x, v.y, v.z))
			spawn:SetAngles(Angle(v.pit, v.yaw, v.rol))
			if v.model then
				spawn:SetModel(v.model)
			end

			spawn.CDSIgnore = true
			spawn.Autospawned = true
			spawn.RealAutospawned = true
			spawn.SkipSBChecks = true
			spawn.AutospawnInfo = v.info

			spawn:Spawn()
			local phys = spawn:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end
			if v.sound then
				local mySND = CreateSound(spawn, Sound(v.sound))
				if mySND then
					spawn.SASound = mySND
					spawn.SASound:Play()
				end
			end

			if spawn.AutospawnDone then
				spawn:AutospawnDone()
			end
		end
	end

	if ply and ply:IsPlayer() then
		print(ply, "respawned all SpaceAge stuff")
	end
end
timer.Simple(1, SA_Autospawner)
concommand.Add("sa_autospawn_run", function(ply) if ply:IsSuperAdmin() then SA_Autospawner(ply) end end)

local SA_Don_Toollist = SA.Config.Load("donator_tools", true)

local function SA_DonatorCanTool(ply, tr, mode)
	for k, v in pairs(SA_Don_Toollist) do
		if mode == v and not ply.sa_data.IsDonator then
			ply:AddHint("This is a donator-only tool, a reward for contributing to the community.", NOTIFY_CLEANUP, 10)
			return false
		end
	end
end
hook.Add("CanTool", "SA_DonatorCanTool", SA_DonatorCanTool)
