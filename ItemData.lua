local module = {}

module.Items = {
	Fruits = {
		"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn",
		"Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
		"Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper"
	},
	Gears = {
		"Watering Can", "Trowel", "Basic Sprinkler", "Advanced Sprinkler",
		"Godly Sprinkler", "Lightning Rod", "Master Sprinkler"
	}
}

module.Prices = {
	["Carrot"] = 10, ["Strawberry"] = 50, ["Blueberry"] = 400, ["Orange Tulip"] = 600,
	["Tomato"] = 800, ["Corn"] = 1300, ["Daffodil"] = 1000, ["Watermelon"] = 2500,
	["Pumpkin"] = 3000, ["Apple"] = 3250, ["Bamboo"] = 4000, ["Coconut"] = 6000,
	["Cactus"] = 15000, ["Dragon Fruit"] = 50000, ["Mango"] = 100000, ["Grape"] = 850000,
	["Mushroom"] = 150000, ["Pepper"] = 1000000,
	["Watering Can"] = 50000, ["Trowel"] = 100000,
	["Basic Sprinkler"] = 25000, ["Advanced Sprinkler"] = 50000,
	["Godly Sprinkler"] = 120000, ["Lightning Rod"] = 1000000,
	["Master Sprinkler"] = 10000000
}

function module.DefaultSettings(itemGroups)
	local settings = {}
	for _, group in pairs(itemGroups) do
		for _, item in ipairs(group) do
			settings[item] = { enabled = false, max = false, amount = 1 }
		end
	end
	return settings
end

return module
