AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")
local SA_TheWorld

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_tibrefinery")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if not SA_TheWorld then
		SA_TheWorld = ents.FindByClass("worldspawn")[1]
	end

	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() and myPl:SteamID() ~= "STEAM_0:0:5394890" then
		myPl:Kill()
		self:Remove()
	end
	self:SetModel("models/slyfo/sat_rtankstand.mdl")
	self.TouchTable = {}
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
	if ent.IsTiberiumStorage and (RD.GetResourceAmount( ent, "tiberium" ) >= 0) then
		local attachPlace = SA.Tiberium.FindFreeAttachPlace(ent,self)
		if not attachPlace then return end
		if not SA.Tiberium.AttachStorage(ent,self,attachPlace) then return end
		constraint.Weld(ent, SA_TheWorld,0,0,false)
		self.TouchTable[attachPlace] = ent
		--local tmp = RD.GetEntityTable(ent)
		--self.TouchNetTable[ent:EntIndex()] = tmp.network
		RD.Unlink(ent)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	for k,v in pairs(self.TouchTable) do
		if v.IsTiberiumStorage then
			RD.Unlink(v)
			local ply = SA.PP.GetOwner(v)
			if ply and ply:IsValid() and ply:IsPlayer() then
				local am = RD.GetResourceAmount( v, "tiberium" )
				local taken = 10000
				if am < taken then taken = am end
				if taken <= 0 then
					v:Remove()
					self.TouchTable[k] = nil
				else
					RD.ConsumeResource(v, "tiberium", taken)
					local creds = math.Round(taken * (math.random(20,30)))
					if ply.UserGroup == "corporation" or ply.UserGroup == "alliance" then
						creds = math.ceil((creds * 1.33) * 1000) / 1000
					elseif ply.UserGroup == "starfleet" then
						creds = math.ceil((creds * 1.11) * 1000) / 1000
					end
					ply.Credits = ply.Credits + creds
					if ply.TotalCredits > 100000000 then
						if ply.UserGroup  == "legion" then
							creds = creds * 0.5
						else
							creds = creds * 0.4
						end
					end
					ply.TotalCredits = ply.TotalCredits + creds
					SA.SendCreditsScore(ply)
				end
			else
				v:Remove()
				self.TouchTable[k] = nil
			end
		else
			self.TouchTable[k] = nil
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end
