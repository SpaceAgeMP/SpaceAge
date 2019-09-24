AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() then
		myPl:Kill()
		self:Remove()
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:OnRemove()
	SA.Asteroids.OnRemove(self)
end
