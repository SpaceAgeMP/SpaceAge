local AllAsteroids = {
	{ "models/ce_ls3additional/asteroids/asteroid_200.mdl", 400 },
	{ "models/ce_ls3additional/asteroids/asteroid_250.mdl", 500 },
	{ "models/ce_ls3additional/asteroids/asteroid_300.mdl", 600 },
	{ "models/ce_ls3additional/asteroids/asteroid_350.mdl", 700 },
	{ "models/ce_ls3additional/asteroids/asteroid_400.mdl", 800 },
	{ "models/ce_ls3additional/asteroids/asteroid_450.mdl", 900 },
	{ "models/ce_ls3additional/asteroids/asteroid_500.mdl", 1000 },
}

SA.Asteroids = {}
SA.Asteroids.MaxCount = 0

local SA_Roid_Count = 0

function SA.Asteroids.OnRemove(ent)
	if (ent.RespOnRemove == true) then
		ent.RespOnRemove = false
		SA_Roid_Count = SA_Roid_Count - 1
	end
end

local function SpawnAsteroid(model, pos, size)
	if ( SA_Roid_Count >= SA.Asteroids.MaxCount ) then
		return
	end
	SA_Roid_Count = SA_Roid_Count + 1

	local asteroid = ents.Create("sa_roid")
	asteroid:SetModel( model )
	asteroid:SetPos( pos )
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
	asteroid.health = size * 3
	asteroid.maxhealth = size * 3
	SA.PP.MakeOwner(asteroid)
end

local function CreateAsteroids(cnt,noamount)
	local Afield = {}
	local filename = "spaceage/asteroids/" .. game.GetMap() .. ".txt"
	local roids
	if file.Exists(filename, "DATA") then
		roids = util.JSONToTable(file.Read(filename))
		Afield.x, Afield.y, Afield.z, Afield.radius, Afield.num = roids["x"], roids["y"], roids["z"], roids["radius"], roids["amount"]
	else
		return
	end
	if not noamount then
		SA.Asteroids.MaxCount = roids["amount"]
	end
	if (cnt ~= 0) then
		Afield.num = cnt
	end
	for k = 1, Afield.num do
		local picked = math.random(1,table.Count(AllAsteroids))
		SpawnAsteroid(AllAsteroids[picked][1],Vector(Afield.x + math.random(-Afield.radius,Afield.radius),Afield.y + math.random(-Afield.radius,Afield.radius),Afield.z + (math.random(-Afield.radius,Afield.radius) / 2)),AllAsteroids[picked][2])
	end
end
timer.Simple(5,function() CreateAsteroids(0) end)


concommand.Add("sa_respawn_asteroids",function(ply)
	if ply:GetLevel() < 3 then return end
	for k,v in pairs(ents.FindByClass("sa_roid")) do
		v.RespOnRemove = false
		v:Remove()
	end
	SA_Roid_Count = 0
	CreateAsteroids(0,true)
	if (ply and ply:IsPlayer()) then
		SystemSendMSG(ply,"respawned all asteroids")
	end
end)

local LastSpawn = 0
timer.Create("SA_AsteroidReplenishment",1,0,function()
	if SA_Roid_Count >= SA.Asteroids.MaxCount then return end
	local DelayFactor = (SA_Roid_Count ^ 2) / 10
	if ((LastSpawn + DelayFactor) < CurTime()) then
		CreateAsteroids(1)
		LastSpawn = CurTime()
	end
end)
