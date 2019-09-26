AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local ForceShowDoorCs = false

function ENT:SpawnFunction(ply, tr)
	if (ForceShowDoorCs == false or not tr.Hit) then return end
	local SpawnPos = tr.HitPos + Vector(0, 0, 100)
	local ent = ents.Create("sa_doorchecker")
	ent:SetModel("models/props/cs_assault/Billboard.mdl")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.isopen = 0
	self.fullyopen = 0
	self.fullyclosed = 0
	self.blocked = 0
	self.animov = 0
	self.LastFCD = not ForceShowDoorCs

	local xuuid = "sa_dchecker_" .. tostring(CurTime())

	self:Fire("addoutput", "targetname " .. xuuid, 0)


	self:Think()

	local entitT = ents.FindByName("Silo_L")
	if (#entitT <= 0) then
		self:Remove()
		return
	end
	local entit = entitT[1]


	entit:Fire("addoutput", "OnAnimationBegun " .. xuuid .. ", xtabegun", 0)
	entit:Fire("addoutput", "OnAnimationDone " .. xuuid .. ", xtadone", 0)
	entit:Fire("addoutput", "OnOpen " .. xuuid .. ", xtopen", 0)
	entit:Fire("addoutput", "OnClose " .. xuuid .. ", xtclose", 0)
	entit:Fire("addoutput", "OnBlockedOpening " .. xuuid .. ", xtbopen", 0)
	entit:Fire("addoutput", "OnBlockedClosing " .. xuuid .. ", xtbclose", 0)
	entit:Fire("addoutput", "OnUnblockedOpening " .. xuuid .. ", xtubopen", 0)
	entit:Fire("addoutput", "OnUnblockedClosing " .. xuuid .. ", xtubclose", 0)
	entit:Fire("addoutput", "OnFullyOpen " .. xuuid .. ", xtfopen", 0)
	entit:Fire("addoutput", "OnFullyClosed " .. xuuid .. ", xtfclose", 0)

	self.xent = entit

	self:SetFully(0, true)
	self:SetBlocked(0)

	self.xswitch = switch {
		xtopen = function(x) self:SetOpen(1) end,
		xtclose = function(x) self:SetOpen(0) end,
		xtbopen = function(x) self:SetOpen(0) self:SetBlocked(1) end,
		xtbclose = function(x) self:SetOpen(1) self:SetBlocked(1) end,
		xtubopen = function(x) self:SetOpen(1) self:SetBlocked(0) end,
		xtubclose = function(x) self:SetOpen(0) self:SetBlocked(0) end,
		xtfopen = function(x) self:SetFully(1) end,
		xtfclose = function(x) self:SetFully(0) end,
		xtabegun = function(x) if (self.animov <= 0) then self:SetOpen(1 - self.isopen) else self.animov = (self.animov - 1) end end,
		xtadone = function(x) self:SetFully(self.isopen) end,
	}
end

function ENT:Think()
	if (self.LastFCD == ForceShowDoorCs) then return end
	self.LastFCD = ForceShowDoorCs
	if (ForceShowDoorCs == true) then
		self:SetNotSolid(false)
		self:DrawShadow(true)
		self:SetNoDraw(false)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	else
		self:PhysicsInit(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:SetNoDraw(true)
	end
	timer.Create("SA_KeepUpAtmosphere", 60, 1, function() self:RefreshAtmo() end)
end

function ENT:AcceptInput(name, activator, caller)
	self.xswitch:case(name)
end

function ENT:closeself()
	if (self.isopen == 1) then
		self.animov = self.animov + 1
		self:SetOpen(0)
		self.xent:Fire("close")
	end
end

function ENT:openself()
	if (self.isopen == 0) then
		self.animov = self.animov + 1
		self.xent:Fire("open")
		self:SetOpen(1)
	end
end

function ENT:SetOpen(val, norefresh)
	self.fullyopen = 0
	self.fullyclosed = 0
	if (val == self.isopen) then return end
	if (val == 1) then
		self.isopen = 1
	elseif (val == 0) then
		self.isopen = 0
	else
		return
	end
	if (not norefresh) then self:RefreshAtmo() end
end

function ENT:SetFully(val, norefresh)
	if val == 0 then
		self:SetOpen(0, true)
		self.fullyclosed = 1
	elseif val == 1 then
		self:SetOpen(1, true)
		self.fullyopen = 1
	else
		return
	end

	self:SetBlocked(0)

	if (not norefresh) then self:RefreshAtmo() end
end

function ENT:SetBlocked(val)
	if val == self.blocked then return end
	if val == 0 then
		self.blocked = 0
	elseif val == 1 then
		self.blocked = 1
	else
		return
	end
end

function ENT:RefreshAtmo()
	local env = self.environment
	if not env then return end
	if self.isopen ~= 0 then
		SA.Planets.MakeSpace(env)
	elseif self.fullyclosed ~= 0 then
		SA.Planets.MakeHabitable(env)
	end
end
