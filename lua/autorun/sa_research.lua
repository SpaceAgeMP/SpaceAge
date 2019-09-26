if SERVER then
	AddCSLuaFile()
end

SA.Research = {}

local Researches = {}
local ResearchGroups = {"Asteroid Mining","Tiberium Mining","Ice Mining", "Miscellaneous"}
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
		return name
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
		if ply.SAData.Research[dname] == nil then
			ply.SAData.Research[dname] = idx and {} or 0
		end
		if idx and ply.SAData.Research[dname][idx] == nil then
			ply.SAData.Research[dname][idx] = 0
		end
	end
end

function SA.Research.GetFromPlayer(ply, name)
	local dname, idx = ParseResearchName(name)
	if idx then
		return ply.SAData.Research[dname][idx]
	end
	return ply.SAData.Research[dname]
end

function SA.Research.SetToPlayer(ply, name, value)
	local dname, idx = ParseResearchName(name)
	if idx then
		ply.SAData.Research[dname][idx] = value
	end
	ply.SAData.Research[name] = value
end

local function SA_VerifyResearchXQINT(res)
	for _,v in pairs(res) do
		if v[1] == "faction" then return false end
	end
	return true
end

local function SA_AddResearch(name,group,displayname,ranks,cost,costinc,desc,reqtype,prereq,position,classes,image)
	local tbl = {}
	image = image or "sa_research_icon"
	tbl["name"] = name
	tbl.group = group
	tbl["display"] = displayname
	tbl["ranks"] = ranks
	tbl["cost"] = cost
	tbl["costinc"] = costinc
	tbl["desc"] = desc
	tbl["type"] = reqtype
	tbl["prereq"] = prereq
	tbl["pos"] = position
	tbl["classes"] = classes
	tbl["image"] = image

	local resetreq = ranks
	if reqtype == "unlock" then
		if not SA_VerifyResearchXQINT(prereq) then resetreq = 0 end
	elseif reqtype == "perrank" then
		for k,v in pairs(prereq) do
			if not SA_VerifyResearchXQINT(v) then resetreq = (k - 1) end
		end
	end
	tbl["resetreq"] = resetreq

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
			Class types to update with new values)
]]

SA_AddResearch("OreLaserYield[1]","Asteroid Mining","Augmented Mining Lasers I",300,10000,25,"Each rank increases the amount of ore mined by the MkI laser by 6.25 a second.","none",{},1,{"sa_mining_laser"})
SA_AddResearch("OreLaserYield[2]","Asteroid Mining","Augmented Mining Lasers II",300,800000,0.625,"Each rank increases the amount of ore mined by the MkII laser by 12.5 a second.","unlock",{{"OreLaserYield[1]",300},{"OreLaserLevel",1}},2,{"sa_mining_laser_ii"})
SA_AddResearch("OreLaserYield[3]","Asteroid Mining","Augmented Mining Lasers III",300,2500000,0.4,"Each rank increases the amount of ore mined by the MkIII laser by 25 a second.","unlock",{{"OreLaserYield[2]",300},{"OreLaserLevel",2}},3,{"sa_mining_laser_iii"})
SA_AddResearch("OreLaserYield[4]","Asteroid Mining","Augmented Mining Lasers IV",300,6250000,0.32,"Each rank increases the amount of ore mined by the MkIV laser by 50 a second.","unlock",{{"OreLaserYield[3]",300},{"OreLaserLevel",3}},4,{"sa_mining_laser_iv"})
SA_AddResearch("OreLaserYield[5]","Asteroid Mining","Augmented Mining Lasers V",300,12500000,0.32,"Each rank increases the amount of ore mined by the MkV laser by 100 a second.","unlock",{{"OreLaserYield[4]",300},{"OreLaserLevel",4}},5,{"sa_mining_laser_v"})
SA_AddResearch("OreLaserYield[6]","Asteroid Mining","Augmented Mining Lasers VI",300,25000000,0.32,"Each rank increases the amount of ore mined by the MkVI laser by 200 a second.","unlock",{{"OreLaserYield[5]",300},{"OreLaserLevel",5},{"faction",{"miners","alliance"}}},6,{"sa_mining_laser_vi"})
SA_AddResearch("OreLaserLevel","Asteroid Mining","Mining Theory",5,5000000,100,"Unlocks the use of more powerful Mining Lasers.","perrank",{{{"OreLaserYield[1]",300}},{{"OreLaserYield[2]",300}},{{"OreLaserYield[3]",300}},{{"OreLaserYield[4]",300}},{{"OreLaserYield[5]",300},{"faction",{"miners","alliance"}}}},7,{})
SA_AddResearch("MiningEnergyEfficiency","Asteroid Mining","Mining Power Reduction",45,10000,50,"Each rank reduces the amount of energy consumed by the mining laser by 25 a second.\n(Energy reduction cannot drop below 1/4th base.)","none",{},8,{"sa_mining_laser","sa_mining_laser_ii","sa_mining_laser_iii","sa_mining_laser_iv","sa_mining_laser_v","sa_mining_laser_vi"})
SA_AddResearch("OreStorageCapacity[1]","Asteroid Mining","Increased Ore Capacity - Small",300,5000,25,"Each rank increases the capacity of the small ore storage container by 5000.","none",{},9,{"ore_storage"})
SA_AddResearch("OreStorageCapacity[2]","Asteroid Mining","Increased Ore Capacity - Medium",300,400000,0.625,"Each rank increases the capacity of the medium ore storage container by 10000.","unlock",{{"OreStorageCapacity[1]",300},{"OreStorageLevel",1}},10,{"ore_storage_ii"})
SA_AddResearch("OreStorageCapacity[3]","Asteroid Mining","Increased Ore Capacity - Large",300,1250000,0.4,"Each rank increases the capacity of the large ore storage container by 20000.","unlock",{{"OreStorageCapacity[2]",300},{"OreStorageLevel",2}},11,{"ore_storage_iii"})
SA_AddResearch("OreStorageCapacity[4]","Asteroid Mining","Increased Ore Capacity - Huge",300,2500000,0.32,"Each rank increases the capacity of the huge ore storage container by 40000.","unlock",{{"OreStorageCapacity[3]",300},{"OreStorageLevel",3}},12,{"ore_storage_iv"})
SA_AddResearch("OreStorageCapacity[5]","Asteroid Mining","Increased Ore Capacity - Giant",300,5000000,0.32,"Each rank increases the capacity of the giant ore storage container by 80000.","unlock",{{"OreStorageCapacity[4]",300},{"OreStorageLevel",4},{"faction",{"miners","starfleet","alliance"}}},13,{"ore_storage_v"})
SA_AddResearch("OreStorageLevel","Asteroid Mining","Ore Management",4,2500000,100,"Unlocks the use of bigger ore containers.","perrank",{{{"OreStorageCapacity[1]",300}},{{"OreStorageCapacity[2]",300}},{{"OreStorageCapacity[3]",300}},{{"OreStorageCapacity[4]",300},{"faction",{"miners","starfleet","alliance"}}}},14,{})
SA_AddResearch("TiberiumDrillYield[1]","Tiberium Mining","Augmented Mining Drill",300,12000,25,"Each rank increases the amount of tiberium mined by the drill by 10 a second.","none",{},1,{"sa_mining_drill"})
SA_AddResearch("TiberiumDrillYield[2]","Tiberium Mining","Augmented Mining Drill II",300,24000,25,"Each rank increases the amount of tiberium mined by the drill II by 20 a second.","unlock",{{"Research.TiberiumDrillYield[1]",300},{"TiberiumDrillLevel",1},{"faction",{"legion","alliance"}}},2,{"sa_mining_drill_ii"})
SA_AddResearch("TiberiumDrillLevel","Tiberium Mining","Tiberium Drills",1,25000000,100,"Unlocks the use of better tiberium drills.","perrank",{{{"Research.TiberiumDrillYield[1]",300},{"faction",{"legion","alliance"}}}},3,{})
SA_AddResearch("TiberiumStorageCapacity[1]","Tiberium Mining","Increased Tiberium Capacity",300,5000,16,"Each rank increases the capacity of the tiberium storage container by 5000.","none",{},4,{"tiberium_storage"})
SA_AddResearch("TiberiumStorageCapacity[2]","Tiberium Mining","Increased Tiberium Capacity II",300,10000,16,"Each rank increases the capacity of the tiberium storage container II by 10000.","unlock",{{"Research.TiberiumDrillYield[1]",300},{"TiberiumStorageLevel",1},{"faction",{"legion","alliance"}}},5,{"tiberium_storage_ii"})
SA_AddResearch("TiberiumStorageLevel","Tiberium Mining","Tiberium Storages",1,20000000,100,"Unlocks the use of bigger tiberium containers.","perrank",{{{"Research.TiberiumStorageCapacity[1]",300},{"faction",{"legion","alliance"}}}},6,{})
SA_AddResearch("RTA","Miscellaneous","Remote Terminal Access",2,50000000,200,"Allows use of the R.T.A. (Remote Terminal Access) device.","perrank",{{},{{"faction",{"corporation","alliance"}}}},2,{})
SA_AddResearch("IceRefineryLevel","Ice Mining","Ice Refineries",2,750000000,150,"Allows using better ice refineries.","none",{},1,{})
SA_AddResearch("IceLaserLevel","Ice Mining","Ice Lasers",2,1000000000,150,"Allows using better ice lasers.","none",{},2,{})
SA_AddResearch("IceRawStorageLevel","Ice Mining","Ice Storages",4,300000000,150,"Allows using better raw Ice Storages.","none",{},3,{})
SA_AddResearch("IceProductStorageLevel","Ice Mining","Ice Product Storages",6,300000000,150,"Allows using better ice product storages.","none",{},4,{})

for k,v in pairs(ResearchIcons) do
	resource.AddFile("materials/spaceage/" .. k .. ".vmt")
	resource.AddFile("materials/spaceage/" .. k .. ".vmf")
end
