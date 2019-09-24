AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.delay = CurTime()+math.random(5,20)
	self.Max = math.Rand(1,4)
	self.Cur = 0
	self.Removetime = CurTime()+math.random(20,40)
	self.alpha = 255
	self.Players = {}
	self.UpdateEnts = CurTime()
	self.MainSpawnedBy = NULL

	SA.PP.MakeOwner(self)
	self.Autospawned = true
	self.CDSIgnore = true
end

function ENT:Use( activator, caller )
end

function ENT:Think()
	if not self:IsValid() then
		return
	end
	if not SA.PP.IsWorldEnt(self) then
		self:Remove()
		return
	end
	local timeUntilDelete = SA.Tiberium.GetTimeUntilDelete(self.MainSpawnedBy)

	if timeUntilDelete then
		if CurTime() < timeUntilDelete  then
			if CurTime() > self.UpdateEnts then
				self.Players = ents.FindInSphere(self:GetPos(),250)
				for _,ply in pairs(self.Players) do
					if ply:IsPlayer() then
						if ply:Alive() then
							ply:Kill()
						end
					end
				end
				self.UpdateEnts = CurTime()+1
			end
			if CurTime() > self.delay then
				if #ents.FindByClass(self:GetClass()) <= 100 then
					local Pos = SA.Tiberium.FindWorldFloor(self:GetPos()+Vector(math.Rand(-500,500),math.Rand(-500,500),500),nil,{self})
					if Pos then
						local crystal = ents.Create("sa_tibcrystal_rep")
						crystal:SetModel( self:GetModel() )
						self.Height = math.abs(crystal:OBBMaxs().z - crystal:OBBMins().z)
						crystal:SetPos(Pos-Vector(0,0,self.Height))
						crystal:SetAngles(Angle(0,math.Rand(0,359),0))
						SA.Functions.PropMoveSlow(crystal,crystal:GetPos()+Vector(0,0,self.Height-5),math.Rand(10,45))
						crystal:Spawn()
						crystal.MainSpawnedBy = self.MainSpawnedBy
					end
					self.delay = CurTime()+math.random(5,20)
				end
			end
		end
		if CurTime() > timeUntilDelete then
			if self.alpha > 0 then
				self.alpha = self.alpha - 10
				self:SetColor(255,255,255,self.alpha)
			end
		end
	end
	if self.alpha <= 0 then
		self:SetColor(255,255,255,0)
		self:Remove()
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
	elseif eClass == "sa_crystal" or eClass == "sa_crystaltower" or eClass == "sa_tibcrystal_rep" then
		ent:Remove()
	end
end
