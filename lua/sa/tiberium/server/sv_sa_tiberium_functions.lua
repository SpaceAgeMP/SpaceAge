SA.Tiberium = {}

function SA.Tiberium.FindFreeAttachPlace(ent, holder)
	if table.HasValue(holder.TouchTable, ent) then return end
	for i = 1, 2 do
		local tmpX = holder.TouchTable[i]
		if not (tmpX and tmpX.IsValid and tmpX:IsValid()) then return i end
	end
end

function SA.Tiberium.AttachStorage(ent, holder, pos)
	if ent.TouchPos then return false end
	if holder:GetModel() ~= "models/slyfo/sat_rtankstand.mdl" then return false end
	if ent:GetModel() ~= "models/slyfo/sat_resourcetank.mdl" then return false end

	local relPos = Vector(0, 0, 0)
	if pos == 1 then
		relPos = Vector(1.0884, 18.9070, 21.4414)
	elseif pos == 2 then
		relPos = Vector(1.0199, -18.7096, 21.4414)
	else
		return false
	end
	ent:SetAngles(holder:GetAngles())
	ent:SetPos(holder:LocalToWorld(relPos))
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return true end
	phys:EnableMotion(true)
	phys:Wake()
	return true
end

function SA.Tiberium.RemoveIntersecting(ent, ignoClasses) --ignoClass IS AND MUST ALWAYS BE A TABLE OR NIL!!!!
	if not ignoClasses then ignoClasses = {} end
	--if string.lower(type(ignoClasses)) == "string" then ignoClasses = {ignoClasses, "sa_mining_drill"} end
	local minPos = ent:LocalToWorld(ent:OBBMins())
	local maxPos = ent:LocalToWorld(ent:OBBMaxs())
	table.insert(ignoClasses, "worldspawn")
	table.insert(ignoClasses, "physgun_beam")
	table.insert(ignoClasses, "predicted_viewmodel")
	for k, v in pairs(ents.FindInBox(minPos, maxPos)) do
		local eClass = v:GetClass()
		if v ~= ent and (not table.HasValue(ignoClasses, eClass)) and (not (v:IsWeapon() or v:IsPlayer() or v:IsNPC())) and v:EntIndex() > 0 then
			local eCG = v:GetCollisionGroup()
			if (eCG == COLLISION_GROUP_WORLD and (not v.Autospawned)) or eClass == "sa_crystal" then
				v:Remove()
			end
		end
	end
end

function SA.Tiberium.FindWorldFloor(fromPos, traceIgno, mayNotHit) --traceIgno AND mayNotHit ARE AND MUST ALWAYS BE A TABLE OR NIL!!!!
	if not traceIgno then traceIgno = {} end
	if not mayNotHit then mayNotHit = {} end
	local i = 0
	while true do
		i = i + 1
		local traceData = nil
		traceData = util.QuickTrace(fromPos, Vector(0, 0, -2000), traceIgno)
		if traceData.HitWorld then
			return traceData.HitPos
		elseif i > 10 then
			return
		elseif traceData.HitNonWorld then
			if table.HasValue(mayNotHit, traceData.Entity) then
				return
			end
			table.Add(traceIgno, traceData.Entity)
		else
			return
		end
	end
end

concommand.Add("sa_respawn_crystals", function(ply)
	if ply:GetLevel() < 3 then return end
	local tempMax = SA_MaxCrystalCount
	SA_MaxCrystalCount = 0
	for k, v in pairs(ents.FindByClass("sa_crystal")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("sa_crystaltower")) do
		v.crystalCount = 0
	end
	SA_MaxCrystalCount = tempMax
	for k, v in pairs(ents.FindByClass("sa_crystaltower")) do
		v:AutoSpawn()
	end
	if (ply and ply:IsPlayer()) then
		SystemSendMSG(ply, " respawned all tiberium crystals")
	end
end)

function SA.Tiberium.DestroyConstraints(Ent1, Ent2, Bone1, Bone2, cType)
	if (not constraint.CanConstrain(Ent1, Bone1)) then return false end
	if (not constraint.CanConstrain(Ent2, Bone2)) then return false end

	local Phys1 = Ent1:GetPhysicsObjectNum(Bone1)
	local Phys2 = Ent2:GetPhysicsObjectNum(Bone2)

	if (Phys1 == Phys2) then return false end

	if (not Ent1:GetTable().Constraints and not Ent2:GetTable().Constraints) then return end
	if (not Ent1:GetTable().Constraints) then -- If our Ent1 is the world, we can't get a constraint table, so switch the entities and look through them that way
		local thirdEnt
		thirdEnt = Ent1
		Ent1 = Ent2
		Ent2 = thirdEnt
	end

	local foundConstraint

	--Next, run through all of the constraints on the entity
	--There's already a function for this, but it doesn't
	--really take into account choosing the world first
	for k, v in pairs(Ent1:GetTable().Constraints) do

		if (v:IsValid()) then -- Continues if it finds a valid constraint

			local CTab = v:GetTable() -- Variableizes all of the attributes of the individual constraint

			if (CTab.Type == cType and CTab.Ent1 == Ent1 and CTab.Ent2 == Ent2 and CTab.Bone1 == Bone1 and CTab.Bone2 == Bone2) or  (CTab.Type == cType and CTab.Ent1 == Ent2 and CTab.Ent2 == Ent1 and CTab.Bone1 == Bone2 and CTab.Bone2 == Bone1) then

				foundConstraint = v -- We've found the constraint we want to destroy

			end
		end
	end

	if not foundConstraint then return false end
	foundConstraint:Remove()
	foundConstraint = nil

	return true
end

local tiberiumTimeUntilDelete = {}

function SA.Tiberium.SetTimeUntilDelete(ent, time)
	tiberiumTimeUntilDelete[ent:EntIndex()] = time
end

function SA.Tiberium.GetTimeUntilDelete(ent)
	return tiberiumTimeUntilDelete[ent:EntIndex()]
end
