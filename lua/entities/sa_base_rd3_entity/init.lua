AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CAF_PostInit()
	self:InitializeRankedVars()

	local ply = self:GetTable().Founder
	if self.ForcedModel and self:GetModel():lower() ~= self.ForcedModel:lower() then
		self:Remove()
		ply:AddHint("Tried to spawn entity with invalid model (got \"" .. self:GetModel() .. "\", required \""  .. self.ForcedModel .. "\")!", NOTIFY_ERROR, 5)
		return
	end

	if self.RequireFaction and ply.sa_data.faction_name ~= self.RequireFaction then
		local faction = SA.Factions.GetByName(self.RequireFaction)
		self:Remove()
		ply:AddHint("You must be a member of " .. faction.display_name .. " to spawn this entity!", NOTIFY_ERROR, 5)
		return
	end
	self:CalcVars(ply)
end

function ENT:CalcVars(ply)
	-- Do nothing here, subclasses override it
end
