local SA_SmokeSpeed = 200
local SA_SmokeWindSpeed = SA_SmokeSpeed / 10
local SA_SmokeTable = {}
local SA_SmokeSpawners = {}

local function SA_StopSmoke(id,doremove)
	if not SA_SmokeTable[id] then return end
	timer.Remove("SA_SmokeWind_" .. id)
	timer.Remove("SA_RemoveSmoke_" .. id)
	local smokeEnt = SA_SmokeTable[id]
	if (smokeEnt:IsValid() and doremove) then smokeEnt:Remove() end
	SA_SmokeTable[id] = nil
end

local function SA_StopSmokeSpawner(id)
	if not SA_SmokeSpawners[id] then return end
	SA_SmokeSpawners[id] = nil
	timer.Remove("SA_SpawnSmoke_" .. id)
end

local function SA_DeleteAllSmoke()
	if SA_SmokeSpawners then
		for k,v in pairs(SA_SmokeSpawners) do
			SA_StopSmokeSpawner(k)
		end
	end
	if SA_SmokeTable then
		for k,v in pairs(SA_SmokeTable) do
			SA_StopSmoke(k,true)
		end
	end

	for k,v in pairs(ents.FindByClass("env_smoketeail")) do
		v:Remove()
	end
	SA_SmokeTable = {}
	SA_SmokeSpawners = {}
end
SA_DeleteAllSmoke()

local function SA_NewSmoke(id,startPos,endPosT,noWind,windAfter) --endPos is either VECTOR or NUMBER (height)
	if not id then return end
	if not startPos then return end
	if not endPosT then return end
	endPos = Vector(0,0,tonumber(endPosT))
	local smoke = ents.Create("env_smoketrail")
	smoke:SetPos(startPos)
	smoke:SetAngles(Angle(0,0,0))
	smoke:Spawn()
	smoke:Activate()
	smoke:SetMoveType(MOVETYPE_NOCLIP)
	smoke:SetVelocity(endPos:GetNormal() * SA_SmokeSpeed)
	id = id .. "_" .. smoke:EntIndex()
	SA_StopSmoke(id,true)
	SA_SmokeTable[id] = smoke
	local smokeTime = endPosT / SA_SmokeSpeed
	timer.Create("SA_RemoveSmoke_" .. id,smokeTime,0,function() SA_StopSmoke(id,true) end)
	if not noWind then
		local windAfterTime = 0
		if windAfter then
			windAfterTime = windAfter / SA_SmokeSpeed
		end
		timer.Simple(windAfterTime, function()
			timer.Create("SA_SmokeWind_" .. id,0.1,0,function() smoke:SetVelocity(Vector(SA_SmokeWindSpeed,0,0)) end)
		end)
	end
end

local function SA_NewSmokeSpawner(id,startPos,endPosT,noWind,windAfter)
	if not (id and startPos and endPosT) then return end
	SA_StopSmokeSpawner(id)
	SA_SmokeSpawners[id] = true
	timer.Create("SA_SpawnSmoke_" .. id,1,0,function() SA_NewSmoke(id,startPos,endPosT,noWind,windAfter) end)
end

local function SA_MapSmokers()
	SA_DeleteAllSmoke()
	local mapname = game.GetMap()
	local mapSmokers = {}
	--[[if mapname == "sb_gooniverse" then
		mapSmokers = {
			{"factory1",Vector(3962.6250,-10867.1563,-1815.1250),400,nil,200},
			{"factory2",Vector(3839.1563,-10866.7188,-1739.5938),400,nil,200},
			{"factory3",Vector(3710.3438,-10864.2500,-1817.8438),400,nil,200},
			{"factory4",Vector(3836.7813,-10420.9688,-1746.0625),400,nil,200}
		}
	end]]
	for k,v in pairs(mapSmokers) do
		SA_NewSmokeSpawner(v[1],v[2],v[3],v[4],v[5])
	end
end
timer.Simple(0,SA_MapSmokers)
