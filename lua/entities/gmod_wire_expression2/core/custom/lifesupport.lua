--glualint:ignore-file
local RD = CAF.GetAddon("Resource Distribution")
E2Lib.RegisterExtension("lifesupport", false)

local function convert_table_to_e2_table(tab)
	local newTab = {}
	for k, v in pairs(tab) do
		local ty = string.lower(type(v))
		if ty == "string" then
			newTab["s"..k] = v
		elseif ty == "number" then
			newTab["n"..k] = v
		elseif ty == "entity" then
			newTab["e"..k] = v
		end
	end
	return newTab
end

local function ls_table_to_e2_table(sbenv)
	local retTab = convert_table_to_e2_table(sbenv)
	if sbenv.air then
		for k, v in pairs(sbenv.air) do
			if type(v) == "number" then
				retTab["nair"..k] = v
			end
		end
	end
	return retTab
end

local function e2_ls_info(ent)
	local retTab = {}
	if ent.sbenvironment then
		retTab = ls_table_to_e2_table(ent.sbenvironment)
		if SA.ValidEntity(ent) then
			retTab.eentity = ent
		end
	end
	if ent.environment and ent.environment.sbenvironment then
		if ent.sbenvironment then
			if ent.environment ~= ent and SA.ValidEntity(ent.environment) then
				retTab.eparent = ent.environment
			end
		else
			retTab = ls_table_to_e2_table(ent.environment.sbenvironment)
			if SA.ValidEntity(ent.environment) then
				retTab.eentity = ent.environment
			end
		end
	end
	return retTab
end

local function ls_get_res_by_ent(this)
	if (not SA.ValidEntity(this)) then return nil end
	local netid = this:GetNWInt("netid")
	if netid <= 0 then return nil end
	local nettable = RD.GetNetTable(netid)
	if not nettable.resources then return nil end
	return nettable.resources
end

e2function table entity:lsInfo()
	if (not SA.ValidEntity(this)) then return {} end
	return e2_ls_info(this)
end

e2function table lsInfo()
	return e2_ls_info(self)
end


e2function array entity:lsGetResources()
	local nettable = ls_get_res_by_ent(this)
	if not nettable then return {} end
	local aTab = {}
	for k, v in pairs(nettable) do
		table.insert(aTab, k)
		if #aTab >= E2_MAX_ARRAY_SIZE then break end
	end
	return aTab
end

e2function string lsGetName(string key)
	return RD.GetProperResourceName(key)
end

e2function number entity:lsGetAmount(string key)
	local nettable = ls_get_res_by_ent(this)
	if not (nettable and nettable[key]) then return 0 end
	return nettable[key].value
end

e2function number entity:lsGetCapacity(string key)
	local nettable = ls_get_res_by_ent(this)
	if not (nettable and nettable[key]) then return 0 end
	return nettable[key].maxvalue
end
