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

-- prettier labels → internal lookup for mutation particles
local mutationMap = {
	Frozen = "FrozenParticle",
	Wet = "WetParticle",
	Chilled = "ChilledParticle",
	Shocked = "ShockedParticle"
}

local selectedCrops = {}
local selectedVariants = {}
local selectedMutations = {}

local function hasRequiredMutations(fruit)
	for label, particle in pairs(mutationMap) do
		if selectedMutations[label] then
			if fruit:FindFirstChild(particle) then
				print(`🧪 Found mutation "{label}" on {fruit.Name}`)
			else
				print(`❌ Missing mutation "{label}" on {fruit.Name}`)
				return false
			end
		end
	end
	return true
end

local function collectFruits()
	print("🌾 Beginning fruit collection...")

	local collected = 0
	local skipped = 0

	for _, farm in ipairs(Workspace:GetChildren()) do
		print("🔍 Checking object in workspace:", farm.Name)

		if farm:IsA("Folder") and farm.Name == "Farm" then
			print("🏡 Found Farm folder.")

			local ownerVal = farm:FindFirstChild("Owner")
			if not ownerVal then
				print("❌ No 'Owner' StringValue found.")
				continue
			end

			print("👤 Owner check:", ownerVal.Value)

			if ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name then
				print("✅ This farm belongs to the local player.")

				local plants = farm:FindFirstChild("Plants_Physical")
				if not plants then
					print("⚠️ No Plants_Physical folder. Using Farm folder instead.")
					plants = farm
				end

				for _, crop in ipairs(plants:GetChildren()) do
					print("🌱 Crop found:", crop.Name)

					local fruitFolder = crop:FindFirstChild("Fruits") or crop
					for _, fruit in ipairs(fruitFolder:GetChildren()) do
						print("🍒 Checking fruit:", fruit.Name)

						local name = fruit.Name
						local variant = fruit:GetAttribute("Variant") or "Normal"
						local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)

						if not selectedCrops[name] then
							skipped += 1
							print(`⚪ Skipped: "{name}" — not selected`)
							continue
						end

						if not selectedVariants[variant] then
							skipped += 1
							print(`⚪ Skipped: "{name}" — variant "{variant}" not selected`)
							continue
						end

						if not hasRequiredMutations(fruit) then
							skipped += 1
							print(`⚪ Skipped: "{name}" — mutation mismatch`)
							continue
						end

						if prompt then
							print(`✨ Found prompt for {name}, firing...`)
							fireproximityprompt(prompt)
							collected += 1
							task.wait(0.1)
						else
							print(`⚠️ No prompt on {name}. Skipped.`)
							skipped += 1
						end
					end
				end
			else
				print("⛔ Skipping farm not owned by player.")
			end
		end
	end

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

-- 📋 UI Constructor
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
	for label, _ in pairs(mutationMap) do
		selectedMutations[label] = false
		createCheckbox(scroll, label, function(state)
			selectedMutations[label] = state
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
