local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SellAllEvent = GameEvents:WaitForChild("Sell_Inventory")
local SELL_POSITION = Vector3.new(61, 3, 0)

local BASE_URL = "https://raw.githubusercontent.com/SinnyTime/GrowaGarden/main/"
local function import(name)
	local src = game:HttpGet(BASE_URL .. name .. ".lua")
	local module = loadstring(src)
	assert(module, "Failed to load module: " .. name)
	return module()
end

local ItemData = import("ItemData")
local crops = {}
for _, name in ipairs(ItemData.Items.Fruits) do
	table.insert(crops, name)
end
for _, name in ipairs(ItemData.Items.PremiumFruits or {}) do
	table.insert(crops, name)
end

local variants = { "Normal", "Gold", "Rainbow" }

local mutationMap = {
	FrozenParticle = "Frozen",
	WetParticle = "Wet",
	ChilledParticle = "Chilled",
	ShockedParticle = "Shocked"
}

local selectedCrops, selectedVariants, selectedMutations = {}, {}, {}
local allFruits, allVariants, allMutations = false, false, false
local autoSellEnabled = false
local flyingBP, flyingGyro, noclipConn

local function enableFly()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	flyingBP = Instance.new("BodyPosition")
	flyingBP.Name = "FlyBP"
	flyingBP.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	flyingBP.D = 1500
	flyingBP.P = 50000
	flyingBP.Position = root.Position
	flyingBP.Parent = root

	flyingGyro = Instance.new("BodyGyro")
	flyingGyro.Name = "FlyGyro"
	flyingGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	flyingGyro.D = 500
	flyingGyro.P = 3000
	flyingGyro.CFrame = root.CFrame
	flyingGyro.Parent = root

	LocalPlayer.Character:SetAttribute("NoclipActive", true)
	noclipConn = RunService.Stepped:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:GetAttribute("NoclipActive") then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function moveTo(pos)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root and flyingBP and flyingGyro then
		flyingBP.Position = pos
		flyingGyro.CFrame = CFrame.new(pos)
	end
end

local function disableFly()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		if flyingBP then flyingBP:Destroy() flyingBP = nil end
		if flyingGyro then flyingGyro:Destroy() flyingGyro = nil end
	end
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	LocalPlayer.Character:SetAttribute("NoclipActive", false)
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = true end
	end
end

local function hasBadMutations(fruit)
	if allMutations then return false end

	local found = {}
	for _, descendant in ipairs(fruit:GetDescendants()) do
		if mutationMap[descendant.Name] then
			found[descendant.Name] = true
		end
	end

	local userSelected = {}
	for mutation, selected in pairs(selectedMutations) do
		if selected then
			userSelected[mutation] = true
		end
	end

	if next(userSelected) == nil then
		return next(found) ~= nil
	end

	for mutation in pairs(userSelected) do
		if not found[mutation] then return true end
	end
	for mutation in pairs(found) do
		if not userSelected[mutation] then return true end
	end

	return false
end

local function getFruitParts(crop)
	local fruits = {}
	for _, descendant in ipairs(crop:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			local part = descendant:FindFirstAncestorWhichIsA("Model") or descendant:FindFirstAncestorWhichIsA("BasePart")
			if part and not table.find(fruits, part) then
				table.insert(fruits, part)
			end
		end
	end
	return fruits
end

local function collectFruits()
	print("🍇 Starting fruit collection...")
	local collected, skipped = 0, 0

	local root = Workspace:FindFirstChild("Farm")
	if not root then return warn("❌ No 'Farm' found.") end

	local playerFarm
	for _, farm in ipairs(root:GetChildren()) do
		local owner = farm:FindFirstChild("Important")
			and farm.Important:FindFirstChild("Data")
			and farm.Important.Data:FindFirstChild("Owner")
		if owner and owner:IsA("StringValue") and owner.Value == LocalPlayer.Name then
			playerFarm = farm
			break
		end
	end
	if not playerFarm then return warn("❌ Your farm wasn't found.") end

	local plants = playerFarm.Important:FindFirstChild("Plants_Physical")
	if not plants then return warn("❌ No Plants_Physical folder found.") end

	local returnPos = playerFarm:FindFirstChild("Sign")
		and playerFarm.Sign:FindFirstChild("Core_Part")
		and playerFarm.Sign.Core_Part.Position

	enableFly()

	for _, crop in ipairs(plants:GetChildren()) do
		local cropName = crop.Name
		if not allFruits and not selectedCrops[cropName] then continue end

		for _, fruit in ipairs(getFruitParts(crop)) do
			local variantObj = fruit:FindFirstChild("Variant")
			local variant = (variantObj and typeof(variantObj.Value) == "string" and variantObj.Value) or "Normal"

			if not allVariants and not selectedVariants[variant] then continue end
			if hasBadMutations(fruit) then skipped += 1 continue end

			local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
			local part = fruit:IsA("Model") and fruit:FindFirstChildWhichIsA("BasePart") or fruit
			if not (prompt and part) then skipped += 1 continue end

			local above = part.Position + Vector3.new(0, 3, 0)
			moveTo(above)
			task.wait(0.35)

			local cam = Workspace.CurrentCamera
			if cam then cam.CFrame = CFrame.new(above, part.Position) end
			task.wait(0.15)

			local success = false
			for _ = 1, 10 do
				if not prompt:IsDescendantOf(game) then success = true break end
				pcall(function() fireproximityprompt(prompt) end)
				task.wait(0.25)
			end

			if success then
				collected += 1
			else
				skipped += 1
				warn("⚠️ Could not collect:", cropName, fruit.Name)
			end
		end
	end

	if autoSellEnabled then
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local returnPos = root and root.Position
		moveTo(SELL_POSITION)
		task.wait(0.5)
		SellAllEvent:FireServer()
		task.wait(0.5)
		if returnPos then moveTo(returnPos) end
	end

	if returnPos then
		moveTo(returnPos + Vector3.new(0, 10, 0))
		task.wait(0.5)
	end

	disableFly()
	print(`✅ Done. Collected: {collected}, Skipped: {skipped}`)
end

local function createHeader(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 26)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
end

local function createCheckbox(parent, labelText, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 26)
	container.BackgroundTransparency = 1
	container.Parent = parent

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

	createHeader(scroll, "🌽 Select Crops")
	createCheckbox(scroll, "✅ All Fruits", function(state) allFruits = state end)
	for _, crop in ipairs(crops) do
		selectedCrops[crop] = false
		createCheckbox(scroll, crop, function(state)
			selectedCrops[crop] = state
		end)
	end

	createHeader(scroll, "✨ Select Variants")
	createCheckbox(scroll, "✅ All Variants", function(state) allVariants = state end)
	for _, variant in ipairs(variants) do
		selectedVariants[variant] = false
		createCheckbox(scroll, variant, function(state)
			selectedVariants[variant] = state
		end)
	end

	createHeader(scroll, "❄️ Select Mutations")
	createCheckbox(scroll, "✅ All Mutations", function(state) allMutations = state end)
	for particleName, displayName in pairs(mutationMap) do
		selectedMutations[particleName] = false
		createCheckbox(scroll, displayName, function(state)
			selectedMutations[particleName] = state
		end)
	end

	local footer = Instance.new("Frame", tab)
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundTransparency = 1

	local collectBtn = Instance.new("TextButton", footer)
	collectBtn.Size = UDim2.new(0, 160, 0, 36)
	collectBtn.Position = UDim2.new(0.5, -170, 0.5, -18)
	collectBtn.Text = "Collect Now"
	collectBtn.Font = Enum.Font.GothamBold
	collectBtn.TextSize = 16
	collectBtn.TextColor3 = Color3.new(1, 1, 1)
	collectBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

	collectBtn.MouseButton1Click:Connect(collectFruits)

	local toggle = Instance.new("TextButton", footer)
	toggle.Size = UDim2.new(0, 140, 0, 36)
	toggle.Position = UDim2.new(0.5, 30, 0.5, -18)
	toggle.Text = "Auto Sell: OFF"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 16
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

	toggle.MouseButton1Click:Connect(function()
		autoSellEnabled = not autoSellEnabled
		toggle.Text = autoSellEnabled and "Auto Sell: ON" or "Auto Sell: OFF"
	end)
end
