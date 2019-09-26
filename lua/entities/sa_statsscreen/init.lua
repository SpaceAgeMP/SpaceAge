AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

require("supernet")

ENT.WireDebugName = "SpaceAge Stats Display"

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_statsscreen")
	ent:SetModel("models/props/cs_assault/Billboard.mdl")
	ent:SetPos(tr.HitPos + Vector(0, 0, 100))
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use()
end

function ENT:Think()
end
