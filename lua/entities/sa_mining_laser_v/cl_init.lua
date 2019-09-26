include("shared.lua")

language.Add("sa_mining_laser_v", "Mining Laser")

function ENT:CalcColor(level)
	return Color(0, 255, 255 - math.floor(level * 0.85))
end
