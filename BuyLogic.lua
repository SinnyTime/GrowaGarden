local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

local BuySeedStock = GameEvents:FindFirstChild("BuySeedStock")
local BuyGearStock = GameEvents:FindFirstChild("BuyGearStock")

return function(settings, itemList, prices, getStock, getMoney)
	local money = getMoney()

	local sorted = {}
	for _, item in ipairs(itemList) do
		if settings[item] and settings[item].enabled then
			table.insert(sorted, item)
		end
	end

	table.sort(sorted, function(a, b)
		return (prices[a] or 0) > (prices[b] or 0)
	end)

	for _, item in ipairs(sorted) do
		local isGear = BuyGearStock and table.find(settings._Gears or {}, item) ~= nil
		local remote = isGear and BuyGearStock or BuySeedStock
		local price = prices[item] or 1
		local stock = getStock(item, isGear)
		local bought = 0

		if settings[item].max then
			local maxBuy = math.min(math.floor(money / price), stock)
			for i = 1, maxBuy do
				remote:FireServer(item, 1)
				money -= price
				bought += 1
				task.wait(0.2)
			end
		else
			local amount = settings[item].amount or 1
			for i = 1, amount do
				if money < price then break end
				remote:FireServer(item, 1)
				money -= price
				bought += 1
				task.wait(0.2)
			end
		end

		if bought == 0 then
			warn(string.format("[BuyLogic] ❌ Failed to buy %s — Money: %d, Stock: %d", item, money, stock))
		end
	end
end
