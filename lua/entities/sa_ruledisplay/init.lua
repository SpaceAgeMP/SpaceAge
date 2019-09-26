AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.HitWorld) then return end

	local ent = ents.Create("sa_ruledisplay")
	ent:SetPos(tr.HitPos + Vector(0, 0, 100))
	ent:SetAngles(Angle(0, -180, 0))
	ent:Spawn()
	return ent
end

function ENT:Initialize()
	self:SetModel("models/props_canal/canal_bridge02.mdl")
	self:DrawShadow(false)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end
