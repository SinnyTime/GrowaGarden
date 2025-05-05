-- Base URL
local BASE_URL = "https://raw.githubusercontent.com/SinnyTime/GrowaGarden/main/"

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

-- Build UI
local ui = UIBuilder(settings, items)

-- OPTIONAL: hook to UI buy button here if you want interactivity
-- Otherwise it just runs right away:

BuyLogic(settings, items.Fruits, prices, StockUtils.getStock, StockUtils.getMoney)
BuyLogic(settings, items.Gears, prices, StockUtils.getStock, StockUtils.getMoney)
