include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Think()
	local mining = self:GetNWBool("m")
	local entindex = self:GetNWEntity("r")
	local ent = nil
	if entindex then
		ent =  ents.GetByIndex( entindex )
	end
	if mining == true and ent:IsValid() then
		local startpos = self:GetPos() + self:GetUp() * 24
		local endpos = ent:NearestPoint(self:GetPos())
		local effectdata = EffectData()
		effectdata:SetOrigin(endpos)
		effectdata:SetStart(startpos)
		effectdata:SetMagnitude((endpos - startpos):Length())
		util.Effect( "mining_beam", effectdata )
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DoNormalDraw()
	self:DrawModel()
end

function ENT:DrawEntityOutline( size )
end
