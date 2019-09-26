if SERVER then
	AddCSLuaFile()
end

function SA.AddCommasToInt(str)
	str = string.reverse(tostring(str)) -- Make sure this is a string!

	local len = str:len() - 1
	local ret = ""
	for i = 1, len do
		ret = ret .. str:sub(i, i)
		if i % 3 == 0 then
			ret = ret .. ", "
		end
	end
	len = len + 1
	ret = ret .. str:sub(len , len)
	return string.reverse(ret)
end

function SA.GetPlayerByName(name)
	return nil
end

function SA.FormatTime(time)
	return tostring(time)
end

function SA.ValidEntity(ent)
	return ent and ent:IsValid()
end
