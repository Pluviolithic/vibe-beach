local player = game:GetService("Players").LocalPlayer
local remotes = game:GetService("ReplicatedStorage").Remotes
local marketplace_service = game:GetService("MarketplaceService")

local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local data = require(client.data)

local rp_name_color = remotes.RP_Name_Color
local chat_color = remotes.Chat_Color
local rp_name = remotes.RP_Name
local screen_ui = player.PlayerGui:WaitForChild("MainUI")

local player_ui = screen_ui.PlayerFrame
local rp_name_box = player_ui.RPName

local TAG_PASS_ID = "12682631"
local CHAT_PASS_ID = "12682638"

require(client.openable_ui).new(screen_ui.Player, player_ui)

rp_name.OnClientEvent:Connect(function(name)
    rp_name_box.Text = name or player.Name
end)

rp_name_color.OnClientEvent:Connect(function(color_array)
    for i, color_value in ipairs(color_array) do
        player_ui["NameColor"..i].Text = math.round(color_value*255)
    end
end)

chat_color.OnClientEvent:Connect(function(color_array)
    for i, color_value in ipairs(color_array) do
        player_ui["ChatColor"..i].Text = math.round(color_value*255)
    end
end)

for i = 1, 3 do
    local name_color_box = player_ui["NameColor"..i]
    local chat_color_box = player_ui["ChatColor"..i]
    name_color_box.FocusLost:Connect(function()
        if not data[TAG_PASS_ID] then
            marketplace_service:PromptGamePassPurchase(player, tonumber(TAG_PASS_ID))
            return
        end
        local n = tonumber(name_color_box.Text)
        if not n then return end
        rp_name_color:FireServer(i, n/255)
    end)
    chat_color_box.FocusLost:Connect(function()
        if not data[CHAT_PASS_ID] then
            marketplace_service:PromptGamePassPurchase(player, tonumber(CHAT_PASS_ID))
            return
        end
        local n = tonumber(chat_color_box.Text)
        if not n then return end
        chat_color:FireServer(i, n/255)
    end)
end

rp_name_box.FocusLost:Connect(function()
    if not data[TAG_PASS_ID] then
        marketplace_service:PromptGamePassPurchase(player, tonumber(TAG_PASS_ID))
        return
    end
    rp_name:FireServer(rp_name_box.Text)
end)

return true
