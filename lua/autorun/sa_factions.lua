if SERVER then
	AddCSLuaFile()
end

SA.Factions = {}
SA.Factions.Table = {}
table.insert(SA.Factions.Table, { "Freelancers", "freelancer", Color(158,134,97,255),"models/player/Group01/male_02.mdl","models/player/Group01/male_02.mdl",nil,"have"})
table.insert(SA.Factions.Table, { "Star Fleet", "starfleet", Color(210,210,210,255),"models/player/police.mdl","models/player/combine_super_soldier.mdl",nil,"has"})
table.insert(SA.Factions.Table, { "The Legion", "legion", Color(85,221,34,255),"models/player/Hostage/Hostage_01.mdl","models/player/breen.mdl",nil,"has"})
table.insert(SA.Factions.Table, { "Major Miners", "miners", Color(128,64,0,255),"models/player/Group03/male_01.mdl","models/player/Group03/male_06.mdl",nil,"have"})
table.insert(SA.Factions.Table, { "The Corporation", "corporation", Color(0,150,255,255),"models/player/Hostage/Hostage_02.mdl","models/player/gman_high.mdl",nil,"has"})
table.insert(SA.Factions.Table, { "The Alliance", "alliance", Color(229,33,222,255),"models/player/Group01/male_02.mdl","models/player/Group01/male_02.mdl",nil,"has"})
table.insert(SA.Factions.Table, { "P.L.A.N.E.T.", "planet", Color(255,175,0,255),"models/player/Group01/male_02.mdl","models/player/Group01/male_02.mdl",nil,"has"})
table.insert(SA.Factions.Table, { "FAILED TO LOAD", "noload", Color(75,75,75,255),"models/player/Group01/male_02.mdl","models/player/Group01/male_02.mdl",nil,"HAR"})

SA.Factions.Min = 2
SA.Factions.Max = 7

SA.Factions.ToLong = {}
SA.Factions.Colors = {}
	
for k,v in pairs(SA.Factions.Table) do
	SA.Factions.ToLong[v[2]] = v[1]
	SA.Factions.Colors[v[2]] = v[3]
	team.SetUp(k,v[1],Color(v[3].r,v[3].g,v[3].b,255))
end