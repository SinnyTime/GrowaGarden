local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getMoney()
	local stats = LocalPlayer:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Sheckles") and stats.Sheckles.Value or 0
end

local function getStock(item, isGear)
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	local shopUI = isGear and gui:FindFirstChild("Gear_Shop") or gui:FindFirstChild("Seed_Shop")
	if not shopUI then return 0 end

	local entry
	for _, obj in ipairs(shopUI:GetDescendants()) do
		if obj:IsA("Frame") and obj.Name == item then
			entry = obj
			break
		end
	end
	if not entry then return 0 end

	for _, desc in ipairs(entry:GetDescendants()) do
		if desc:IsA("TextLabel") and desc.Name == "Stock_Text" then
			local text = desc.Text or "0"
			local stock = tonumber(text:match("%d+"))
			return stock or 0
		end
	end

	return 0
end

return {
	getMoney = getMoney,
	getStock = getStock
}
