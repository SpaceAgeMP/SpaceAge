include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:DrawEntityOutline( size )
end

function ENT:Draw( bDontDrawModel )
	if (not bDontDrawModel ) then self:DrawModel() end
end
