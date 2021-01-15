if SERVER then
	local hudaf = {}
	timer.Create("armorfix", 0.4, 0, function()
		for k, pl in pairs(player.GetAll()) do
			local userid = pl:UniqueID()
			if pl:Armor() ~= hudaf[userid] then
				pl:SetNWInt("armor", pl:Armor())
				hudaf[userid] = pl:Armor()
			end
		end
	end);
	Msg("SERVER: Armor fix running.\n")
end

if CLIENT then
	local meta = FindMetaTable("Player")
	function meta:Armor()
		return self:GetNWInt("armor")
	end
	Msg("Armor fix running.\n")
end
