local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local BASE_URL = "https://raw.githubusercontent.com/SinnyTime/GrowaGarden/main/"
local function import(name)
	local src = game:HttpGet(BASE_URL .. name .. ".lua")
	local module = loadstring(src)
	assert(module, "Failed to load module: " .. name)
	return module()
end

local ItemData = import("ItemData")

local crops = ItemData.Items.Fruits
local variants = { "Normal", "Gold", "Rainbow" }

local mutationMap = {
	FrozenParticle = "Frozen",
	WetParticle = "Wet",
	ChilledParticle = "Chilled",
	ShockedParticle = "Shocked"
}
local particles = {}
for particle in pairs(mutationMap) do table.insert(particles, particle) end

local selectedCrops = {}
local selectedVariants = {}
local selectedParticles = {}
local seenUnmatchedFruits = {}

local function deepFindParticle(fruit, particleName)
	for _, descendant in ipairs(fruit:GetDescendants()) do
		if descendant.Name == particleName then
			return true
		end
	end
	return false
end

local function hasRequiredParticles(fruit)
	for particle, enabled in pairs(selectedParticles) do
		if enabled and not deepFindParticle(fruit, particle) then
			return false
		end
	end
	return true
end

local function getReasonSkipped(fruit)
	if not selectedCrops[fruit.Name] then
		return "❌ Crop not selected: " .. fruit.Name
	end
	local variant = fruit:GetAttribute("Variant") or "Normal"
	if not selectedVariants[variant] then
		return "❌ Variant not selected: " .. variant
	end
	for particle, required in pairs(selectedParticles) do
		if required and not deepFindParticle(fruit, particle) then
			return "❌ Missing mutation: " .. mutationMap[particle]
		end
	end
	return nil
end

local function getFruitParts(crop)
	local found = {}
	for _, descendant in ipairs(crop:GetDescendants()) do
		if descendant:IsA("Model") or descendant:IsA("Part") then
			table.insert(found, descendant)
		end
	end
	return found
end

local function collectFruits()
	print("🌾 Beginning fruit collection...")
	local collected, skipped = 0, 0

	local root = Workspace:FindFirstChild("Farm")
	if not root then
		warn("❌ No 'Farm' folder found in Workspace.")
		return
	end

	local playerFarm
	for _, farm in ipairs(root:GetChildren()) do
		if farm:IsA("Folder") and farm.Name == "Farm" then
			local owner = farm:FindFirstChild("Important")
				and farm.Important:FindFirstChild("Data")
				and farm.Important.Data:FindFirstChild("Owner")
			if owner and owner:IsA("StringValue") and owner.Value == LocalPlayer.Name then
				playerFarm = farm
				break
			end
		end
	end

	if not playerFarm then
		warn("❌ Could not find your farm.")
		return
	end

	local plants = playerFarm:FindFirstChild("Important") and playerFarm.Important:FindFirstChild("Plants_Physical")
	if not plants then
		warn("❌ No 'Plants_Physical' folder found in your farm.")
		return
	end

	for _, crop in ipairs(plants:GetChildren()) do
		for _, fruit in ipairs(getFruitParts(crop)) do
			if not (fruit:IsA("Model") or fruit:IsA("Part")) then continue end
			if not table.find(crops, fruit.Name) then
				if not seenUnmatchedFruits[fruit.Name] then
					seenUnmatchedFruits[fruit.Name] = true
					print("👀 Unmatched fruit seen in farm:", fruit.Name)
				end
				continue
			end

			local name = fruit.Name
			local variant = fruit:GetAttribute("Variant") or "Normal"
			local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)

			local reason = getReasonSkipped(fruit)
			if reason then
				print("⏭️ Skipped:", name, "-", reason)
				skipped += 1
				continue
			end

			if prompt then
				fireproximityprompt(prompt)
				collected += 1
				task.wait(0.1)
			else
				print("❌ No ProximityPrompt for", name)
				skipped += 1
			end
		end
	end

	if collected == 0 then warn("⚠️ No fruits were collected. Double-check your filters!") end
	print(`✅ Fruit collection complete. Collected: {collected}, Skipped: {skipped}`)
end

local function createHeader(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 26)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
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
	label.Parent = container

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
	scroll.Position = UDim2.new(0, 0, 0, 0)
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
	for _, crop in ipairs(crops) do
		selectedCrops[crop] = false
		createCheckbox(scroll, crop, function(state)
			selectedCrops[crop] = state
		end)
	end

	createHeader(scroll, "✨ Select Variants")
	for _, variant in ipairs(variants) do
		selectedVariants[variant] = false
		createCheckbox(scroll, variant, function(state)
			selectedVariants[variant] = state
		end)
	end

	createHeader(scroll, "🧬 Select Mutations")
	for _, particle in ipairs(particles) do
		selectedParticles[particle] = false
		createCheckbox(scroll, mutationMap[particle], function(state)
			selectedParticles[particle] = state
		end)
	end

	local footer = Instance.new("Frame", tab)
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundTransparency = 1

	local btn = Instance.new("TextButton", footer)
	btn.Size = UDim2.new(0, 160, 0, 36)
	btn.Position = UDim2.new(0.5, -80, 0.5, -18)
	btn.Text = "Collect Now"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(collectFruits)
end
