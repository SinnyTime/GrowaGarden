-- SellTab.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents
local SellEvent = ReplicatedStorage:WaitForChild("SellItem")
local EquipEvent = ReplicatedStorage:WaitForChild("EquipItem")

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

-- UI Elements
local selectedFruits = {}
local selectedMutations = {}

-- Utility Functions
local function hasBadMutations(item)
	for particleName in pairs(mutationMap) do
		if item:FindFirstChild(particleName) and not selectedMutations[particleName] then
			return true
		end
	end
	return false
end

local function teleportTo(position)
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character:MoveTo(position)
	end
end

local function getInventoryItems()
	local backpack = LocalPlayer:WaitForChild("Backpack")
	local inventoryItems = {}
	for _, item in ipairs(backpack:GetChildren()) do
		if table.find(fruits, item.Name) and selectedFruits[item.Name] and not hasBadMutations(item) then
			table.insert(inventoryItems, item)
		end
	end
	return inventoryItems
end

local function sellItems(items)
	local originalPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
	if not originalPosition then return end

	teleportTo(SELL_POSITION)
	task.wait(RETURN_DELAY)

	for _, item in ipairs(items) do
		EquipEvent:FireServer(item.Name)
		task.wait(0.1)
		SellEvent:FireServer(item.Name)
		task.wait(0.1)
	end

	task.wait(RETURN_DELAY)
	teleportTo(originalPosition)
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

	-- Populate Fruit Checkboxes
	createHeader("🍓 Select Fruits")
	for _, fruit in ipairs(fruits) do
		selectedFruits[fruit] = false
		createCheckbox(fruit, function(state)
			selectedFruits[fruit] = state
		end)
	end

	-- Populate Mutation Checkboxes
	createHeader("🧬 Select Mutations")
	for particleName, displayName in pairs(mutationMap) do
		selectedMutations[particleName] = false
		createCheckbox(displayName, function(state)
			selectedMutations[particleName] = state
		end)
	end

	-- Footer Buttons
	local footer = Instance.new("Frame", tab)
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundTransparency = 1

	local sellInventoryButton = Instance.new("TextButton", footer)
	sellInventoryButton.Size = UDim2.new(0, 160, 0, 36)
	sellInventoryButton.Position = UDim2.new(0.5, -170, 0.5, -18)
	sellInventoryButton.Text = "Sell Inventory"
	sellInventoryButton.Font = Enum.Font.GothamBold
	sellInventoryButton.TextSize = 16
	sellInventoryButton.TextColor3 = Color3.new(1, 1, 1)
	sellInventoryButton.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", sellInventoryButton).CornerRadius = UDim.new(0, 6)

	local sellSelectedButton = Instance.new("TextButton", footer)
	sellSelectedButton.Size = UDim2.new(0, 160, 0, 36)
	sellSelectedButton.Position = UDim2.new(0.5, 10, 0.5, -18)
	sellSelectedButton.Text = "Sell Selected"
	sellSelectedButton.Font = Enum.Font.GothamBold
	sellSelectedButton.TextSize = 16
	sellSelectedButton.TextColor3 = Color3.new(1, 1, 1)
	sellSelectedButton.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", sellSelectedButton).CornerRadius = UDim.new(0, 6)

	sellInventoryButton.MouseButton1Click:Connect(function()
		local items = getInventoryItems()
		sellItems(items)
	end)

	sellSelectedButton.MouseButton1Click:Connect(function()
		local items = getInventoryItems()
		sellItems(items)
	end)
end
