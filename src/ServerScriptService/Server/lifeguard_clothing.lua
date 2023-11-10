local marketplace_service = game:GetService("MarketplaceService")
local wrappers = require(game:GetService("ServerScriptService").Server.wrappers)
local LIFEGUARD_ID = "12682622"

local stand_a = workspace.LifeguardClothingA.Stand
local stand_b = workspace.LifeguardClothingB.Stand

stand_a.Shirt:FindFirstChild("ClickDetector", true).MouseClick:Connect(function(player)
    local wrapper = wrappers[player]
    if not wrapper then return end
    if wrapper:get(LIFEGUARD_ID) then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local description = humanoid:GetAppliedDescription()
        description.Shirt = stand_a.Shirt:FindFirstChild("ID", true).Value
        humanoid:ApplyDescription(description)
    else
        marketplace_service:PromptGamePassPurchase(player, LIFEGUARD_ID)
    end
end)

stand_a.Pants:FindFirstChild("ClickDetector", true).MouseClick:Connect(function(player)
    local wrapper = wrappers[player]
    if not wrapper then return end
    if wrapper:get(LIFEGUARD_ID) then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local description = humanoid:GetAppliedDescription()
        description.Pants = stand_a.Pants:FindFirstChild("ID", true).Value
        humanoid:ApplyDescription(description)
    else
        marketplace_service:PromptGamePassPurchase(player, LIFEGUARD_ID)
    end
end)

stand_b.Shirt:FindFirstChild("ClickDetector", true).MouseClick:Connect(function(player)
    local wrapper = wrappers[player]
    if not wrapper then return end
    if wrapper:get(LIFEGUARD_ID) then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local description = humanoid:GetAppliedDescription()
        description.Shirt = stand_b.Shirt:FindFirstChild("ID", true).Value
        humanoid:ApplyDescription(description)
    else
        marketplace_service:PromptGamePassPurchase(player, LIFEGUARD_ID)
    end
end)

stand_b.Pants:FindFirstChild("ClickDetector", true).MouseClick:Connect(function(player)
    local wrapper = wrappers[player]
    if not wrapper then return end
    if wrapper:get(LIFEGUARD_ID) then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local description = humanoid:GetAppliedDescription()
        description.Pants = stand_b.Pants:FindFirstChild("ID", true).Value
        humanoid:ApplyDescription(description)
    else
        marketplace_service:PromptGamePassPurchase(player, LIFEGUARD_ID)
    end
end)

return true
