SA.Planets = {}

local SB = CAF.GetAddon("Spacebuild")

local SB_Terraforming_Target = {o2 = 29, co2 = 0.6, h = 0.4, n = 70, empty = 0}

local SA_MyPlanets = {}
local SA_DefEnvsA = {}
local SA_DefEnvs = {}
local SA_IgnoreValsA = {o2per = true, nper = true, hper = true, co2per = true, emptyper = true}

function SA.Planets.MakeHabitable(planet)
	local mainenv = planet.sbenvironment
	local mainair = planet.sbenvironment.air
	mainenv.atmosphere = 0
	planet:ChangeAtmosphere(0.5)
	planet:ChangeGravity(1)
	mainenv.temperature = 288
	mainenv.temperature2 = 288
	local tmpCurrent = 0
	for k, v in pairs(SB_Terraforming_Target) do
		mainair[k .. "per"] = v
		local cvalR = math.floor((v / 100) * mainair.max)
		mainair[k] = cvalR
		tmpCurrent = tmpCurrent + cvalR
	end
	if (tmpCurrent < mainair.max) then
		local xTmp = (mainair.max - tmpCurrent)
		mainair.o2 = mainair.o2 + xTmp
		mainair.o2per = mainair.o2per + (xTmp / mainair.max)
	end
end

local function MakePlanetProtected(planet)
	planet.IsProtected = true
	if not planet.OldConvertResource then planet.OldConvertResource = planet.ConvertResource end
	planet.ConvertResource = function(ent, r1, r2, amount)
		return amount
	end
	if not planet.OldConvert then planet.OldConvert = planet.Convert end
	planet.Convert = function(ent, a1, a2, amount)
		return amount
	end
end

function SA.Planets.MakeSpace(planet)
	local mainenv = planet.sbenvironment
	local mainair = planet.sbenvironment.air
	mainenv.temperature = 14
	mainenv.temperature2 = 14
	for k, v in pairs(mainair) do
		mainair[k] = 0
	end
end

local function InitHabitablePlanets()
	local toTerraform = {}
	local toAdd = {}
	local toRename = {}
	local toRemove = {}
	local toProtect = {}
	local mapname = string.lower(game:GetMap())
	local dirname = "Spaceage/planetsave/" .. mapname .. "/"
	if mapname == "sb_new_worlds_2" then
		toTerraform = {"naar'ak asteroid base"}
		toAdd = {{"Naar'ak Asteroid Base", Vector(-9275, -9818, -11428), 900},
				 {"Naar'ak Asteroid Base", Vector(-8257, -8609, -11229), 600},
				 {"Kestrel", Vector(8872, -7112, -7624), 600}}
		toProtect = {"maldoran", "naar'ak asteroid base", "kestrel"}
	elseif mapname == "sb_gooniverse" then
		toAdd = {
					{"Hantar", Vector(3865, -10656, -1991), 700},
					{"Hantar", Vector(4023, -9866, -2047), 640},

					{"Hantar", Vector(4649, -8871, -2048), 200},
					{"Hantar", Vector(4641, -8459, -2048), 200},
					{"Hantar", Vector(4629, -7994, -2048), 200},

					{"Hantar", Vector(4880, -9155, -1911), 100},
					{"Hantar", Vector(5379, -9155, -1911), 100}
				}
		toProtect = {"earth", "termanon", "hantar"}
		toRename["planet 1"] = "Earth"
		toRename["planet 2"] = "Gantron"
		toRename["planet 3"] = "Hantar"
		toRename["planet 4"] = "Termanon"
		toRename["planet 5"] = "Porantus"
		toRename["planet 6"] = "Xanit"
	elseif mapname == "sb_wuwgalaxy_fix" then
		toAdd = {
					{"Space Station", Vector(8368, 2689, 7096), 1150},
					{"Space Station", Vector(8335, 3257, 7107), 600},
					{"Space Station", Vector(8997, 3767, 7099), 850},
					{"Space Station", Vector(8453, 3762, 7093), 850},
					{"Space Station", Vector(8338, 4356, 7079), 800},
					{"Space Station", Vector(8420, 5365, 7122), 2500}
				}
		toTerraform = {"space station"}
		toProtect = {"space station"}
		toRemove = {"space station"}
	elseif mapname == "sb_lostinspace_rc4" then
		toAdd = {{"Umemeru", Vector(8548.4717, 9319.7842, 8059.2813), 400}}
		toProtect = {"ochl", "umemeru", "nuyitae"}
	elseif (mapname == "sb_forlorn_sb3_r2l") then
		toProtect = {"spawn room", "shakuras", "station 457", "dunomane"}
	elseif (mapname == "sb_forlorn_sb3_r3") then
		toProtect = {"spawn room", "shakuras", "station 457", "dunomane"}
	elseif (mapname == "gm_galactic") then
		toProtect = {"Planet 1", "Planet 2", "Planet 4", "Planet 5", "Planet 8", "Planet 9"}
	end

	for k, v in pairs(ents.FindByClass("base_sb_planet*")) do
		if (v.SA_Created) then
			print("Found SpaceAge environment: " .. v.sbenvironment.name .. "! Removing!")
			v:Remove()
		elseif table.HasValue(toRemove, string.lower(v.sbenvironment.name)) then
			print("Found ToRemove environment: " .. v.sbenvironment.name .. "! Removing!")
			v:Remove()
		end
	end
	for k, v in pairs(toAdd) do
		local planet = ents.Create("base_sb_planet2")
		planet:SetModel("models/props_lab/huladoll.mdl")
		planet:SetPos(v[2])
		planet:Spawn()

		local closestPlan = SB.FindClosestPlanet(v[2], false)
		local plSB = closestPlan.sbenvironment
		planet.sbenvironment.bloom = table.Copy(plSB.bloom)
		planet.sbenvironment.color = table.Copy(plSB.color)
		planet:CreateEnvironment(planet, 0, 0, 0, 0, 0, 0, 0, 0, v[1])
		planet:UpdateSize(0, v[3])
		planet:PhysicsInit(SOLID_NONE)
		planet:SetMoveType(MOVETYPE_NONE)
		planet:SetSolid(SOLID_NONE)
		planet.sbenvironment.temperature2 = 0
		planet.sbenvironment.sunburn = false
		planet.sbenvironment.unstable = false
		planet:SetNotSolid(true)
		planet:DrawShadow(false)
		planet:SetNoDraw(true)
		planet.sbenvironment.name = v[1]
		planet.SA_Created = true
		planet.MyPriority = 2
		SA.Planets.MakeHabitable(planet)
		MakePlanetProtected(planet)
	end
	local envname
	for k, v in pairs(ents.FindByClass("base_sb_planet*")) do
		envname = string.lower(v.sbenvironment.name)
		if toRename[envname] then
			v.sbenvironment.name = toRename[envname]
			envname = string.lower(v.sbenvironment.name)
		end
		if (table.HasValue(toTerraform, envname)) then
			print("Making planet \"" .. v.sbenvironment.name .. "\" habitable!")
			SA.Planets.MakeHabitable(v)
		end
		if (table.HasValue(toProtect, envname)) then
			MakePlanetProtected(v)
			v.sbenvironment.pressure = 1
			v.sbenvironment.atmosphere = 1
			print("Protecting planet \"" .. v.sbenvironment.name .. "\"!")
		elseif envname ~= "no name" then
			local filename = dirname .. envname
			SA_DefEnvsA[envname] = v.sbenvironment.air
			SA_DefEnvs[envname] = v.sbenvironment
			if file.Exists(filename .. "_default.txt", "DATA") == false then
				local output = util.TableToJSON(v.sbenvironment)
				file.Write(filename .. "_default.txt", output)
			end
			if file.Exists(filename .. ".txt", "DATA") then
				local envfile = file.Read(filename .. ".txt")
				local envdata = util.JSONToTable(envfile)
				envdata.bloom = v.sbenvironment.bloom
				envdata.color = v.sbenvironment.color
				v.sbenvironment = envdata
			end
			print("DEBUG: " .. filename .. " : " .. tostring(v))
			table.insert(SA_MyPlanets, v)
		end
	end
end
timer.Simple(1, InitHabitablePlanets)

local function SA_PlanetRestore()
	for k, v in pairs(SA_MyPlanets) do
		local envname = string.lower(v.sbenvironment.name)
		if SA_DefEnvsA[envname] then
			for ke, ve in pairs(SA_DefEnvsA[envname]) do
				if not (SA_IgnoreValsA[ke] and SA_IgnoreValsA[ke] == true) then
					local curair = v.sbenvironment.air[ke]
					local newair = curair - math.ceil((curair - ve) * 0.01)
					v.sbenvironment.air[ke] = newair
				end
			end
		end
		if SA_DefEnvs[envname] then
			local myenvT = SA_DefEnvs[envname]
			local curtemp = v.sbenvironment.temperature
			local newtemp = curtemp - ((curtemp - myenvT.temperature) * 0.01)
			v.sbenvironment.temperature = newtemp

			curtemp = v.sbenvironment.temperature2
			newtemp = curtemp - ((curtemp - myenvT.temperature2) * 0.01)
			v.sbenvironment.temperature2 = newtemp
		end
	end
end
timer.Create("SA_PlanetBackfall", 50, 0, SA_PlanetRestore)

function SA.Planets.Save()
	local dirname = "spaceage/planetsave/" .. string.lower(game.GetMap()) .. "/"
	if not file.Exists(dirname, "DATA") then
		file.CreateDir(dirname)
	end
	for k, v in pairs(SA_MyPlanets) do
		local envname = string.lower(v.sbenvironment.name)
		if envname ~= "no name" then
			file.Write(dirname .. envname .. ".txt", util.TableToJSON(v.sbenvironment))
		end
	end
end

concommand.Add("sa_restart_environment", function(ply)
	if ply:GetLevel() < 3 then return end
	for k, v in pairs(SA_MyPlanets) do
		local envname = string.lower(v.sbenvironment.name)
		local filename = "spaceage/planetsave/" .. string.lower(game:GetMap()) .. "/" .. envname .. "_default.txt"
		if file.Exists(filename, "DATA") then
			local envfile = file.Read(filename)
			local envdata = util.JSONToTable(envfile)
			envdata.bloom = v.sbenvironment.bloom
			envdata.color = v.sbenvironment.color
			v.sbenvironment = envdata
			SA_DefEnvs[envname] = envdata
			SA_DefEnvsA[envname] = envdata.air
		end
	end
	SA.Planets.Save()
end)

concommand.Add("sa_print_environment", function(ply)
	if ply:GetLevel() < 3 then return end
	local env = CAF.GetAddon("Spacebuild").FindClosestPlanet(ply:GetPos(), false)
	local name = env:GetEnvironmentName()
	local pos = env:GetPos()
	local size = env:GetSize()
	ply:ChatPrint(name)
	ply:ChatPrint(tostring(pos))
	ply:ChatPrint(tostring(size))
	ply:ChatPrint(tostring(ply:GetPos().z - pos.z))
end)

