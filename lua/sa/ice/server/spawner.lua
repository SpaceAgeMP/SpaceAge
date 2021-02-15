SA.REQUIRE("random")
SA.REQUIRE("config")
SA.REQUIRE("ice.main")
SA.REQUIRE("ice.types")

local AllAsteroids = {
	{ model = "models/props_wasteland/rockgranite04a.mdl" },
	{ model = "models/props_wasteland/rockgranite04b.mdl" },
}
local AllAsteroidsCount = #AllAsteroids

local IceMaterial = "models/shiny"

local function CalcRing(inrad, outrad, angle)
	local RandAng = math.rad(math.random(0, 360))
	return (angle:Right() * math.sin(RandAng) + angle:Forward() * math.cos(RandAng)) * math.random(tonumber(inrad), tonumber(outrad))
end

function SA.Ice.SpawnRoidRing(iceType, data)
	local asteroid_type = AllAsteroids[math.random(1, AllAsteroidsCount)]
	local ent = ents.Create("sa_iceroid")

	local IceData = SA.Ice.Types[iceType]

	ent:SetColor(IceData.col)
	ent:SetModel(asteroid_type.model)
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
	until SA.IsValidRoidPos(pos)

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
