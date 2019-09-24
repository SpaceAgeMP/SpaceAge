AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	if not self.SwitchPeriod then self.SwitchPeriod = 5 end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Think()
	local skins = self:SkinCount()
	if skins > 1 then
		local currentskin = self:GetSkin()
		local newskin = 0
		if (currentskin + 1) >= skins then
			newskin = currentskin + 1 - skins
		else
			newskin = currentskin + 1
		end
		self:SetSkin(newskin)
	end
	self:NextThink(CurTime() + self.SwitchPeriod)
	return true
end
