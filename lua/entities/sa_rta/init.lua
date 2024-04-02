AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
util.PrecacheSound("tools/ifm/beep.wav")

local function ClampLevelByFaction(ply)
	if not IsValid(ply) then
		return 0
	end
	local level = ply.sa_data.research.rta[1]
	if ply.sa_data.faction_name == "corporation" then
		return level
	end
	if level > 1 then
		level = 1
	end
	return level
end

local function OpenTerminal(ent, ply, founder)
	if CurTime() < ent.NextUse then return end
	ent.NextUse = CurTime() + 1
	if ent:GetPos():Distance(SA.Terminal.GetStationPos()) > SA.Terminal.GetStationSize() and ClampLevelByFaction(founder) <= 1 then
		ent:EmitSound("tools/ifm/beep.wav")
		ply:AddHint("RTA device out of range of station.", NOTIFY_CLEANUP, 5)
		return
	end
	if ply:GetPos():Distance(ent:GetPos()) > 1000 then ent:EmitSound("tools/ifm/beep.wav") ply:AddHint("Too far away from RTA device.", NOTIFY_CLEANUP, 5) return end
	SA.Terminal.Open(ply, ent)
end

function ENT:Initialize()
	self:SetModel("models/slyfo/rover_na_large.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.Inputs = Wire_CreateInputs(self, { "OpenTerminal" })
	self.NextUse = 0
end

function ENT:CAF_PostInit()
	self:CheckCanSpawn(self:GetTable().Founder)
end

function ENT:CheckCanSpawn(ply)
	if (ply.sa_data.research.rta[1] < 1) then
		SA.Research.RemoveEntityWithWarning(self, "rta", 1)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "OpenTerminal") and value ~= 0 then
		local ply = self:GetTable().Founder
		OpenTerminal(self, ply, ply)
	end
end

function ENT:Use(ply, called)
	OpenTerminal(self, ply, self:GetTable().Founder)
end
