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
local particles = { "FrozenParticle", "WetParticle", "ChilledParticle", "ShockedParticle" }

local selectedCrops = {}
local selectedVariants = {}
local selectedParticles = {}

-- ✅ Check if fruit has all selected particles
local function hasRequiredParticles(fruit)
	for particle, enabled in pairs(selectedParticles) do
		if enabled and not fruit:FindFirstChild(particle) then
			return false
		end
	end
	return true
end

-- 🌾 Core Auto-Collect Logic
local function collectFruits()
	for _, farm in pairs(Workspace:GetChildren()) do
		if farm:IsA("Folder") and farm.Name == "Farm" then
			local ownerVa = farm:FindFirstChild("Owner")
			if ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name then
				local plants = farm:FindFirstChild("Plants_Physical")
				if plants then
					for _, crop in pairs(plants:GetChildren()) do
						local fruitFolder = crop:FindFirstChild("Fruits") or crop
						for _, fruit in pairs(fruitFolder:GetChildren()) do
							local name = fruit.Name
							local variant = fruit:GetAttribute("Variant") or "Normal"
							if selectedCrops[name] and selectedVariants[variant] and hasRequiredParticles(fruit) then
								local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
								if prompt then
									fireproximityprompt(prompt)
									task.wait(0.1)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- 🧱 Inline UI Creation (no UIBuilder dependency)
local function createLabel(parent text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function createCheckbox(parent, labelText, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local box = Instance.new("TextButton")
	box.Size = UDim2.new(0, 30, 1, 0)
	box.Text = "☐"
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 16
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
	box.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 40, 0, 0)
	label.Text = labelText
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 15
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

local function createButton(parent, labelText, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 160, 0, 36)
	btn.Text = labelText
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = parent
	btn.MouseButton1Click:Connect(onClick)
end

-- 📋 Tab Constructor
return function(tab)
	createLabel(tab, "Select Crops:")
	for _, crop in ipairs(crops) do
		selectedCrops[crop] = false
		createCheckbo(tab, crop, function(state)
			selectedCrops[crop] = state
		end)
	end

	createLabel(tab, "Select Variants:")
	for _, variant in ipairs(variants) do
		selectedVariants[variant] = false
		createCheckbox(tab, variant, function(state)
			selectedVariants[variant] = state
		end)
	end

	createLabel(tab, "Select Particles:")
	for _, particle in ipairs(particles) do
		selectedParticles[particle] = false
		createCheckbox(tab, particle, function(state)
			selectedParticles[particle] = state
		end)
	end

	createButton(tab, "Collect Now", collectFruits)
end
