local function Vector(x,y,z)
	return {x,y,z}
end

function runfor(mapname)
	local toAdd, toRemove, toTerraform, toProtect, toRename
	if mapname == "sb_new_worlds_2" then
		toTerraform = {"naar'ak asteroid base"}
		toAdd = {{"Naar'ak Asteroid Base", Vector(-9275, -9818, -11428), 900},
				 {"Naar'ak Asteroid Base", Vector(-8257, -8609, -11229), 600},
				 {"Kestrel", Vector(8872, -7112, -7624), 600}}
		toProtect = {"maldoran", "naar'ak asteroid base", "kestrel"}
	elseif mapname == "sb_gooniverse" or mapname == "sb_gooniverse_v4" then
		toAdd = {
					{"Cerebus", Vector(3865, -10656, -1991), 700},
					{"Cerebus", Vector(4023, -9866, -2047), 640},

					{"Cerebus", Vector(4649, -8871, -2048), 200},
					{"Cerebus", Vector(4641, -8459, -2048), 200},
					{"Cerebus", Vector(4629, -7994, -2048), 200},

					{"Cerebus", Vector(4880, -9155, -1911), 100},
					{"Cerebus", Vector(5379, -9155, -1911), 100}
				}
		toProtect = {"hiigara", "coruscant", "cerebus"}
	elseif mapname == "sb_wuwgalaxy_fix" then
		toAdd = {
					{"Space Station", Vector(8368, 2689, 7096), 1150},
					{"Space Station", Vector(8335, 3257, 7107), 600},
					{"Space Station", Vector(8997, 3767, 7099), 850},
					{"Space Station", Vector(8453, 3762, 7093), 850},
					{"Space Station", Vector(8338, 4356, 7079), 800},
					{"Space Station", Vector(8420, 5365, 7122), 2500}
				}
		toTerraform = {"space station"}
		toProtect = {"space station"}
		toRemove = {"space station"}
	elseif mapname == "sb_lostinspace_rc4" then
		toAdd = {{"Umemeru", Vector(8548.4717, 9319.7842, 8059.2813), 400}}
		toProtect = {"ochl", "umemeru", "nuyitae"}
	elseif mapname == "sb_forlorn_sb3_r2l" or mapname == "sb_forlorn_sb3_r3" then
		toProtect = {"spawn room", "shakuras", "station 457", "dunomane"}
	end

	if toAdd then
		for k, v in pairs(toAdd) do
			toAdd[k] = {
				Name = v[1],
				Position = v[2],
				Radius = v[3],
			}
		end
	end

	config = {
		Add = toAdd,
		Remove = toRemove,
		Protect = toProtect,
		Terraform = toTerraform,
		Rename = toRename
	}

	file.CreateDir(mapname)
	file.Write(mapname .. "/environments.json", util.TableToJSON(config))
end

runfor("sb_forlorn_sb3_r3")
runfor("sb_lostinspace_rc4")
runfor("sb_wuwgalaxy_fix")
runfor("sb_gooniverse_v4")
runfor("sb_new_worlds_2")
