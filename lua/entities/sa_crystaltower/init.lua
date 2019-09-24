AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

if not SA.Tiberium then
	SA.Tiberium = {}
end

SA.Tiberium.MaxCrystalCount = 6
SA.Tiberium.CrystalRadius = 1024

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_crystaltower")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	self.BaseClass.Think(self)
	SA.Tiberium.RemoveIntersecting(self,{"sa_crystaltower","sa_mining_drill"})
	self:NextThink(CurTime() + 2)
	return true
end

function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() and myPl:SteamID() ~= "STEAM_0:0:5394890" then
		myPl:Kill()
		self:Remove()
	end
	self:SetModel("models/ce_mining/tiberium/ce_tib_500_200.mdl")
	self.MayNotBeFound = true
	self.CrystalResistant = true
	self:SetSkin(math.random(0,1))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)
	self.crystalCount = 0

	self:AutoSpawn()

	self:SpawnCrystal(true)
end

function ENT:AutoSpawn()
	while self.crystalCount < SA.Tiberium.MaxCrystalCount do
		self:SpawnCrystal(false)
	end
end

function ENT:StartTouch(ent)
	local eClass = ent:GetClass()
	if ent:IsPlayer() then
		ent:Kill()
	elseif not (ent.CrystalResistant or ent.Autospawned) then
		local skin = self:GetSkin()
		local material
		if skin == 0 then
			material = "ce_mining/tib_blue.vtf"
		elseif skin == 1 then
			material = "ce_mining/tib_green.vtf"
		elseif skin == 2 then
			material = "ce_mining/tib_red.vtf"
		end
		ent:SetMaterial(material)
		constraint.RemoveAll(ent)
		ent:GetPhysicsObject():EnableMotion()
		timer.Simple(3,function() ent:Remove() end)
	elseif eClass == "sa_crystal" or eClass == "sa_crystaltower" then
		ent:Remove()
	end
end

function ENT:CrystalRemoved()
	if self.crystalCount <= 0 then return end
	self.crystalCount = self.crystalCount - 1
end

function ENT:SpawnCrystal(auto)
	if not self then return end
	if auto then
		local ctal = self
		timer.Simple(math.random(1,10),function() ctal:SpawnCrystal(true) end)
	end

	local SA_MaxCrystalCount = SA.Tiberium.MaxCrystalCount
	local SA_CrystalRadius = SA.Tiberium.CrystalRadius

	if self.crystalCount >= SA_MaxCrystalCount then return end

	local p = self:GetPos()
	local tmpPos = SA.Tiberium.FindWorldFloor(Vector(math.random(-SA_CrystalRadius,SA_CrystalRadius)+p.x,math.random(-SA_CrystalRadius,SA_CrystalRadius)+p.y,p.z+200),nil,{self})
	if not tmpPos then
		if auto then
			self:SpawnCrystal(false)
		end
		return
	end

	local crystal = ents.Create("sa_crystal")

	local cHealth = math.random(1200,3000) --1200 UNTIL 3000

	if cHealth <= 1800 then
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_160_60.mdl")
	elseif cHealth <= 2400 then
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_250_60.mdl")
	else
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_360_125.mdl")
	end

	crystal:SetAngles(Angle(0, math.random(0, 360), 0))

	crystal:SetPos(tmpPos)

	crystal:SetSkin(self:GetSkin())

	crystal:Spawn()

	crystal.MasterTower = self
	crystal.IsCrystal = true
	crystal.Autospawned = true
	crystal.CDSIgnore = true
	crystal.health = cHealth
	crystal.maxhealth = cHealth

	SA.PP.MakeOwner(crystal)

	if auto then
		crystal:SetPos(tmpPos - Vector(0,0,(crystal:LocalToWorld(crystal:OBBMaxs()) - crystal:LocalToWorld(crystal:OBBMins())).z))
	end

	local phys = crystal:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)

	SA.Functions.PropMoveSlow(crystal,tmpPos,2)

	self:DeleteOnRemove(crystal)

	self.crystalCount = self.crystalCount + 1
end
