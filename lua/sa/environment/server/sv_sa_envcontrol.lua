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
	local dirname = "sa_planetsave/" .. game.GetMap():lower() .. "/"
	if not file.Exists(dirname, "DATA") then
		file.CreateDir(dirname)
	end

	local config = SA.Config.Load("environments")
	if not config then
		config = {}
	end
	if not config.Add then
		config.Add = {}
	end
	if not config.Remove then
		config.Remove = {}
	end
	if not config.Rename then
		config.Rename = {}
	end
	if not config.Terraform then
		config.Terraform = {}
	end
	if not config.Protect then
		config.Protect = {}
	end

	for k, v in pairs(ents.FindByClass("base_sb_planet*")) do
		if (v.SA_Created) then
			print("Found SpaceAge environment: " .. v.sbenvironment.name .. "! Removing!")
			v:Remove()
		elseif table.HasValue(config.Remove, string.lower(v.sbenvironment.name)) then
			print("Found ToRemove environment: " .. v.sbenvironment.name .. "! Removing!")
			v:Remove()
		end
	end
	for k, v in pairs(config.Add) do
		local position = Vector(unpack(v.Position))

		local planet = ents.Create("base_sb_planet2")
		planet:SetModel("models/props_lab/huladoll.mdl")
		planet:SetPos(position)
		planet:Spawn()

		local closestPlan = SB.FindClosestPlanet(position, false)
		local plSB = closestPlan.sbenvironment
		planet.sbenvironment.bloom = table.Copy(plSB.bloom)
		planet.sbenvironment.color = table.Copy(plSB.color)
		planet:CreateEnvironment(0, 0, 0, 0, 0, 0, 0, 0, v.Name)
		planet:UpdateSize(0, v.Radius)
		planet:PhysicsInit(SOLID_NONE)
		planet:SetMoveType(MOVETYPE_NONE)
		planet:SetSolid(SOLID_NONE)
		planet.sbenvironment.temperature2 = 0
		planet.sbenvironment.sunburn = false
		planet.sbenvironment.unstable = false
		planet:SetNotSolid(true)
		planet:DrawShadow(false)
		planet:SetRenderMode(RENDERMODE_NONE)
		planet.sbenvironment.name = v.Name
		planet.SA_Created = true
		planet.MyPriority = 2
		SA.Planets.MakeHabitable(planet)
		MakePlanetProtected(planet)
	end
	local envname
	for k, v in pairs(ents.FindByClass("base_sb_planet*")) do
		envname = string.lower(v.sbenvironment.name)
		if config.Rename[envname] then
			v.sbenvironment.name = config.Rename[envname]
			envname = string.lower(v.sbenvironment.name)
		end
		if (table.HasValue(config.Terraform, envname)) then
			print("Making planet \"" .. v.sbenvironment.name .. "\" habitable!")
			SA.Planets.MakeHabitable(v)
		end
		if (table.HasValue(config.Protect, envname)) then
			MakePlanetProtected(v)
			v.sbenvironment.pressure = 1
			v.sbenvironment.atmosphere = 1
			print("Protecting planet \"" .. v.sbenvironment.name .. "\"!")
		elseif envname ~= "no name" and not v.IsProtected then
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
timer.Simple(2, InitHabitablePlanets)

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
	local dirname = "sa_planetsave/" .. game.GetMap():lower() .. "/"
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
		local filename = "sa_planetsave/" .. game.GetMap():lower() .. "/" .. envname .. "_default.txt"
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

timer.Simple(10, function()
	for k,v in pairs(ents.FindByModel("models/props_lab/huladoll.mdl")) do
		v:SetRenderMode(RENDERMODE_NONE)
	end
end)
