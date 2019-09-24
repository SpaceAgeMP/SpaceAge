local SA_ChatCommands = {}

function SA_RegisterChatCommand(cmd,func)
	SA_ChatCommands[cmd] = func
end

local function SA_JoinFaction(ply,txt)
	if ply.InvitedTo then
		ply.TeamIndex = ply.InvitedTo
		ply.UserGroup = SA.Factions.Table[ply.InvitedTo][2]
		ply.IsLeader = false
		ply:Spawn()
		ply.InvitedTo = false
		SA.SendCreditsScore(ply)
		for k,v in pairs(player.GetAll()) do
			if v.TeamIndex == ply.TeamIndex then
				v:AddHint(ply:Name() .. " has joined the faction!",NOTIFY_GENERIC,5)
			end
		end
	else
		ply:AddHint("You have not been invited to any factions.",NOTIFY_ERROR,5)
	end
end
SA_RegisterChatCommand("join",SA_JoinFaction)

local function SA_InviteToFaction(ply,txt)
	local name = string.sub(txt,9)
	if ply.IsLeader then
		local v = SA.GetPlayerByName(name)
		if v then
			v.InvitedTo = ply.TeamIndex
			ply:AddHint("Invited " .. v:Name() .. " to your faction.",NOTIFY_GENERIC,5)
			v:AddHint("You have been invited to join " .. SA.Factions.Table[v.InvitedTo][1] .. " type [join to accept the invitation.",NOTIFY_GENERIC,5)
			SA.SendCreditsScore(v)
		else
			ply:AddHint("No players match the name given.",NOTIFY_ERROR,5)
		end
	else
		ply:AddHint("You must be the leader of a faction to use this command.",NOTIFY_ERROR,5)
	end
end
SA_RegisterChatCommand("invite",SA_InviteToFaction)

local function SA_KickFaction(ply,txt)
	local name = string.sub(txt,7)
	if ply.IsLeader then
		local v = SA.GetPlayerByName(name)
		if v then
			if ply == v then ply:AddHint("You cannot kick yourself.", NOTIFY_CLEANUP, 5) return "" end
			if v.TeamIndex == ply.TeamIndex then
				ply:ChatPrint("Kicked " .. v:Name() .. " out of your faction.")
				v:AddHint("You have been kicked out of " .. SA.Factions.Table[v.TeamIndex][1], NOTIFY_CLEANUP, 5)
				v.TeamIndex = 1
				v.UserGroup = "freelancer"
				v.IsLeader = false
				v:Spawn()
				SA.SendCreditsScore(v)
			else
				ply:AddHint("You may only kick players out of your own faction.", NOTIFY_ERROR, 5)
			end
		else
			ply:AddHint("No players match the name given.", NOTIFY_ERROR, 5)
		end
	else
		ply:AddHint("You must be the leader of a faction to use this command.", NOTIFY_ERROR, 5)
	end
end
SA_RegisterChatCommand("kick",SA_KickFaction)

local function SA_LeaveFaction(ply,txt)
	if (ply.IsLeader) then
		ply:AddHint("You are leader of that faction, you can not leave it!", NOTIFY_ERROR, 5)
		return
	end
	ply:AddHint("You have left the faction and are now freelancer again!", NOTIFY_CLEANUP, 5)
	ply.TeamIndex = 1
	ply.UserGroup = "freelancer"
	ply.IsLeader = false
	ply:Spawn()
	SA.SendCreditsScore(ply)
end
SA_RegisterChatCommand("leave",SA_LeaveFaction)

local function SA_ApplyFaction(ply,txt)
	ply:SendLua("StartApply()")
end
SA_RegisterChatCommand("apply",SA_ApplyFaction)

local function SA_ChatGiveCredits(ply,txt)
	local texty = string.sub(txt,7)
	local splode = string.Explode(" ",texty)
	if #splode ~= 2 then ply:ChatPrint("The correct format is [give <name> <amount>") return end
	SA.GiveCredits.ByName(ply,splode[1],splode[2])
end
SA_RegisterChatCommand("give",SA_ChatGiveCredits)

local function SA_ChatTypeSACommand(ply,txt)
	local spacepos = string.find(txt," ",1,true)
	local cmd = ""
	if not spacepos then
		cmd = txt
	else
		cmd = string.sub(txt,1,spacepos-1)
	end
	local cFunc = SA_ChatCommands[cmd]
	if type(cFunc) ~= "function" then return end
	cFunc(ply,"[" .. txt)
	return ""
end
--FA.RegisterChatType("[","SpaceAge Command",SA_ChatTypeSACommand,0)
