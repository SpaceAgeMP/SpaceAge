SA.REQUIRE("random")
SA.REQUIRE("config")
SA.REQUIRE("ore.main")

local AllAsteroids = {
	{ model = "models/ce_ls3additional/asteroids/asteroid_200.mdl", size = 1200 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_250.mdl", size = 1500 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_300.mdl", size = 1800 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_350.mdl", size = 2100 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_400.mdl", size = 2400 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_450.mdl", size = 2700 },
	{ model = "models/ce_ls3additional/asteroids/asteroid_500.mdl", size = 3000 },
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
		until SA.IsValidRoidPos(pos)
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
