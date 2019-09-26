AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	local ply = self:GetTable().Founder

	if not ply:IsAdmin() then
		self:SetModel("models/slyfo/sat_resourcetank.mdl")
	end

	self:CalcVars(ply)
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, { "Tiberium", "Max Tiberium" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(500)
	end
end

function ENT:CalcVars(ply)
	self.IsTiberiumStorage = true
	RD.AddResource(self, "tiberium", self:GetCapacity(ply), 0)
end

function ENT:GetCapacity(ply)
	return (50000 + (ply.SAData.Research.TiberiumStorageCapacity[1] * 5000)) * ply.SAData.Research.GlobalMultiplier
end

function ENT:Think()
	if WireAddon ~= nil then
		self:UpdateWireOutput()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Tiberium", RD.GetResourceAmount(self, "tiberium"))
	Wire_TriggerOutput(self, "Max Tiberium", RD.GetNetworkCapacity(self, "tiberium"))
end

function ENT:OnTakeDamage(dmginfo)
	local dmg = dmginfo:GetDamage()
	if math.Rand(0, (dmg * 0.3) + 18) >= 20 then self:Remove() end
end

function ENT:OnRemove()
	if RD.GetResourceAmount(self, "tiberium") < 1000 then return self.BaseClass.OnRemove(self) end

	local wreck = ents.Create("wreckedstuff")
	wreck:SetSolid(SOLID_NONE)
	wreck:SetModel(self:GetModel())
	wreck:SetAngles(self:GetAngles())
	wreck:SetPos(self:GetPos())
	wreck:Spawn()
	wreck:Activate()
	wreck.deathtype = 1

	self:Leak()

	self.BaseClass.OnRemove(self)
end

function ENT:Leak()
	for i = 1, math.Rand(1, 4) do
		if #ents.FindByClass("sa_tibcrystal_rep") >= 100 then return end
		local Pos = SA.Tiberium.FindWorldFloor(self:GetPos() + Vector(math.Rand(-500, 500), math.Rand(-500, 500), 500), nil, {self})
		if Pos then
			local crystal = ents.Create("sa_tibcrystal_rep")
			SA.Tiberium.SetTimeUntilDelete(crystal, CurTime() + math.Rand(10, 30))
			crystal:SetModel("models/ce_ls3additional/tiberium/tiberium_normal.mdl")
			local Height = math.abs(crystal:OBBMaxs().z - crystal:OBBCenter().z)
			crystal:SetPos(Pos-Vector(0, 0, Height-5))
			crystal:SetAngles(Angle(0, math.Rand(0, 359), 0))
			SA.Functions.PropMoveSlow(crystal, crystal:GetPos() + Vector(0, 0, Height-5), math.Rand(10, 45))
			crystal:Spawn()
			crystal.MainSpawnedBy = crystal
		end
	end
end
