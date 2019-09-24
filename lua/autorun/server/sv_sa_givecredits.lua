SA.GiveCredits = {}

local SA_GiveRequests = {}

function SA.GiveCredits.ByName(ply,name,amt)
	local v = SA.GetPlayerByName(name,nil)
	if v then
		return SA.GiveCredits.Do(ply,v,amt)
	end
	return false
end

function SA.GiveCredits.Do(ply,v,amt)
	if not (ply and v and ply:IsValid() and v:IsValid() and ply:IsPlayer() and v:IsPlayer()) then ply:AddHint("Invalid command parameters.", NOTIFY_CLEANUP, 5) return false end

	amt = tonumber(amt)
	if not amt then ply:AddHint("Invalid command parameters.", NOTIFY_CLEANUP, 5) return false end
	local cred = tonumber(ply.Credits)
	if (amt <= 0) or (math.ceil(amt) ~= math.floor(amt)) then ply:AddHint("That is not a valid number.", NOTIFY_CLEANUP, 5) return false end
	if (amt > cred) then ply:AddHint("You do not have enough credits.", NOTIFY_CLEANUP, 5) return false end

	v.Credits = v.Credits + amt
	ply.Credits = ply.Credits - amt
	local num = SA.AddCommasToInt(amt)
	ply:AddHint("You have given " .. v:Name() .. " " .. num .. " credits.", NOTIFY_GENERIC, 5)
	v:AddHint(ply:Name() .. " has given you " .. num .. " credits.", NOTIFY_GENERIC, 5)
	SA.SendCreditsScore(ply)
	SA.SendCreditsScore(v)

	return true
end

function SA.GiveCredits.Confirm(ply,v,amt,func)
	local theID = ply:SteamID()
	if SA_GiveRequests[theID] then return false end --No multiple requests to same user .. .
	SA_GiveRequests[theID] = {ply,v,amt,func}
	net.Start("SA_OpenGiveQuery")
		net.WriteString(v:Name())
		net.WriteInt(amt, 32)
		net.WriteString(theID)
	net.Send(ply)
	return true
end

function SA.GiveCredits.Remove(ply)
	SA_GiveRequests[ply:SteamID()] = nil
end

local function SA_GiveRequestHandler(ply,cmd,args)
	if #args ~= 2 then return end
	local allowed = (args[1] == "allow")
	local theID = args[2]
	local theRequest = SA_GiveRequests[theID]
	if not (theRequest and theRequest[1] == ply) then return end
	local func = theRequest[4]
	if func then func(theRequest,allowed) end
	local tmpRet = {}
	if allowed then tmpRet = SA.GiveCredits.Do(theRequest[1],theRequest[2],theRequest[3]) end
	SA_GiveRequests[theID] = nil
	return tmpRet
end
concommand.Add("sa_giverequest",SA_GiveRequestHandler)

local function SA_CmdGiveCredits(ply,cmd,args)
	SA.GiveCredits.ByName(ply,args[1],args[2])
end
concommand.Add("sa_givecredits",SA_CmdGiveCredits)
