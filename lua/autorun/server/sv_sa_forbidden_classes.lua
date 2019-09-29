-- Find upvalue of function by name
local function findUpvalue(func, name)
	for i = 1, 50 do
			local _name, val = debug.getupvalue(func, i)
			if not _name then
				return
			end
			if _name == name then
					return val
			end
	end
end

SA.OldE2RegisterCallback = SA.OldE2RegisterCallback or registerCallback

-- Overwrite forbidden_classes list of E2 find module to be able to prevent certain classes from being seen
-- https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/find.lua#L16
local function fixE2FinderCB(func)
	local filter_default = findUpvalue(func, "filter_default")
	if not filter_default then
		return false
	end

	local forbidden_classes = findUpvalue(filter_default, "forbidden_classes")
	if not forbidden_classes then
		return false
	end

	if forbidden_classes.iceroid then
		return true
	end

	forbidden_classes.iceroid = true
	return true
end

-- Overwrite E2 registerCallback function with hooked version
function registerCallback(name, func)
	if name == "construct" then
		fixE2FinderCB(func)
	end
	return SA.OldE2RegisterCallback(name, func)
end

-- Overwrite existing E2 callbacks on map load
local function fixE2Finder()
	if not wire_expression_callbacks then
		return false
	end

	local construct_callbacks = wire_expression_callbacks.construct
	if not construct_callbacks then
		return false
	end

	for _, func in pairs(construct_callbacks) do
		if fixE2FinderCB(func) then
			return true
		end
	end

	return false
end

timer.Create("SA_Fix_E2_Finder", 1, 0, function()
	if fixE2Finder() then
		timer.Remove("SA_Fix_E2_Finder")
		wire_expression2_reload()
	end
end)
