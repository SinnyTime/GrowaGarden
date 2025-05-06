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

local UIBuilder = import("UIBuilder")
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
			local ownerVal = farm:FindFirstChild("Owner")
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

-- 📋 UI Tab Constructor
return function(tab)
	UIBuilder.CreateLabel(tab, "Select Crops:")
	for _, crop in ipairs(crops) do
		selectedCrops[crop] = false
		UIBuilder.CreateCheckbox(tab, crop, function(state)
			selectedCrops[crop] = state
		end)
	end

	UIBuilder.CreateLabel(tab, "Select Variants:")
	for _, variant in ipairs(variants) do
		selectedVariants[variant] = false
		UIBuilder.CreateCheckbox(tab, variant, function(state)
			selectedVariants[variant] = state
		end)
	end

	UIBuilder.CreateLabel(tab, "Select Particles:")
	for _, particle in ipairs(particles) do
		selectedParticles[particle] = false
		UIBuilder.CreateCheckbox(tab, particle, function(state)
			selectedParticles[particle] = state
		end)
	end

	UIBuilder.CreateButton(tab, "Collect Now", collectFruits)
end
