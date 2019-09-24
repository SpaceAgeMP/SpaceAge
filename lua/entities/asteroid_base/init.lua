AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WorldInternal = true


function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() then
		myPl:Kill()
		self:Remove()
	end

	self:SetModel(self.AsteroidModel)
	self:SetColor(self.AsteroidColor)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end

	AM_AddOre(self.MineralName , self.MineralVol)

	self:SetOverlayText(self.MineralName)
end

function ENT:SpawnFunction( ply, tr )
	if (not tr.Hit ) then return end
	local ent = ents.Create( "asteroid_base" )
	ent:SetPos(tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:OnRemove()
	local smokepuff = ents.Create( "env_ar2explosion" )
	smokepuff:SetPos(self:GetPos())
	smokepuff:SetKeyValue( "material", "particle/particle_noisesphere" )
	smokepuff:Spawn()
	smokepuff:Activate()
	smokepuff:Fire("explode", "", 0)
	smokepuff:Fire("kill","",10)
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.MineralAmount <= 0 then
		self:Remove()
		return false
	end

	if self.MineralAmount < self.MineralMax then
		local newamount = self.MineralAmount + ((self.MineralRegen)/60)
		if newamount > self.MineralMax then
			self.MineralAmount = self.MineralMax
		else
			self.MineralAmount = newamount
		end
	end

	self:NextThink(CurTime()+1)
	return true
end
