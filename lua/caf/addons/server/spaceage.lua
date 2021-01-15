local SA_CAF = {}

local status = false

--[[
	The Constructor for this Custom Addon Class
]]
function SA_CAF.__Construct()
	if status then return false , "This Addon is already Active!" end
	SA_LoadAllModules()
	status = true --You decide how you want to be able to set the status internaly for the GetStatus functions, but this is a good way to do it.
	return true -- If Succesfull
end

--[[
	The Destructor for this Custom Addon Class
]]
function SA_CAF.__Destruct()
	return false, "This addon can't be disabled"
end

--[[
	Get the Boolean Status from this Addon Class
]]
function SA_CAF.GetStatus()
	return status
end

--[[
	Get the Version of this Custom Addon Class
]]
function SA_CAF.GetVersion()
	return 1.00, "Live"
end

--[[
	Get any custom options this Custom Addon Class might have
        Not implemented by CAF yet.
]]
function SA_CAF.GetExtraOptions()
	return {}
end

--[[
	Get the required Addons for this Addon Class
]]
function SA_CAF.GetRequiredAddons()
	return {} --Returns a table with the names of the required Custom Addons for this Custom Addon to work, Empty table for none
end

--[[
	Get the Custom String Status from this Addon Class
        String version of the status, can be anything you want.
]]
function SA_CAF.GetCustomStatus()
	return "Always enabled!"
end

function SA_CAF.AddResourcesToSend()
	--You can set any resource you want to send to the clients here.
end

function SA_CAF.__AutoStart()
	SA_CAF.__Construct()
end

--Register the addon with a name, the table and the "level", 1 = Loaded first, 2 = loaded after all addons in 1, 3 = ..., 4, 5
CAF.RegisterAddon("SpaceAge", SA_CAF, "5")
