SA.REQUIRE("central.main")
SA.REQUIRE("central.types")

local function WriteMessageElement(ele)
	if not ele or not ele.type then
		net.WriteUInt(SA.Central.TYPE_NIL, 8)
		return
	end

	net.WriteUInt(ele.type, 8)
	if ele.type == SA.Central.TYPE_NIL then
		return
	end

	if ele.type == SA.Central.TYPE_TEXT then
		net.WriteString(ele.text)
		return
	end

	if ele.type == SA.Central.TYPE_COLOR then
		net.WriteColor(Color(ele.r, ele.g, ele.b, ele.a))
		return
	end

	if ele.type == SA.Central.TYPE_PLAYER then
		net.WriteString(ele.name)
		net.WriteUInt(ele.team, 8)
		net.WriteBool(ele.alive)
		net.WriteColor(Color(ele.color.r, ele.color.g, ele.color.b, ele.color.a))
		return
	end
end

local function TranslateObjectToCentral(element)
	if not element then
		return {
			type = Sa.Central.TYPE_NIL,
		}
	end

	if element.IsPlayer and element:IsPlayer() then
		return {
			type = SA.Central.TYPE_PLAYER,
			name = element:GetName(),
			team = element:Team(),
			alive = element:Alive(),
			color = team.GetColor(element:Team()),
		}
	end

	if element.r and element.g and element.b and element.a then
		return {
			type = SA.Central.TYPE_COLOR,
			r = element.r,
			g = element.g,
			b = element.b,
			a = element.a,
		}
	end

	return {
		type = SA.Central.TYPE_TEXT,
		text = tostring(element),
	}
end

hook.Add("PlayerSay", "SA_Central_PlayerSay", function (ply, text, teamChat)
	if text == "" then
		return
	end
	local first = text:sub(1, 1)
	if first == "!" or first == "@" then
		return
	end

	SA.Central.Broadcast("chat", {
		ply = TranslateObjectToCentral(ply),
		text = text,
		teamChat = teamChat,
	})
end)

util.AddNetworkString("SA_Central_Chat")
util.AddNetworkString("SA_Central_ChatRaw")

SA.Central.Handle("chat", function(data, ident)
	net.Start("SA_Central_Chat")
		net.WriteString(ident)
		net.WriteBool(data.teamChat)
		net.WriteString(data.ply.name)
		net.WriteUInt(data.ply.team, 8)
		net.WriteColor(data.ply.color)
		net.WriteBool(data.ply.alive)
		net.WriteString(data.text)

	if data.teamChat then
		local rf = RecipientFilter()
		rf:AddRecipientsByTeam(data.ply.team)
		net.Send(rf)
	else
		net.Broadcast()
	end
end)

local function HandleChatRaw(data, ident)
	net.Start("SA_Central_ChatRaw")
		net.WriteString(ident)
		net.WriteUInt(#data, 32)
		for _, v in pairs(data) do
			WriteMessageElement(v)
		end
	net.Broadcast()
end
SA.Central.Handle("chatraw", HandleChatRaw)

function SA.Central.SendChatRaw(...)
	local out = {}
	for _, v in pairs({...}) do
		table.insert(out, TranslateObjectToCentral(v))
	end
	HandleChatRaw(out, "")
	SA.Central.Broadcast("chatraw", out)
end