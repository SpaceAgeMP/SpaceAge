include("shared.lua")

surface.CreateFont("rulesTitle", { font = "Trebuchet18", size = 200, weight = 700, antialias = true, shadow = false})
surface.CreateFont("rulesFont", { font = "Trebuchet18", size = 75, weight = 700, antialias = true, shadow = false})
surface.CreateFont("rulesSmallFont", { font = "Trebuchet18", size = 50, weight = 700, antialias = true, shadow = false})

local maxPlayersCVar = GetConVar("maxplayers")

ENT.Rules = {
	"Treat fellow players with the same respect as treating admins.",
	"Do not cause harm with props.",
	"If you attemp to crash the server, you will be permabanned.",
	"Do not abuse the voice function, turn off your voice when you are instructed to.",
	"The admins are always right, always follow orders given to you by admins.",
	"Communicate with other players on the server with the English or German language.",
	"When you're done with a contraption, remove it, to prevent any useless lag.",
	"NO LARGE GHOSTS OR SPAWNS",
	"When you see a player breaking a rule, don't attempt to solve it yourself, warn an admin instead.",
	"If you are seen breaking any of these rules, you will first be warned and then punished.",
	"Don't use weapons on any Active Planets. (Terminal, Earth, Tiberium)"
}
ENT.AveragePing = 0

function ENT:Initialize()
end

function ENT:DrawText(text, x, y, font)
	surface.SetFont(font)
	surface.SetTextPos(x, y)
	surface.DrawText(text)

	timer.Simple(1, function()
		local ping = 0
		for _, pl in pairs(player.GetHumans()) do ping = ping + pl:Ping() end
		self.AveragePing = math.floor(ping / #player.GetHumans())
	end)
end

function ENT:RulesAndInfo()
	-- Title
	surface.SetTextPos(0, 0)
	surface.SetTextColor(60, 157, 255, 255)
	surface.SetFont("rulesTitle")
	surface.DrawText("SpaceAge Server Rules")

	-- Rules
	surface.SetTextColor(168, 255, 0, 255)
	surface.SetFont("rulesFont")

	for i, r in pairs(self.Rules) do
		surface.SetTextPos(0, 100 + i * 100)
		surface.DrawText(i .. ". " .. r)
	end

	-- Time
	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Current time:", 0, 400 + #self.Rules * 100, "rulesSmallFont")
	surface.SetTextColor(168, 255, 0, 255)
	self:DrawText(os.date("%H:%M:%S"), 0, 450 + #self.Rules * 100, "rulesFont")

	-- Average ping
	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Average ping:", 500, 400 + #self.Rules * 100, "rulesSmallFont")
	surface.SetTextColor(168, 255, 0, 255)
	self:DrawText(self.AveragePing, 500, 450 + #self.Rules * 100, "rulesFont")

	-- Amount of players
	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Amount of players:", 1000, 400 + #self.Rules * 100, "rulesSmallFont")
	surface.SetTextColor(168, 255, 0, 255)
	self:DrawText(#player.GetHumans() .. "/" .. maxPlayersCVar:GetInt(), 1000, 450 + #self.Rules * 100, "rulesFont")

	-- Online admins
	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Online admins:", 1500, 400 + #self.Rules * 100, "rulesSmallFont")
	surface.SetTextColor(168, 255, 0, 255)
	local i = 0
	for _, pl in pairs(player.GetHumans()) do
		if (pl:IsAdmin()) then
			self:DrawText(pl:Nick(), 1500, 450 + #self.Rules * 100 + i * 100, "rulesFont")
			i = i + 1
		end
	end

	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Coded by: Overv", 0, 600 + #self.Rules * 100, "rulesSmallFont")
end

function ENT:Scoreboard()
	-- Title
	surface.SetTextPos(4000, 0)
	surface.SetTextColor(60, 157, 255, 255)
	surface.SetFont("rulesTitle")
	surface.DrawText("Players")

	-- Columns
	surface.SetTextColor(60, 157, 255, 255)
	self:DrawText("Name", 4000, 200, "rulesSmallFont")
	self:DrawText("Frags", 5200, 200, "rulesSmallFont")
	self:DrawText("Deaths", 5450, 200, "rulesSmallFont")
	self:DrawText("Ping", 5700, 200, "rulesSmallFont")

	-- Players
	local i = 0
	for _, pl in pairs(player.GetHumans()) do
		local y = 250 + i * 100
		surface.SetTextColor(168, 255, 0, 255)

		self:DrawText(pl:Nick(), 4000, y, "rulesFont")
		self:DrawText(pl:Frags(), 5200, y, "rulesFont")
		self:DrawText(pl:Deaths(), 5450, y, "rulesFont")
		self:DrawText(pl:Ping(), 5700, y, "rulesFont")

		i = i + 1
	end
end

function ENT:Draw()
	-- Front
	cam.Start3D2D(self:GetPos() + Vector(0, -200, 128), Angle(0, 90, 90), 0.1)
		self:RulesAndInfo()
		self:Scoreboard()
	cam.End3D2D()

	-- Back
	cam.Start3D2D(self:GetPos() + Vector(0, 395, 128), Angle(0, -90, 90), 0.1)
		self:RulesAndInfo()
		self:Scoreboard()
	cam.End3D2D()
end
