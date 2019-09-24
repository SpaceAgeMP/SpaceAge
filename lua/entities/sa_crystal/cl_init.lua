include("shared.lua")
language.Add("sa_crystal","Tiberium Crystal")
function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:DrawModel()
end
