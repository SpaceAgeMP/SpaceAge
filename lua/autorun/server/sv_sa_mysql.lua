require("mysqloolib")

SA.MySQL = {}

local config = util.JSONToTable(file.Read("spaceage/config/mysql.txt"))
local db = mysqloo.CreateDatabase(config.hostname, config.username, config.password, config.database)

-- (data, isok, merror, ply, sid)
local function makecb(cb, ...)
	if not cb then
		return nil
	end

	local args = {...}
	return function(query, status, dataOrError)
		if status then
			cb(dataOrError, true, nil, unpack(args))
		else
			cb(nil, false, dataOrError, unpack(args))
		end
	end
end

function SA.MySQL:Query(query, cb, ...)
	return db:RunQuery(query, makecb(cb, ...))
end

function SA.MySQL:Escape(str)
	return db:escape(str)
end
