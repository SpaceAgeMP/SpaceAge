if SERVER then
	AddCSLuaFile()
end

local OldIsValidModel = util.IsValidModel
function util.IsValidModel(path)
	if string.find(path,"/modbridge/misc/doors/",1,true) then return true end
	return OldIsValidModel(path)
end
