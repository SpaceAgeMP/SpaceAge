if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	local sc_enabled = false
	function gui.ScreenClickerEnabled()
		return sc_enabled
	end
	local old_EnableScreenClicker = gui.EnableScreenClicker
	function gui.EnableScreenClicker(enable)
		sc_enabled = enable
		return old_EnableScreenClicker(enable)
	end
end
