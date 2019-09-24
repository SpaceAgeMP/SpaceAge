AddCSLuaFile("autorun/client/cl_sa_teleporters.lua")

SA.Teleporter = {}

local SA_TeleportLocs = {}
local SA_TeleporterLocs = {}
local SA_TeleportNames = {}

local function AddSATeleporter(name,TeleportLocs,TeleporterLocs)
	SA_TeleportLocs[name] = TeleportLocs
	SA_TeleporterLocs[name] = TeleporterLocs
	table.insert(SA_TeleportNames,name)
end

local function InitSATeleporters()
	for k,v in pairs(ents.FindByClass("teleport_panel")) do v:Remove() end
	local mapname = string.lower(game:GetMap())
	if mapname == "sb_gooniverse" then
		AddSATeleporter("Terminal planet",{Vector(-107.3,363.4,4624),Vector(-242,335.8,4624),Vector(-388,295.5,4624) },{ { Vector(-464.3,226,4692.4),Angle(0,15,90) } })
		AddSATeleporter("Tiberium planet",{Vector(3981.2,-10679.4,-2037.6),Vector(3991.8,-10572.6,-2037.6),Vector(4087.3,-10492.2,-2037.6) },{ { Vector(4052.3,-10809.3,-1974.5),Angle(0,90,0) } })
		AddSATeleporter("Spawn planet", {Vector(-10746.2,-7594.7,-8095.9),Vector(-10737.8,-7325.8,-8095.9),Vector(-10732.4,-7152,-8095.9) },{ { Vector(-11085.7,-2945.1,-8003.6),Angle(0,-90,0)} })
	elseif mapname == "sb_forlorn_sb3_r2l" then
		AddSATeleporter("Terminal station",{Vector(9551.2,10629,830),Vector(9400.1,10634.3,830),Vector(9156.1,10642.4,830) },{ { Vector(9803,10775.4,889.9),Angle(0,-90,-0) } })
		AddSATeleporter("Tiberium planet",{Vector(10563.2,11922.6,-8857.6),Vector(10661.3,11840.2,-8857.2),Vector(10718.4,11787.4,-8856.9) },{ { Vector(10441,11944.4,-8797.5),Angle(-0,-38,-0) } })
		AddSATeleporter("Spawn planet",{Vector(7492,-11339.4,-9233.9),Vector(7499,-11126.4,-9233.9),Vector(7506.7,-10855.1,-9233.9) },{ { Vector(7611.5,-11516.4,-9055),Angle(-0,90,0) } })
	elseif mapname == "sb_forlorn_sb3_r3" then
		AddSATeleporter("Terminal station",{Vector(9551.2,10629,830),Vector(9400.1,10634.3,830),Vector(9156.1,10642.4,830) },{ { Vector(9803,10775.4,889.9),Angle(0,-90,-0) } })
		AddSATeleporter("Tiberium planet",{Vector(10563.2,11922.6,-8857.6),Vector(10661.3,11840.2,-8857.2),Vector(10718.4,11787.4,-8856.9) },{ { Vector(10441,11944.4,-8797.5),Angle(-0,-38,-0) } })
		AddSATeleporter("Spawn planet",{Vector(7492,-11339.4,-9233.9),Vector(7499,-11126.4,-9233.9),Vector(7506.7,-10855.1,-9233.9) },{ { Vector(7611.5,-11516.4,-9055),Angle(-0,90,0) } })
	elseif mapname == "sb_new_worlds_2" then
		AddSATeleporter("Terminal station",{Vector(-8521.5,-8549.9,-11319.9),Vector(-8317.5,-8555.2402,-11319.9),Vector(-8128.8,-8560.1475,-11319.9) },{ { Vector(-8309.8,-8777.2,-11263.6),Angle(-45,90,-0) } })
		AddSATeleporter("Tiberium planet",{Vector(8909.4,-7019.2,-7625.7),Vector(8775.8,-7106.6,-7623.9),Vector(8679.2,-7173.8,-7622.5) },{ { Vector(8943.7,-6945.7,-7556),Angle(-0,-140,0) } })
		AddSATeleporter("Spawn planet",{Vector(-6064.8,-3057.7,3),Vector(-6066.8,-2861.4,3),Vector(-6069.4,-2601.2,3) },{ { Vector(-6038.1,-3191.3,68.1),Angle(-0,90,0) } })
	elseif mapname == "sb_wuwgalaxy_fix" then
		AddSATeleporter("Terminal station",{Vector(9142,4926,7068),Vector(9142,5042,7068),Vector(9142,5158,7068) },{ { Vector(9227,4934,7071),Angle(0,180,0) } })
		AddSATeleporter("Asteroid",{Vector(-7941,-8573,-11241),Vector(-7941,-8699,-11241),Vector(-7941,-8829,-11241) },{ { Vector(-7888,-8610,-11238),Angle(0,180,0) } })
		AddSATeleporter("Forlorn",{Vector(8802,-11445,-9900),Vector(8802,-11300,-9900),Vector(8802,-11155,-9900) },{ { Vector(8812,-11516,-9958),Angle(0,90,0) } })
	elseif mapname == "gm_galactic_rc1" then
		AddSATeleporter("Gas Station (Terminal)",{Vector(-9075, 10650, 705), Vector(-8817, 10624, 705), Vector(-8946, 10624, 705)},{{Vector(-8744, 10635, 766), Angle(0, -180, 0)}})
		AddSATeleporter("Space Ship",{Vector(10710, 2591, 361), Vector(10785, 2485, 361), Vector(10894, 2485, 361)},{{Vector(10672, 2518, 420), Angle(0, 0, 0)}})
	end
	for ke,ve in pairs(SA_TeleporterLocs) do
		for k,v in pairs(ve) do
			local tele = ents.Create("teleport_panel")
			local phys = tele:GetPhysicsObject()
			if phys and phys.IsValid and phys:IsValid() then
				phys:EnableMotion(false)
			end
			tele:SetPos(v[1])
			tele:SetAngles(v[2])
			tele.TeleKey = ke
			SA.PP.MakeOwner(tele)
			tele.Autospawned = true
			tele.CDSIgnore = true
			tele:Spawn()
		end
	end
end
timer.Simple(2,InitSATeleporters)

concommand.Add("sa_teleporter_update",function(ply,cmd,args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	if ply.LastTeleKey == ply.AtTeleporter then return end
	net.Start("SA_TeleporterUpdate")
		net.WriteInt(#SA_TeleportNames - 1, 16)
		for k,v in pairs(SA_TeleportNames) do
			if v ~= ply.AtTeleporter then
				net.WriteString(v)
			end
		end
	net.Send(ply)
	ply.LastTeleKey = ply.AtTeleporter
end)

local function AbortTeleport(ply,cmd,args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	ply.AtTeleporter = nil
	net.Start("SA_HideTeleportPanel")
		net.WriteBool(false)
	net.Send(ply)
	hook.Remove("KeyPress", "SA_TeleAbortMove_" .. ply:EntIndex())
end
concommand.Add("sa_teleporter_cancel",AbortTeleport)

concommand.Add("sa_teleporter_do",function(ply,cmd,args)
	if not (ply and ply.IsValid and ply:IsValid() and ply.AtTeleporter) then return end
	local TeleKey = string.Implode(" ",args)
	if ply.AtTeleporter == TeleKey then return end
	if not TeleKey then ply:ChatPrint("NO TELEPORT LOCATION") return end
	local TeleTBL = SA_TeleportLocs[TeleKey]
	if not TeleTBL then ply:ChatPrint("INVALID TELEPORT LOCATION") return end
	ply.LastTeleKey = nil
	AbortTeleport(ply)
	ply:SetPos(table.Random(TeleTBL))
end)

function SA.Teleporter.Open(ply,TeleKey)
	if not (ply and ply.IsValid and ply:IsValid()) then return end
	if ply.AtTeleporter then return end
	ply.AtTeleporter = TeleKey
	net.Start("SA_OpenTeleporter")
		net.WriteString(TeleKey)
	net.Send(ply)
	hook.Add("KeyPress", "SA_TeleAbortMove_" .. ply:EntIndex(),function(ply, key)
		if key ~= IN_USE and ply and ply.IsValid and ply:IsValid() then
			AbortTeleport(ply)
			hook.Remove("KeyPress","SA_TeleAbortMove_" .. ply:EntIndex())
		end
	end)
end
