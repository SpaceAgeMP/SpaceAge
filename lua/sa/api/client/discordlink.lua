SA.REQUIRE("api.main")

function SA.API.GetDiscordLinkToken(callback)
    local function raw_callback(data, code)
        if data and data.token and code == 200 then
            callback(data.token)
        else
            callback(nil)
        end
    end
    local steamid = LocalPlayer():SteamID()
    return SA.API.Post("/players/" .. steamid .. "/discordlink", {}, raw_callback)
end

concommand.Add("sa_get_discord_link_token", function()
	SA.API.GetDiscordLinkToken(function(code)
        if not code then
            print("Failed to get discord link token")
            return
        end

        print("Your code for /salink is: " .. code)
    end)
end)
