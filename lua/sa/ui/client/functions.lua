SA.REQUIRE("ui.main")

local function GetProceduralEdge(vertices, cornerRadius, divisions, startDegrees, circleCenterX, circleCenterY, x, y, width, height)
	for i = 1, divisions do
		local offset = (90 / divisions) * i
		local degrees = startDegrees - offset

		local finalX = circleCenterX + (math.cos(math.rad(degrees)) * cornerRadius)
		local finalY = circleCenterY - (math.sin(math.rad(degrees)) * cornerRadius)

		table.insert(vertices, {x = finalX, y = finalY, u = (finalX-x) / width, v = (finalY-y) / height})
	end
end

function SA.UI.DrawTexturedRectRounded(x, y, width, height, cornerRadius, divisions, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
	local vertices = {}

	--top left and variable init
	local cornerX = x
	local cornerY = y

	local startDegrees = 180

	-- default nil round values
	local roundTL = true
	if (roundTopLeft ~= nil) then
		 roundTL = roundTopLeft
	end

	local roundTR = true
	if (roundTopRight ~= nil) then
		 roundTR = roundTopRight
	end

	local roundBL = true
	if (roundBottomLeft ~= nil) then
		 roundBL = roundBottomLeft
	end

	local roundBR = true
	if (roundBottomRight ~= nil) then
		 roundBR = roundBottomRight
	end

	local circleCenterX = cornerX + cornerRadius
	local circleCenterY = cornerY + cornerRadius

-- top left insert

	if (roundTL) then
		GetProceduralEdge(vertices, cornerRadius, divisions, startDegrees, circleCenterX, circleCenterY, x, y, width, height)
	else
		table.insert(vertices, {x = cornerX, y = cornerY, u = (cornerX-x) / width, v = (cornerY-y) / height })
	end


-- top right
	startDegrees = 90
	cornerX = x + width
	circleCenterX = cornerX - cornerRadius

	if (roundTR) then
		GetProceduralEdge(vertices, cornerRadius, divisions, startDegrees, circleCenterX, circleCenterY, x, y, width, height)
	else
		table.insert(vertices, {x = cornerX, y = cornerY, u = (cornerX-x) / width, v = (cornerY-y) / height })
	end

-- bottom right
	startDegrees = 360
	cornerY = y + height
	circleCenterY = cornerY - cornerRadius

	if (roundBR) then
		GetProceduralEdge(vertices, cornerRadius, divisions, startDegrees, circleCenterX, circleCenterY, x, y, width, height)
	else
		table.insert(vertices, {x = cornerX, y = cornerY, u = (cornerX-x) / width, v = (cornerY-y) / height})
	end

-- bottom left
	startDegrees = 270
	cornerX = x
	circleCenterX = cornerX + cornerRadius

	if (roundBL) then
		GetProceduralEdge(vertices, cornerRadius, divisions, startDegrees, circleCenterX, circleCenterY, x, y, width, height)
	else
		table.insert(vertices, {x = cornerX, y = cornerY, u = (cornerX-x) / width, v = (cornerY-y) / height})
	end

	surface.DrawPoly(vertices)
end
