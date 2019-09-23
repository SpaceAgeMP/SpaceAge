
include( "admin_buttons.lua" )
include( "vote_button.lua" )

local PANEL = {}

function PANEL:Init()

	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}

	self.btnKick = vgui.Create( "SA_PlayerKickButton", self )
	self.btnBan = vgui.Create( "SA_PlayerBanButton", self )
	self.btnPBan = vgui.Create( "SA_PlayerPermBanButton", self )

	self.VoteButtons = {}

	self.VoteButtons[1] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[1]:SetUp( "exclamation", "bad", "This player is naughty!" )

	self.VoteButtons[2] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[2]:SetUp( "emoticon_smile", "smile", "I like this player!" )

	self.VoteButtons[3] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[3]:SetUp( "heart", "love", "I love this player!" )

	self.VoteButtons[4] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[4]:SetUp( "palette", "artistic", "This player is artistic!" )

	self.VoteButtons[5] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[5]:SetUp( "star", "star", "Wow! Gold star for you!" )

	self.VoteButtons[6] = vgui.Create( "SA_SpawnMenuVoteButton", self )
	self.VoteButtons[6]:SetUp( "wrench", "builder", "Good at building!" )

end

function PANEL:SetInfo( column, k, v )

	if ( !v or v == "" ) then v = "N/A" end

	if ( !self.InfoLabels[ column ][ k ] ) then

		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self:InvalidateLayout()

	end

	self.InfoLabels[ column ][ k ].Value:SetText( v )
	return true

end


function PANEL:SetPlayer( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

function PANEL:UpdatePlayerData()

	if (!self.Player) then return end
	if ( !self.Player:IsValid() ) then return end

	--[[ self:SetInfo( 2, "Website:", self.Player:GetWebsite() )
	self:SetInfo( 2, "Location:", self.Player:GetLocation() )
	self:SetInfo( 2, "Email:", self.Player:GetEmail() )
	self:SetInfo( 2, "GTalk:", self.Player:GetGTalk() )
	self:SetInfo( 2, "MSN:", self.Player:GetMSN() )
	self:SetInfo( 2, "AIM:", self.Player:GetAIM() )
	self:SetInfo( 2, "XFire:", self.Player:GetXFire() ) ]]

	--[[self:SetInfo(1, "Tiberium Drills:","Level "..self.Player:GetNWInt("TibDLV"))
	self:SetInfo(1, "Tib Storages:","Level "..self.Player:GetNWInt("TibSLV"))
	self:SetInfo(1, "ICE Lasers:","Mark "..LaserMKRoman(self.Player,"IceLLV"))
	self:SetInfo(1, "ICE Ref.:",ICERefWord(self.Player))
	self:SetInfo(1, "ICE Storages:","Raw: "..(self.Player:GetNWInt("IceRSLV")+1).."; Product: "..(self.Player:GetNWInt("IcePSLV")+1))
	self:SetInfo(1, "Ore Lasers:","Mark "..LaserMKRoman(self.Player) .." at level "..self.Player:GetNWInt("LaserLV") )
	self:SetInfo(1, "Ore Storages:",OreMKStr(self.Player) .." storages at level "..self.Player:GetNWInt("OreLV"))]]
	self:SetInfo(1, "Time played:",SA.FormatTime(math.abs(os.time() - self.Player:GetNWInt("Playtime"))))

	self:InvalidateLayout()

end

--[[function OreMKStr(ply)
	if not tmpX then tmpX = "OreMK" end
	local tmp = ply:GetNWInt(tmpX)
	if tmp == 0 then
		return "Small"
	elseif tmp == 1 then
		return "Medium"
	elseif tmp == 2 then
		return "Large"
	elseif tmp == 3 then
		return "Huge"
	elseif tmp == 4 then
		return "Giant"
	else
		return "Unknown"
	end
end

function ICERefWord(ply)
	local tmp = ply:GetNWInt("IceRLV")
	if tmp == 0 then
		return "Basic"
	elseif tmp == 1 then
		return "Improved"
	elseif tmp == 2 then
		return "Advanced"
	else
		return "Unknown"
	end
end

function LaserMKRoman(ply,tmpX)
	if not tmpX then tmpX = "LaserMK" end
	local tmp = ply:GetNWInt(tmpX)
	if tmp == 0 then
		return "I"
	elseif tmp == 1 then
		return "II"
	elseif tmp == 2 then
		return "III"
	elseif tmp == 3 then
		return "IV"
	elseif tmp == 4 then
		return "V"
	elseif tmp == 5 then
		return "VI"
	else
		return "?"
	end
end*]]

function PANEL:ApplySchemeSettings()

	for _k, column in pairs( self.InfoLabels ) do

		for k, v in pairs( column ) do

			v.Key:SetFGColor( 255, 255, 255, 100 )
			v.Value:SetFGColor( 255, 255, 255, 200 )

		end

	end

end

function PANEL:Think()

	if ( self.PlayerUpdate and self.PlayerUpdate > CurTime() ) then return end
	self.PlayerUpdate = CurTime() + 0.25

	self:UpdatePlayerData()

end

function PANEL:PerformLayout()

	local x = 5

	for colnum, column in pairs( self.InfoLabels ) do

		local y = 0
		local RightMost = 0

		for k, v in pairs( column ) do

			v.Key:SetPos( x, y )
			v.Key:SizeToContents()

			v.Value:SetPos( x + 70 , y )
			v.Value:SizeToContents()

			y = y + v.Key:GetTall() + 2

			RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )

		end

		-- x = RightMost + 10
		x = x + 300

	end

	if ( !self.Player or
		 self.Player == LocalPlayer() or
		 !LocalPlayer():IsAdmin() ) then

		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )

	else

		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )

		self.btnKick:SetPos( self:GetWide() - 52 * 3, 90 )
		self.btnKick:SetSize( 48, 20 )

		self.btnBan:SetPos( self:GetWide() - 52 * 2, 90 )
		self.btnBan:SetSize( 48, 20 )

		self.btnPBan:SetPos( self:GetWide() - 52 * 1, 90 )
		self.btnPBan:SetSize( 48, 20 )

	end

	for k, v in ipairs( self.VoteButtons ) do

		v:InvalidateLayout()
		v:SetPos( self:GetWide() -  k * 25, 0 )
		v:SetSize( 20, 32 )

	end

end

function PANEL:Paint()
	return true
end


vgui.Register( "SA_ScorePlayerInfoCard", PANEL, "Panel" )
