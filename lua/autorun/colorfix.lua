if SERVER then
	AddCSLuaFile("colorfix.lua");
end
function Color(r, g, b, a)
	if(!a) then a = 255 end
	return {r=r,g=g,b=b,a=a}
end