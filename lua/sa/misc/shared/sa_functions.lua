if SERVER then
	AddCSLuaFile()
end

function SA.AddCommasToInt(str)
	str = tostring(str)

	local expl = string.Explode(".", str)
	local numstr = expl[1]
	local decimalstr = expl[2]

	numstr = string.reverse(numstr)

	local len = numstr:len() - 1
	local ret = ""
	for i = 1, len do
		ret = ret .. numstr:sub(i, i)
		if i % 3 == 0 then
			ret = ret .. ","
		end
	end
	len = len + 1
	ret = ret .. numstr:sub(len , len)

	if (decimalstr) then
		return string.reverse(ret) .. "." .. decimalstr
	else
		return string.reverse(ret)
	end
end

function SA.GetPlayerByName(name)
	return nil
end

local function dString(num)
	if num < 10 then
		return "0" .. tostring(num)
	end
	return tostring(num)
end

function SA.FormatTime(time)
	local seconds = time % 60
	local minutes = math.floor(time / 60) % 60
	local hours = math.floor(time / 3600)
	return hours .. ":" .. dString(minutes) .. ":" .. dString(seconds)
end

function SA.ValidEntity(ent)
	return ent and ent:IsValid()
end

function SA.IsInsideMap(vector)
	return util.IsInWorld(vector)
end
