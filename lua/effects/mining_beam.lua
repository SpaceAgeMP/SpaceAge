local bGlow1 = Material("sprites/orangecore2")
bGlow1:SetInt("$spriterendermode", 9)
bGlow1:SetInt("$ignorez", 1)
bGlow1:SetInt("$illumfactor", 8)
local bGlow2 = Material("effects/orangeflare1")
bGlow2:SetInt("$spriterendermode", 9)
bGlow2:SetInt("$ignorez", 1)
bGlow2:SetInt("$illumfactor", 8)

local lGlow1 = Material("sprites/physbeam")
lGlow1:SetInt("$spriterendermode", 9)
lGlow1:SetInt("$ignorez", 1)
lGlow1:SetInt("$illumfactor", 8)
local lGlow2 = Material("sprites/orangelight1")
lGlow2:SetInt("$spriterendermode", 9)
lGlow2:SetInt("$ignorez", 1)
lGlow2:SetInt("$illumfactor", 8)

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Multi = data:GetMagnitude()
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local rt = RealTime() * 2
	render.SetMaterial(lGlow1)
	render.DrawBeam(self.StartPos, self.EndPos, 32, rt, rt + 0.001 * self.Multi, color_white)

	render.SetMaterial(lGlow2)
	render.DrawBeam(self.StartPos, self.EndPos, 32, rt, rt + 0.002 * self.Multi, color_white)

	render.SetMaterial(bGlow1)
	render.DrawSprite(self.EndPos, 64, 64, color_white)

	render.SetMaterial(bGlow2)
	render.DrawSprite(self.StartPos, 64, 64, color_white)
end
