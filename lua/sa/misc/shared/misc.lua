function bool_to_number(val)
	return val and 1 or 0
end

local EntityMeta = FindMetaTable("Entity")
EntityMeta.GetGravityMultiplier = EntityMeta.GetGravity
EntityMeta.GetGravity = nil
