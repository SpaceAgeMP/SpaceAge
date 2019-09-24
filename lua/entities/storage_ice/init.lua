AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:CalcVars(self:GetTable().Founder)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Blue Ice",
	"Clear Ice",
	"Glacial Mass",
	"White Glaze",
	"Dark Glitter",
	"Glare Crust",
	"Gelidus",
	"Krystallos",
	"Max Blue Ice",
	"Max Clear Ice",
	"Max Glacial Mass",
	"Max White Glaze",
	"Max Dark Glitter",
	"Max Glare Crust",
	"Max Gelidus",
	"Max Krystallos"})
end

function ENT:CalcVars(ply)
	local reqLvl = SA.Ice.GetLevelForStorageModel(self:GetModel())
	if ((reqLvl == nil) or (ply.icerawmod < reqLvl)) then self:Remove() return end

	local Capacity = math.floor(8*(4.5^reqLvl))*ply.devlimit

	RD.AddResource(self, "Blue Ice", Capacity)
	RD.AddResource(self, "Clear Ice", Capacity)
	RD.AddResource(self, "Glacial Mass", Capacity)
	RD.AddResource(self, "White Glaze", Capacity)
	RD.AddResource(self, "Dark Glitter", Capacity)
	RD.AddResource(self, "Glare Crust", Capacity)
	RD.AddResource(self, "Gelidus", Capacity)
	RD.AddResource(self, "Krystallos", Capacity)
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "mining_laser_base" )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Blue Ice", RD.GetResourceAmount(self, "Blue Ice") )
	Wire_TriggerOutput(self, "Clear Ice", RD.GetResourceAmount(self, "Clear Ice") )
	Wire_TriggerOutput(self, "Glacial Mass", RD.GetResourceAmount(self, "Glacial Mass") )
	Wire_TriggerOutput(self, "White Glaze", RD.GetResourceAmount(self, "White Glaze") )
	Wire_TriggerOutput(self, "Dark Glitter", RD.GetResourceAmount(self, "Dark Glitter") )
	Wire_TriggerOutput(self, "Glare Crust", RD.GetResourceAmount(self, "Glare Crust") )
	Wire_TriggerOutput(self, "Gelidus", RD.GetResourceAmount(self, "Gelidus") )
	Wire_TriggerOutput(self, "Krystallos", RD.GetResourceAmount(self, "Krystallos") )

	Wire_TriggerOutput(self, "Max Blue Ice", RD.GetNetworkCapacity(self, "Blue Ice") )
	Wire_TriggerOutput(self, "Max Clear Ice", RD.GetNetworkCapacity(self, "Clear Ice") )
	Wire_TriggerOutput(self, "Max Glacial Mass", RD.GetNetworkCapacity(self, "Glacial Mass") )
	Wire_TriggerOutput(self, "Max White Glaze", RD.GetNetworkCapacity(self, "White Glaze"))
	Wire_TriggerOutput(self, "Max Dark Glitter", RD.GetNetworkCapacity(self, "Dark Glitter") )
	Wire_TriggerOutput(self, "Max Glare Crust", RD.GetNetworkCapacity(self, "Glare Crust") )
	Wire_TriggerOutput(self, "Max Gelidus",  RD.GetNetworkCapacity(self, "Gelidus") )
	Wire_TriggerOutput(self, "Max Krystallos", RD.GetNetworkCapacity(self, "Krystallos"))
end
