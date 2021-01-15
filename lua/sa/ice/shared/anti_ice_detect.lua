local SERVER = SERVER
local dgetinfo = debug.getinfo
local pairs = pairs
local tinsert = table.insert
local sfind = string.find
local GetEntityClass = FindMetaTable("Entity").GetClass

local CALLED_IDX = 2
local CALLER_IDX = 3
local OKAY_CALLERS = { "addons/spaceage/", "lua/fpp/", "lua/ulib/" }

SA.RunAntiIceDebug = false

if SERVER then
	AddCSLuaFile()
end

local function IsOkay(ent)
	if SA.ValidEntity(ent) and GetEntityClass(ent) == "iceroid" then
		return false
	end

	return true
end


local function SkipFilter()
	if not SERVER then
		return false
	end

	local caller = dgetinfo(CALLER_IDX, "S")

	for _, v in pairs(OKAY_CALLERS) do
		if sfind(caller.short_src, v, 1, true) == 1 then
			return true
		end
	end

	if SA.RunAntiIceDebug then
		local funcCalled = dgetinfo(CALLED_IDX, "n").name
		file.Append("findlog.txt", funcCalled .. "\n" .. util.TableToJSON(caller) .. "\n\n")
	end

	return false
end

local function FilterTable(tbl)
	if not tbl then return tbl end

	local out = {}
	for _, ent in pairs(tbl) do
		if IsOkay(ent) then
			tinsert(out, ent)
		end
	end
	return out
end

local function OverwriteTableFunc(idx, tbl)
	if not tbl then tbl = ents end

	local old = tbl[idx]
	tbl[idx] = function(...)
		local data = old(...)
		if SkipFilter() then
			return data
		end
		return FilterTable(data)
	end
end

local function OverwriteSingleFunc(idx, tbl)
	if not tbl then tbl = ents end

	local old = tbl[idx]
	tbl[idx] = function(...)
		local ent = old(...)
		if IsOkay(ent) then
			return ent
		end

		if SkipFilter() then
			return ent
		end

		return NULL
	end
end

local function OverwriteTraceFunc(idx, tbl)
	local old = tbl[idx]
	tbl[idx] = function(...)
		local tr = old(...)
		if not IsOkay(tr.Entity) then
			if SkipFilter() then
				return tr
			end
			tr.Entity = NULL
		end
		return tr
	end
end

local ICEROID = "iceroid"
local function IsIceroidWildcard(cls)
	if cls == ICEROID then
		return true
	end

	return sfind(cls, "[^A-Za-z0-9_]")
end

local oldFindByClass = ents.FindByClass
function ents.FindByClass(cls)
	local data = oldFindByClass(cls)
	if not IsIceroidWildcard(cls) then
		return data
	end
	if SkipFilter() then
		return data
	end
	return FilterTable(data)
end

OverwriteTableFunc("FindByModel")
OverwriteTableFunc("FindInBox")
OverwriteTableFunc("FindInCone")
OverwriteTableFunc("FindInSphere")
OverwriteTableFunc("GetAll")

OverwriteSingleFunc("GetByIndex")
OverwriteSingleFunc("Entity", _G)

OverwriteTraceFunc("TraceHull", util)
