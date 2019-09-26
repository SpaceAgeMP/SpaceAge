TOOL.Category = "SpaceAge"
TOOL.Name = "#Terraforming"
TOOL.Command = nil
TOOL.ConfigName = ""
if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end

TOOL.ClientConVar.type = "sa_terraformer"
TOOL.ClientConVar.model = "models/chipstiks_ls3_models/Terraformer/terraformer.mdl"

cleanup.Register("terraforming")

if (CLIENT) then
	language.Add("tool.terraforming.name", "Terraforming Systems")
	language.Add("tool.terraforming.desc", "Create Terraforming Systems attached to any surface.")
	language.Add("tool.terraforming.0", "Left-Click: Spawn a Device.  Right-Click: Repair Device.")

	language.Add("Undone_terraforming", "Terraforming Device Undone")
	language.Add("Cleanup_terraforming", "Terraforming Device")
	language.Add("Cleaned_terraforming", "Terraforming Devices")
	language.Add("SBoxLimit_terraforming", "Maximum Terraforming Devices Reached")
end

if not CAF or not CAF.GetAddon("Resource Distribution") then Error("Please Install Resource Distribution Addon.") return end
if not CAF or not CAF.GetAddon("Life Support") then return end

local terraforming_models = {
		{ "Terraformer", "models/chipstiks_ls3_models/Terraformer/terraformer.mdl", "sa_terraformer" },
		{ "Terraforming Storage", "models/Slyfo/barrel_unrefined.mdl", "sa_storage_terraform" }
	}
CAF_ToolRegister(TOOL, terraforming_models, nil, "terraforming", 4)
