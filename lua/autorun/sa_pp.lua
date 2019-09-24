if SERVER then
	AddCSLuaFile()
end

SA.PP = {}

function SA.PP.GetOwner(ent)
	return ent:CPPIGetOwner()
end

function SA.PP.MakeOwner(ent, owner)
	return ent:CPPISetOwner(owner)
end

function SA.PP.IsWorldEnt(ent)
	local _, ownerId = ent:CPPISetOwner()
	return not ownerId
end

function SA.PP.PlyCanPerform(ply, ent)
	return ent:CPPICanPhysgun(ply)
end

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:IsVIP()
	return self.donator
end

function PlayerMeta:GetLevel()
	if self:IsSuperAdmin() then
		return 3
	end
	if self:IsAdmin() then
		return 2
	end
	if self:IsVIP() then
		return 1
	end
	return 0
end
