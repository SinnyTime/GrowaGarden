-- Base URL
local BASE_URL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/"

-- Loader helper
local function import(name)
	local src = game:HttpGet(BASE_URL .. name .. ".lua")
	local module = loadstring(src)
	assert(module, "Failed to load module: " .. name)
	return module()
end

-- Import modules
local ItemData = import("ItemData")
local StockUtils = import("StockUtils")
local BuyLogic = import("BuyLogic")
local UIBuilder = import("UIBuilder")

-- Build data & settings
local items = ItemData.Items
local prices = ItemData.Prices
local settings = ItemData.DefaultSettings(items)

-- Build UI and get back the buy button
local ui = UIBuilder(settings, items)

-- Connect buy logic to button
BuyLogic.Init({
	settings = settings,
	items = items.Fruits,
	prices = prices,
	getStock = StockUtils.getStock,
	getMoney = StockUtils.getMoney,
})

BuyLogic.Init({
	settings = settings,
	items = items.Gears,
	prices = prices,
	getStock = StockUtils.getStock,
	getMoney = StockUtils.getMoney,
})
