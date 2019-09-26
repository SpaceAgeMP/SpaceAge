local sa_enpay = CreateClientConVar("sa_enable_payments", "1", true, false)

local function SA_AnswerGiveQuery(answer, theID, noSC)
	RunConsoleCommand("sa_giverequest", answer, theID)
	if not noSC then gui.EnableScreenClicker(false) end
end

net.Receive("SA_OpenGiveQuery", function(len, ply)
	local to = net.ReadString()
	local amt = SA.AddCommasToInt(net.ReadInt(32))
	local theID = net.ReadString()

	if (not sa_enpay:GetBool()) or gui.ScreenClickerEnabled() then SA_AnswerGiveQuery("deny", theID, true) return end

	gui.EnableScreenClicker(true)
	Derma_Query(
		"Would you like to pay the player \"" .. to .. "\" " .. amt .. " credits?",
		"Pay Query",
		"Yes",
		function() SA_AnswerGiveQuery("allow", theID) end,
		"No",
		function() SA_AnswerGiveQuery("deny", theID) end
	)
end)
