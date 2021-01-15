local BadSENTs = {"sent_ball"}

hook.Add("PlayerSpawnSENT", "SA_StopBadProps", function(ply, ent)
	for k, v in  pairs(BadSENTs) do
		if v == ent then
			ply:ChatPrint ("Sorry you can't spawn this SENT "  .. v)
			return false
		end
	end
end)
