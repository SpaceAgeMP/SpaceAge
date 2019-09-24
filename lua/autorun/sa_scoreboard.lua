if SERVER then
	AddCSLuaFile("autorun/sa_scoreboard.lua")
	AddCSLuaFile("sa_scoreboard/admin_buttons.lua")
	AddCSLuaFile("sa_scoreboard/player_frame.lua")
	AddCSLuaFile("sa_scoreboard/player_infocard.lua")
	AddCSLuaFile("sa_scoreboard/player_row.lua")
	AddCSLuaFile("sa_scoreboard/scoreboard.lua")
	AddCSLuaFile("sa_scoreboard/vote_button.lua")
	resource.AddFile("resources/fonts/neuropol.ttf")
else
	include("sa_scoreboard/scoreboard.lua")

	timer.Simple(1.5, function()
		function GAMEMODE:CreateScoreboard()
			if SA.ScoreBoard then
				SA.ScoreBoard:Remove()
				SA.ScoreBoard = nil
			end

			SA.ScoreBoard = vgui.Create("SA_ScoreBoard")

			return true
		end

		function GAMEMODE:ScoreboardShow()
			if not SA.ScoreBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SA.ScoreBoard:SetVisible( true )
			SA.ScoreBoard:UpdateScoreboard( true )

			return true
		end

		function GAMEMODE:ScoreboardHide()
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			SA.ScoreBoard:SetVisible( false )

			return true
		end
	end)
end
