TOOL.Category		= "SpaceAge"
TOOL.Name			= "RTA Device"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab = "Custom Addon Framework"

if (CLIENT) then
	language.Add("tool.rta_device.name", "RTA Device")
	language.Add("tool.rta_device.desc", "Creates a Remote Terminal Access computer.")
	language.Add("tool.rta_device.0", "Primary: Create RTA Device.")
	language.Add("sboxlimit_rta_devices", "You've hit the RTA devices limit.")
	language.Add("undone_rta device", "Undone RTA Device")
end

if (SERVER) then
	CreateConVar("sbox_maxrta_devices", 1)
end

cleanup.Register("rta_devices")

local function MakeRTA(pl, Pos, Ang)
	if (not pl:CheckLimit("rta_devices")) then return false end

	local RTA = ents.Create("sa_rta")
	if (not RTA:IsValid()) then return false end

	RTA:SetAngles(Ang)
	RTA:SetPos(Pos)
	RTA:Spawn()

	RTA:SetPlayer(pl)

	local ttable = {
		pl = pl,
	}
	table.Merge(RTA:GetTable(), ttable)

	pl:AddCount("rta_devices", RTA)

	return RTA
end

if SERVER then
	duplicator.RegisterEntityClass("sa_rta", MakeRTA, "Pos", "Ang", "Vel", "aVel", "frozen")
end

function TOOL:LeftClick(trace)
	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return true end

	local ply = self:GetOwner()

	if (!self:GetSWEP():CheckLimit("rta_devices")) then return false end

	local Ang = trace.HitNormal:Angle()

	local RTA = MakeRTA(ply, trace.HitPos, Ang)

	local min = RTA:OBBMins()
	RTA:SetPos(trace.HitPos - trace.HitNormal * min.x)

	local const = WireLib.Weld(RTA, trace.Entity, trace.PhysicsBone, true)

	undo.Create("RTA Device")
		undo.AddEntity(RTA)
		undo.AddEntity(const)
		undo.SetPlayer(ply)
	undo.Finish()

	ply:AddCleanup("rta_devices", RTA)

	return true
end

function TOOL:UpdateGhostRTA(ent, player)
	if (!ent or !ent:IsValid()) then return end

	local tr 	= util.GetPlayerTrace(player, player:GetAimVector())
	local trace 	= util.TraceLine(tr)

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.x)
	ent:SetAngles(Ang)

	ent:SetNoDraw(false)
end

function TOOL:Think()
	if (!self.GhostEntity or !self.GhostEntity:IsValid() ) then
		self:MakeGhostEntity("models/slyfo/rover_na_large.mdl" , Vector(0,0,0), Angle(0,0,0))
	end

	self:UpdateGhostRTA(self.GhostEntity, self:GetOwner())
end

