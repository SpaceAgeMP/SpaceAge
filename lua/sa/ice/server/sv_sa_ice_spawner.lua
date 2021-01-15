SA_REQUIRE("config")

if not SA.Ice then
	SA.Ice = {}
end

local IceTypes = {}
local IceModels = {"models/props_wasteland/rockgranite04a.mdl", "models/props_wasteland/rockgranite04b.mdl"}

local function RegisterIce(Name, col, Start, Max, Regen)
	IceTypes[Name] = { col = col, StartIce = Start, MaxIce = Max, RegenIce = Regen}
end

--RegisterIce(<name>, <color>, <starting ice>, <max ice>, <regen an hour>)
RegisterIce("Blue Ice", Color(75, 125, 255, 75), 60, 600, 60)
RegisterIce("Clear Ice", Color(0, 0, 0, 150), 55, 550, 55)
RegisterIce("Glare Crust", Color(125, 125, 125, 150), 50, 500, 50)
RegisterIce("Glacial Mass", Color(175, 200, 255, 100), 45, 450, 45)
RegisterIce("White Glaze", Color(200, 200, 200, 100), 40, 400, 40)
RegisterIce("Gelidus", Color(25, 175, 255, 75), 35, 350, 35)
RegisterIce("Krystallos", Color(0, 0, 0, 75), 30, 300, 30)
RegisterIce("Dark Glitter", Color(0, 0, 0, 255), 25, 275, 27)

local IceMaterial = "models/shiny"

local function CalcRing(inrad, outrad, angle)
	local RandAng = math.rad(math.random(0, 360))
	return (angle:Right() * math.sin(RandAng) + angle:Forward() * math.cos(RandAng)) * math.random(tonumber(inrad), tonumber(outrad))
end

function SA.Ice.SpawnRoidRing(iceType, data)
	local ent = ents.Create("iceroid")

	local IceData = IceTypes[iceType]

	ent:SetColor(IceData.col)
	ent:SetModel(table.Random(IceModels))
	ent:SetMaterial(IceMaterial)
	ent.MineralName = iceType
	ent.MineralAmount = IceData.StartIce
	ent.MineralMax = IceData.MaxIce
	ent.MineralRegen = IceData.RegenIce
	ent.RespawnDelay = math.random(1600, 2000)

	ent.IcePattern = "ring"
	ent.IceData = data

	local pos
	repeat
		pos = data.Origin + CalcRing(data.InnerRadius, data.OuterRadius, data.Angle)
	until SA.IsInsideMap(pos)

	ent:SetPos(pos)
	ent:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
	ent:Spawn()
	ent:Activate()
	ent.Autospawned = true

	ent.MineralAmount = ent.MineralAmount * data.MineralAmountMultiplier

	return ent
end

function SA.Ice.SpawnRoid(iceType, pattern, data)
	if pattern == "ring" then
		return SA.Ice.SpawnRoidRing(iceType, data)
	end

	error("Unknown Ice pattern " .. pattern)
end

local function AM_Spawn_Ice(tbl)
	for _, ring in pairs(tbl.Ring) do
		ring.Config.Origin = Vector(unpack(ring.Config.Origin))
		ring.Config.Angle = Angle(unpack(ring.Config.Angle))

		for iceType, iceCount in pairs(ring.Counts) do
			for i = 1, iceCount do
				SA.Ice.SpawnRoidRing(iceType, ring.Config)
			end
		end
	end
end

timer.Simple(1, function()
	local ice = SA.Config.Load("ice")
	if not ice then
		return
	end
	AM_Spawn_Ice(ice)
end)
