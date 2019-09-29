local function findUpvalue(func, name)
	for i = 1, 50 do
			local _name, val = debug.getupvalue(func, i)
			if _name == name then
					return val
			end
	end
end

local function fixE2Finder()
	if not wire_expression_callbacks then
		return false
	end

	local construct_callbacks = wire_expression_callbacks.construct
	if not construct_callbacks then
		return false
	end

	local filter_default
	for _, func in pairs(construct_callbacks) do
			filter_default = findUpvalue(func, "filter_default")
			if filter_default then
					break
			end
	end

	if not filter_default then
		return false
	end

	local forbidden_classes = findUpvalue(filter_default, "forbidden_classes")
	if not forbidden_classes then
		return false
	end

	forbidden_classes["iceroid"] = true
	--forbidden_classes["sa_crystal"] = true
	--forbidden_classes["sa_crystalroid"] = true
	--forbidden_classes["sa_crystaltower"] = true
	return true
end

timer.Create("SA_Fix_E2_Finder", 1, 0, function()
	if fixE2Finder() then
		timer.Remove("SA_Fix_E2_Finder")
	end
end)
