-- UIBuilder.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function buildUI(settings, items)
	local gui = Instance.new("ScreenGui")
	gui.Name = "AutoShopUI"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 520, 0, 580)
	main.Position = UDim2.new(0.5, -260, 0.5, -290)
	main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
	main.Parent = gui

	local topBar = Instance.new("Frame", main)
	topBar.Size = UDim2.new(1, 0, 0, 30)
	topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	topBar.BorderSizePixel = 0

	local closeBtn = Instance.new("TextButton", topBar)
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -32, 0, 2)
	closeBtn.Text = "✖"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	closeBtn.MouseEnter:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	end)
	closeBtn.MouseLeave:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	end)
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local dragging = false
	local dragStart, startPos
	local uis = game:GetService("UserInputService")

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local conn; conn = uis.InputChanged:Connect(function(move)
				if move == input and dragging then
					local delta = move.Position - dragStart
					main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				elseif not dragging then
					conn:Disconnect()
				end
			end)
		end
	end)

-- Scroll container for tab buttons
local tabScroll = Instance.new("ScrollingFrame", main)
tabScroll.Size = UDim2.new(1, -50, 0, 40)
tabScroll.Position = UDim2.new(0, 10, 0, 35)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 4
tabScroll.CanvasSize = UDim2.new(0, 0, 1, 0)
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
tabScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar

-- The container that holds the tab buttons
local tabHolder = Instance.new("Frame", tabScroll)
tabHolder.Size = UDim2.new(0, 0, 1, 0)
tabHolder.AutomaticSize = Enum.AutomaticSize.X
tabHolder.BackgroundTransparency = 1
	
local tabLayout = Instance.new("UIListLayout", tabHolder)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 10)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left


local function createTab(name)
	local btn = Instance.new("TextButton")
	btn.Parent = tabHolder
	btn.Size = UDim2.new(0, 150, 1, 0)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local autoTabBtn = createTab("AutoBuy")
local stockTabBtn = createTab("Stock")
local tpTabBtn = createTab("Teleports")
local petsTabBtn = createTab("Pets")
local sellTabBtn = createTab("Auto Sell")
local collectTabBtn = createTab("Auto Collect")
local endPadding = Instance.new("Frame")
endPadding.Size = UDim2.new(0, 20, 1, 0)
endPadding.BackgroundTransparency = 1
endPadding.Parent = tabHolder



	local tabContentFrames = {}

local function createTabContent()
	local frame = Instance.new("Frame", main)
	frame.Size = UDim2.new(1, -20, 1, -120)
	frame.Position = UDim2.new(0, 10, 0, 70)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	return frame
end

local autoBuyFrame = createTabContent()
autoBuyFrame.Visible = true
	
-- 🟢 SCROLL first
local scroll = Instance.new("ScrollingFrame", autoBuyFrame)
scroll.Size = UDim2.new(1, 0, 1, -50)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

-- 🔵 FOOTER after
local footer = Instance.new("Frame", autoBuyFrame)
footer.Size = UDim2.new(1, 0, 0, 50)
footer.Position = UDim2.new(0, 0, 1, -50)
footer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
footer.BorderSizePixel = 0
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 8)
	
tabContentFrames["AutoBuy"] = autoBuyFrame
tabContentFrames["Stock"] = createTabContent()
tabContentFrames["Teleports"] = createTabContent()
tabContentFrames["Pets"] = createTabContent()
tabContentFrames["Auto Sell"] = createTabContent()
tabContentFrames["Auto Collect"] = createTabContent()

	-- Tab switching logic
local function showTab(name)
	for tabName, frame in pairs(tabContentFrames) do
		frame.Visible = (tabName == name)
	end
end

autoTabBtn.MouseButton1Click:Connect(function() showTab("AutoBuy") end)
stockTabBtn.MouseButton1Click:Connect(function() showTab("Stock") end)
tpTabBtn.MouseButton1Click:Connect(function() showTab("Teleports") end)
petsTabBtn.MouseButton1Click:Connect(function() showTab("Pets") end)
sellTabBtn.MouseButton1Click:Connect(function() showTab("Auto Sell") end)
collectTabBtn.MouseButton1Click:Connect(function() showTab("Auto Collect") end)

	-- Optional placeholder text
local function addPlaceholder(frame, text)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, 0, 0, 30)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextWrapped = true
end
	
	-- 🚀 Teleport buttons
do
	local tpFrame = tabContentFrames["Teleports"]
		local layout = Instance.new("UIListLayout", tpFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

		addPlaceholder(tabContentFrames["Pets"], "🐾 Pet system coming soon!")
addPlaceholder(tabContentFrames["Auto Sell"], "💰 Auto-sell system in progress!")
addPlaceholder(tabContentFrames["Auto Collect"], "🌾 Auto-collect setup coming soon!")


	
	local function createTeleportButton(labelText, position)
		local btn = Instance.new("TextButton", tpFrame)
		btn.Size = UDim2.new(0, 200, 0, 40)
		btn.Position = UDim2.new(0.5, -100, 0, 10 + (#tpFrame:GetChildren() - 1) * 50)
		btn.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 16
		btn.Font = Enum.Font.GothamBold
		btn.Text = labelText
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		btn.MouseButton1Click:Connect(function()
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char:MoveTo(position)
			end
		end)
	end

	createTeleportButton("🌱 Angry Plant", Vector3.new(-98, 4, -5))
	createTeleportButton("🥚 Egg Shop", Vector3.new(-256, 3, -2))
end



	local layout = Instance.new("UIListLayout", scroll)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)

	local function createSection(title, list)
		local section = Instance.new("Frame", scroll)
		section.Size = UDim2.new(1, 0, 0, 30)
		section.BackgroundTransparency = 1

		local btn = Instance.new("TextButton", section)
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.Text = ""
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

		local arrow = Instance.new("TextLabel", btn)
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(0, 5, 0, 0)
		arrow.Text = "▸"
		arrow.TextSize = 18
		arrow.TextColor3 = Color3.new(1, 1, 1)
		arrow.Font = Enum.Font.GothamBold
		arrow.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", btn)
		label.Size = UDim2.new(1, -30, 1, 0)
		label.Position = UDim2.new(0, 30, 0, 0)
		label.Text = title
		label.Font = Enum.Font.GothamBold
		label.TextSize = 16
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left

		local holder = Instance.new("Frame", scroll)
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.BackgroundTransparency = 1
		holder.ClipsDescendants = true
		local subLayout = Instance.new("UIListLayout", holder)
		subLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local contentHeight = 0
		subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			contentHeight = subLayout.AbsoluteContentSize.Y
		end)

		local isOpen = false
		btn.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			arrow.Text = isOpen and "▼" or "▸"
			TweenService:Create(holder, TweenInfo.new(0.25), {
				Size = UDim2.new(1, 0, 0, isOpen and contentHeight or 0)
			}):Play()
		end)

		for _, item in ipairs(list) do
			local container = Instance.new("Frame", holder)
			container.Size = UDim2.new(1, 0, 0, 30)
			container.BackgroundTransparency = 1

			local cb = Instance.new("TextButton", container)
			cb.Size = UDim2.new(0, 30, 1, 0)
			cb.Text = "☐"
			cb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			cb.TextColor3 = Color3.new(1, 1, 1)
			cb.Font = Enum.Font.Gotham
			cb.TextSize = 16
			Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)

			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(0.35, 0, 1, 0)
			label.Position = UDim2.new(0, 35, 0, 0)
			label.Text = item
			label.Font = Enum.Font.Gotham
			label.TextSize = 15
			label.TextColor3 = Color3.new(1, 1, 1)
			label.BackgroundTransparency = 1
			label.TextXAlignment = Enum.TextXAlignment.Left

			local input = Instance.new("TextBox", container)
			input.Size = UDim2.new(0, 50, 0.9, 0)
			input.Position = UDim2.new(0.55, 0, 0.05, 0)
			input.Text = "1"
			input.TextColor3 = Color3.new(1, 1, 1)
			input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			input.Font = Enum.Font.Gotham
			input.TextSize = 14
			Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)

			local toggle = Instance.new("TextButton", container)
			toggle.Size = UDim2.new(0, 80, 0.9, 0)
			toggle.Position = UDim2.new(1, -90, 0.05, 0)
			toggle.Text = "Max: Off"
			toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			toggle.TextColor3 = Color3.new(1, 1, 1)
			toggle.Font = Enum.Font.Gotham
			toggle.TextSize = 14
			Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)

			cb.MouseButton1Click:Connect(function()
				settings[item].enabled = not settings[item].enabled
				cb.Text = settings[item].enabled and "☑" or "☐"
			end)
			toggle.MouseButton1Click:Connect(function()
				settings[item].max = not settings[item].max
				toggle.Text = settings[item].max and "Max: On" or "Max: Off"
			end)
			input:GetPropertyChangedSignal("Text"):Connect(function()
				local n = tonumber(input.Text)
				if n then settings[item].amount = math.clamp(n, 1, 999) end
			end)
		end

		holder.Parent = scroll
	end

	createSection("🌽 Fruits", items.Fruits)
	createSection("🛠️ Gear", items.Gears)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- 🛒 Buy Button
local buyButton = Instance.new("TextButton", footer)
buyButton.Size = UDim2.new(0, 160, 0, 36)
buyButton.Position = UDim2.new(0.5, -80, 0.5, -18)
buyButton.Text = "Buy Stock"
buyButton.Font = Enum.Font.GothamBold
buyButton.TextSize = 16
buyButton.TextColor3 = Color3.new(1, 1, 1)
buyButton.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
Instance.new("UICorner", buyButton).CornerRadius = UDim.new(0, 6)


buyButton.MouseButton1Click:Connect(function()
	for itemName, data in pairs(settings) do
		if data.enabled then
			local quantity = data.max and "MAX" or data.amount
			print("Buying:", itemName, "Amount:", quantity)
			-- You can replace this print with your buy function, like:
			-- game:GetService("ReplicatedStorage").Buy:FireServer(itemName, quantity)
		end
	end
end)

	return {
	GUI = gui,
	MainFrame = main,
	BuyButton = buyButton,
	StockTab = tabContentFrames["Stock"],
	RefreshStock = function(getStock)
		for itemName, data in pairs(settings) do
			if type(data) == "table" then
				local isGear = table.find(items.Gears, itemName) ~= nil
				local stock = getStock(itemName, isGear)
				-- You could optionally update the button text here if you want
				print(`[UIBuilder] {itemName} has {stock} in stock`)
			end
		end
	end
}
end


return buildUI
