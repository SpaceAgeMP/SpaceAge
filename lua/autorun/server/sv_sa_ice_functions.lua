if not SA.Ice then
	SA.Ice = {}
end

local SA_RawIceStorageModels = {}
SA_RawIceStorageModels['models/mandrac/resource_cache/colossal_cache.mdl'] = 4
SA_RawIceStorageModels['models/mandrac/nitrogen_tank/nitro_large.mdl'] = 3
SA_RawIceStorageModels['models/mandrac/resource_cache/huge_cache.mdl'] = 2
SA_RawIceStorageModels['models/mandrac/energy_cell/large_cell.mdl'] = 1
SA_RawIceStorageModels['models/mandrac/energy_cell/medium_cell.mdl'] = 0

local SA_IceProductStorageModels = {}
SA_IceProductStorageModels['models/slyfo/doublecarrier.mdl'] = 6
SA_IceProductStorageModels['models/slyfo/carrierbay.mdl'] = 5
SA_IceProductStorageModels['models/spacebuild/medbridge2_fighterbay3.mdl'] = 4
SA_IceProductStorageModels['models/mandrac/resource_cache/colossal_cache.mdl'] = 3
SA_IceProductStorageModels['models/mandrac/water_storage/water_storage_large.mdl'] = 2
SA_IceProductStorageModels['models/mandrac/resource_cache/hangar_container.mdl'] = 1
SA_IceProductStorageModels['models/mandrac/hw_tank/hw_tank_large.mdl'] = 0


function SA.Ice.GetLevelForStorageModel(mdl)
	return SA_RawIceStorageModels[mdl]
end

function SA.Ice.GetLevelForProductStorageModel(mdl)
	return SA_IceProductStorageModels[mdl]
end
