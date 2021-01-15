AddCSLuaFile("autorun/client/cl_sa_teleporters.lua")

SA.Teleporter = {}

local SA_TeleportLocs = {}
local SA_TeleportNames = {}

local function InitSATeleporters()
	for k, v in pairs(ents.FindByClass("teleport_panel")) do
		v:Remove()
	end

	SA_TeleportLocs = {}
	SA_TeleportNames = {}

	local teleporters = SA.Config.Load("teleporters")
	if not teleporters then
		return
	end

	for name, config in pairs(teleporters) do
		local spawns = {}
		for _, spawn in pairs(config.Spawns) do
			table.insert(spawns, Vector(unpack(spawn)))
		end
		SA_TeleportLocs[name] = spawns
		table.insert(SA_TeleportNames, name)

		for k, v in pairs(config.Panels) do
			local tele = ents.Create("teleport_panel")
			local phys = tele:GetPhysicsObject()
			if phys and phys.IsValid and phys:IsValid() then
				phys:EnableMotion(false)
			end
			tele:SetPos(Vector(unpack(v.Position)))
			tele:SetAngles(Angle(unpack(v.Angle)))
			tele.TeleKey = name
			tele.Autospawned = true
			tele.CDSIgnore = true
			tele:Spawn()
		end
	end
end

timer.Simple(2, InitSATeleporters)

concommand.Add("sa_teleporter_respawn", function(ply)
	if not (ply and ply:IsSuperAdmin()) then
		return
	end
	InitSATeleporters()
end)

concommand.Add("sa_teleporter_update", function(ply, cmd, args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	if ply.LastTeleKey == ply.AtTeleporter then return end
	net.Start("SA_TeleporterUpdate")
		net.WriteInt(#SA_TeleportNames - 1, 16)
		for k, v in pairs(SA_TeleportNames) do
			if v ~= ply.AtTeleporter then
				net.WriteString(v)
			end
		end
	net.Send(ply)
	ply.LastTeleKey = ply.AtTeleporter
end)

local function AbortTeleport(ply, cmd, args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	ply.AtTeleporter = nil
	net.Start("SA_HideTeleportPanel")
		net.WriteBool(false)
	net.Send(ply)
	hook.Remove("KeyPress", "SA_TeleAbortMove_" .. ply:EntIndex())
end
concommand.Add("sa_teleporter_cancel", AbortTeleport)

concommand.Add("sa_teleporter_do", function(ply, cmd, args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	local TeleKey = string.Implode(" ", args)
	if ply.AtTeleporter == TeleKey then return end
	if not TeleKey then ply:ChatPrint("NO TELEPORT LOCATION") return end
	local TeleTBL = SA_TeleportLocs[TeleKey]
	if not TeleTBL then ply:ChatPrint("INVALID TELEPORT LOCATION") return end
	ply.LastTeleKey = nil
	AbortTeleport(ply)
	ply:SetPos(table.Random(TeleTBL))
end)

function SA.Teleporter.Open(ply, TeleKey)
	if not (ply and ply.IsValid and ply:IsValid()) then return end
	if ply.AtTeleporter then return end
	ply.AtTeleporter = TeleKey
	net.Start("SA_OpenTeleporter")
		net.WriteString(TeleKey)
	net.Send(ply)
end

hook.Add("KeyPress", "SA_TeleAbortMove_Abort", function(ply, key)
	if key ~= IN_USE then
		AbortTeleport(ply)
	end
end)
