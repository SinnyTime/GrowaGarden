-- SellTab.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SellEvent = GameEvents:WaitForChild("Sell_Item")
local SellAllEvent = GameEvents:WaitForChild("Sell_Inventory")

-- Configuration
local SELL_POSITION = Vector3.new(61, 3, 0)
local RETURN_DELAY = 0.5

-- Fruit List
local fruits = {
	"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn",
	"Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
	"Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper",
	"Raspberry", "Cranberry", "Durian", "Eggplant", "Lotus"
}

-- Mutation Mapping
local mutationMap = {
	FrozenParticle = "Frozen",
	WetParticle = "Wet",
	ChilledParticle = "Chilled",
	ShockedParticle = "Shocked"
}

local variantList = { "Normal", "Gold", "Rainbow" }

-- UI Elements
local selectedFruits = {}
local selectedMutations = {}
local selectedVariants = {}

-- Utility Functions
local function hasBadMutations(item)
	for mutation in pairs(mutationMap) do
		if item:FindFirstChild(mutation) and not selectedMutations[mutation] then
			return true
		end
	end
	return false
end

local function matchesVariant(tool)
	local variantObj = tool:FindFirstChild("Variant")
	local variant = (variantObj and typeof(variantObj.Value) == "string" and variantObj.Value) or "Normal"
	return selectedVariants[variant]
end

local function teleportTo(position)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char:MoveTo(position)
	end
end

local function getInventoryItems()
	local backpack = LocalPlayer:WaitForChild("Backpack")
	local items = {}

	for _, tool in ipairs(backpack:GetChildren()) do
		for _, fruitName in ipairs(fruits) do
			if tool.Name:match(fruitName) and selectedFruits[fruitName] then
				if not hasBadMutations(tool) and matchesVariant(tool) then
					table.insert(items, tool)
					break
				end
			end
		end
	end

	return items
end

local function sellItems(items)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local originalPos = root.Position

	teleportTo(SELL_POSITION)
	task.wait(RETURN_DELAY)

	for _, tool in ipairs(items) do
		SellEvent:FireServer(tool.Name)
		task.wait(0.1)
	end

	task.wait(RETURN_DELAY)
	teleportTo(originalPos)
end

local function sellFullInventory()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local originalPos = root.Position

	teleportTo(SELL_POSITION)
	task.wait(RETURN_DELAY)

	SellAllEvent:FireServer()
	task.wait(RETURN_DELAY)

	teleportTo(originalPos)
end

-- UI Construction
return function(tab)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -50)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Parent = tab

	local layout = Instance.new("UIListLayout", scroll)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	local function createHeader(text)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 26)
		label.Text = text
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 16
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = scroll
	end

	local function createCheckbox(labelText, callback)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 26)
		container.BackgroundTransparency = 1
		container.Parent = scroll

		local box = Instance.new("TextButton", container)
		box.Size = UDim2.new(0, 26, 1, 0)
		box.Text = "☐"
		box.Font = Enum.Font.Gotham
		box.TextSize = 16
		box.TextColor3 = Color3.new(1, 1, 1)
		box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

		local label = Instance.new("TextLabel", container)
		label.Size = UDim2.new(1, -34, 1, 0)
		label.Position = UDim2.new(0, 34, 0, 0)
		label.Text = labelText
		label.Font = Enum.Font.Gotham
		label.TextSize = 15
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left

		local checked = false
		box.MouseButton1Click:Connect(function()
			checked = not checked
			box.Text = checked and "☑" or "☐"
			callback(checked)
		end)
	end

	-- Fruits
	createHeader("🍓 Select Fruits")
	for _, fruit in ipairs(fruits) do
		selectedFruits[fruit] = false
		createCheckbox(fruit, function(state)
			selectedFruits[fruit] = state
		end)
	end

	-- Variants
	createHeader("🌈 Select Variants")
	for _, variant in ipairs(variantList) do
		selectedVariants[variant] = false
		createCheckbox(variant, function(state)
			selectedVariants[variant] = state
		end)
	end

	-- Mutations
	createHeader("🧬 Require Mutations")
	for mutation, label in pairs(mutationMap) do
		selectedMutations[mutation] = false
		createCheckbox(label, function(state)
			selectedMutations[mutation] = state
		end)
	end

	-- Footer
	local footer = Instance.new("Frame", tab)
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundTransparency = 1

	local sellSelected = Instance.new("TextButton", footer)
	sellSelected.Size = UDim2.new(0, 160, 0, 36)
	sellSelected.Position = UDim2.new(0.5, -170, 0.5, -18)
	sellSelected.Text = "Sell Selected"
	sellSelected.Font = Enum.Font.GothamBold
	sellSelected.TextSize = 16
	sellSelected.TextColor3 = Color3.new(1, 1, 1)
	sellSelected.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
	Instance.new("UICorner", sellSelected).CornerRadius = UDim.new(0, 6)
	sellSelected.MouseButton1Click:Connect(function()
		local items = getInventoryItems()
		sellItems(items)
	end)

	local sellAll = Instance.new("TextButton", footer)
	sellAll.Size = UDim2.new(0, 160, 0, 36)
	sellAll.Position = UDim2.new(0.5, 10, 0.5, -18)
	sellAll.Text = "Sell Inventory"
	sellAll.Font = Enum.Font.GothamBold
	sellAll.TextSize = 16
	sellAll.TextColor3 = Color3.new(1, 1, 1)
	sellAll.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
	Instance.new("UICorner", sellAll).CornerRadius = UDim.new(0, 6)
	sellAll.MouseButton1Click:Connect(sellFullInventory)
end
