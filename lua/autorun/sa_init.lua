if SERVER then
	print("RandomLoad", pcall(require, "random"))
	if SecureRandomNumber then
		math.random = SecureRandomNumber
	end
	AddCSLuaFile()
end

SA = {}

local SA_ModuleList = {}

local function TryLoadModule(moduleName, loadChain)
	local module = SA_ModuleList[moduleName]

	if module.loaded then
		return
	end
	loadChain[moduleName] = true

	print("Loading module " .. moduleName)

	if loadChain[module] then
		PrintTable(loadChain)
		error("Circular dependency!")
	end
	for _, dependency in pairs(module.dependencies) do
		TryLoadModule(dependency, loadChain)
	end

	if module.fileName then
		print("Loading module file " .. module.fileName)
		include(module.fileName)
	end
end

local function LoadModuleTree()
	for moduleName, module in pairs(SA_ModuleList) do
		TryLoadModule(module, {})
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
		if addClient then
			AddCSLuaFile(fileName)
		end
		if loadFile then
			local fileData = file.Read(fileName, "LUA")
			local dependencyLine = fileData:find("--DEPENDS ", 1, true)
			local dependencies = {}
			if dependencyLine then
				local dependencyLineEnd = fileData:find("\n", dependencyLine, true)
				dependencies = fileData:sub(dependencyLine, dependencyLineEnd):Split(" ")
			end
			table.insert(SA_ModuleTree[module].dependencies, moduleName)
			SA_ModuleTree[moduleName] = {
				dependencies = dependencies,
				fileName = fileName
			}
		end
	end
end

local function LoadAllModules()
	_, modules = file.Find("sa/*", "LUA")
	for _, module in pairs(modules) do
		SA_ModuleTree[module] = {
			dependencies = {}
		}
		LoadAllFilesForModule(module, "shared")
		LoadAllFilesForModule(module, "client")
		LoadAllFilesForModule(module, "server")
	end
end

LoadAllModules()
LoadModuleTree()
