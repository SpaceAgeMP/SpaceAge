if SERVER then
	print("RandomLoad", pcall(require, "random"))
	if SecureRandomNumber then
		math.random = SecureRandomNumber
	end
	AddCSLuaFile()
end

SA = {}

local SA_ModuleList = {}
local SA_FileDepends = {}

if CLIENT then
	SA_FileDepends = util.JSONToTable(file.Read("data/sa_modules.json", "DOWNLOAD"))
end

local function TryLoadModule(moduleName, loadChain)
	local module = SA_ModuleList[moduleName]
	if not module then
		error("Cannot find module " .. moduleName)
	end

	if module.loaded then
		return
	end

	print("Loading module " .. moduleName)

	if loadChain[moduleName] then
		PrintTable(loadChain)
		error("Circular dependency!")
	end
	loadChain[moduleName] = true

	for _, dependency in pairs(module.dependencies) do
		TryLoadModule(dependency, loadChain)
	end

	module.loaded = true

	if module.fileNames then
		for _, fileName in pairs(module.fileNames) do
			print("Loading module file " .. fileName)
			include(fileName)
		end
	end
end

local function LoadModuleTree()
	for moduleName, _ in pairs(SA_ModuleList) do
		TryLoadModule(moduleName, {})
	end
end

local function LoadAllFilesForModule(module, side)
	local folder = "sa/" .. module .. "/" .. side .. "/"
	local files, _ = file.Find(folder .. "*.lua", "LUA")

	local addClient = side ~= "server" and SERVER
	local loadFile = side == "shared" or (side == "server" and SERVER) or (side == "client" and CLIENT)

	for _, f in pairs(files) do
		local fileName = folder .. f
		local moduleName = module .. "." .. f:sub(1, -4)

		local dependencies = {}

		if SERVER then
			local fileData = file.Read(fileName, "LUA")
			local dependencyLine = fileData:find("--DEPENDS ", 1, true)
			if dependencyLine then
				local dependencyLineBegin = fileData:find(" " , dependencyLine, true)
				local dependencyLineEnd = fileData:find("\n", dependencyLineBegin, true)
				dependencies = fileData:sub(dependencyLineBegin, dependencyLineEnd):Trim():Split(" ")
			end

			if addClient then
				AddCSLuaFile(fileName)
				SA_FileDepends[fileName] = table.Copy(dependencies)
			end
		else
			dependencies = SA_FileDepends[fileName] or {}
		end

		if loadFile then
			table.insert(SA_ModuleList[module].dependencies, moduleName)
			if SA_ModuleList[moduleName] then
				table.insert(SA_ModuleList[moduleName].fileNames, fileName)
				table.Add(SA_ModuleList[moduleName].dependencies, dependencies)
			else
				SA_ModuleList[moduleName] = {
					dependencies = dependencies,
					fileNames = {fileName}
				}
			end
		end
	end
end

function SA_LoadAllModules()
	_, modules = file.Find("sa/*", "LUA")
	for _, module in pairs(modules) do
		SA_ModuleList[module] = {
			dependencies = {}
		}
		LoadAllFilesForModule(module, "shared")
		LoadAllFilesForModule(module, "client")
		LoadAllFilesForModule(module, "server")
	end

	file.Write("sa_modules.json", util.TableToJSON(SA_FileDepends))
	resource.AddSingleFile("data/sa_modules.json")

	LoadModuleTree()
end
