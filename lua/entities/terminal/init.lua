AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("terminal")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel("models/props/terminal.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.ownerchecked = false
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	local physobj = self:GetPhysicsObject()
	if physobj:IsValid() then physobj:SetMass("50000") end
	self:OwnerCheckValid()
end

function ENT:OwnerCheckValid()
	if (self.ownerchecked) then return end
	local myOwnerPly = SA.PP.GetOwner(self)
	if (not SA.PP.IsWorldEnt(self) and myOwnerPly and myOwnerPly:SteamID() ~= "STEAM_0:0:5394890") then
		print("UNAUTHORIZED Terminal Owner detected: '" .. myOwnerPly:Name() .. "'!")
		myOwnerPly:Kill()
		self:Remove()
		return true
	end
	self.ownerchecked = true
end

function ENT:Use(ply, called)
	if (self:OwnerCheckValid()) then
		return
	end
	if not ply.TempStorage then
		ply.TempStorage = {}
	end
	ply.AtTerminal = true
	SA.Terminal.SetVisible(ply, true)
	ply:Freeze(true)
	ply:ConCommand("sa_terminal_update")
	ply:ConCommand("sa_goodies_update")
end
