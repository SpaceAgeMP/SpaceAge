--if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end
TOOL.Tab			= "Administration"
TOOL.Category		= "Administration"
TOOL.Name			= "#TurnToSkinSwitcher"
TOOL.Command 		= nil
TOOL.ConfigName 	= ""

if (CLIENT) then
	language.Add("tool.turn_into_skinswitcher.name" , "Make-A-Skin-Switcher Tool")
	language.Add("tool.turn_into_skinswitcher.desc" , "Easily turn props into skin switchers.")
	language.Add("tool.turn_into_skinswitcher.0", "Left click a prop to turn it into a skin switcher.")
	language.Add("undone_Skin Switcher", "Undone Habitable Module")
	language.Add("TurnToSkinSwitcher","Make-A-Skin-Switcher")
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	if trace.Entity:IsValid() then
		local traceEnt = trace.Entity
		local ply = self:GetOwner()

		local prop = {}
		prop.model	= traceEnt:GetModel()
		prop.pos	= traceEnt:GetPos()
		prop.angles	= traceEnt:GetAngles()
		prop.skin	= traceEnt:GetSkin()


		traceEnt:Remove()

		local sksw = ents.Create("skin_switcher")
		sksw:SetModel(prop.model)
		sksw:Spawn()
		sksw:Activate()
		sksw:SetPos(prop.pos)
		sksw:SetAngles(prop.angles)
		sksw:SetSkin(prop.skin)
		sksw:SetPlayer(ply)
		sksw:GetPhysicsObject():EnableMotion(false)

		print("Turned into SkinSwitcher!")

		undo.Create("Skin Switcher")
			undo.SetPlayer(ply)
			undo.AddEntity(sksw)
			undo.Finish()

		ply:AddCleanup("skin_switchers" , habmod)

		return true
	end
end


function TOOL:RightClick(trace)

end

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header",
				{
				Text = "Tool_turn_into_skinswitcher_name",
				Description = "Tool_turn_into_skinswitcher_desc"
				})

	BindLabel = {}
	BindLabel.Text = "\nLeft Click to turn a prop into a Skin Switcher. \nThis tool does not yet save constraints, so you will\n need to re-weld things afterwards. Or use\n this tool on the prop before attaching it\n in the first place."
	BindLabel.Description = "Disclaimer."
	panel:AddControl("Label", BindLabel)

 end
