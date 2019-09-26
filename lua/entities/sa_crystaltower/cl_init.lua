include("shared.lua")
language.Add("sa_crystaltower", "Tiberium Crystal")
function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:DrawModel()
end
