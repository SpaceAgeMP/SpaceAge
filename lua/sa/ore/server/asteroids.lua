SA.REQUIRE("config")

local AllAsteroids = {
	{ "models/ce_ls3additional/asteroids/asteroid_200.mdl", 1200 },
	{ "models/ce_ls3additional/asteroids/asteroid_250.mdl", 1500 },
	{ "models/ce_ls3additional/asteroids/asteroid_300.mdl", 1800 },
	{ "models/ce_ls3additional/asteroids/asteroid_350.mdl", 2100 },
	{ "models/ce_ls3additional/asteroids/asteroid_400.mdl", 2400 },
	{ "models/ce_ls3additional/asteroids/asteroid_450.mdl", 2700 },
	{ "models/ce_ls3additional/asteroids/asteroid_500.mdl", 3000 },
}
local AllAsteroidsCount = #AllAsteroids

SA.Asteroids = {}
SA.Asteroids.MaxCount = 0

local SA_Roid_Count = 0

function SA.Asteroids.OnRemove(ent)
	if ent.RespOnRemove == true then
		ent.RespOnRemove = false
		SA_Roid_Count = SA_Roid_Count - 1
	end
end

local function SpawnAsteroid(model, pos, size)
	if SA_Roid_Count >= SA.Asteroids.MaxCount then
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
		cnt = SA.Asteroids.MaxCount
	end

	for k = 1, cnt do
		local picked = math.random(1, AllAsteroidsCount)
		local pos
		repeat
			pos = Vector(roids.x + math.random(-roids.radius, roids.radius), roids.y + math.random(-roids.radius, roids.radius), roids.z + (math.random(-roids.radius, roids.radius) / 2))
		until SA.IsInsideMap(pos)
		SpawnAsteroid(AllAsteroids[picked][1], pos, AllAsteroids[picked][2])
	end
end

local function RespawnAllAsteroids()
	roids = SA.Config.Load("asteroids")
	if not roids then
		return
	end

	SA.Asteroids.MaxCount = roids.amount

	for k, v in pairs(ents.FindByClass("sa_roid")) do
		v.RespOnRemove = false
		v:Remove()
	end
	SA_Roid_Count = 0

	CreateAsteroids(0)
end
timer.Simple(5, RespawnAllAsteroids)


concommand.Add("sa_respawn_asteroids", function(ply)
	if ply:GetLevel() < 3 then return end
	RespawnAllAsteroids()
	if (ply and ply:IsPlayer()) then
		print(ply, "respawned all asteroids")
	end
end)

local LastSpawn = 0
timer.Create("SA_AsteroidReplenishment", 1, 0, function()
	if SA_Roid_Count >= SA.Asteroids.MaxCount then return end
	local DelayFactor = (SA_Roid_Count ^ 2) / 10
	if (LastSpawn + DelayFactor) < CurTime() then
		CreateAsteroids(1)
		LastSpawn = CurTime()
	end
end)
