include("shared.lua")

surface.CreateFont("SAToolTipFont",
{
	font = "neuropol",
	size = 20,
	weight = 700
})

local cl_drawworldtooltips = GetConVar("cl_drawworldtooltips", "1")
local worldTip = nil

--
-- Adds a hint to the queue
--
function AddWorldTip(unused1, text, unused2, pos, ent)
	worldTip = {
		dietime = SysTime() + 0.05,
		text = text,
		pos = pos,
		ent = ent
	}
end

local function drawThiccBox(x, y, w, h, b)
	-- top
	surface.DrawRect(x, y, w, b)
	-- right
	surface.DrawRect(x + w - b, y, b, h)
	-- bottom
	surface.DrawRect(x, y + h - b, w, b)
	--left
	surface.DrawRect(x, y, b, h)
end

local padding = 30
local offset = 50
local border = 2

function GM:PaintWorldTips()
	if (not cl_drawworldtooltips:GetBool()) then return end

	if (not worldTip or worldTip.dietime < SysTime()) then
		return
	end
	if (IsValid(worldTip.ent)) then
		worldTip.pos = worldTip.ent:GetPos()
	end

	local pos = worldTip.pos:ToScreen()

	local fdColor = team.GetColor(LocalPlayer():Team())

	fdColor.a = 200

	surface.SetFont("SAToolTipFont")
	local w, h = surface.GetTextSize(worldTip.text)

	local x = (pos.x - w) - offset
	local y = (pos.y - h) - offset

	surface.SetDrawColor(20, 20, 20, 200)
	local bX = x - padding
	local bY = y - padding
	local bW = w + padding
	local bH = h + padding
	surface.DrawRect(bX, bY, bW, bH)
	surface.SetDrawColor(fdColor)
	drawThiccBox(bX, bY, bW, bH, border)

	draw.DrawText(worldTip.text, "SAToolTipFont", x + (w - padding) / 2, y - padding / 2, fdColor, TEXT_ALIGN_CENTER)
end
