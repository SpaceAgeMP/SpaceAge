local PLY = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString("Player_AddHint")
	function PLY:AddHint(txt, typ, len)
		net.Start("Player_AddHint")
			net.WriteString(txt)
			net.WriteInt(typ, 32)
			net.WriteInt(len, 32)
		net.Send(self)
	end
end

if CLIENT then
	function PLY:AddHint(txt, typ, len)
		notification.AddLegacy(txt, typ, len)
	end

	net.Receive("Player_AddHint", function(_, ply)
		local txt = net.ReadString()
		local typ = net.ReadInt(32)
		local len = net.ReadInt(32)
		notification.AddLegacy(txt, typ, len)
	end)
end
