include("shared.lua")

language.Add("sa_mining_laser_ii", "Mining Laser")

function ENT:CalcColor(level)
	return Color(255, 0, math.floor(level * 0.85))
end
