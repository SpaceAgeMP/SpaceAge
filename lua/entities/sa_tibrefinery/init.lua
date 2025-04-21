AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_tibrefinery")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self.SkipSBChecks = true

	self:SetModel("models/slyfo/sat_rtankstand.mdl")
	self.TouchTable = {}
	self.IgnoreTable = {}
	--self.TouchNetTable = {}
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)
end

function ENT:StartTouch(ent)
	if not ent.IsTiberiumStorage then
		return
	end

	local tibAmount = ent:GetResourceAmount("tiberium")
	if tibAmount > 0 then
		local attachPlace = SA.Tiberium.FindFreeAttachPlace(ent, self)
		if not attachPlace then return end
		if not SA.Tiberium.AttachStorage(ent, self, attachPlace) then return end
		RD.Unlink(ent)
		constraint.RemoveAll(ent)
		constraint.Weld(ent, self, 0, 0, false)
		ent.TibRefineAmount = ent:ConsumeResource("tiberium", tibAmount) or 0
		self.TouchTable[attachPlace] = ent
	end
end

function ENT:Think()
	BaseClass.Think(self)
	for k, v in pairs(self.TouchTable) do
		if not IsValid(v) or not v.IsTiberiumStorage then
			self.TouchTable[k] = nil
			continue
		end
		RD.Unlink(v)
		local ply = v:CPPIGetOwner()
		if IsValid(ply) and ply:IsPlayer() then
			local taken = v.TibRefineAmount
			if taken == nil or taken <= 0 then
				v.TibRefineAmount = nil
				constraint.RemoveAll(v)
				v.FPPRestrictConstraint = {}
				v.FPPConstraintReasons = {}

				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(self:GetAngles():Up() * 10)
				end
				self.TouchTable[k] = nil
			else
				if taken > 10000 then
					taken = 10000
				end
				v.TibRefineAmount = v.TibRefineAmount - taken

				local creds = math.Round(taken * 25)
				if ply.sa_data.faction_name == "corporation" then
					creds = math.ceil((creds * 1.33) * 1000) / 1000
				end
				ply:RewardCredits(creds)
			end
		else
			v:Remove()
			self.TouchTable[k] = nil
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end
