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

-- 🧱 Inline UI Creation (no UIBuilder dependency)
local function createLabel(parent, text)
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
	-- 🔁 Scrolling Frame Container
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
	layout.Padding = UDim.new(0, 6)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- 🔽 Collapsible Section Helper
	local function createCollapsibleSection(titleText, itemList, selectionTable)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 30)
	section.BackgroundTransparency = 1
	section.Parent = scroll

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.Parent = section

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(0, 5, 0, 0)
	arrow.Text = "▸"
	arrow.TextColor3 = Color3.new(1, 1, 1)
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 16
	arrow.BackgroundTransparency = 1
	arrow.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 30, 0, 0)
	label.Text = titleText
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.BackgroundTransparency = 1
	holder.ClipsDescendants = true
	holder.Parent = scroll

	local innerLayout = Instance.new("UIListLayout")
	innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	innerLayout.Padding = UDim.new(0, 4)
	innerLayout.Parent = holder

	local contentHeight = 0
	innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		contentHeight = innerLayout.AbsoluteContentSize.Y
	end)

	local isOpen = false
	btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "▼" or "▸"
		local goalSize = isOpen and contentHeight or 0
		TweenService:Create(holder, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, goalSize) }):Play()
	end)

	for _, item in ipairs(itemList) do
		selectionTable[item] = false

		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 26)
		container.BackgroundTransparency = 1
		container.Parent = holder

		local box = Instance.new("TextButton")
		box.Size = UDim2.new(0, 26, 1, 0)
		box.Text = "☐"
		box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		box.TextColor3 = Color3.new(1, 1, 1)
		box.Font = Enum.Font.Gotham
		box.TextSize = 16
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
		box.Parent = container

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -34, 1, 0)
		label.Position = UDim2.new(0, 34, 0, 0)
		label.Text = item
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		box.MouseButton1Click:Connect(function()
			selectionTable[item] = not selectionTable[item]
			box.Text = selectionTable[item] and "☑" or "☐"
		end)
	end
end


	-- 🧩 Build Sections
	createCollapsibleSection("🌽 Select Crops", crops, selectedCrops)
	createCollapsibleSection("✨ Select Variants", variants, selectedVariants)
	createCollapsibleSection("❄️ Select Particles", particles, selectedParticles)

	-- 🔘 Collect Button
	local footer = Instance.new("Frame")
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundTransparency = 1
	footer.Parent = tab

	local collectBtn = Instance.new("TextButton", footer)
	collectBtn.Size = UDim2.new(0, 160, 0, 36)
	collectBtn.Position = UDim2.new(0.5, -80, 0.5, -18)
	collectBtn.Text = "Collect Now"
	collectBtn.Font = Enum.Font.GothamBold
	collectBtn.TextSize = 16
	collectBtn.TextColor3 = Color3.new(1, 1, 1)
	collectBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 255)
	Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

	collectBtn.MouseButton1Click:Connect(collectFruits)
end
