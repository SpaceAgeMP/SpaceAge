include("shared.lua")
language.Add("sa_crystalroid","Tiberium Asteroid")
function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:DrawModel()
end
