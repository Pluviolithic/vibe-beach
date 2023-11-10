local players = game:GetService("Players")
local server = game:GetService("ServerScriptService").Server
local marketplace_service = game:GetService("MarketplaceService")

local functions = require(game:GetService("ReplicatedStorage").Shared.functions)
local player_wrapper = require(server.players)
local wrappers = require(server.wrappers)

local spawn, wait = functions.spawn, functions.wait
local seats = require(server.seats)

require(server.music)
require(server.day_night_cycle)
require(server.obby_handler)
require(server.spleef_handler)
require(server.shop_handler)
local update_passes = require(server.dev_products)

local function handle_seat_animations(character)
    local sit_animation = character.Animate.sit.SitAnim
    local humanoid = character.Humanoid
    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if not humanoid.SeatPart then return end
        if humanoid.SeatPart.Name:match("Lifeguard") then
            local player = players:GetPlayerFromCharacter(character)
            local wrapper = wrappers[player]
            if not wrapper then return end
            if not wrapper:get("12682622") then
                marketplace_service:PromptGamePassPurchase(player, "12682622")
                wait(0.5)
                -- for some reason, this doesn't work without a yield
                -- because it's not critical code, I'm fine with just taking the easy route
                local seat = humanoid.SeatPart
                if seat then
                    humanoid.SeatPart.SeatWeld:Destroy()
                end
                return
            end
        end
        if not seats[humanoid.SeatPart] then return end
        sit_animation.AnimationId = seats[humanoid.SeatPart]
    end)
end

local function initialize_player(player)
    local wrapper = player_wrapper.init(player)
    handle_seat_animations(player.Character or player.CharacterAdded:Wait())
    player.CharacterAdded:Connect(handle_seat_animations)
    wrapper:update_chat_color(0)
    update_passes(player)
    wait(60)
    wrapper = wrappers[player]
    while wrapper do
        wrapper:update("Vibe Bux", 10)
        wait(60)
        wrapper = wrappers[player]
    end
end

players.PlayerAdded:Connect(initialize_player)
for _, player in ipairs(players:GetPlayers()) do
    spawn(function()
        initialize_player(player)
    end)
end

players.PlayerRemoving:Connect(function(player)
    wrappers[player] = nil
end)
