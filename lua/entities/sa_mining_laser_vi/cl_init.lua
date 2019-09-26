include("shared.lua")

language.Add("sa_mining_laser_vi", "Mining Laser")

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.color = Color(255, 255, 255, 255)
	self.colord = Color(math.random(-1, -0.5), math.random(-1, -0.5), math.random(-1, -0.5), 1)
	self.length = 3000
	self.width = 1
end

function ENT:Think()
	self.BaseClass.Think(self)

	self.color.r = (math.random(1, 7) * self.colord.r) + self.color.r
	if self.color.r >= 255 then
		self.color.r = 255
		self.colord.r = math.random(-1, -0.5)
	elseif self.color.r <= 0 then
		self.color.r = 0
		self.colord.r = math.random(0.5, 1)
	end
	self.color.g = (math.random(1, 7) * self.colord.g) + self.color.g
	if self.color.g >= 255 then
		self.color.g = 255
		self.colord.g = math.random(-1, -0.5)
	elseif self.color.g <= 0 then
		self.color.g = 0
		self.colord.g = math.random(0.5, 1)
	end
	self.color.b = (math.random(1, 7) * self.colord.b) + self.color.b
	if self.color.b >= 255 then
		self.color.b = 255
		self.colord.b = math.random(-1, -0.5)
	elseif self.color.b <= 0 then
		self.color.b = 0
		self.colord.b = math.random(0.5, 1)
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:DrawLaser()
	self:DrawLaserDef(self.color, self.width)
end
