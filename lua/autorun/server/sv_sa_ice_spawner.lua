if not SA.Ice then
	SA.Ice = {}
end

local IceTypes = {}
local IceModels = {"models/props_wasteland/rockgranite04a.mdl", "models/props_wasteland/rockgranite04b.mdl"}

local function RegisterIce(Name,col,Start,Max,Regen)
	IceTypes[Name] = { col = col, StartIce = Start, MaxIce = Max, RegenIce = Regen}
end

--RegisterIce(<name>,<color>,<starting ice>,<max ice>,<regen an hour>)
RegisterIce("Blue Ice",Color(75,125,255,75),60,600,60)
RegisterIce("Clear Ice",Color(0,0,0,150),55,550,55)
RegisterIce("Glare Crust",Color(125,125,125,150),50,500,50)
RegisterIce("Glacial Mass",Color(175,200,255,100),45,450,45)
RegisterIce("White Glaze",Color(200,200,200,100),40,400,40)
RegisterIce("Gelidus",Color(25,175,255,75),35,350,35)
RegisterIce("Krystallos",Color(0,0,0,75),30,300,30)
RegisterIce("Dark Glitter",Color(0,0,0,255),25,275,27)

local IceMaterial = "models/shiny"

local function Calc_Ring(inrad, outrad, angle)
	local RandAng = math.rad(math.random(0,360))
	return (angle:Right() * math.sin(RandAng) + angle:Forward() * math.cos(RandAng)) * math.random(tonumber(inrad),tonumber(outrad))
end

function SA.Ice.SpawnRoid(Type,data)
	local ent = ents.Create("iceroid")

	local IceData = IceTypes[Type]

	ent:SetColor(IceData.col.r,IceData.col.g,IceData.col.b,IceData.col.a)
	ent:SetModel(table.Random(IceModels))
	ent:SetMaterial(IceMaterial)
	ent.MineralName = Type
	ent.MineralAmount = IceData.StartIce
	ent.MineralMax = IceData.MaxIce
	ent.MineralRegen = IceData.RegenIce
	ent.RespawnDelay = math.random(1600,2000)

	ent.data = data
	ent:SetPos(data.pos + Calc_Ring(data.inrad,data.outrad,data.ang))
	ent:SetAngles( Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)) )
	ent:Spawn()
	ent:Activate()
	ent.Autospawned = true
	SA.PP.MakeOwner(ent)
	return ent
end

local function AM_Spawn_Ice(tbl)
	for _,ice in pairs(tbl) do
		if ice.Type and ice.Origin and ice.Type == "Ring" and ice.InnerRadius and ice.OuterRadius and ice.Angle then
			local RingData = {
				pos = Vector(unpack(ice.Origin:TrimExplode(" "))),
				inrad = unpack(ice.InnerRadius:TrimExplode(" ")),
				outrad = unpack(ice.OuterRadius:TrimExplode(" ")),
				ang = Angle(unpack(ice.Angle:TrimExplode(" ")))
			}

			for _,i in pairs(ice.BlueIce:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Blue Ice",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.ClearIce:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Clear Ice",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.GlacialMass:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Glacial Mass",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.WhiteGlaze:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("White Glaze",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.GlareCrust:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Glare Crust",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.DarkGlitter:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Dark Glitter",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.Gelidus:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Gelidus",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
			for _,i in pairs(ice.Krystallos:TrimExplode(" ")) do
				for a = 1,i do
					local Roid = SA.Ice.SpawnRoid("Krystallos",RingData)
					Roid.MineralAmount = Roid.MineralAmount * 2
				end
			end
		end
	end
end

timer.Simple(1, function()
	local iceTxt = file.Read("spaceage/ice/maps/" .. game.GetMap():lower() .. ".txt")
	if not iceTxt then
		return
	end
	AM_Spawn_Ice(util.JSONToTable(iceTxt))
end)
