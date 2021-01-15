SA.Config = {}

function SA.Config.Load(typ, isGlobal)
	if not isGlobal then
		typ = "maps/" .. game.GetMap() .. "/" .. typ
	end
	local path = "sa_config/" .. typ .. ".json"
	local data = file.Read(path, "GAME")
	if not data then
		return
	end
	return util.JSONToTable(data)
end
