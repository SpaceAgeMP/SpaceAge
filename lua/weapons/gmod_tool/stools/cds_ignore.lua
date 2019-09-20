TOOL.Category = 'Administration'
TOOL.Name = 'CDS Prop Toggler'
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Administration"

if ( CLIENT ) then
	language.Add( 'Tool_cds_ignore_name', 'CDS Prop Toggler' )
	language.Add( 'Tool_cds_ignore_desc', 'Left Click: Enable CDS Damage. Right Click: Disable CDS Damage.' )
	language.Add( 'Tool_cds_ignore_0', 'Hai!' )
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if tr.Entity then
		local ent = tr.Entity
		if ent:IsValid() then
			if not ent.Autospawned then
				ent.CDSIgnore = true
				owner:ChatPrint("CDS Damage Enabled")
			end
		end
	end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if tr.Entity then
		local ent = tr.Entity
		if ent:IsValid() then
			if not ent.Autospawned then
				ent.CDSIgnore = false
				owner:ChatPrint("CDS Damage Disabled")
			end
		end
	end
end
