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
local particles = {} -- raw keys for filtering
for particle in pairs(mutationMap) do table.insert(particles, particle) end

local selectedCrops = {}
local selectedVariants = {}
local selectedParticles = {}

local function hasRequiredParticles(fruit)
	for particle, enabled in pairs(selectedParticles) do
		if enabled then
			if not fruit:FindFirstChild(particle) then
				print("❌ Missing:", mutationMap[particle], "on", fruit.Name)
				return false
			else
				print("✅ Found:", mutationMap[particle], "on", fruit.Name)
			end
		end
	end
	return true
end

local function collectFruits()
	print("🌾 Beginning fruit collection...")
	local collected, skipped = 0, 0

	local root = Workspace:FindFirstChild("Farm")
	if not root then
		warn("❌ No 'Farm' folder found in Workspace.")
		return
	end

	local playerFarm = nil
	for _, farm in ipairs(root:GetChildren()) do
		if farm:IsA("Folder") and farm.Name == "Farm" then
			local owner = farm:FindFirstChild("Important")
				and farm.Important:FindFirstChild("Data")
				and farm.Important.Data:FindFirstChild("Owner")
			if owner and owner:IsA("StringValue") then
				print("🔎 Found owner value:", owner.Value)
				if owner.Value == LocalPlayer.Name then
					playerFarm = farm
					print("✅ Matched player farm!")
					break
				end
			else
				print("❌ No valid Owner value in", farm:GetFullName())
			end
		end
	end

	if not playerFarm then
		warn("❌ Could not find your farm.")
		return
	end

	local plants = playerFarm:FindFirstChild("Objects_Physical")
	if not plants then
		warn("❌ No 'Objects_Physical' folder found in your farm.")
		return
	end

	for _, crop in ipairs(plants:GetChildren()) do
		local fruitFolder = crop:FindFirstChild("Fruits") or crop
		for _, fruit in ipairs(fruitFolder:GetChildren()) do
			local name = fruit.Name
			local variant = fruit:GetAttribute("Variant") or "Normal"
			local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)

			if not selectedCrops[name] then
				skipped += 1
				print("⚪ Skipped", name, "(crop not selected)")
				continue
			end

			if not selectedVariants[variant] then
				skipped += 1
				print("⚪ Skipped", name, "(variant not selected:", variant .. ")")
				continue
			end

			if not hasRequiredParticles(fruit) then
				skipped += 1
				print("⚪ Skipped", name, "(missing required mutations)")
				continue
			end

			if prompt then
				fireproximityprompt(prompt)
				collected += 1
				print("✅ Collected:", name, "(variant:", variant .. ")")
				task.wait(0.1)
			else
				skipped += 1
				print("⚠️ No prompt found on:", name)
			end
		end
	end

	print(`✅ Fruit collection complete. Collected: {collected}, Skipped: {skipped}`)
end

-- UI Helpers
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
