local ItemData = require(script.ItemData)
local StockUtils = require(script.StockUtils)
local BuyLogic = require(script.BuyLogic)

local items = ItemData.Items
local prices = ItemData.Prices
local settings = ItemData.DefaultSettings(items)

-- build UI and connect buyBtn
-- when clicked:
BuyLogic(settings, items.Fruits, prices, StockUtils.getStock, StockUtils.getMoney)
BuyLogic(settings, items.Gears, prices, StockUtils.getStock, StockUtils.getMoney)
