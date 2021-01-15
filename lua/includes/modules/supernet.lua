supernet = {}

if SERVER then
	AddCSLuaFile()
end

local table = table
local net = net
local util = util

local TOTAL_SIZE_MAX = SERVER and 2000000 or nil
local SIZE_MAX = 60000
local MSGCOUNT_MAX = TOTAL_SIZE_MAX and math.floor(TOTAL_SIZE_MAX / SIZE_MAX) or nil

local queue = {}
local inqueue = {}
local hooks = {}
local msgid = 0

print("supernet, TOTAL_SIZE_MAX = ", TOTAL_SIZE_MAX, ", SIZE_MAX = ", SIZE_MAX, ", MSGCOUNT_MAX = ", MSGCOUNT_MAX)

if SERVER then
	util.AddNetworkString("SuperNet_MSG")
end

function supernet.Send(trg, name, data, cb)
	msgid = msgid + 1
	if msgid > 4095 then
		msgid = 1
	end
	local dJSON = util.TableToJSON(data)
	local dComp = util.Compress(dJSON)
	table.insert(queue, {msgid, trg, name, dComp, cb, 1, dComp:len()})
end

function supernet.Hook(name, cb)
	hooks[name] = cb
end

local function callCB(cb, ply, str)
	local decomp = util.Decompress(str, TOTAL_SIZE_MAX)
	if not decomp then
		return
	end
	local tbl = util.JSONToTable(decomp)
	cb(ply, tbl)
end

local function NetReceive(len, ply)
	local myqueue = inqueue
	if SERVER then
		myqueue = inqueue[ply]
		if not myqueue then
			myqueue = {}
			inqueue[ply] = myqueue
		end
	end

	local isNew = net.ReadBool()
	local isEnd = net.ReadBool()
	local msgId = net.ReadUInt(14)

	local name
	if isNew then
		name = net.ReadString()
	end

	local dLen = net.ReadUInt(16)
	local dBin = net.ReadData(dLen)

	local data

	if isNew then
		if not name then
			print("No name got from " .. tostring(ply))
			return
		end

		local cb = hooks[name]
		if not cb then
			print("Received supernet for unknown name " .. name .. " from " .. tostring(ply))
			return
		end

		if isEnd then
			callCB(cb, ply, dBin)
			return
		end

		data = {cb, {dBin}, name}
		myqueue[msgId] = data
	else
		data = myqueue[msgId]
		if not data then
			print("Invalid message for ID " .. tostring(msgId) .. "from " .. tostring(ply) .. ": Not found")
			return
		end
		table.insert(data[2], dBin)
	end

	local bits = data[2]
	if MSGCOUNT_MAX and #bits > MSGCOUNT_MAX then
		print("Ignoring message " .. data[3] .. " from " .. tostring(ply) .. ": Exceeded maximum message count!")
		myqueue[msgId] = nil
		return
	end

	if isEnd then
		myqueue[msgId] = nil
		callCB(data[1], ply, table.concat(bits))
	end
end
net.Receive("SuperNet_MSG", NetReceive)

local current
local function FinishQueue()
	local cb = current[5]
	current = nil
	if cb then
		cb()
	end
end

local function RunQueue()
	local isNew = false

	if not current then
		if #queue < 1 then
			return
		end

		isNew = true
		current = table.remove(queue, #queue)
	end

	--local msgid = current[1]
	local target = current[2]
	--local name = current[3]
	--local data = current[4]
	local pos = current[6]
	local left = current[7]

	if target and not target:IsValid() then
		return FinishQueue()
	end

	local isEnd = false
	local len = SIZE_MAX
	if left <= SIZE_MAX then
		isEnd = true
		len = left
	end

	local dSub = current[4]:sub(pos, (pos + len) - 1)
	net.Start("SuperNet_MSG")
		net.WriteBool(isNew)
		net.WriteBool(isEnd)
		net.WriteUInt(current[1], 14)
		if isNew then
			net.WriteString(current[3])
		end
		net.WriteUInt(len, 16)
		net.WriteData(dSub, len)

	if CLIENT then
		net.SendToServer()
	elseif target then
		net.Send(target)
	else
		net.Broadcast()
	end

	if isEnd then
		return FinishQueue()
	end

	current[6] = pos + SIZE_MAX
	current[7] = left - SIZE_MAX
end
timer.Create("supernet_RunQueue", 0, 0, RunQueue)
