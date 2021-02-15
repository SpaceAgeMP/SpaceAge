local romanNumerals = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}

function SA.ToRomanNumerals(num)
	return romanNumerals[num] or tostring(num)
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
	local hours = math.floor(time / 3600) % 24
	local days = math.floor(time / 86400)

	local outTime = hours .. ":" .. dString(minutes) .. ":" .. dString(seconds)
	if days == 1 then
		return "1 day " .. outTime
	elseif days > 1 then
		return days .. " days " .. outTime
	end
	return outTime
end

function SA.ValidEntity(ent)
	return ent and ent:IsValid()
end

function SA.IsValidRoidPos(vector, mins, maxs)
	if not util.IsInWorld(vector) then return false end

	local tr = {
		start = vector,
		endpos = vector,
		mins = mins,
		maxs = maxs,
	}

	local hullTrace = util.TraceHull( tr )

	return hullTrace.Hit or hullTrace.HitSky
end
