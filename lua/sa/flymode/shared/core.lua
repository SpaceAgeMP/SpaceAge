SA.FlyMode = SA.FlyMode or {}

local convarEnable = CreateConVar("sa_use_flymode", "0", FCVAR_REPLICATED)

function SA.FlyMode.Set(ply, enabled)
	ply:SetNWBool("flymode", enabled)
end

function SA.FlyMode.Toggle(ply)
	SA.FlyMode.Set(ply, not ply:GetNWBool("flymode"))
end

hook.Add("PlayerNoClip", "SA_NoclipFlyMode", function(ply, state)
	if not convarEnable:GetBool() or not state then
		SA.FlyMode.Set(ply, false)
		return true
	end

	SA.FlyMode.Toggle(ply)
	return false
end)

hook.Add("Move", "SA_FlyMode_Move", function(ply, mv)
	if not ply:GetNWBool("flymode") then
		return
	end

	local speed = 0.05 * FrameTime()
	if mv:KeyDown(IN_SPEED) then speed = speed * 5 end

	mv:SetMoveAngles(Angle(0,0,0))
	local vel = Vector(
		mv:GetForwardSpeed(),
		-mv:GetSideSpeed(),
		mv:GetUpSpeed()
	)
	vel:Rotate(mv:GetAngles())
	mv:SetVelocity(vel)

	local startPos = mv:GetOrigin()
	local endPos = startPos + (vel * speed)

	local tr = util.TraceHull({
		start = startPos,
		endpos = endPos,
		maxs = ply:OBBMaxs(),
		mins = ply:OBBMins(),
		filter = ply,
	})

	if tr.Hit then
		endPos = startPos + (vel * speed * tr.Fraction)
	end

	mv:SetOrigin(endPos)

	return true
end)
