--glualint:ignore-file
local RD = CAF.GetAddon("Resource Distribution")
E2Lib.RegisterExtension("lifesupport", false)

local function e2defaulttable()
	return {n={},ntypes={},s={},stypes={},size=0}
end

local function convert_table_to_e2_table(tab)
	local newTab = e2defaulttable()
	for k, v in pairs(tab) do
		local ty = string.lower(type(v))
		local validType = true
		if ty == "string" then
			newTab.stypes[k] = "s"
		elseif ty == "number" then
			newTab.stypes[k] = "n"
		elseif ty == "entity" then
			newTab.stypes[k] = "e"
		else
			validType = false
		end
		if validType then
			newTab.s[k] = v
			newTab.size = newTab.size + 1
		end
	end
	return newTab
end

local function ls_table_to_e2_table(sbenv)
	local retTab = convert_table_to_e2_table(sbenv)
	if sbenv.air then
		for k, v in pairs(sbenv.air) do
			if type(v) == "number" then
				k = "air"..k
				retTab.s[k] = v
				retTab.stypes[k] = "n"
				retTab.size = retTab.size + 1
			end
		end
	end
	return retTab
end

local function e2_ls_info(ent)
	local retTab = e2defaulttable()
	if ent.sbenvironment then
		retTab = ls_table_to_e2_table(ent.sbenvironment)
		if SA.ValidEntity(ent) then
			retTab.s.entity = ent
			retTab.stypes.entity = "e"
			retTab.size = retTab.size + 1
		end
	end
	if ent.environment and ent.environment.sbenvironment then
		if ent.sbenvironment then
			if ent.environment ~= ent and SA.ValidEntity(ent.environment) then
				retTab.s.parent = ent.environment
				retTab.stypes.parent = "e"
				retTab.size = retTab.size + 1
			end
		else
			retTab = ls_table_to_e2_table(ent.environment.sbenvironment)
			if SA.ValidEntity(ent.environment) then
				retTab.s.entity = ent.environment
				retTab.stypes.entity = "e"
				retTab.size = retTab.size + 1
			end
		end
	end
	return retTab
end

local function ls_get_nettbl_by_ent(this)
	if not SA.ValidEntity(this) then return nil end
	local netid = this:GetNWInt("netid")
	if netid <= 0 then return nil end
	local nettable = RD.GetNetTable(netid)
	if not nettable.resources then return nil end
	return nettable.resources
end

local function ls_get_res_by_ent(this, res)
	local amount, capacity, temperature = RD.GetResourceData(this, res)
	return amount, capacity, temperature
end

__e2setcost(10)
e2function table entity:lsInfo()
	if not SA.ValidEntity(this) then return e2defaulttable() end
	return e2_ls_info(this)
end

e2function table lsInfo()
	return e2_ls_info(self.entity)
end

e2function array entity:lsGetResources()
	local nettable = ls_get_nettbl_by_ent(this)
	if not nettable then return {} end
	local aTab = {}
	for k, v in pairs(nettable) do
		table.insert(aTab, k)
		if #aTab >= E2_MAX_ARRAY_SIZE then break end
	end
	return aTab
end

local function ls_get_res

__e2setcost(5)
e2function string lsGetName(string key)
	return RD.GetProperResourceName(key)
end

e2function number entity:lsGetAmount(string key)
	local amount, _, _ = ls_get_res_by_ent(this, key)
	return amount
end

e2function number entity:lsGetCapacity(string key)
	local _, capacity, _ = ls_get_res_by_ent(this, key)
	return capacity
end

e2function number entity:lsGetTemperature(string key)
	local _, _, temperature = ls_get_res_by_ent(this, key)
	return temperature
end

e2function table entity:lsGetData(string key)
	local amount, capacity, temperature = ls_get_res_by_ent(this, key)
	return {
		n={},
		ntypes={},
		s={
			amount = amount,
			capacity = capacity,
			temperature = temperature
		},
		stypes={
			amount = "n",
			capacity = "n",
			temperature = "n"
		},
		size=3
	}
end
