AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() then
		myPl:Kill()
		self.RespawnDelay = 0
		self:Remove()
	end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end
end

function ENT:OnRemove()
	local smokepuff = ents.Create( "env_ar2explosion" )
	smokepuff:SetPos(self:GetPos())
	smokepuff:SetKeyValue( "material", "particle/particle_noisesphere" )
	smokepuff:Spawn()
	smokepuff:Activate()
	smokepuff:Fire("explode", "", 0)
	smokepuff:Fire("kill","",10)

	if self.RespawnDelay > 0 then
		timer.Simple(self.RespawnDelay, function() SA.Ice.SpawnRoid(self.MineralName, self.data) end)
	end
end

function ENT:Think()

	if self.MineralAmount <= 1 then
		self:Remove()
		return false
	end

	if self.MineralAmount < self.MineralMax then
		local newamount = self.MineralAmount + (self.MineralRegen / (60 * 60))
		if newamount > self.MineralMax then
			self.MineralAmount = self.MineralMax
		else
			self.MineralAmount = newamount
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end


