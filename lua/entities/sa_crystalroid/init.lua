AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_crystalroid")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	self.BaseClass.Think(self)
	SA.Tiberium.RemoveIntersecting(self,{"sa_crystal","sa_mining_drill"})
	self:NextThink(CurTime() + 2)
	return true
end

local modelTbl = {
	"models/ce_ls3additional/asteroids/asteroid_200.mdl",
	"models/ce_ls3additional/asteroids/asteroid_250.mdl",
	"models/ce_ls3additional/asteroids/asteroid_300.mdl",
	"models/ce_ls3additional/asteroids/asteroid_350.mdl",
	"models/ce_ls3additional/asteroids/asteroid_400.mdl",
	"models/ce_ls3additional/asteroids/asteroid_450.mdl",
	"models/ce_ls3additional/asteroids/asteroid_500.mdl"
}

function ENT:Initialize()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() and myPl:SteamID() ~= "STEAM_0:0:5394890" then
		myPl:Kill()
		self:Remove()
	end
	self:SetModel(table.Random(modelTbl))
	self.MayNotBeFound = true
	self.CrystalResistant = true
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
	while self.crystalCount < SA_MaxCrystalCount do
		self:SpawnCrystal(false)
	end
end

function ENT:StartTouch(ent)
end

function ENT:CrystalRemoved()
	if self.crystalCount <= 0 then return end
	self.crystalCount = self.crystalCount - 1
end

function ENT:FindCrystalPos()
	local res = nil

	local selfCenter = self:LocalToWorld(self:OBBCenter())
	local tracedata = {start = selfCenter + Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):Normalize() * 2000, endpos = selfCenter, filter = {}}
	local tries = 0
	while not res or res.Entity ~= self do
		res = util.TraceLine(tracedata)
		if not (res.Hit and res.HitNonWorld and SA.ValidEntity(res.Entity)) then return end
		table.insert(tracedata.filter,res.Entity)
		if tries > 100 then return end
		tries = tries + 1
	end
	return res
end

function ENT:SpawnCrystal(auto)
	if not self then return end
	if auto then
		timer.Simple(math.random(1,10),function() self:SpawnCrystal(true) end)
	end
	if self.crystalCount >= SA_MaxCrystalCount then return end

	local trace = self:FindCrystalPos()
	if not trace then return end

	local crystal = ents.Create("sa_crystal")

	local cHealth = math.random(1200,3000) --1200 UNTIL 3000

	if cHealth <= 1800 then
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_160_60.mdl")
	elseif cHealth <= 2400 then
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_250_60.mdl")
	else
		crystal:SetModel("models/ce_mining/tiberium/ce_tib_360_125.mdl")
	end

	crystal:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
	crystal:SetPos(trace.HitPos)

	crystal:SetSkin(2)
	crystal:Spawn()

	crystal.MasterTower = self
	crystal.IsCrystal = true
	crystal.Autospawned = true
	crystal.CDSIgnore = true
	crystal.health = cHealth
	crystal.maxhealth = cHealth

	SA.PP.MakeOwner(crystal)

	local phys = crystal:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)

	self:DeleteOnRemove(crystal)

	self.crystalCount = self.crystalCount + 1
end
