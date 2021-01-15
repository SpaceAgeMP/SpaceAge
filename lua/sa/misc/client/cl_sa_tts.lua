local playingSounds = {}

local MAX_TTS_DIST = 2000

MAX_TTS_DIST = MAX_TTS_DIST * MAX_TTS_DIST -- squared distance!

local function CleanupTTS()
	local stillPlaying = {}
	for _, v in pairs(playingSounds) do
		if v:GetState() ~= GMOD_CHANNEL_STOPPED then
			table.insert(stillPlaying, v)
		end
	end
	playingSounds = stillPlaying
end
timer.Create("SA_TTS_Cleanup", 10, 0, CleanupTTS)

local function PlayTTS()
	local url = net.ReadString()
	local pos = net.ReadVector()

	if pos:DistToSqr(LocalPlayer():GetPos()) > MAX_TTS_DIST then
		return
	end

	sound.PlayURL(url, "3d noplay", function(station)
		if not IsValid(station)  then
			return
		end

		station:SetPos(pos)
		station:Play()

		table.insert(playingSounds, station)
	end)
end
net.Receive("SA_TTS_PlayURL", PlayTTS)
