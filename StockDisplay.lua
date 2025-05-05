-- StockDisplay.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function createStockUI(tabFrame, items, getStock)
	-- Clear placeholder if present
	tabFrame:ClearAllChildren()

	-- Countdown label
	local timerLabel = Instance.new("TextLabel", tabFrame)
	timerLabel.Size = UDim2.new(1, 0, 0, 30)
	timerLabel.Position = UDim2.new(0, 0, 0, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 20
	timerLabel.TextColor3 = Color3.new(1, 1, 1)
	timerLabel.Text = "Refreshing soon..."

	-- ScrollFrame below
	local scroll = Instance.new("ScrollingFrame", tabFrame)
	scroll.Size = UDim2.new(1, 0, 1, -35)
	scroll.Position = UDim2.new(0, 0, 0, 35)
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local entryRefs = {}

	local function createEntry(name, isGear)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 28)
		frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(0.7, 0, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Color3.new(1, 1, 1)

		local stockLabel = Instance.new("TextLabel", frame)
		stockLabel.Size = UDim2.new(0.25, 0, 1, 0)
		stockLabel.Position = UDim2.new(0.75, -8, 0, 0)
		stockLabel.BackgroundTransparency = 1
		stockLabel.TextXAlignment = Enum.TextXAlignment.Right
		stockLabel.Font = Enum.Font.GothamBold
		stockLabel.TextSize = 14
		stockLabel.TextColor3 = Color3.new(1, 1, 1)
		stockLabel.Text = "0"

		entryRefs[name] = { label = stockLabel, isGear = isGear }
		frame.Parent = scroll
	end

	for _, item in ipairs(items.Fruits) do createEntry(item, false) end
	for _, item in ipairs(items.Gears) do createEntry(item, true) end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end)

	-- Countdown logic
	local function updateCountdown()
		local now = os.time()
		local nextRefresh = now - now % 300 + 305 -- round to next 5m + 5s
		local diff = nextRefresh - now
		local mins = math.floor(diff / 60)
		local secs = diff % 60
		timerLabel.Text = string.format("⏳ Refreshing in %02d:%02d", mins, secs)
		return diff <= 0
	end

	-- Stock refresh logic
	local function refreshStock()
		for name, entry in pairs(entryRefs) do
			local stock = getStock(name, entry.isGear)
			entry.label.Text = stock
		end
	end

	-- Loop
	task.spawn(function()
		while true do
			local shouldRefresh = updateCountdown()
			if shouldRefresh then
				refreshStock()
				task.wait(1)
			else
				task.wait(1)
			end
		end
	end)
end

return createStockUI
