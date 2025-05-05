-- StockTab.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function formatTime(seconds)
	local min = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", min, sec)
end

return function(tabFrame, items, getStock)
	local timerLabel = Instance.new("TextLabel", tabFrame)
	timerLabel.Size = UDim2.new(1, 0, 0, 35)
	timerLabel.Position = UDim2.new(0, 0, 0, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.Text = "Loading next refresh..."

	local scroll = Instance.new("ScrollingFrame", tabFrame)
	scroll.Position = UDim2.new(0, 0, 0, 40)
	scroll.Size = UDim2.new(1, 0, 1, -40)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	local layout = Instance.new("UIListLayout", scroll)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)

	local function clearItems()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") and child ~= layout then
			child:Destroy()
		end
	end
end


	local function createItemLabel(name, stock)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 26)
		row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		row.BorderSizePixel = 0
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

		local label = Instance.new("TextLabel", row)
		label.Size = UDim2.new(0.7, 0, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.Text = name
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Color3.fromRGB(255, 255, 255)

		local stockLabel = Instance.new("TextLabel", row)
		stockLabel.Size = UDim2.new(0.25, 0, 1, 0)
		stockLabel.Position = UDim2.new(0.75, -10, 0, 0)
		stockLabel.Text = tostring(stock) .. "x"
		stockLabel.TextXAlignment = Enum.TextXAlignment.Right
		stockLabel.BackgroundTransparency = 1
		stockLabel.Font = Enum.Font.GothamBold
		stockLabel.TextSize = 14
		stockLabel.TextColor3 = stock > 0 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)

		return row
	end

	local function refreshStock()
		clearItems()

		local function createCategoryHeader(text)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 26)
	header.Text = text
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.TextSize = 16
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Position = UDim2.new(0, 8, 0, 0)
	return header
end

-- Add Fruits section
createCategoryHeader("🍎 Fruits").Parent = scroll
for _, item in ipairs(items.Fruits) do
	local stock = getStock(item, false)
	createItemLabel(item, stock).Parent = scroll
end

-- Add Gears section
createCategoryHeader("🛠️ Gears").Parent = scroll
for _, item in ipairs(items.Gears) do
	local stock = getStock(item, true)
	createItemLabel(item, stock).Parent = scroll
end

		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end

	local function getNextRefreshDelay()
		local now = os.time()
		local interval = 300 -- 5 minutes
		local refreshDelay = 1
		local nextRefresh = now - (now % interval) + interval + refreshDelay
		return nextRefresh - now
	end

	local function startTimerLoop()
		while true do
			local delay = getNextRefreshDelay()

			for t = delay, 0, -1 do
				timerLabel.Text = "Next Refresh: " .. formatTime(t)
				task.wait(1)
			end

			timerLabel.Text = "Waiting for stock to update..."
			task.wait(5)

			timerLabel.Text = "Refreshing..."
			refreshStock()
		end
	end

	task.spawn(function()
		refreshStock()
		startTimerLoop()
	end)
end
