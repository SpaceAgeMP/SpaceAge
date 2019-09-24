local rDrawBeam = render.DrawBeam;
local rDrawSprite = render.DrawSprite;
local beammat = Material("sprites/bluelaser1");
local spritemat = Material("effects/blueflare1");
local buildmat = Material("models/props_combine/com_shield001a");

function EFFECT:Init(data)
	local ent = data:GetEntity();
	self:SetModel(ent:GetModel());
	self:SetPos(ent:GetPos());
	self:SetAngles(ent:GetAngles());
	ent:SetColor(Color(255,255,255,0))
	self:SetParent(ent);
	self:SetSkin(ent:GetSkin())
	self.ent = ent;
	local dim = self:OBBMaxs() - self:OBBMins();
	self.dimx = dim.x;
	self.dimy = dim.y * 1.05;
	self.dimz = dim.z * 1.05;
	self.buildtime = 2;
	self.inittime = RealTime();
	self.building = true;
	self.buildcolor = Color(255,255,255,255);
	self.shouldremove = false;
	self.FadeColor = 1;
end

function EFFECT:RenderBuild()
	local col = self.buildcolor;
	local front = self:GetForward();
	local center = self:LocalToWorld(self:OBBCenter());
	local offset = front * self.dimx * (math.min((RealTime() - self.inittime) / self.buildtime, 1) - 0.5)
	SetMaterialOverride(buildmat);
	render.EnableClipping(true);
	render.PushCustomClipPlane(-front,-front:Dot(center - offset));
		self:DrawModel();
	render.PopCustomClipPlane();
	SetMaterialOverride(nil);
	render.PushCustomClipPlane(front,front:Dot(center - offset));
		self:DrawModel()
	render.PopCustomClipPlane();
	render.EnableClipping(false);
	front = front * (self.dimx / 2);
	local right = self:GetRight() * (self.dimy / 2);
	local top = self:GetUp() * (self.dimz / 2);

	local FRT = (center + front + right + top);
	local BLB = (center - offset - right - top);
	local FLT = (center + front - right + top);
	local BRT = (center - offset + right + top);
	local BLT = (center - offset - right + top);
	local FRB = (center + front + right - top);
	local FLB = (center + front - right - top);
	local BRB = (center - offset + right - top);

	render.SetMaterial(buildmat);
	render.DrawQuad(BLT,BRT,BRB,BLB);

	render.SetMaterial(beammat);
	rDrawBeam(FLT, FRT, 5, 0, 0, col);
	rDrawBeam(FRT, BRT, 5, 0, 0, col);
	rDrawBeam(BRT, BLT, 5, 0, 0, col);
	rDrawBeam(BLT, FLT, 5, 0, 0, col);

	rDrawBeam(FLT, FLB, 5, 0, 0, col);
	rDrawBeam(FRT, FRB, 5, 0, 0, col);
	rDrawBeam(BRT, BRB, 5, 0, 0, col);
	rDrawBeam(BLT, BLB, 5, 0, 0, col);

	rDrawBeam(FLB, FRB, 5, 0, 0, col);
	rDrawBeam(FRB, BRB, 5, 0, 0, col);
	rDrawBeam(BRB, BLB, 5, 0, 0, col);
	rDrawBeam(BLB, FLB, 5, 0, 0, col);

	render.SetMaterial(spritemat);
	local sin = ((math.sin(RealTime() * 4) + 1) + 0.2) * 16;
	rDrawSprite(FRT,sin,sin,col);
	rDrawSprite(BLB,sin,sin,col);
	rDrawSprite(FLT,sin,sin,col);
	rDrawSprite(BRT,sin,sin,col);
	rDrawSprite(BLT,sin,sin,col);
	rDrawSprite(FRB,sin,sin,col);
	rDrawSprite(FLB,sin,sin,col);
	rDrawSprite(BRB,sin,sin,col);
end

function EFFECT:Think()
	if (not SA.ValidEntity(self.ent)) then
		return false;
	end
	return not self.shouldremove;
end

function EFFECT:Render()
	if (self.building) then
		if ((self.inittime + self.buildtime) <= RealTime()) then
			self.building = false;
			self:RenderBuildEnd();
		else
			self:RenderBuild();
		end
	else
		self:RenderBuildEnd();
	end
end

function EFFECT:RenderBuildEnd()
	self:DrawModel();
	local col = self.buildcolor;
	col.r = col.r * self.FadeColor;
	col.g = col.g * self.FadeColor;
	col.b = col.b * self.FadeColor;
	local center = self:LocalToWorld(self:OBBCenter());
	local front = self:GetForward() * (self.dimx / 2);
	local right = self:GetRight() * (self.dimy / 2);
	local top = self:GetUp() * (self.dimz / 2);
	local FRT = (center + front + right + top);
	local BLB = (center - front - right - top);
	local FLT = (center + front - right + top);
	local BRT = (center - front + right + top);
	local BLT = (center - front - right + top);
	local FRB = (center + front + right - top);
	local FLB = (center + front - right - top);
	local BRB = (center - front + right - top);
	render.SetMaterial(beammat)
	rDrawBeam(FLT, FRT, 5, 0, 0, col);
	rDrawBeam(FRT, BRT, 5, 0, 0, col);
	rDrawBeam(BRT, BLT, 5, 0, 0, col);
	rDrawBeam(BLT, FLT, 5, 0, 0, col);

	rDrawBeam(FLT, FLB, 5, 0, 0, col);
	rDrawBeam(FRT, FRB, 5, 0, 0, col);
	rDrawBeam(BRT, BRB, 5, 0, 0, col);
	rDrawBeam(BLT, BLB, 5, 0, 0, col);

	rDrawBeam(FLB, FRB, 5, 0, 0, col);
	rDrawBeam(FRB, BRB, 5, 0, 0, col);
	rDrawBeam(BRB, BLB, 5, 0, 0, col);
	rDrawBeam(BLB, FLB, 5, 0, 0, col);

	render.SetMaterial(spritemat);
	rDrawSprite(FRT,18,18,col);
	rDrawSprite(BLB,18,18,col);
	rDrawSprite(FLT,18,18,col);
	rDrawSprite(BRT,18,18,col);
	rDrawSprite(BLT,18,18,col);
	rDrawSprite(FRB,18,18,col);
	rDrawSprite(FLB,18,18,col);
	rDrawSprite(BRB,18,18,col);

	self.FadeColor = self.FadeColor - 0.01;
	if (self.FadeColor <= 0) then
		self.ent:SetColor(Color(255,255,255,255))
		self.shouldremove = true;
	end
end
