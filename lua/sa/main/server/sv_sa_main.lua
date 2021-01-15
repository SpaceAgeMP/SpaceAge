SA_REQUIRE("config")

timer.Simple(1, function() RD = CAF.GetAddon("Resource Distribution") end)

local WorldClasses = {}
local function AddWorldClass(name)
	table.insert(WorldClasses, name)
end
AddWorldClass("prop_door_rotating")
AddWorldClass("prop_dynamic")
AddWorldClass("func_useableladder")
AddWorldClass("func_rotating")
AddWorldClass("func_rot_button")
AddWorldClass("func_door")
AddWorldClass("func_door_rotating")
AddWorldClass("func_button")
AddWorldClass("func_movelinear")


local function SetupConvars(name)
	if (not ConVarExists(name)) then
		return CreateConVar(name, 0)
	end
	return GetConVar(name)
end
local autoSaveTimeCVar = SetupConvars("sa_autosave_time")
CreateConVar("sa_autospawner", "1")
SetupConvars("sa_friendlyfire")
CreateConVar("sa_pirating", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED })
CreateConVar("sa_faction_only", "0", { FCVAR_NOTIFY })
local sa_faction_only = GetConVar("sa_faction_only")

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:AssignFaction(name, cb)
	local old_name = self.sa_data.faction_name

	if name then
		self.sa_data.faction_name = name
	end
	if not self.sa_data.faction_name then
		self.sa_data.faction_name = "freelancer"
	end
	if self.sa_data.faction_name == "alliance" and self.sa_data.alliance_membership_expiry < os.time() then
		self.sa_data.faction_name = "freelancer"
	end

	local idx = SA.Factions.IndexByShort[self.sa_data.faction_name]
	self:SetTeam(idx)

	if not self:Team() then
		self:SetTeam(7)
		self.sa_data.faction_name = "noload"
		return
	end

	if name then
		self:Spawn()
		SA.SendBasicInfo(self)
	end

	if self.sa_data.faction_name ~= old_name then
		self.sa_data.is_faction_leader = false
		local steamId = self:SteamID()
		SA.SaveUser(self, nil, function()
			http.Fetch("https://spaceage.mp/sa_group_sync.php?steam_id=" .. steamId .. "&authkey=TwB8a4yUKkF13bpI")
		end)
	end
end

local LoadRes, SA_AddSAData

local function SA_IsValidSteamID(sid, allowzero)
	if not sid or sid == "" or sid == "STEAM_ID_PENDING" then
		return false
	end
	return true
end

local function SA_InitSpawn(ply)
	SA.GiveCredits.Remove(ply)
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
hook.Add("PlayerFullLoad", "SA_LoadPlayer", SA_InitSpawn)

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

hook.Add("Initialize", "SA_MapCleanInitialize", function()
	timer.Simple(5, SA_MapCleanInitialize)
end)

SA_AddSAData = function(ply)
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
	if data.alliance_membership_expiry == nil then
		data.alliance_membership_expiry = 0
	end
	if data.faction_name == nil then
		data.faction_name = "noload"
	end
	if data.research == nil then
		data.research = {}
	end
	SA.Research.InitPlayer(ply)
	if data.advancement_level == nil or data.advancement_level <= 0 then
		data.advancement_level = 1
	end
end

timer.Create("SA_PlayTimeTracker", 1, 0, function()
	for _, ply in pairs(player.GetHumans()) do
		if ply.sa_data and ply.sa_data.loaded then
			ply.sa_data.playtime = ply.sa_data.playtime + 1
		end
	end
end)

LoadRes = function(ply, body, code)
	print("Loaded:", ply:Name(), code)
	if code == 404 then
		SA_AddSAData(ply)
		ply.sa_data.faction_name = "freelancer"
		ply.sa_data.loaded = true
		ply:ChatPrint("You have not been found in the database, an account has been created for you.")
		SA.Terminal.SetupStorage(ply)
		ply:AssignFaction()
		SA.SaveUser(ply)
	elseif code == 200 then
		ply.sa_data = body
		SA_AddSAData(ply)
		ply.sa_data.loaded = true
		SA.Terminal.SetupStorage(ply, ply.sa_data.station_storage.contents)
		ply:ChatPrint("Your account has been loaded, welcome on duty.")
		ply:AssignFaction()
	end

	if sa_faction_only:GetBool() and
		(ply:Team() < SA.Factions.Min or
		ply:Team() > SA.Factions.Max or
		tonumber(ply.sa_data.score) < 100000000) then
			ply:Kick("You don't meet the requirements for this server!")
	end

	ply.InvitedTo = false
	ply.IsAFK = false
	ply.MayBePoked = false

	ply:SetNWBool("isleader", ply.sa_data.is_faction_leader)
	ply:SetNWInt("Score", ply.sa_data.score)

	timer.Simple(1, function()
		if not SA.ValidEntity(ply) then return end
		ply.MayBePoked = true
		SA.SendBasicInfo(ply)
		ply:ChatPrint("Spawn limitations disengaged. Happy travels.")
	end)
	ply:SetNWBool("isloaded", true)
	if ply.sa_data.loaded then
		ply:Spawn()
	end

	hook.Run("SA_PlayerLoaded", ply)
end

function SA.SaveUser(ply, isautosave, cb)
	if isautosave == "sa_autosaver" then
		ply:SetNWInt("sa_save_int", autoSaveTimeCVar:GetInt() * 60)
		ply:SetNWInt("sa_last_saved", CurTime())
	end

	local sid = ply:SteamID()
	if not ply.sa_data or not ply.sa_data.loaded or not SA_IsValidSteamID(sid) then
		return false
	end

	ply.sa_data.name = ply:Nick()
	ply.sa_data.station_storage.contents = SA.Terminal.GetPermStorage(ply)
	SA.API.UpsertPlayer(ply, cb)
	return true
end
hook.Add("PlayerDisconnected", "SA_Save_Disconnect", SA.SaveUser)

local function SA_SaveAllUsers()
	local autoSaveTime = autoSaveTimeCVar:GetInt()
	if autoSaveTime > 0 then
		timer.Adjust("SA_Autosave", autoSaveTime * 60, 0, SA_SaveAllUsers)
		for _, v in ipairs(player.GetHumans()) do
			SA.SaveUser(v, "sa_autosaver")
		end
		SA.Planets.Save()
	end
end
timer.Create("SA_Autosave", 60, 0, SA_SaveAllUsers)
concommand.Add("sa_save_players", function(ply) if not ply or ply:IsAdmin() then SA_SaveAllUsers() end end)

local function SA_Autospawner(ply)
	if (not GetConVar("sa_autospawner"):GetBool()) then
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
			if not SA.ValidEntity(spawn) then
				print("Could not create: " .. v.class)
				continue
			end

			spawn:SetPos(Vector(v.x, v.y, v.z))
			spawn:SetAngles(Angle(v.pit, v.yaw, v.rol))
			if v.model then
				spawn:SetModel(v.model)
			end

			spawn:Spawn()
			local phys = spawn:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end
			spawn.CDSIgnore = true
			spawn.Autospawned = true
			spawn.RealAutospawned = true
			if v.sound then
				local mySND = CreateSound(spawn, Sound(v.sound))
				if mySND then
					spawn.SASound = mySND
					spawn.SASound:Play()
				end
			end
		end
	end

	if (ply and ply:IsPlayer()) then
		SystemSendMSG(ply, "respawned all SpaceAge stuff")
	end
end
timer.Simple(1, SA_Autospawner)
concommand.Add("sa_autospawn_run", function(ply) if ply:GetLevel() >= 3 then SA_Autospawner(ply) end end)

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
