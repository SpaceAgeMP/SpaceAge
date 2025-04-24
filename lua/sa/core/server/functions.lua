SA.Functions = SA.Functions or {}

function SA.SendBasicInfo(ply)
	ply.sa_data.credits = math.floor(ply.sa_data.credits)
	ply.sa_data.score = math.floor(ply.sa_data.score)
	ply:SetNWString("score", ply.sa_data.score)
	net.Start("SA_SendBasicInfo")
		net.WriteString(ply.sa_data.credits)
		net.WriteUInt(ply.sa_data.playtime, 32)
		net.WriteUInt(ply.sa_data.prestige_level, 32)
	net.Send(ply)
end

function SA.Functions.PropMoveSlow(ent, endPos, speed)
	if not speed then speed = 20 end
	local entID = ent:EntIndex()
	--timer.Remove("SA_StopMovement_" .. entID)
	timer.Remove("SA_ControlMovement_" .. entID)
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
	timer.Create("SA_ControlMovement_" .. entID, 0.01, 0, function()
		timePassed = timePassed + 0.01
		if not (ent:IsValid()) then timer.Remove("SA_ControlMovement_" .. entID) return end
		local shouldBe = startPos + (diffVecN * (speed * timePassed))
		if phys and phys.IsValid and phys:IsValid() then
			phys:EnableMotion(false)
		end
		ent:SetPos(shouldBe)
		ent:SetAngles(startAngle)
		if shouldBe == endPos or timePassed >= veloTime or shouldBe:Distance(endPos) <= 1 then
			ent:SetPos(endPos)
			timer.Remove("SA_ControlMovement_" .. entID)
		end
	end)
end

function SA.Functions.MineThing(ent, hitent, resType)
	local own = ent:CPPIGetOwner()
	if not IsValid(own) or own.IsAFK then return end

	if hitent.health <= 0 then
		hitent:Remove()
		return
	end

	local amount = ent.yield
	local damage = ent.damage
	if hitent.health <= damage then
		amount = math.floor(ent.yield * (hitent.health / damage))
		damage = hitent.health
		hitent:Remove()
	end
	ent:SupplyResource(resType, amount)
	hitent.health = hitent.health - ent.damage
end
