--glualint:ignore-file
E2Lib.RegisterExtension("sa_tts", false)

local TTS_MAX_LENGTH = 256

local function doTTS(target, filter, text)
	if text:len() > TTS_MAX_LENGTH then
		error("TTS is limited to 256 characters!", 2)
		return
	end

	http.Post("https://tts.spaceage.mp/mp3", { q = text }, function (body, length, headers, code)
		if code ~= 200 then
			return
		end
		local url = body

		net.Start("SA_TTS_PlayURL")
			net.WriteString(url)
			if target then
				net.WriteBool(true)
				net.WriteVector(target)
			else
				net.WriteBool(false)
			end

		if filter then
			net.Send(filter)
		else
			net.Broadcast()
		end
	end)
end

__e2setcost(50)
e2function void playTTS(string text)
	doTTS(self.entity:GetPos(), nil, text)
end

e2function void playTTSOwner(string text)
	local owner = self.player
	if IsValid(owner) then
		doTTS(false, owner, text)
	end
end

util.AddNetworkString("SA_TTS_PlayURL")
