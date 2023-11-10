local marketplace_service = game:GetService("MarketplaceService")
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local player = game:GetService("Players").LocalPlayer

local data = require(client.data)
local main_ui = player:WaitForChild("PlayerGui").MainUI
local emote_ui = main_ui.EmotesFrame

local EMOTE_PASS_ID = "12682642"

local current_id
local loaded_animation

require(client.openable_ui).new(main_ui.Emotes, emote_ui)

local function play_emote(animation)
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    if loaded_animation then
        loaded_animation:Stop()
        loaded_animation = nil
    end
    if current_id == animation.AnimationId then current_id = nil return end
    current_id = animation.AnimationId
    loaded_animation = humanoid:WaitForChild("Animator"):LoadAnimation(animation)
    loaded_animation:Play()
end

for _, button in ipairs(emote_ui.ScrollingFrame:GetChildren()) do
    local animation = button:FindFirstChildWhichIsA("Animation")
    if button.Name == "Emote" then
        button.Activated:Connect(function()
            play_emote(animation)
        end)
    elseif button.Name == "PaidEmote" then
        button.Activated:Connect(function()
            if not data[EMOTE_PASS_ID] then
                marketplace_service:PromptGamePassPurchase(player, tonumber(EMOTE_PASS_ID))
                return
            end
            play_emote(animation)
        end)
    end
end

return true
