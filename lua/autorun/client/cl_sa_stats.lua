local SA_MaxNameLength = 24

SA.StatsTable = {}

local function SA_ReceiveStatsUpdate(body, code)
	if code ~= 200 then
		return
	end

	SA.StatsTable = {}
	for i, v in pairs(body) do

		local newEntry = {}
		newEntry.Name = string.Left(v.Name, SA_MaxNameLength)
		newEntry.Score = SA.AddCommasToInt(v.Score)
		local tempColor = SA.Factions.Colors[v.FactionName]
		if not tempColor then tempColor = Color(255, 100, 0, 255) end
		newEntry.FactionColor = tempColor
		newEntry.Info = v

		table.insert(SA.StatsTable, newEntry)
	end

	hook.Run("SA_StatsUpdate", SA.StatsTable)
end
local function SA_RequestStatsUpdate()
	SA.API.ListPlayers(SA_ReceiveStatsUpdate)
end
timer.Create("SA_StatsUpdater", 30, 0, SA_RequestStatsUpdate)
timer.Simple(2, SA_RequestStatsUpdate)
