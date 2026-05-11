SA.REQUIRE("config")
SA.REQUIRE("api")
SA.REQUIRE("central.main")

local apiConfig = SA.Config.Load("api", true) or {}
apiConfig.centralUrl = apiConfig.centralUrl or "NONE"

if SA.Central.Socket then
	SA.Central.Socket:close()
	SA.Central.Socket = nil
end

SA.Central.Handlers = SA.Central.Handlers or {}

local socket
local ourIdent
local SendCentralMessage

local function SendCommand(command, target, data)
	local cmd = {
		command = command,
		data = data,
	}
	SendCentralMessage(cmd, target)
end

local function HandleCentralMessage(msg, headers)
	local ident = headers["user-id"]
	if (not ident) or (ident == ourIdent) then
		return
	end

	if msg.command == "error" then
		print("Got error", msg.id, msg.data)
		return
	end

	local handler = SA.Central.Handlers[msg.command]
	if handler then
		handler(msg.data, ident)
	end
end

SendCentralMessage = function(msg, target)
	if not socket then
		return
	end
	socket:send("/topic/" .. (target or "broadcast"):lower(), msg)
end

local ConnectCentral
local function TimerConnectCentral()
	timer.Simple(1, ConnectCentral)
end

ConnectCentral = function()
	if apiConfig.centralUrl == "NONE" then
		return
	end

	if not NewSTOMPSocket then
		require("stomp")
	end

	ourIdent = SA.API.GetServerName()
	local ourKey = SA.API.GetServerToken()

	if not ourIdent then
		TimerConnectCentral()
		return
	end

	socket = NewSTOMPSocket({
		url = apiConfig.centralUrl,
		vhost = "spaceage",
		login = ourIdent,
		passcode = ourKey,
		autoReconnect = true,
	})
	SA.Central.Socket = socket
	socket:subscribe("/topic/broadcast", HandleCentralMessage, STOMP_DEFAULT_DURABLE)
	socket:subscribe("/topic/" .. ourIdent:lower(), HandleCentralMessage, STOMP_DEFAULT_DURABLE)

	function socket:onConnected()
		print("[Central] Link connected...")
		if not SA.Central.StartupSent then
			if not SA.API.IsServerHidden() then
				SA.Central.Broadcast("serverjoin")
			end
			SA.Central.StartupSent = true
		end
	end

	function socket:onDisconnected()
		print("[Central] Link lost...")
	end

	socket:open()
end

TimerConnectCentral()

function SA.Central.SendTo(target, command, data)
	SendCommand(command, target, data)
end

function SA.Central.Broadcast(command, data)
	SendCommand(command, nil, data)
end

function SA.Central.Handle(command, callback)
	if SA.Central.Handlers[command] then
		print("[Central] WARNING: Overwriting old handler for " .. command)
	end
	SA.Central.Handlers[command] = callback
end

function SA.Central.Reconnect()
	if socket then
		local _socket = socket
		socket = nil
		_socket:unsubscribeAll()
		timer.Simple(2, function()
			_socket:close()
		end)
	end
	timer.Simple(5, ConnectCentral)
end
concommand.Add("sa_central_reconnect", function (ply)
	if IsValid(ply) and not ply:IsAdmin() then
		return
	end
	SA.Central.Reconnect()
end)
