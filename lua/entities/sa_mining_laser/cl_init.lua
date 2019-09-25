include("shared.lua")

language.Add("sa_mining_laser", "Mining Laser")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")
local BeamColor = {Color(255,0,0,255),Color(0,255,0,255),Color(0,0,255,255)}

function ENT:Draw()
	self:DrawModel()
	if self:GetNWBool("o") == true then
		self:DrawLaser()
	end
end

function ENT:CalcColor(level)
	return Color(255, 255 - math.floor(level * 0.85), 0)
end

function ENT:DrawLaser()
	local level = self:GetNWInt("level")
	if level ~= self.LastLevel then
		self.LastLevel = level
		self.LaserColor = self:CalcColor(level)
		self.LaserWidth = self.BeamWidthOffset + math.floor(level / 10)
	end
	self:DrawLaserDef(self.LaserColor, self.LaserWidthwidth)
end

function ENT:DrawLaserDef(color, width)
	local width2 = width / 2
	local ang = self:GetAngles()
	local up = ang:Up()
	local right = ang:Right()
	local fow = ang:Forward()
	local start = self:GetPos() + (up * self:OBBMaxs().z)
	local trace = util.TraceLine({start = start, endpos = start + (up * self.BeamLength), filter = { self }})

	local End = trace.HitPos

	render.SetMaterial(mat)
	render.DrawBeam(start, End, width, 0, width * 4, color)

	render.SetMaterial(sprite)
	render.DrawSprite(start, width2, width2, color)

	if (SA.ValidEntity(trace.Entity) and trace.Entity:GetClass() == "sa_roid") then
		render.DrawSprite(End,width2,width2,color)

		local len = start:Distance(End) / 19

		local T = RealTime()

		render.SetMaterial(mat)
		for Beam = 1,3 do
			local b_ang = math.rad(((Beam * 120) + T * 90) % 360)
			render.StartBeam(20)
			for seg = 1,20 do
				local segm = seg-1
				render.AddBeam(start + (up * (len * segm)) + ((math.sin(b_ang) * right + math.cos(b_ang) * fow):Normalize() * (math.sin(math.rad(segm * 9.4736842)) * len / 2)),width2,T,BeamColor[Beam])
			end
			render.EndBeam()
		end
	end
end
