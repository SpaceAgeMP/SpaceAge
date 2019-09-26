include("shared.lua")

language.Add("sa_mining_laser_iv", "Mining Laser")

function ENT:CalcColor(level)
	return Color(0, math.floor(level * 0.85), 255)
end
