local module = {}

-- Item categories
module.Items = {
	Fruits = {
		"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn",
		"Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
		"Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper", "Cocao"
	},
	PremiumFruits = {
		"Raspberry", "Cranberry", "Durian", "Eggplant", "Lotus", "Peach", "Pineapple"
	},
	Gears = {
		"Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler",
		"Godly Sprinkler", "Lightning Rod", "Master Sprinkler", "Favorite Tool"
	}
}

-- Flat price lookup
module.Prices = {
	["Carrot"] = 10, ["Strawberry"] = 50, ["Blueberry"] = 400, ["Orange Tulip"] = 600,
	["Tomato"] = 800, ["Corn"] = 1300, ["Daffodil"] = 1000, ["Watermelon"] = 2500,
	["Pumpkin"] = 3000, ["Apple"] = 3250, ["Bamboo"] = 4000, ["Coconut"] = 6000,
	["Cactus"] = 15000, ["Dragon Fruit"] = 50000, ["Mango"] = 100000, ["Grape"] = 850000,
	["Mushroom"] = 150000, ["Pepper"] = 1000000, ["Cacao"] = 250000m
	["Watering Can"] = 50000, ["Trowel"] = 100000,
	["Recall Wrench"] = 150000
	["Basic Sprinkler"] = 25000, ["Advanced Sprinkler"] = 50000,
	["Godly Sprinkler"] = 120000, ["Lightning Rod"] = 1000000,
	["Master Sprinkler"] = 10000000,
	["Favorite Tool"] = 20000000
}

-- Default toggle state settings
function module.DefaultSettings(itemGroups)
	local settings = {}
	for _, group in pairs(itemGroups) do
		for _, item in ipairs(group) do
			settings[item] = { enabled = false, max = false, amount = 1 }
		end
	end
	return settings
end

-- Returns the price of a given item or 0 if not found
function module.GetPrice(item)
	return module.Prices[item] or 0
end

-- Returns a flat list of all items (Fruits + Gears)
function module.GetAllItems()
	local all = {}
	for _, group in pairs(module.Items) do
		for _, item in ipairs(group) do
			table.insert(all, item)
		end
	end
	return all
end

-- Developer helper: warns if any item is missing from Prices table
function module.ValidatePrices()
	for _, group in pairs(module.Items) do
		for _, item in ipairs(group) do
			if not module.Prices[item] then
				warn("[ItemData] Missing price for item: " .. item)
			end
		end
	end
end

return module
