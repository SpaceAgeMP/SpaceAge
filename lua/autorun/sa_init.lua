if SERVER then
	AddCSLuaFile()
end

if not SA then
	SA = {}
end

local SA_ModuleList = {}

local SA_CurrentLoadChain = nil

local function TryLoadModule(moduleName, loadChain)
	local module = SA_ModuleList[moduleName]
	if not module then
		error("Cannot find module " .. moduleName)
	end

	if module.loaded then
		return
	end

	print("[SA] Loading module " .. moduleName)

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
			print("[SA] Loading module file " .. fileName)

			local oldLoadChain = SA_CurrentLoadChain
			SA_CurrentLoadChain = loadChain
			include(fileName)
			SA_CurrentLoadChain = oldLoadChain
		end
	end

	print("[SA] Loaded module " .. moduleName)
end

local function Local_SA_REQUIRE(moduleName)
	TryLoadModule(moduleName, SA_CurrentLoadChain)
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
		local moduleName = module .. "." .. f:sub(1, -5)
		if addClient then
			AddCSLuaFile(fileName)
		end
		if loadFile then
			table.insert(SA_ModuleList[module].dependencies, moduleName)
			if SA_ModuleList[moduleName] then
				table.insert(SA_ModuleList[moduleName].fileNames, fileName)
			else
				SA_ModuleList[moduleName] = {
					dependencies = {},
					fileNames = {fileName}
				}
			end
		end
	end
end

local function SA_LoadAllModules()
	if SA.ALL_MODULES_LOADED then
		return
	end

	local _, modules = file.Find("sa/*", "LUA")
	for _, module in pairs(modules) do
		SA_ModuleList[module] = {
			dependencies = {}
		}
		LoadAllFilesForModule(module, "shared")
		LoadAllFilesForModule(module, "client")
		LoadAllFilesForModule(module, "server")
	end

	SA.REQUIRE = Local_SA_REQUIRE
	LoadModuleTree()

	SA.REQUIRE = function() end
	SA.ALL_MODULES_LOADED = true
end

SA_LoadAllModules()
