local SellTab = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local PlayerGui = player:WaitForChild("PlayerGui")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SellItem = GameEvents:WaitForChild("Sell_Item")
local SellInventory = GameEvents:WaitForChild("Sell_Inventory")

-- ✅ Complete fruit list
local cropOptions = {
	"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn",
	"Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut",
	"Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper",
	"Raspberry", "Cranberry", "Durian", "Eggplant", "Lotus"
}

-- Mutation list
local mutationOptions = {
	"Gold", "Rainbow", "Wet", "Frozen", "Chilled", "Shocked"
}

-- Sell zone teleport position
local SELL_POSITION = Vector3.new(61, 3, 0)

-- State tables
local selectedCrops = {}
local selectedMutations = {}

-- 🧠 Extract mutations from tool name
local function extractMutations(toolName)
	local mutations = {}
	local prefix = toolName:match("^%[(.-)%]")
	if prefix then
		for mutation in prefix:gmatch("[^,%s]+") do
			table.insert(mutations, mutation)
		end
	end
	return mutations
end

-- ✅ Tool filter match
local function isValidTool(tool)
	if not tool:IsA("Tool") then return false end

	local name = tool.Name
	local cleanName = name:match(".*%] (.-) %[%d") or name:match("^(.-) %[%d") or name

	if not selectedCrops[cleanName] then return false end

	local mutations = extractMutations(name)
	for required in pairs(selectedMutations) do
		local found = false
		for _, m in ipairs(mutations) do
			if m == required then
				found = true
				break
			end
		end
		if not found then return false end
	end

	return true
end

-- 🚀 Teleport
local function teleportTo(position)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(position)
	end
end

-- 🔘 Sell Inventory
function SellTab.SellAll()
	local originalPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart").Position
	teleportTo(SELL_POSITION)
	task.wait(0.3)
	SellInventory:FireServer()
	task.wait(0.2)
	teleportTo(originalPos)
end

-- 🔘 Sell Selected
function SellTab.SellSelected()
	local originalPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart").Position
	teleportTo(SELL_POSITION)
	task.wait(0.2)

	for _, tool in ipairs(backpack:GetChildren()) do
		if isValidTool(tool) then
			player.Character.Humanoid:EquipTool(tool)
			task.wait(0.15)
			SellItem:FireServer(tool)
			task.wait(0.15)
		end
	end

	task.wait(0.2)
	teleportTo(originalPos)
end

-- 🧩 UI bindings
function SellTab.SetCropSelected(crop, state)
	selectedCrops[crop] = state or nil
end

function SellTab.SetMutationSelected(mutation, state)
	selectedMutations[mutation] = state or nil
end

-- 🧱 UI Builder Function
function SellTab.BuildUI(frame)
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 4)
	UIListLayout.Parent = frame

	local function makeCheckbox(text, callback)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 28)
		button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Text = "[ ] " .. text
		button.Font = Enum.Font.Gotham
		button.TextSize = 14

		local selected = false
		button.MouseButton1Click:Connect(function()
			selected = not selected
			button.Text = selected and "[✔] " .. text or "[ ] " .. text
			callback(text, selected)
		end)

		button.Parent = frame
	end

	-- 🍓 Fruit checkboxes
	local cropLabel = Instance.new("TextLabel")
	cropLabel.Text = "Select Crops to Sell"
	cropLabel.Size = UDim2.new(1, 0, 0, 24)
	cropLabel.BackgroundTransparency = 1
	cropLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	cropLabel.Font = Enum.Font.GothamBold
	cropLabel.TextSize = 16
	cropLabel.Parent = frame

	for _, crop in ipairs(cropOptions) do
		makeCheckbox(crop, SellTab.SetCropSelected)
	end

	-- 🌈 Mutation toggles
	local mutationLabel = Instance.new("TextLabel")
	mutationLabel.Text = "Select Required Mutations"
	mutationLabel.Size = UDim2.new(1, 0, 0, 24)
	mutationLabel.BackgroundTransparency = 1
	mutationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	mutationLabel.Font = Enum.Font.GothamBold
	mutationLabel.TextSize = 16
	mutationLabel.Parent = frame

	for _, mutation in ipairs(mutationOptions) do
		makeCheckbox(mutation, SellTab.SetMutationSelected)
	end

	-- 🎯 Sell Buttons
	local buttonSellSelected = Instance.new("TextButton")
	buttonSellSelected.Size = UDim2.new(1, 0, 0, 36)
	buttonSellSelected.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
	buttonSellSelected.TextColor3 = Color3.new(1, 1, 1)
	buttonSellSelected.Text = "Sell Selected"
	buttonSellSelected.Font = Enum.Font.GothamBold
	buttonSellSelected.TextSize = 16
	buttonSellSelected.Parent = frame
	buttonSellSelected.MouseButton1Click:Connect(SellTab.SellSelected)

	local buttonSellAll = Instance.new("TextButton")
	buttonSellAll.Size = UDim2.new(1, 0, 0, 36)
	buttonSellAll.BackgroundColor3 = Color3.fromRGB(120, 70, 70)
	buttonSellAll.TextColor3 = Color3.new(1, 1, 1)
	buttonSellAll.Text = "Sell Entire Inventory"
	buttonSellAll.Font = Enum.Font.GothamBold
	buttonSellAll.TextSize = 16
	buttonSellAll.Parent = frame
	buttonSellAll.MouseButton1Click:Connect(SellTab.SellAll)
end

return SellTab
