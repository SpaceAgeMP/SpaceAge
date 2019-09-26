if SERVER then
	AddCSLuaFile()
end

SA.Goodies = {
	ally_1m = {
		name = "Alliance 1 month",
		desc = "1 month membership in the faction \"The Alliance\"",
		image = "SA_Research_Icon",
		func = function(ply)
			ply.SAData.AllianceMembershipExpiry = math.max(ply.SAData.AllianceMembershipExpiry, os.time()) + (2592000 * 1)
			ply:AssignFaction("alliance")
		end
	},
	ally_3m = {
		name = "Alliance 3 months",
		desc = "3 months membership in the faction \"The Alliance\"",
		image = "SA_Research_Icon",
		func = function(ply)
			ply.SAData.AllianceMembershipExpiry = math.max(ply.SAData.AllianceMembershipExpiry, os.time()) + (2592000 * 3)
			ply:AssignFaction("alliance")
		end
	},
	ally_6m = {
		name = "Alliance 6 months",
		desc = "6 months membership in the faction \"The Alliance\"",
		image = "SA_Research_Icon",
		func = function(ply)
			ply.SAData.AllianceMembershipExpiry = math.max(ply.SAData.AllianceMembershipExpiry, os.time()) + (2592000 * 6)
			ply:AssignFaction("alliance")
		end
	},
	ally_12m = {
		name = "Alliance 12 months",
		desc = "12 months membership in the faction \"The Alliance\"",
		image = "SA_Research_Icon",
		func = function(ply)
			ply.SAData.AllianceMembershipExpiry = math.max(ply.SAData.AllianceMembershipExpiry, os.time()) + (2592000 * 12)
			ply:AssignFaction("alliance")
		end
	},
	vip = {
		name = "VIP + Donator",
		desc = "Lifetime VIP rank + donator status",
		image = "SA_Research_Icon",
		func = function(ply)
			--if ply.Level < 1 then ply:SetLevel(1) end
			--if ply.PLevel < 1 then ply.PLevel = 1 end
			ply.donator = true
		end
	}
}
