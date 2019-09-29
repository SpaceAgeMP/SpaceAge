local render = render
local team = team
local Color = Color
local LocalPlayer = LocalPlayer
local math = math
local RealTime = RealTime
local FrameTime = FrameTime

local beammat = Material("trails/laser")
local spritemat = Material("effects/blueflare1")
local buildmat = Material("models/props_combine/com_shield001a")

function EFFECT:Init(data)
	local ent = data:GetEntity()
	self:SetModel(ent:GetModel())
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())
	ent.RenderOverride = function() end
	self:SetParent(ent)
	self:SetSkin(ent:GetSkin())
	self.ent = ent
	local dim = self:OBBMaxs() - self:OBBMins()
	self.dimx = dim.x * 1.05
	self.dimy = dim.y * 1.05
	self.dimz = dim.z * 1.05
	self.buildtime = 1
	self.inittime = RealTime()
	self.building = true
	self.buildcolor = team.GetColor((self.ent.CPPIGetOwner and self.ent:CPPIGetOwner() or LocalPlayer()):Team())
	self.shouldremove = false
	self.FadeColor = 1
end

function EFFECT:RenderBuild()
	local col = self.buildcolor
	local front = self:GetForward() * (self.dimx / 2)
	local center = self:LocalToWorld(self:OBBCenter())
	local top = self:GetUp()
	local offset = top * (self.dimz * (math.min((RealTime() - self.inittime) / self.buildtime, 1) - 0.5))
	render.EnableClipping(true)
	render.MaterialOverride(buildmat)
	render.PushCustomClipPlane(-top, -top:Dot(center - offset))
		self:DrawModel()
	render.PopCustomClipPlane()
	render.MaterialOverride(nil)
	render.PushCustomClipPlane(top, top:Dot(center - offset))
		self:DrawModel()
	render.PopCustomClipPlane()
	render.EnableClipping(false)
	top = top * (self.dimz / 2)
	local right = self:GetRight() * (self.dimy / 2)

	local BLB = (center - front - right - top)
	local BLT = (center - front- offset - right)
	local BRB = (center - front + right - top)
	local BRT = (center - front - offset + right)
	local FLB = (center + front - right - top)
	local FLT = (center - offset + front - right)
	local FRB = (center + front + right - top)
	local FRT = (center - offset + front + right)

	render.SetMaterial(buildmat)
	render.DrawQuad(BRT, BLT, FLT, FRT)

	render.SetMaterial(beammat)
	local width = 10
	render.DrawBeam(FLT, FRT, width, 0, 0, col)
	render.DrawBeam(FRT, BRT, width, 0, 0, col)
	render.DrawBeam(BRT, BLT, width, 0, 0, col)
	render.DrawBeam(BLT, FLT, width, 0, 0, col)

	render.DrawBeam(FLT, FLB, width, 0, 0, col)
	render.DrawBeam(FRT, FRB, width, 0, 0, col)
	render.DrawBeam(BRT, BRB, width, 0, 0, col)
	render.DrawBeam(BLT, BLB, width, 0, 0, col)

	render.DrawBeam(FLB, FRB, width, 0, 0, col)
	render.DrawBeam(FRB, BRB, width, 0, 0, col)
	render.DrawBeam(BRB, BLB, width, 0, 0, col)
	render.DrawBeam(BLB, FLB, width, 0, 0, col)

	render.SetMaterial(spritemat)
	local sin = ((math.sin(RealTime() * 4) + 1) + 0.2) * 16
	render.DrawSprite(FRT, sin, sin, col)
	render.DrawSprite(BLB, sin, sin, col)
	render.DrawSprite(FLT, sin, sin, col)
	render.DrawSprite(BRT, sin, sin, col)
	render.DrawSprite(BLT, sin, sin, col)
	render.DrawSprite(FRB, sin, sin, col)
	render.DrawSprite(FLB, sin, sin, col)
	render.DrawSprite(BRB, sin, sin, col)
end

function EFFECT:Think()
	if (not IsValid(self.ent)) then
		return false
	end
	return not self.shouldremove
end

function EFFECT:Render()
	if (self.building) then
		if ((self.inittime + self.buildtime) <= RealTime()) then
			self.building = false
			self:RenderBuildEnd()
		else
			self:RenderBuild()
		end
	else
		self:RenderBuildEnd()
	end
end

function EFFECT:RenderBuildEnd()
	self:DrawModel()
	local col = self.buildcolor
	col.r = col.r * self.FadeColor
	col.g = col.g * self.FadeColor
	col.b = col.b * self.FadeColor
	local center = self:LocalToWorld(self:OBBCenter())
	local front = self:GetForward() * (self.dimx / 2)
	local right = self:GetRight() * (self.dimy / 2)
	local top = self:GetUp() * (self.dimz / 2)
	local FRT = (center + front + right + top)
	local BLB = (center - front - right - top)
	local FLT = (center + front - right + top)
	local BRT = (center - front + right + top)
	local BLT = (center - front - right + top)
	local FRB = (center + front + right - top)
	local FLB = (center + front - right - top)
	local BRB = (center - front + right - top)

	render.SetMaterial(beammat)
	render.DrawBeam(FLT, FRT, 5, 0, 0, col)
	render.DrawBeam(FRT, BRT, 5, 0, 0, col)
	render.DrawBeam(BRT, BLT, 5, 0, 0, col)
	render.DrawBeam(BLT, FLT, 5, 0, 0, col)

	render.DrawBeam(FLT, FLB, 5, 0, 0, col)
	render.DrawBeam(FRT, FRB, 5, 0, 0, col)
	render.DrawBeam(BRT, BRB, 5, 0, 0, col)
	render.DrawBeam(BLT, BLB, 5, 0, 0, col)

	render.DrawBeam(FLB, FRB, 5, 0, 0, col)
	render.DrawBeam(FRB, BRB, 5, 0, 0, col)
	render.DrawBeam(BRB, BLB, 5, 0, 0, col)
	render.DrawBeam(BLB, FLB, 5, 0, 0, col)

	render.SetMaterial(spritemat)
	render.DrawSprite(FRT, 18, 18, col)
	render.DrawSprite(BLB, 18, 18, col)
	render.DrawSprite(FLT, 18, 18, col)
	render.DrawSprite(BRT, 18, 18, col)
	render.DrawSprite(BLT, 18, 18, col)
	render.DrawSprite(FRB, 18, 18, col)
	render.DrawSprite(FLB, 18, 18, col)
	render.DrawSprite(BRB, 18, 18, col)

	self.FadeColor = self.FadeColor - FrameTime() / 20
	if (self.FadeColor <= 0) then
		self.ent.RenderOverride = nil
		self.ent:SetColor(Color(255, 255, 255, 255))
		self.shouldremove = true
	end
end
