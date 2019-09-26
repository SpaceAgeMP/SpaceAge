include("shared.lua")

language.Add("sa_mining_laser_iii", "Mining Laser")

function ENT:CalcColor(level)
	return Color(255 - math.floor(level * 0.85), 0, 255)
end
