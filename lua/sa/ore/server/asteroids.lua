SA.REQUIRE("random")
SA.REQUIRE("config")
SA.REQUIRE("ore.main")

local AllAsteroids = {
	{ model = "models/ce_ls3additional/asteroids/asteroid_200.mdl", size = 1200, mins = Vector(-221.455505, -270.105804, -229.255142), maxs = Vector(278.458405, 234.547714, 239.313370) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_250.mdl", size = 1500, mins = Vector(-288.556854, -289.388702, -267.263580), maxs = Vector(251.217529, 291.029785, 231.219879) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_300.mdl", size = 1800, mins = Vector(-295.745819, -356.820404, -281.769806), maxs = Vector(328.969360, 334.036102, 322.683533) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_350.mdl", size = 2100, mins = Vector(-350.449036, -404.668396, -356.196716), maxs = Vector(420.215881, 391.942169, 374.206818) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_400.mdl", size = 2400, mins = Vector(-464.005341, -467.412537, -376.379608), maxs = Vector(477.348114, 487.325165, 410.702911) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_450.mdl", size = 2700, mins = Vector(-563.345581, -733.006165, -450.250031), maxs = Vector(527.834351, 783.589233, 450.250031) },
	{ model = "models/ce_ls3additional/asteroids/asteroid_500.mdl", size = 3000, mins = Vector(-569.022461, -562.240967, -411.354431), maxs = Vector(574.921814, 560.376221, 466.674377) },
}
local AllAsteroidsCount = #AllAsteroids

SA.Ore.MaxAsteroidCount = 0

local SA_Roid_Count = 0

function SA.Ore.OnAsteroidRemove(ent)
	if ent.RespOnRemove == true then
		ent.RespOnRemove = false
		SA_Roid_Count = SA_Roid_Count - 1
	end
end

local function SpawnAsteroid(model, pos, size)
	if SA_Roid_Count >= SA.Ore.MaxAsteroidCount then
		return
	end
	SA_Roid_Count = SA_Roid_Count + 1

	local asteroid = ents.Create("sa_roid")
	asteroid:SetModel(model)
	asteroid:SetPos(pos)
	asteroid:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
	asteroid:Spawn()
	local phys = asteroid:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)

	asteroid.IsAsteroid = true
	asteroid.RespOnRemove = true
	asteroid.Autospawned = true
	asteroid.CDSIgnore = true
	asteroid.health = size
	asteroid.maxhealth = size
end

local roids

local function CreateAsteroids(cnt)
	if cnt == 0 then
		cnt = SA.Ore.MaxAsteroidCount
	end

	for k = 1, cnt do
		local asteroid_type = AllAsteroids[math.random(1, AllAsteroidsCount)]
		local pos
		repeat
			pos = Vector(roids.x + math.random(-roids.radius, roids.radius), roids.y + math.random(-roids.radius, roids.radius), roids.z + (math.random(-roids.radius, roids.radius) / 2))
		until SA.IsValidRoidPos(pos, asteroid_type.mins, asteroid_type.maxs)
		SpawnAsteroid(asteroid_type.model, pos, asteroid_type.size)
	end
end

local function RespawnAllAsteroids()
	roids = SA.Config.Load("asteroids")
	if not roids then
		return
	end

	SA.Ore.MaxAsteroidCount = roids.amount

	for k, v in pairs(ents.FindByClass("sa_roid")) do
		v.RespOnRemove = false
		v:Remove()
	end
	SA_Roid_Count = 0

	CreateAsteroids(0)
end
timer.Simple(5, RespawnAllAsteroids)


concommand.Add("sa_respawn_asteroids", function(ply)
	if not ply:IsSuperAdmin() then return end
	RespawnAllAsteroids()
	if (ply and ply:IsPlayer()) then
		print(ply, "respawned all asteroids")
	end
end)

local LastSpawn = 0
timer.Create("SA_AsteroidReplenishment", 1, 0, function()
	if SA_Roid_Count >= SA.Ore.MaxAsteroidCount then return end
	local DelayFactor = (SA_Roid_Count ^ 2) / 10
	if (LastSpawn + DelayFactor) < CurTime() then
		CreateAsteroids(1)
		LastSpawn = CurTime()
	end
end)
