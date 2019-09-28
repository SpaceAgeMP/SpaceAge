local GTableMeta = getmetatable(_G)
if not GTableMeta then
	GTableMeta = {}
	setmetatable(_G, GTableMeta)
end

if CLIENT then
	file.Write("gvars_client.txt", "")
end
if SERVER then
	file.Write("gvars_server.txt", "")
end

if not GTableMeta.__newindex_sa_checker then
	GTableMeta.__newindex_sa_checker = true

	local oldNewIndex = GTableMeta.__newindex or rawset
	local oldIndex = GTableMeta.__index or rawget

	local detections = {
		SCRIPTNAME = true,
		SCRIPTPATH = true,
		ENT = true,
		SA = true,
		supernet = true,
	}

	local function GVDetector(tbl, idx)
		if detections[idx] then
			return
		end

		local tbidx = 2
		local tb

		repeat
			tbidx = tbidx + 1
			tb = debug.getinfo(tbidx, "S")
			if not tb or not tb.short_src then
				return
			end
		until tb.name ~= "__newindex" and tb.name ~= "__index"

		if tb.short_src:sub(1, 16) ~= "addons/spaceage/" then
			return
		end

		detections[idx] = true

		local side
		if CLIENT then
			side = "client"
		end
		if SERVER then
			side = "server"
		end

		local str = idx .. " " .. tostring(tb.short_src) .. " @ " .. tostring(tb.linedefined) .. "\n"
		file.Append("gvars_" .. side .. ".txt", str)
		print("GVars DETECTOR on ", side, str)
	end

	function GTableMeta.__newindex(tbl, idx, val)
		oldNewIndex(tbl, idx, val)
		GVDetector(tbl, idx)
	end

	function GTableMeta.__index(tbl, idx)
		local res = oldIndex(tbl, idx)
		GVDetector(tbl, idx)
		return res
	end
end

if SERVER then
	print("RandomLoad", pcall(require, "random"))
	if SecureRandomNumber then
		math.random = SecureRandomNumber
	end
	AddCSLuaFile()
end

if not SA then
	SA = {}
end
