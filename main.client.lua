-- Base URL to your GitHub repo
local BASE_URL = "https://raw.githubusercontent.com/SinnyTime/GrowaGarden/main/"

-- Loader helper
local function import(name)
	local src = game:HttpGet(BASE_URL .. name .. ".lua")
	local module = loadstring(src)
	assert(module, "Failed to load module: " .. name)
	return module()
end

-- Import all modules
local ItemData = import("ItemData")
local StockUtils = import("StockUtils")
local BuyLogic = import("BuyLogic")
local UIBuilder = import("UIBuilder")
local StockTab = import("StockTab")

-- Set up data
local items = ItemData.Items
local prices = ItemData.Prices
local settings = ItemData.DefaultSettings(items)
settings._Gears = items.Gears -- used by BuyLogic to check gear items

-- Build UI
local ui = UIBuilder(settings, items)
-- Start StockTab logic
if ui.StockTab then
	StockTab(ui.StockTab, items, StockUtils.getStock)
else
	warn("❌ StockTab frame not returned by UIBuilder!")
end


-- Wire the button to BuyLogic
if ui.BuyButton then
	ui.BuyButton.MouseButton1Click:Connect(function()
		print("💰 Buying selected items...")
		BuyLogic(settings, items.Fruits, prices, StockUtils.getStock, StockUtils.getMoney)
		BuyLogic(settings, items.Gears, prices, StockUtils.getStock, StockUtils.getMoney)
	end)
else
	warn("❌ BuyButton not returned by UIBuilder!")
end

-- Optional stock refresh logging
ui.RefreshStock(StockUtils.getStock)

-- Hotkey toggle: Left Control
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
		ui.GUI.Enabled = not ui.GUI.Enabled
	end
end)

print("🌱 Grow a Garden AutoShop UI loaded and ready!")
