TOOL.Tab = "Utilities"
TOOL.Category = "Admin"
TOOL.Name = "Prop Autospawn Special"
TOOL.Command = nil
TOOL.ConfigName = ""

if (CLIENT) then
	language.Add("tool.autospawn2.name", "Autospawn Special")
	language.Add("tool.autospawn2.desc", "ASK DORIDIAN TO USE")
	language.Add("tool.autospawn2.0", "Wut")
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsSuperAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if not owner.Autospawner2List then
		owner.Autospawner2List = {}
	end
		if tr.Entity then
			local ent = tr.Entity
			if ent:IsValid() and not ent.Autospawned and not ent.Autospawn2Selected then
				local data = {
					x = ent:GetPos().x,
					y = ent:GetPos().y,
					z = ent:GetPos().z,
					pit = ent:GetAngles().p,
					yaw = ent:GetAngles().y,
					rol = ent:GetAngles().r,
					class = ent:GetClass(),
					model = ent:GetModel()
				}

				owner.Autospawner2List[ent:EntIndex()] = data
				ent:SetColor(Color(0, 255, 0, 150))
				ent.Autospawn2Selected = true
				owner:ChatPrint("Selected")
				return true
			else
				owner.Autospawner2List[ent:EntIndex()] = nil
				ent:SetColor(color_white)
				ent.Autospawn2Selected = false
				owner:ChatPrint("Deselected")
				return true
			end
		end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsSuperAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if not file.IsDir("autospawn2_tmp") then
		file.CreateDir("autospawn2_tmp")
	end
	local mapname = game.GetMap():lower()
	local filename = "autospawn2_tmp/" .. mapname .. ".txt"
	if file.Exists(filename, "DATA") then
		local oldfile = file.Read(filename)
		local olddata = util.JSONToTable(oldfile)
		for _, v in pairs(olddata) do
			table.insert(owner.Autospawner2List, v)
		end
	else
		local oldConfig = SA.Config.Load("autospawn2")
		if oldConfig then
			for _, v in pairs(oldConfig) do
				table.insert(owner.Autospawner2List, v)
			end
		end
	end
	file.Write(filename, util.TableToJSON(owner.Autospawner2List))
	owner.Autospawner2List = {}
	owner:ChatPrint("Saved File")
end

function TOOL:Reload(tr)
	local owner = self:GetOwner()
	for k, v in pairs(owner.Autospawner2List) do if (v and v:IsValid()) then v:SetColor(color_white) end end
	owner.Autospawner2List = {}
	owner:ChatPrint("Cleared selection")
end
