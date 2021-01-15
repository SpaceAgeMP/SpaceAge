if not SA.Ice then
	SA.Ice = {}
end

function SA.Ice.GetRefined(ore, efficiency)
	if not efficiency then
		efficiency = 0.5
	end

	if ore == "Blue Ice" then
		return {
			liquidnitrogen = math.floor(2500 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(50 * efficiency),
			oxygen = math.floor(300 * efficiency),
			hydrogen = math.floor(150 * efficiency),
			helium = math.floor(400 * efficiency),
			nitrogen = math.floor(400 * efficiency),
			ozone = math.floor(50 * efficiency),
			strontium = math.floor(25 * efficiency)
		}
	elseif ore == "Clear Ice" then
		return {
			liquidnitrogen = math.floor(2500 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(50 * efficiency),
			oxygen = math.floor(150 * efficiency),
			hydrogen = math.floor(100 * efficiency),
			helium = math.floor(300 * efficiency),
			nitrogen = math.floor(500 * efficiency),
			ozone = math.floor(200 * efficiency),
			strontium = math.floor(50 * efficiency)
		}
	elseif ore == "Glacial Mass" then
		return {
			liquidnitrogen = math.floor(2500 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(50 * efficiency),
			oxygen = math.floor(125 * efficiency),
			hydrogen = math.floor(300 * efficiency),
			helium = math.floor(50 * efficiency),
			nitrogen = math.floor(150 * efficiency),
			ozone = math.floor(300 * efficiency),
			strontium = math.floor(100 * efficiency)
		}
	elseif ore == "White Glaze" then
		return {
			liquidnitrogen = math.floor(2500 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(50 * efficiency),
			oxygen = math.floor(200 * efficiency),
			hydrogen = math.floor(200 * efficiency),
			helium = math.floor(200 * efficiency),
			nitrogen = math.floor(300 * efficiency),
			ozone = math.floor(250 * efficiency),
			strontium = math.floor(75 * efficiency)
		}
	elseif ore == "Dark Glitter" then
		return {
			liquidnitrogen = math.floor(10000 * efficiency),
			water = math.floor(25000 * efficiency),
			heavywater = math.floor(500 * efficiency),
			oxygen = math.floor(75 * efficiency),
			hydrogen = math.floor(75 * efficiency),
			helium = math.floor(75 * efficiency),
			nitrogen = math.floor(75 * efficiency),
			ozone = math.floor(800 * efficiency),
			strontium = math.floor(50 * efficiency)
		}
	elseif ore == "Glare Crust" then
		return {
			liquidnitrogen = math.floor(10000 * efficiency),
			water = math.floor(25000 * efficiency),
			heavywater = math.floor(1000 * efficiency),
			oxygen = math.floor(150 * efficiency),
			hydrogen = math.floor(150 * efficiency),
			helium = math.floor(150 * efficiency),
			nitrogen = math.floor(150 * efficiency),
			ozone = math.floor(500 * efficiency),
			strontium = math.floor(25 * efficiency)
		}
	elseif ore == "Gelidus" then
		return {
			liquidnitrogen = math.floor(50000 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(250 * efficiency),
			oxygen = math.floor(100 * efficiency),
			hydrogen = math.floor(80 * efficiency),
			helium = math.floor(100 * efficiency),
			nitrogen = math.floor(150 * efficiency),
			ozone = math.floor(500 * efficiency),
			strontium = math.floor(150 * efficiency),
		}
	elseif ore == "Krystallos" then
		return {
			liquidnitrogen = math.floor(50000 * efficiency),
			water = math.floor(10000 * efficiency),
			heavywater = math.floor(100 * efficiency),
			oxygen = math.floor(100 * efficiency),
			hydrogen = math.floor(150 * efficiency),
			helium = math.floor(150 * efficiency),
			nitrogen = math.floor(500 * efficiency),
			ozone = math.floor(350 * efficiency),
			strontium = math.floor(75 * efficiency),
		}
	end
end
