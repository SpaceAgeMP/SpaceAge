include("shared.lua")

language.Add("sa_asteroid_scanner","Mining Scanner")

local mat = Material("trails/laser")

function ENT:Draw()
	self.BaseClass.Draw(self)
	if self:GetNWBool("o") == true then
		self:DrawLaser()
	end
end

local white = Color(255,255,255,255)

function ENT:DrawLaser()
	local up = self:GetAngles():Up()
	local start = self:GetPos() + (up * self:OBBMaxs().z)
	render.SetMaterial( mat )
	render.DrawBeam( start, util.TraceLine({start = start, endpos = start + (up * 3000), filter = { self }}).HitPos, 5, 0, 20, white)
end

function ENT:Think()
	if (CurTime() >= (self.NextUpdate or 0)) then
		self.NextUpdate = CurTime() + 1
		self:SetRenderBounds(self:OBBMins(),self:OBBMaxs() + Vector(0,0,3000))
	end
end
