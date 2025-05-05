local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getMoney()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    return stats and stats:FindFirstChild("Sheckles") and stats.Sheckles.Value or 0
end

local function getStock(item, isGear)
    local gui = LocalPlayer.PlayerGui
    local shopUI = isGear and gui:FindFirstChild("Gear_Shop") or gui:FindFirstChild("Seed_Shop")
    if not shopUI then return 0 end

    local entry = shopUI:FindFirstChild(item, true)
    if not entry then return 0 end

    for _, desc in ipairs(entry:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Name == "Stock_Text" then
            local text = desc.Text or "0X Stock"
            return tonumber(text:match("X(%d+)")) or tonumber(text:match("(%d+)")) or 0
        end
    end

    return 0
end

return {
    getMoney = getMoney,
    getStock = getStock
}
