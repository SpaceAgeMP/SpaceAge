TOOL.Category = "SpaceAge"
TOOL.Name = "Mining Storage"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Custom Addon Framework"

TOOL.ClientConVar["type"] = "ore_storage"
TOOL.ClientConVar["model"] = "models/slyfo/sat_resourcetank.mdl"

cleanup.Register("asteroid mining")

if ( CLIENT ) then
	language.Add( "tool.mining_storage.name", "Mining Storage" )
	language.Add( "tool.mining_storage.desc", "Spawn storages for ore." )
	language.Add( "tool.mining_storage.0", "Left click to spawn a storage." )

	language.Add( "Undone_mining_storage", "Mining Storage Undone" )
	language.Add( "Cleanup_mining_storage", "Mining Storage" )
	language.Add( "Cleaned_mining_storage", "Cleaned up all Mining Storages" )
	language.Add( "SBoxLimit_mining_storage", "Maximum Mining Storages Reached" )
end

local miningdevice_models = {
	{ "Ore Container (Small)", "models/slyfo/sat_resourcetank.mdl", "ore_storage" },
	{ "Ore Container (Medium)", "models/Slyfo/nacshortsleft.mdl", "ore_storage_ii" },
	{ "Ore Container (Large)", "models/Slyfo/nacshuttleright.mdl", "ore_storage_iii" },
	{ "Ore Container (Huge)", "models/slyfo/crate_resource_small.mdl", "ore_storage_iv" },
	{ "Ore Container (Giant)", "models/slyfo/crate_resource_large.mdl", "ore_storage_v" },
	{ "Tiberium Container", "models/slyfo/sat_resourcetank.mdl", "tiberium_storage" },
	{ "Tiberium Container II", "models/slyfo/sat_resourcetank.mdl", "tiberium_storage_ii" },
	{ "ICE Storage Level 5: Massive", "models/mandrac/resource_cache/colossal_cache.mdl", "storage_ice" },
	{ "ICE Storage Level 4: Huge", "models/mandrac/nitrogen_tank/nitro_large.mdl", "storage_ice" },
	{ "ICE Storage Level 3: Large Tank", "models/mandrac/resource_cache/huge_cache.mdl", "storage_ice" },
	{ "ICE Storage Level 2: Medium Tank", "models/mandrac/energy_cell/large_cell.mdl", "storage_ice" },
	{ "ICE Storage Level 1: Small Tank", "models/mandrac/energy_cell/medium_cell.mdl", "storage_ice" },
	{ "ICE Product Storage Level 7: 2x Carrier Bay", "models/slyfo/doublecarrier.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 6: Carrier Bay", "models/slyfo/carrierbay.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 5: Massive Bay", "models/spacebuild/medbridge2_fighterbay3.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 4: Massive", "models/mandrac/resource_cache/colossal_cache.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 3: Huge", "models/mandrac/water_storage/water_storage_large.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 2: Large Tank", "models/mandrac/resource_cache/hangar_container.mdl", "storage_ice_product" },
	{ "ICE Product Storage Level 1: Medium Tank", "models/mandrac/hw_tank/hw_tank_large.mdl", "storage_ice_product" },
}

CAF_ToolRegister( TOOL, miningdevice_models, nil, "mining_storage", 4 )
