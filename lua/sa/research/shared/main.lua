SA.Research = {}

local Researches = {}
local ResearchGroups = {"Asteroid Mining", "Tiberium Mining", "Ice Mining", "Miscellaneous"}
local ResearchIcons = {}

function SA.Research.Get()
	return Researches
end

function SA.Research.GetGroups()
	return ResearchGroups
end

local function ParseResearchName(name)
	local openBracketIdx = name:find("[", 1, true)
	if not openBracketIdx then
		return name, 1
	end
	local closeBracketIdx = name:find("]", openBracketIdx, true)
	if not closeBracketIdx then
		error("Invalid research descriptor " .. name)
	end
	local strBefore = name:sub(1, openBracketIdx - 1)
	local strAfter = tonumber(name:sub(openBracketIdx + 1, closeBracketIdx - 1))
	return strBefore, strAfter
end

function SA.Research.InitPlayer(ply)
	for _, research in pairs(Researches) do
		local dname, idx = ParseResearchName(research.name)
		if ply.sa_data.research[dname] == nil then
			ply.sa_data.research[dname] = {}
		end
		if ply.sa_data.research[dname][idx] == nil then
			ply.sa_data.research[dname][idx] = 0
		end
	end
end

function SA.Research.GetFromPlayer(ply, name)
	local dname, idx = ParseResearchName(name)
	return ply.sa_data.research[dname][idx]
end

function SA.Research.SetToPlayer(ply, name, value)
	local dname, idx = ParseResearchName(name)
	ply.sa_data.research[dname][idx] = value
end

local function SA_VerifyResearchXQINT(res)
	for _, v in pairs(res) do
		if v[1] == "faction" then return false end
	end
	return true
end

local function SA_AddResearch(name, group, displayname, ranks, cost, costinc, desc, reqtype, prereq, position, classes, image)
	local tbl = {}
	image = image or "sa_research_icon"
	tbl.name = name
	tbl.group = group
	tbl.display = displayname
	tbl.ranks = ranks
	tbl.cost = cost
	tbl.costinc = costinc
	tbl.desc = desc
	tbl.type = reqtype
	tbl.prereq = prereq
	tbl.pos = position
	tbl.classes = classes
	tbl.image = image

	local resetreq = ranks
	if reqtype == "unlock" then
		if not SA_VerifyResearchXQINT(prereq) then resetreq = 0 end
	elseif reqtype == "perrank" then
		for k, v in pairs(prereq) do
			if not SA_VerifyResearchXQINT(v) then resetreq = (k - 1) end
		end
	end
	tbl.resetreq = resetreq

	ResearchIcons[image] = true
	Researches[name] = tbl
end


--[[
SA_AddResearch(Research Name,
			Research Group,
			Display Name,
			Max rank (0 = infinite),
			Base Cost,
			Price increase (% of base),
			Description,
			Pre-Requisite,
			Position on List,
			Class types to update with new values,
			icon)
]]

SA_AddResearch("ore_laser_yield[1]", "Asteroid Mining", "Augmented Mining Lasers I", 300, 10000, 25, "Each rank increases the amount of ore mined by the MkI laser by 12.5 a second.", "none", {}, 1, {"sa_mining_laser"}, "laser_icon_i.png")
SA_AddResearch("ore_laser_yield[2]", "Asteroid Mining", "Augmented Mining Lasers II", 300, 800000, 0.625, "Each rank increases the amount of ore mined by the MkII laser by 25 a second.", "unlock", {{"ore_laser_yield[1]", 300}, {"ore_laser_level", 1}}, 2, {"sa_mining_laser_ii"}, "laser_icon_ii.png")
SA_AddResearch("ore_laser_yield[3]", "Asteroid Mining", "Augmented Mining Lasers III", 300, 2500000, 0.4, "Each rank increases the amount of ore mined by the MkIII laser by 50 a second.", "unlock", {{"ore_laser_yield[2]", 300}, {"ore_laser_level", 2}}, 3, {"sa_mining_laser_iii"}, "laser_icon_iii.png")
SA_AddResearch("ore_laser_yield[4]", "Asteroid Mining", "Augmented Mining Lasers IV", 300, 6250000, 0.32, "Each rank increases the amount of ore mined by the MkIV laser by 100 a second.", "unlock", {{"ore_laser_yield[3]", 300}, {"ore_laser_level", 3}}, 4, {"sa_mining_laser_iv"}, "laser_icon_iv.png")
SA_AddResearch("ore_laser_yield[5]", "Asteroid Mining", "Augmented Mining Lasers V", 300, 12500000, 0.32, "Each rank increases the amount of ore mined by the MkV laser by 200 a second.", "unlock", {{"ore_laser_yield[4]", 300}, {"ore_laser_level", 4}}, 5, {"sa_mining_laser_v"}, "laser_icon_v.png")
SA_AddResearch("ore_laser_yield[6]", "Asteroid Mining", "Augmented Mining Lasers VI", 300, 25000000, 0.32, "Each rank increases the amount of ore mined by the MkVI laser by 400 a second.", "unlock", {{"ore_laser_yield[5]", 300}, {"ore_laser_level", 5}, {"faction", {"miners", "alliance"}}}, 6, {"sa_mining_laser_vi"}, "laser_icon_vi.png")
SA_AddResearch("ore_laser_level", "Asteroid Mining", "Mining Theory", 5, 5000000, 100, "Unlocks the use of more powerful Mining Lasers.", "perrank", {{{"ore_laser_yield[1]", 300}}, {{"ore_laser_yield[2]", 300}}, {{"ore_laser_yield[3]", 300}}, {{"ore_laser_yield[4]", 300}}, {{"ore_laser_yield[5]", 300}, {"faction", {"miners", "alliance"}}}}, 7, {}, "laser_icon_research.png")
SA_AddResearch("mining_energy_efficiency", "Asteroid Mining", "Mining Power Reduction", 45, 10000, 50, "Each rank reduces the amount of energy consumed by the mining laser by 50 a second.\n(Energy reduction cannot drop below 1/4th base.)", "none", {}, 8, {"sa_mining_laser", "sa_mining_laser_ii", "sa_mining_laser_iii", "sa_mining_laser_iv", "sa_mining_laser_v", "sa_mining_laser_vi"}, "laser_icon_energy.png")
SA_AddResearch("ore_storage_capacity[1]", "Asteroid Mining", "Increased Ore Capacity - Small", 300, 5000, 25, "Each rank increases the capacity of the small ore storage container by 5000.", "none", {}, 9, {"ore_storage"}, "laser_storage_icon_small.png")
SA_AddResearch("ore_storage_capacity[2]", "Asteroid Mining", "Increased Ore Capacity - Medium", 300, 400000, 0.625, "Each rank increases the capacity of the medium ore storage container by 10000.", "unlock", {{"ore_storage_capacity[1]", 300}, {"ore_storage_level", 1}}, 10, {"ore_storage_ii"}, "laser_storage_icon_med.png")
SA_AddResearch("ore_storage_capacity[3]", "Asteroid Mining", "Increased Ore Capacity - Large", 300, 1250000, 0.4, "Each rank increases the capacity of the large ore storage container by 20000.", "unlock", {{"ore_storage_capacity[2]", 300}, {"ore_storage_level", 2}}, 11, {"ore_storage_iii"}, "laser_storage_icon_large.png")
SA_AddResearch("ore_storage_capacity[4]", "Asteroid Mining", "Increased Ore Capacity - Huge", 300, 2500000, 0.32, "Each rank increases the capacity of the huge ore storage container by 40000.", "unlock", {{"ore_storage_capacity[3]", 300}, {"ore_storage_level", 3}}, 12, {"ore_storage_iv"}, "laser_storage_icon_huge.png")
SA_AddResearch("ore_storage_capacity[5]", "Asteroid Mining", "Increased Ore Capacity - Giant", 300, 5000000, 0.32, "Each rank increases the capacity of the giant ore storage container by 80000.", "unlock", {{"ore_storage_capacity[4]", 300}, {"ore_storage_level", 4}, {"faction", {"miners", "starfleet", "alliance"}}}, 13, {"ore_storage_v"}, "laser_storage_icon_giant.png")
SA_AddResearch("ore_storage_level", "Asteroid Mining", "Ore Management", 4, 2500000, 100, "Unlocks the use of bigger ore containers.", "perrank", {{{"ore_storage_capacity[1]", 300}}, {{"ore_storage_capacity[2]", 300}}, {{"ore_storage_capacity[3]", 300}}, {{"ore_storage_capacity[4]", 300}, {"faction", {"miners", "starfleet", "alliance"}}}}, 14, {}, "storage_icon_research.png")
SA_AddResearch("tiberium_drill_yield[1]", "Tiberium Mining", "Augmented Mining Drill", 300, 12000, 25, "Each rank increases the amount of tiberium mined by the drill by 20 a second.", "none", {}, 1, {"sa_mining_drill"}, "tiberium_drill_icon_i.png")
SA_AddResearch("tiberium_drill_yield[2]", "Tiberium Mining", "Augmented Mining Drill II", 300, 24000, 25, "Each rank increases the amount of tiberium mined by the drill II by 40 a second.", "unlock", {{"tiberium_drill_yield[1]", 300}, {"tiberium_drill_level", 1}, {"faction", {"legion", "alliance"}}}, 2, {"sa_mining_drill_ii"}, "tiberium_drill_icon_ii.png")
SA_AddResearch("tiberium_drill_level", "Tiberium Mining", "Tiberium Drills", 1, 25000000, 100, "Unlocks the use of better tiberium drills.", "perrank", {{{"tiberium_drill_yield[1]", 300}, {"faction", {"legion", "alliance"}}}}, 3, {}, "tiberium_drill_icon_research.png")
SA_AddResearch("tiberium_storage_capacity[1]", "Tiberium Mining", "Increased Tiberium Capacity", 300, 5000, 16, "Each rank increases the capacity of the tiberium storage container by 5000.", "none", {}, 4, {"tiberium_storage"}, "tiberium_storage_icon_i.png")
SA_AddResearch("tiberium_storage_capacity[2]", "Tiberium Mining", "Increased Tiberium Capacity II", 300, 10000, 16, "Each rank increases the capacity of the tiberium storage container II by 10000.", "unlock", {{"tiberium_drill_yield[1]", 300}, {"tiberium_storage_level", 1}, {"faction", {"legion", "alliance"}}}, 5, {"tiberium_storage_ii"}, "tiberium_storage_icon_ii.png")
SA_AddResearch("tiberium_storage_level", "Tiberium Mining", "Tiberium Storages", 1, 20000000, 100, "Unlocks the use of bigger tiberium containers.", "perrank", {{{"tiberium_storage_capacity[1]", 300}, {"faction", {"legion", "alliance"}}}}, 6, {}, "storage_icon_research.png")
SA_AddResearch("rta", "Miscellaneous", "Remote Terminal Access", 2, 50000000, 200, "Allows use of the R.T.A. (Remote Terminal Access) device.", "perrank", {{}, {{"faction", {"corporation", "alliance"}}}}, 2, {}, "remote_access_icon.png")
SA_AddResearch("ice_refinery_level", "Ice Mining", "Ice Refineries", 2, 750000000, 150, "Allows using better ice refineries.", "none", {}, 1, {}, "ice_icon_refinery_research.png")
SA_AddResearch("ice_laser_level", "Ice Mining", "Ice Lasers", 2, 1000000000, 150, "Allows using better ice lasers.", "none", {}, 2, {}, "ice_icon_research.png")
SA_AddResearch("ice_raw_storage_level", "Ice Mining", "Ice Storages", 4, 300000000, 150, "Allows using better raw Ice Storages.", "none", {}, 3, {}, "storage_icon_research.png")
SA_AddResearch("ice_product_storage_level", "Ice Mining", "Ice Product Storages", 6, 300000000, 150, "Allows using better ice product storages.", "none", {}, 4, {}, "storage_icon_research.png")

if SERVER then
	for k, v in pairs(ResearchIcons) do
		resource.AddFile("materials/spaceage/" .. k)
	end
end
