local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:UniqueID2()
    if not self._UniqueID then
        self._UniqueID = util.CRC("gm_" .. self:SteamID() .. "_gm")
    end
    return self._UniqueID
end
