AddCSLuaFile("autorun/client/cl_sa_givequery.lua")
AddCSLuaFile("autorun/client/cl_sa_functions.lua")

local RD = nil
local function InitSAFuncs()
	RD = CAF.GetAddon("Resource Distribution")
end
timer.Simple(0,InitSAFuncs)

SA.Functions = {}

function SA.SendCreditsScore(ply)
	ply.Credits = math.floor(ply.Credits)
	ply.TotalCredits = math.floor(ply.TotalCredits)
	ply:SetNWInt("Score",ply.TotalCredits)
	net.Start("SA_CreditsScore")
		net.WriteString(ply.Credits)
		net.WriteString(ply.TotalCredits)		
	net.Send(ply)
end

function SA.Functions.PropMoveSlow(ent,endPos,speed)
	if not speed then speed = 20 end
	local entID = ent:EntIndex()
	--timer.Destroy("SA_StopMovement_"..entID)
	timer.Destroy("SA_ControlMovement_"..entID)
	local phys = ent:GetPhysicsObject()
	local startPos = ent:GetPos()
	local diffVec = (endPos - startPos)
	local diffVecN = diffVec:GetNormal()
	local startAngle = ent:GetAngles()
	ent.curVelo = (diffVecN * speed)
	if phys and phys.IsValid and phys:IsValid() then
		phys:EnableMotion(false)
	end
	local timePassed = 0
	local veloTime = diffVec:Length() / speed
	timer.Create("SA_ControlMovement_"..entID,0.01,0,function()
		timePassed = timePassed + 0.01
		local ent = ents.GetByIndex(entID)
		if not (ent and ent.IsValid and ent:IsValid()) then timer.Destroy("SA_ControlMovement_"..entID) return end
		local phys = ent:GetPhysicsObject()
		local shouldBe = startPos + (diffVecN * (speed * timePassed))
		if phys and phys.IsValid and phys:IsValid() then
			phys:EnableMotion(false)
		end		
		ent:SetPos(shouldBe)
		ent:SetAngles(startAngle)
		if shouldBe == endPos or timePassed >= veloTime or shouldBe:Distance(endPos) <= 1 then
			ent:SetPos(endPos)
			timer.Destroy("SA_ControlMovement_"..entID)
		end
	end)
	--[[timer.Create("SA_StopMovement_"..entID,veloTime,1,function()
		timer.Destroy("SA_ControlMovement_"..entID)
		if phys and phys.IsValid and phys:IsValid() then
			phys:SetVelocity(Vector(0,0,0))
			phys:EnableMotion(false)
			phys:EnableCollisions(true)
		else
			ent:SetVelocity(ent.curVelo * -1)
		end
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(endPos)
	end)]]
end

function SA.Functions.Discharge(ent)
	local RD = CAF.GetAddon("Resource Distribution")
	local amount = 0
	local Pos = ent:GetPos()
	local Ang = ent:GetAngles()
	local trace = {}
	trace.start = Pos+(Ang:Up()*ent:OBBMaxs().z)
	trace.endpos = Pos+(Ang:Up()*ent.beamlength)
	trace.filter = { ent }
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		local hitent = tr.Entity
		if hitent.IsAsteroid then
			SA.Functions.MineThing(ent,hitent,"ore")
		elseif hitent.IsOreStorage and GetConVar("sa_pirating"):GetBool() then
			local resLeft = RD.GetResourceAmount(hitent, "ore")
			local toUse = math.floor(ent.yield * 1.5)
			if(resLeft < toUse) then toUse = resLeft end
			RD.ConsumeResource(hitent,"ore",toUse)
			RD.SupplyResource(ent, "ore", math.floor(toUse * 0.9))
		elseif hitent:IsPlayer() then
			hitent:TakeDamage(25,ent,ent)
		end		
	end
end

function SA.Functions.MineThing(ent,hitent,resType)
	local own = SA.PP.GetOwner(ent)
	if own and own.IsAFK then return end
	if (hitent.health > 0) then
		if (hitent.health < ent.damage) then 
			amount = math.floor(ent.yield * (hitent.health / ent.damage))
			hitent:Remove()
		else
			amount = ent.yield
		end
		RD.SupplyResource(ent, resType, amount)
		hitent.health = hitent.health - ent.damage
	else
		hitent:Remove()
	end	
end

local bor = bit.bor
local blshift = bit.lshift
local ENT = FindMetaTable("Entity")
function ENT:SetNetworkedColor(name, c)
	local n = bor(c.r, blshift(c.g, 8), blshift(c.b, 16), 255)
    self:SetNetworkedInt(name, n)
end