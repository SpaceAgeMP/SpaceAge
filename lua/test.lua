local function Vector(x,y,z)
	return {x,y,z}
end

local function Angle(p,y,r)
	return {p,y,r}
end

local tbl = {}

local function AddSATeleporter(name, spawns, panels)
	for k,v in pairs(panels) do
		panels[k] = {
			Position = v[1],
			Angle = v[2],
		}
	end

	tbl[name] = {
		Spawns = spawns,
		Panels = panels,
	}
end

function runfor(mapname)
	local StationPos, StationSize

	if mapname == "gm_galactic_rc1" then
		StationPos = Vector(-8896, 10192, 768)
		StationSize = 1024
	elseif mapname == "sb_forlorn_sb3_r2l" or mapname == "sb_forlorn_sb3_r3" then
		StationPos = Vector(9447, 9824, 461)
		StationSize = 2650
	elseif mapname == "sb_new_worlds_2" then
		StationPos = Vector(-8253, -9771, -11041)
		StationSize = 3000
	elseif mapname == "sb_gooniverse" or mapname == "sb_gooniverse_v4" then
		StationSize = 1130
		StationPos = Vector(2, -1, 4620)
	elseif mapname == "sb_lostinspace_rc4" then
		StationSize = 4200
		StationPos = Vector(-8996, 8636, -6500)
	elseif mapname == "sb_wuwgalaxy_fix" then
		StationSize = 2750
		StationPos = Vector(8348, 4520, 7271)
	elseif mapname == "gm_flatgrass" then
		StationSize = 256
		StationPos = Vector(740, 0, 0)
	end

	file.CreateDir(mapname)
	file.Write(mapname .. "/terminals.json", util.TableToJSON({
		Station = {
			Position = StationPos,
			Size = StationSize,
		}
	}))
end

runfor("sb_forlorn_sb3_r3")
runfor("sb_gooniverse_v4")
runfor("sb_new_worlds_2")
runfor("sb_wuwgalaxy_fix")
