SA.Terraformer = {}

local RD = CAF.GetAddon("Resource Distribution")
local SB = CAF.GetAddon("Spacebuild")

local function SA_Terraformer_PushAtmosphere(terent,resName,atmoname,amount)
	RD.ConsumeResource(terent,resName,amount)
	local terair = terent.environment.sbenvironment.air
	if terair.empty < amount then
		local neededAm = amount - terair.empty
		terair.empty = 0
		if terair.n > 0 then
			if terair.n > neededAm then
				terair.n = terair.n - neededAm
				neededAm = 0
			else
				neededAm = neededAm - terair.n
				terair.n = 0
			end
		end
		if neededAm > 0 and terair.h > 0 then
			if terair.h > neededAm then
				terair.h = terair.h - neededAm
				neededAm = 0
			else
				neededAm = neededAm - terair.h
				terair.h = 0
			end
		end
		if atmoname ~= "co2" and neededAm > 0 and (terair.co2 / terair.max) > 0.80 and terair.co2 > neededAm  then
			terair.co2 = terair.co2 - neededAm
			neededAm = 0
		end
		if atmoname ~= "o2" and neededAm > 0 and (terair.o2 / terair.max) > 0.10 and terair.o2 > neededAm  then
			terair.o2 = terair.o2 - neededAm
			neededAm = 0
		end
		amount = amount - neededAm
	else
		terair.empty = terair.empty - amount
	end
	terair[atmoname] = terair[atmoname] + amount
end

local function SA_Terraformer_Sparks(terent)
		local Rep = ents.Create("point_tesla")
		Rep:SetKeyValue("targetname", "teslab")
		Rep:SetKeyValue("m_SoundName", "DoSpark")
		Rep:SetKeyValue("texture", "sprites/physbeam.spr")
		Rep:SetKeyValue("m_Color", "200 200 255")
		Rep:SetKeyValue("m_flRadius", 1000)
		Rep:SetKeyValue("beamcount_min", 2)
		Rep:SetKeyValue("beamcount_max", 5)
		Rep:SetKeyValue("thick_min", 2)
		Rep:SetKeyValue("thick_max", 8)
		Rep:SetKeyValue("lifetime_min", "0.1")
		Rep:SetKeyValue("lifetime_max", "0.2")
		Rep:SetKeyValue("interval_min", "0.05")
		Rep:SetKeyValue("interval_max", "0.08")
		local OBBMid = terent:OBBCenter()
		local OBBMax = terent:OBBMaxs()
		local SparPos = terent:LocalToWorld(Vector(OBBMid.x, OBBMid.y, OBBMax.z))
		Rep:SetPos(SparPos)
		Rep:Spawn()
		Rep:Fire("DoSpark","",0)
		Rep:Fire("kill","", 1)
end

local function SA_Terraformer_Explosion(terent)
		local OBBMins = terent:OBBMins()
		local OBBMaxs = terent:OBBMaxs()
		local vPoint = terent:LocalToWorld(Vector(math.random(OBBMins.x,OBBMaxs.x),math.random(OBBMins.y,OBBMaxs.y),math.random(OBBMins.z,OBBMaxs.z)))
		local effectdata = EffectData()
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 1 )
		effectdata:SetMagnitude( 1 )
		util.Effect( "Explosion", effectdata )
end

function SA.Terraformer.Run(terent)
	local ply = SA.PP.GetOwner(terent)
	if not (ply and ply:IsValid() and ply:IsPlayer()) then return end

	if terent.environment.IsProtected or (not terent.environment:IsPlanet()) or terent.environment == SB.GetSpace() then return end
	local energy = RD.GetResourceAmount(terent, "energy")
	local o2 = RD.GetResourceAmount(terent, "oxygen")
	local dm = RD.GetResourceAmount(terent, "dark matter")
	local tc = RD.GetResourceAmount(terent, "terracrystal")
	local pf = RD.GetResourceAmount(terent, "permafrost")
	local terenv = terent.environment
	local tersbenv = terenv.sbenvironment
	local terair = tersbenv.air
	if (terent.State < 1) then
		terent:SetState(1)
		terent.StateTicks = 1
	end
	if terent.State > 1 then
		if energy < 10000 then
			terent:TurnOff()
			return
		else
			RD.ConsumeResource(terent, "energy", 10000)
		end
	end
	if tc < 10000 then
		if terent.State > 1 then
			terent:ChangeStability(math.random(-30,-10))
			return
		else
			terent:TurnOff()
			return
		end
	else
		RD.ConsumeResource(terent, "terracrystal", 10000)
	end
	if terent.State == 1 then --Boot up sequence
		if terent.StateTicks > 10 then
			terent:SetState(2)
		else
			if energy < 100000 then
				terent:TurnOff()
				return
			else
				RD.ConsumeResource(terent, "energy", 100000)
			end
		end
	elseif terent.State == 2 then --Gravity adaption
		if tersbenv.gravity > 1.1 then
			tersbenv.gravity = tersbenv.gravity - 0.1
		elseif tersbenv.gravity < 0.9 then
			tersbenv.gravity = tersbenv.gravity + 0.1
		else
			tersbenv.gravity = 1
			terent:SetState(3)
		end
	elseif terent.State == 3 then --Pressure adaption
		if tersbenv.pressure > 1.1 then
			tersbenv.pressure = tersbenv.pressure - 0.1
		elseif tersbenv.pressure < 0.9 then
			tersbenv.pressure = tersbenv.pressure + 0.1
		else
			tersbenv.pressure = 1
			terent:SetState(4)
		end
		tersbenv.atmosphere = tersbenv.pressure
	elseif terent.State == 4 then --We need to make sure the planet is terraformable (temperature 1 adaption)
		local tempe = tersbenv.temperature + (( tersbenv.temperature * ((terenv:GetCO2Percentage() - terair.co2per) / 100)) / 2)
		local tvalid = true
		if tempe > 295 then
			tempe = tersbenv.temperature + (( tersbenv.temperature * ((0 - terair.co2per) / 100)) / 2) --Try what would happen without CO2
			if tempe > 295 then --Nah, not enough :/
				if pf < 1000 then
					terent:ChangeStability(math.random(-30,-10))
					return
				end
				RD.ConsumeResource(terent, "permafrost", 1000)
				terair.temperature = terair.temperature - 1
				tvalid = false
			end
		elseif tempe < 288 then
			tempe = tersbenv.temperature + (( tersbenv.temperature * ((80 - terair.co2per) / 100)) / 2) --Try what would happen with nearly full CO2
			if tempe < 288 then --Nah, not enough :/
				if dm < 1000 then
					terent:ChangeStability(math.random(-30,-10))
					return
				end
				RD.ConsumeResource(terent, "dark matter", 1000)
				tersbenv.temperature = tersbenv.temperature + 1
				tvalid = false
			end
		end
		if tvalid then
			terent:SetState(5)
		end
	elseif terent.State == 5 then --Adapt temp2 to temp1
		local tDiff = tersbenv.temperature2 - tersbenv.temperature
		local tvalid = true
		if tDiff > 1 then
			if pf < 1000 then
				terent:ChangeStability(math.random(-30,-10))
				return
			end
			RD.ConsumeResource(terent, "permafrost", 1000)
			tersbenv.temperature2 = tersbenv.temperature2 - 1
			tvalid = false
		elseif tDiff < -1 then
			if dm < 1000 then
				terent:ChangeStability(math.random(-30,-10))
				return
			end
			RD.ConsumeResource(terent, "dark matter", 1000)
			tersbenv.temperature2 = tersbenv.temperature2 + 1
			tvalid = false
		else
			tersbenv.temperature2  = tersbenv.temperature
		end
		if tvalid then
			terent:SetState(6)
		end
	elseif terent.State == 6 then --The actual terraforming
		local avalid = true
		if (terair.o2 / terair.max) < 0.10 then
			if o2 < 10000 then
				terent:ChangeStability(math.random(-30,-10))
				return
			end
			SA_Terraformer_PushAtmosphere(terent,"oxygen","o2",10000)
			avalid = false
		end
		local ttemp = terenv:GetTemperature(terent)
		if ttemp < 288 then
			SA_Terraformer_PushAtmosphere(terent,"carbon dioxide","co2",10000)
			avalid = false
		elseif ttemp > 295 then
			if terair.co2 > 10000 then
				terair.co2 = terair.co2 - 10000
				terair.empty = terair.empty + 10000
			else
				terair.empty = terair.empty + terair.co2
				terair.co2 =  0
			end
			avalid = false
		end
		if avalid then
			terent:SetState(7)
		end
	elseif terent.State > 6 then
		terent:TurnOff()
		return
	end
end

function SA.Terraformer.SpazzOut(terent,forcekill)
	if terent.FinalSpazzed or terent.environment.IsProtected or (not terent.environment:IsPlanet()) or terent.environment == SB.GetSpace() then return end
	local energy = RD.GetResourceAmount(terent, "energy")
	if terent.State ~= -1 then
		local o2 = RD.GetResourceAmount(terent, "oxygen")
		local co2 = RD.GetResourceAmount(terent, "carbon dioxide")
		local dm = RD.GetResourceAmount(terent, "dark matter")
		local tc = RD.GetResourceAmount(terent, "terracrystal")
		local pf = RD.GetResourceAmount(terent, "permafrost")
		if o2 > 0 then RD.ConsumeResource(terent, "oxygen", o2) end
		if co2 > 0 then RD.ConsumeResource(terent, "carbon dioxide", co2) end
		if dm > 0 then RD.ConsumeResource(terent, "dark matter", dm) end
		if tc > 0 then RD.ConsumeResource(terent, "terracrystal", tc) end
		if pf > 0 then RD.ConsumeResource(terent, "permafrost", pf) end
	end
	terent:SetState(-1)
	if energy < 10000 then
		terent:TurnOff()
		return
	else
		RD.ConsumeResource(terent, "energy", 10000)
	end
	local haschanged = false
	local myenv = terent.environment.sbenvironment
	local envair = myenv.air
	terent:ChangeStability(math.random(-50,-30))
	for k,v in pairs(envair) do
		if string.Right(k,3) == "per" or k == "empty" or k == "max" then
			--Do nothing
		elseif v > 5000000 then
			envair[k] = v - 5000000
			envair["empty"] = envair["empty"] + 5000000
			haschanged = true
		else
			envair["empty"] = envair["empty"] + envair[k]
			envair[k] = 0
		end
	end
	if myenv.temperature >= 25 then
		myenv.temperature = myenv.temperature - 25
		haschanged = true
	else
		myenv.temperature = 0
	end
	if myenv.temperature2 >= 25 then
		myenv.temperature2 = myenv.temperature2 - 25
		haschanged = true
	else
		myenv.temperature2 = 0
	end
	if (not haschanged) or forcekill then
		terent.FinalSpazzed = true
		if math.random(0,1) > 0.5 then
			myenv.temperature = math.random(400,1200)
			myenv.temperature2 = math.random(400,1200)
		else
			myenv.temperature = math.random(10,200)
			myenv.temperature2 = math.random(10,200)
		end
		if (myenv.temperature2 < myenv.temperature) then
			myenv.temperature2 = myenv.temperature + 10
		end
		local leftair = envair.max
		local lastval = math.random(0,leftair)
		envair.h = lastval
		leftair = leftair - lastval
		lastval = math.random(0,leftair)
		envair.n = lastval
		leftair = leftair - lastval
		lastval = math.random(0,leftair)
		envair.co2 = lastval
		leftair = leftair - lastval
		--lastval = math.random(0,leftair)
		--envair.o2 = lastval
		--leftair = leftair - lastval
		envair.empty = leftair
		leftair = 0
		if not forcekill then
			local vPoint = terent:GetPos()
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 2300 )
			effectdata:SetMagnitude( 1 )
			util.Effect( "warpcore_breach", effectdata )
			local shake = ents.Create("env_shake")
			shake:SetKeyValue("amplitude", "16")
			shake:SetKeyValue("duration", "6")
			shake:SetKeyValue("radius", 1)
			shake:SetKeyValue("spawnflags", 5)
			shake:SetKeyValue("frequency", "240")
			shake:SetPos(vPoint)
			shake:Spawn()
			shake:Fire("StartShake","","0.6")
			shake:Fire("kill","","8")
			terent:EmitSound( "explode_9" )
			for k,v in pairs(ents.GetAll()) do
				if (v.Autospawned or v.CDSIgnore or v.environment ~= terent.environment) then
					continue
				end
				if v:IsPlayer() or v:IsNPC() then
					v:Kill()
				elseif v:IsVehicle() then
					for _, pass in pairs({ v:GetPassenger(), v:GetDriver() }) do
						if (pass and pass:IsValid() and (pass:IsPlayer() or pass:IsNPC())) then
							pass:Kill()
						end
					end
					v:Remove()
				else
					v:Remove()
				end
			end
			terent:Remove()
		end
	elseif not forcekill then
		SA_Terraformer_Sparks(terent)
		timer.Simple(0.1,SA_Terraformer_Sparks,terent)
		timer.Simple(0.2,SA_Terraformer_Sparks,terent)
		timer.Simple(0.3,SA_Terraformer_Sparks,terent)
		timer.Simple(0.4,SA_Terraformer_Sparks,terent)
		timer.Simple(0.5,SA_Terraformer_Sparks,terent)
		timer.Simple(0.6,SA_Terraformer_Sparks,terent)
		timer.Simple(0.7,SA_Terraformer_Sparks,terent)
		timer.Simple(0.8,SA_Terraformer_Sparks,terent)
		timer.Simple(0.9,SA_Terraformer_Sparks,terent)
		SA_Terraformer_Explosion(terent)
		timer.Simple(0.5,SA_Terraformer_Explosion,terent)
	end
	local ply = SA.PP.GetOwner(terent)
	if not (ply and ply:IsValid() and ply:IsPlayer()) then return end
end
