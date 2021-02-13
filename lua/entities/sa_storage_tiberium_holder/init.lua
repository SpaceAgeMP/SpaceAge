AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
local RD = CAF.GetAddon("Resource Distribution")
local LS = CAF.GetAddon("Life Support")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
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
		BaseClass.SetActive(self, value)
	end
end

function ENT:StartTouch(ent)
	if (not ent.IsTiberiumStorage) then return end
	local eOwner = self:CPPIGetOwner()
	if not (eOwner and eOwner:IsValid() and eOwner:IsPlayer()) then return end
	if self.Active == 1 then
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
	BaseClass.Repair(self)
	self:SetColor(color_white)
end

function ENT:Destruct()
	LS.Destruct(self, true)
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Tiberium", "tiberium")
end
