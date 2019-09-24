AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local ent = ents.Create( "asteroid_veldspar" )
	ent:SetPos( tr.HitPos + tr.HitNormal * 250 )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:Think()
	self.BaseClass.Think(self)
end
