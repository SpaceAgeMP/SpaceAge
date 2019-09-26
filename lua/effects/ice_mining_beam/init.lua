local bGlow1 = CreateMaterial("sc_blue_ball01", "UnLitGeneric", {
	["$basetexture"] = "sprites/physcannon_bluecore2b",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local bGlow2 = CreateMaterial("sc_blue_ball02", "UnLitGeneric", {
	["$basetexture"] = "effects/bluemuzzle",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})


local lGlow1 = CreateMaterial("sc_blue_beam01", "UnLitGeneric", {
	["$basetexture"] = "sprites/bluelight1",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local col = Color(255, 255, 255, 255)

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Multi = data:GetMagnitude() * 0.001
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local rt = RealTime() * 2
	render.SetMaterial(lGlow1)
	render.DrawBeam(self.StartPos, self.EndPos, 32, rt, rt + self.Multi, col)

	render.SetMaterial(lGlow1)
	render.DrawBeam(self.StartPos, self.EndPos, 32, rt, rt + self.Multi * 2, col)

	render.SetMaterial(bGlow1)
	render.DrawSprite(self.EndPos, 64, 64, col)

	render.SetMaterial(bGlow2)
	render.DrawSprite(self.StartPos, 64, 64, col)
end
