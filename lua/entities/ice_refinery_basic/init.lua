AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

local IceTypes = {
	"Blue Ice",
	"Clear Ice",
	"Glacial Mass",
	"White Glaze",
	"Dark Glitter",
	"Glare Crust",
	"Gelidus",
	"Krystallos"
	}

local GiveTranslate = {
	coolant = "coolant",
	heavywater = "heavy water",
	water = "water",
	oxygen = "Oxygen Isotopes",
	hydrogen = "Hydrogen Isotopes",
	helium = "Helium Isotopes",
	nitrogen = "Nitrogen Isotopes",
	ozone = "Liquid Ozone",
	strontium = "Strontium Clathrates"
	}	


function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS ) 	
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS ) 
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end
	
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "coolant", 0)
	RD_AddResource(self, "water", 0)
	RD_AddResource(self, "heavy water", 0)
	
	for _,Type in pairs(IceTypes) do
		RD_AddResource(self, Type, 0)
	end
	
	RD_AddResource(self, "Oxygen Isotopes", 0)
	RD_AddResource(self, "Hydrogen Isotopes", 0)
	RD_AddResource(self, "Helium Isotopes", 0)
	RD_AddResource(self, "Nitrogen Isotopes", 0)
	RD_AddResource(self, "Liquid Ozone", 0)
	RD_AddResource(self, "Strontium Clathrates", 0)
	
	self:SetOverlayText(self.PrintName.."\n".."Progress: 0%")
	
	self.Inputs = Wire_CreateInputs( self, { "Activate" } ) 
	self.Outputs = Wire_CreateOutputs( self, { "Active", "Progress" } )
	
	self.ShouldRefine = false;
	self.CurrentRef = nil;
	self.Volume = 0;
	self.NextCycle = 0;
	
	timer.Simple(0.1,function() self:CalcVars(self:GetTable().Founder) end)
end

function ENT:CalcVars(ply)
end

function ENT:Refine()

	local CurEnergy = RD_GetResourceAmount(self, "energy")
	local EnergyReq = self.CycleEnergy/self.CycleTime
	
	if (CurEnergy > EnergyReq) then
		if not (self.CurrentRef) then
			for _,Type in pairs(IceTypes) do
				local Avail = RD_GetResourceAmount(self, Type)
				if (Avail > 0) then
					self.CurrentRef = Type
					self.Volume = 1000
					RD_ConsumeResource(self, Type, 1)
					Wire_TriggerOutput(self,"Active",1)
					break
				end
			end
		end
		if (self.CurrentRef) then
			RD_ConsumeResource(self, "energy", EnergyReq)
			
			local RefSpeed = (self.CycleVol / self.CycleTime) * 1000
			self.Volume = self.Volume - RefSpeed
			local Progress = math.Clamp((1000-self.Volume)/10,0,100)
			Wire_TriggerOutput(self,"Progress",Progress)
			self:SetOverlayText(self.PrintName.."\nProgress: "..tostring(Progress).."%")
			if (self.Volume <= 0) then
				local Gives = AM_GetRefined(self.CurrentRef, self.RefineEfficiency)
				for Res,Count in pairs(Gives) do
					RD_SupplyResource(self, GiveTranslate[Res], Count)
				end
				self.CurrentRef = nil
				Wire_TriggerOutput(self,"Active",0)
				Wire_TriggerOutput(self,"Progress",0)
				self:SetOverlayText(self.PrintName.."\nProgress: 0%")
			end
		end
	end
end

function ENT:Think()
	//self.BaseClass.Think(self)
	if (self.ShouldRefine and self.NextCycle < CurTime()) then
		self:Refine()	
		self.NextCycle = CurTime() + 1
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.ShouldRefine = true		
		else
			self.ShouldRefine = false
			Wire_TriggerOutput(self,"Active",0)			
			Wire_TriggerOutput(self,"Progress",0)
			self:SetOverlayText(self.PrintName.."\nProgress: 0%")
		end
	end
end

function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self)
	local DupeInfo = self:BuildDupeInfo()
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		self.Owner = Player	
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end