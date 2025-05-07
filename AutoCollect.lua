local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

local selectedCrops, selectedVariants = {}, {}

local function enableFly()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local bp = Instance.new("BodyPosition")
	bp.Name = "FlyBP"
	bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bp.Position = root.Position
	bp.Parent = root
	LocalPlayer.Character:SetAttribute("NoclipActive", true)
	RunService.Stepped:Connect(function()
		if LocalPlayer.Character:GetAttribute("NoclipActive") then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
end

local function moveTo(pos)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local bp = root:FindFirstChild("FlyBP")
		if bp then bp.Position = pos end
	end
end

local function disableFly()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local bp = root:FindFirstChild("FlyBP")
		if bp then bp:Destroy() end
	end
	LocalPlayer.Character:SetAttribute("NoclipActive", false)
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = true end
	end
end

local function getFruitParts(crop)
	local fruits = {}
	if crop:FindFirstChild("Fruits") then
		for _, fruit in ipairs(crop.Fruits:GetChildren()) do
			if fruit:IsA("Model") or fruit:IsA("Part") then
				table.insert(fruits, fruit)
			end
		end
	else
		for _, child in ipairs(crop:GetChildren()) do
			if tonumber(child.Name) and (child:IsA("Model") or child:IsA("Part")) then
				table.insert(fruits, child)
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
		if not selectedCrops[cropName] then continue end

		for _, fruit in ipairs(getFruitParts(crop)) do
			local variant = fruit:GetAttribute("Variant") or "Normal"
			if not selectedVariants[variant] then continue end

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
				pcall(function()
					fireproximityprompt(prompt)
				end)
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
