local function sa_info_msg_credsc(len, ply)
	fa_info.credits = SA.AddCommasToInt(net.ReadString())
	fa_info.totalcredits = SA.AddCommasToInt(net.ReadString())
end
net.Receive("SA_CreditsScore", sa_info_msg_credsc) 

FA.Topbar.Register(1, "Credits", "fa_info", "credits")
FA.Topbar.Register(1, "Score", "fa_info", "totalcredits")
