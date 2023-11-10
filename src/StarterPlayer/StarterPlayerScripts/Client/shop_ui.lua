local player = game:GetService("Players").LocalPlayer
local screen_ui = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
local marketplace_service = game:GetService("MarketplaceService")

local shop_ui = screen_ui.ShopFrame
local switch = shop_ui.Switch
local current_frame = shop_ui["Vibe Bux"]

require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.openable_ui).new(screen_ui.Shop, shop_ui)

switch.Activated:Connect(function()
    current_frame.Visible = false
    current_frame = shop_ui[switch.Text]
    switch.Text = switch.Text == "Gamepasses" and "Vibe Bux" or "Gamepasses"
    current_frame.Visible = true
end)

for _, button in ipairs(shop_ui:GetDescendants()) do
    local id = tonumber(button.Name)
    if not id then continue end
    local f
    if button.Parent.Name == "Vibe Bux" then
        f = marketplace_service.PromptProductPurchase
    else
        f = marketplace_service.PromptGamePassPurchase
    end
    button.Activated:Connect(function()
        pcall(f, marketplace_service, player, id)
    end)
end

return true
