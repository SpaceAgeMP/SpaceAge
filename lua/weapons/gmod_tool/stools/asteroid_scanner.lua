TOOL.Category = "SpaceAge"
TOOL.Name = "Mining Scanner"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Custom Addon Framework"

TOOL.ClientConVar.type = "sa_asteroid_scanner"
TOOL.ClientConVar.model = "models/jaanus/wiretool/wiretool_beamcaster.mdl"

cleanup.Register("mininglasers")

if (CLIENT) then
	language.Add("tool.asteroid_scanner.name", "Mining Scanner")
	language.Add("tool.asteroid_scanner.desc", "Creates an mining scanner.")
	language.Add("tool.lasteroid_scanner.0", "Left click to spawn a scanner.")

	language.Add("Undone_asteroid_scanner", "Mining Scanner Undone")
	language.Add("Cleanup_asteroid_scanner", "Mining Scanner")
	language.Add("Cleaned_asteroid_scanner", "Cleaned up all mining Scanners")
	language.Add("SBoxLimit_asteroid_scanner", "Maximum mining Scanners Reached")
end

local miningdevice_models = {
	{ "Mining Scanner", "models/jaanus/wiretool/wiretool_beamcaster.mdl", "sa_asteroid_scanner" }
}

CAF_ToolRegister(TOOL, miningdevice_models, nil, "asteroid_scanner", 2)
