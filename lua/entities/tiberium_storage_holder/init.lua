AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
local RD = CAF.GetAddon("Resource Distribution")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("tiberium_storage_holder")
	ent:SetPos(tr.HitPos + Vector(0, 0, 0))
	ent:Spawn()
	ent:Activate()
	self.TouchTable = {}
	return ent
end

function ENT:Initialize()
	self:SetModel("models/slyfo/sat_rtankstand.mdl")
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.TouchTable = {}
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, {"On", "Tiberium", "Max Tiberium" })
	else
		self.Inputs = {{ Name = "On" }}
	end
	RD.RegisterNonStorageDevice(self)
end

function ENT:TurnOn()
	if (self.Active == 1) then
		return
	end
	self.Active = 1
	if WireAddon ~= nil then
		Wire_TriggerOutput(self, "On", self.Active)
	end
	self:SetOOO(1)
end

function ENT:TurnOff()
	if (self.Active == 0) then
		return
	end
	self.Active = 0
	if WireAddon ~= nil then
		Wire_TriggerOutput(self, "On", self.Active)
	end
	self:SetOOO(0)
	for k, v in pairs(self.TouchTable) do
		self:ReleaseStorage(v)
	end
	self.TouchTable = {}
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self.BaseClass.SetActive(self, value)
	end
end

function ENT:StartTouch(ent)
	if (not ent.IsTiberiumStorage) then return end
	local eOwner = SA.PP.GetOwner(ent)
	if not (eOwner and eOwner:IsValid() and eOwner:IsPlayer()) then return end
	if self.Active == 1 and SA.PP.PlyCanPerform(eOwner, self) then
		local attachPlace = SA.Tiberium.FindFreeAttachPlace(ent, self)
		if not attachPlace then return end
		if not SA.Tiberium.AttachStorage(ent, self, attachPlace) then return end
		self.TouchTable[attachPlace] = ent
		ent.TouchPos = attachPlace
		constraint.RemoveAll(ent)
		constraint.Weld(ent, self, 0, 0, false)
		local tmp = RD.GetEntityTable(self)
		if not tmp then return end
		local tmpNet = tmp.network
		if (not tmpNet) or tmpNet == 0 then return end
		RD.Link(ent, tmpNet)
	end
end
function ENT:EndTouch(ent)
	--self:ReleaseStorage(ent)
end

function ENT:ReleaseStorage(ent)
	if table.HasValue(self.TouchTable, ent) and ent.TouchPos then
		self.TouchTable[ent.TouchPos] = nil
		ent.TouchPos = nil
		SA.Tiberium.DestroyConstraints(ent, self, 0, 0, "weld")
		SA.Tiberium.DestroyConstraints(ent, self, 0, 0, "Weld")
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
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
