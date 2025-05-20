SA.REQUIRE("ui.main")

-- configuration
local screen_fov = 75
local x_distance_factor = 0.75
local fov_allowed_rot = 2
local screen_dist = 200
local tri_cols = 50
local tri_rows = 1
local hud_max_angle_vel = 20
local supersample_multiplier = 1

local SA_HUD_RT, SA_HUD_RT_MAT, SA_HUD_MESH
local function UpdateHUDRT()
	SA_HUD_MESH = Mesh(SA_HUD_RT_MAT)

	-- automatic calculations
	local screen_fov_rad = math.rad(screen_fov)
	local screen_fov_y_rad = 2 * math.atan(math.tan(screen_fov_rad / 2) / (ScrW() / ScrH()))

	-- adjust for FOV differences to avoid blanks peeking through
	local fov_allowed_rot_rad = math.rad(fov_allowed_rot) * (math.max(screen_fov_rad, screen_fov_y_rad) / math.min(screen_fov_rad, screen_fov_y_rad))

	local screen_x_size = 2 * math.tan(screen_fov_rad / 2) * screen_dist
	local screen_y_size = 2 * math.tan(screen_fov_y_rad / 2) * screen_dist

	local tri_max_dist = math.tan((math.pi / 2) - screen_fov_rad) * (screen_x_size / 2)

	local screen_x_size_max = 2 * math.tan((screen_fov_rad / 2) + fov_allowed_rot_rad) * screen_dist
	local screen_y_size_max = 2 * math.tan((screen_fov_y_rad / 2) + fov_allowed_rot_rad) * (screen_dist + tri_max_dist)

	local rt_width_circle = 2 * math.pi * (tri_max_dist + screen_dist) * (screen_fov / 360)
	local rt_width = math.ceil(ScrW() * supersample_multiplier * (rt_width_circle / screen_x_size))
	local rt_height = ScrH() * supersample_multiplier

	local i = 0
	-- Create render target
	while true do
		SA_HUD_RT = GetRenderTarget("SA_HUD_RT_" .. tostring(i), rt_width, rt_height)
		if SA_HUD_RT:Width() == rt_width and SA_HUD_RT:Height() == rt_height then
			break
		end
		i = i + 1
	end

	SA_HUD_RT_MAT = CreateMaterial("SA_HUD_RT_MAT_" .. tostring(i), "UnlitGeneric", {
		["$basetexture"] = SA_HUD_RT:GetName(),
		["$model"] = 1,
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
	})

	local one_pixel_u_w = 1 / rt_width
	local one_pixel_v_y = 1 / rt_height

	local tri_width = screen_x_size / tri_cols
	local tri_height = screen_y_size / tri_rows

	local tri_cols_skip = math.floor(((screen_x_size_max / tri_width) - tri_cols) / 2) + 1
	local tri_rows_skip = math.floor(((screen_y_size_max / tri_height) - tri_rows) / 2) + 1

	local triangles = {}
	local tri_rows_half = tri_rows / 2
	local tri_rows_lim = tri_rows - 1
	local tri_cols_half = tri_cols / 2
	local tri_cols_lim = tri_cols - 1

	local start_x = -tri_cols_skip
	local end_x = tri_cols_lim + tri_cols_skip
	local start_y = -tri_rows_skip
	local end_y = tri_rows_lim + tri_rows_skip

	local pi_half = math.pi / 2
	local D_offset = math.cos(-pi_half * x_distance_factor) * (tri_max_dist * x_distance_factor)

	for y = start_y,end_y do
		local Y1 = (y - tri_rows_half) * tri_height
		local Y2 = Y1 + tri_height

		local yleft = tri_rows_lim - y
		local V2 = yleft / tri_rows
		local V1 = (yleft + 1) / tri_rows

		V1 = math.Clamp(V1, one_pixel_v_y, 1 - one_pixel_v_y)
		V2 = math.Clamp(V2, one_pixel_v_y, 1 - one_pixel_v_y)

		for x = start_x,end_x do
			local X1 = (x - tri_cols_half) * tri_width
			local X2 = X1 + tri_width

			local D1 = math.cos((((x / tri_cols) * math.pi) - pi_half) *  x_distance_factor) * (tri_max_dist * x_distance_factor)
			local D2 = math.cos(((((x + 1) / tri_cols) * math.pi) - pi_half) * x_distance_factor) * (tri_max_dist * x_distance_factor)

			D1 = D1 - D_offset
			D2 = D2 - D_offset

			local xleft = tri_cols_lim - x
			local U2 = xleft / tri_cols
			local U1 = (xleft + 1) / tri_cols

			U1 = math.Clamp(U1, one_pixel_u_w, 1 - one_pixel_u_w)
			U2 = math.Clamp(U2, one_pixel_u_w, 1 - one_pixel_u_w)

			-- D, X=U, Y=V
			-- clockwise ordering
			table.insert(triangles, { pos = Vector(D2, X2, Y1), u = U2, v = V1 })
			table.insert(triangles, { pos = Vector(D2, X2, Y2), u = U2, v = V2 })
			table.insert(triangles, { pos = Vector(D1, X1, Y1), u = U1, v = V1 })

			table.insert(triangles, { pos = Vector(D2, X2, Y2), u = U2, v = V2 })
			table.insert(triangles, { pos = Vector(D1, X1, Y2), u = U1, v = V2 })
			table.insert(triangles, { pos = Vector(D1, X1, Y1), u = U1, v = V1 })
		end
	end
	SA_HUD_MESH:BuildFromTriangles(triangles)
end

UpdateHUDRT()
hook.Add("OnScreenSizeChanged", "SA_3DHUD_ScreenSizeChanged", UpdateHUDRT)

local use_3d_hud = CreateClientConVar("cl_sa_use_3dhud", 1, true, false)
--local use_3d_bobbing = CreateClientConVar("cl_sa_use_3dhud_bobbing", 1, true, false)
--local hud_at_angle = nil
local old_clipping = nil

function SA.UI.In3DRender()
	return old_clipping ~= nil
end

function SA.UI.PaintStart()
	old_clipping = nil
	if use_3d_hud:GetInt() == 0 then
		return
	end

	render.PushRenderTarget(SA_HUD_RT)
	cam.Start2D()

	render.OverrideAlphaWriteEnable(true, true)
	render.Clear(0, 0, 0, 0, true, true)

	old_clipping = DisableClipping(true) or false
end

function SA.UI.PaintEnd()
	if old_clipping == nil then
		return
	end
	DisableClipping(old_clipping)
	old_clipping = nil

	render.OverrideAlphaWriteEnable(false)
	cam.End2D()
	render.PopRenderTarget()

	local aim_angle = LocalPlayer():EyeAngles()
	aim_angle.roll = 0
	local clamped_angle = Angle(0, 0, 0)

	--[[if use_3d_bobbing:GetInt() ~= 0 then
		if hud_at_angle == nil then
			hud_at_angle = aim_angle
		end

		local angle_diff = aim_angle - hud_at_angle
		angle_diff:Normalize()

		local max_angle_vel_pitch = hud_max_angle_vel * math.Clamp(math.abs(angle_diff.pitch) / fov_allowed_rot, 0.01, 1)
		local max_angle_vel_yaw = hud_max_angle_vel * math.Clamp(math.abs(angle_diff.yaw) / fov_allowed_rot, 0.01, 1)
		local max_angle_vel_frame = FrameTime() * math.max(max_angle_vel_pitch, max_angle_vel_yaw)

		hud_at_angle.pitch = hud_at_angle.pitch + math.Clamp(angle_diff.pitch, -max_angle_vel_frame, max_angle_vel_frame)
		hud_at_angle.yaw = hud_at_angle.yaw + math.Clamp(angle_diff.yaw, -max_angle_vel_frame, max_angle_vel_frame)

		clamped_angle = aim_angle - hud_at_angle
		clamped_angle:Normalize()
		clamped_angle.pitch = math.Clamp(clamped_angle.pitch, -fov_allowed_rot, fov_allowed_rot)
		clamped_angle.yaw = math.Clamp(clamped_angle.yaw, -fov_allowed_rot, fov_allowed_rot)

		hud_at_angle = aim_angle - clamped_angle
	else
		hud_at_angle = nil
	end]]

	cam.Start3D(Vector(-screen_dist,0,0), clamped_angle, screen_fov)
		render.SetMaterial(SA_HUD_RT_MAT)
		SA_HUD_MESH:Draw()
	cam.End3D()
end
