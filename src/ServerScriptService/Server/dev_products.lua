local marketplace_service = game:GetService("MarketplaceService")
local replicated_storage = game:GetService("ReplicatedStorage")
local server_storage = game:GetService("ServerStorage")
local text_service = game:GetService("TextService")
local players = game:GetService("Players")

local remotes = replicated_storage.Remotes
local server = game:GetService("ServerScriptService").Server
local wrappers = require(server.wrappers)
local functions = require(replicated_storage.Shared.functions)
local spawn, wait = functions.spawn,  functions.wait

local drone = server_storage.Drone
local whistle = server_storage.Whistle
local rp_tools = server_storage.RPTools:GetChildren()

local updatable_products = {
    [1089726441] = {["Vibe Bux"] = 50};
    [1089727179] = {["Vibe Bux"] = 200};
    [1089727409] = {["Vibe Bux"] = 500};
    [1089727794] = {["Vibe Bux"] = 1000};
    [1089728692] = {["Vibe Bux"] = 2500};
    [1089729162] = {["Vibe Bux"] = 7500};
    [1089738095] = {["Song_Requests"] = 1};
}

local gamepass_ids = {
    ["12682638"] = true;
    ["12682631"] = true;
    ["12682642"] = true;
    ["12682622"] = true;
    ["12682646"] = true;
    ["12682668"] = true;
}

local function give_item(player, item)
    if player.Character then
        item:Clone().Parent = player.Backpack
    end
    player.CharacterAdded:Connect(function()
        item:Clone().Parent = player.Backpack
    end)
end

local function give_rp_tools(player)
    if player.Character then
        for _, item in ipairs(rp_tools) do
            item:Clone().Parent = player.Backpack
        end
    end
    player.CharacterAdded:Connect(function()
        for _, item in ipairs(rp_tools) do
            item:Clone().Parent = player.Backpack
        end
    end)
end

require(server.lifeguard_clothing)

marketplace_service.ProcessReceipt = function(receipt_info)
    local wrapper = wrappers[players:GetPlayerByUserId(receipt_info.PlayerId)]
    local update_info = updatable_products[receipt_info.ProductId]
    if wrapper and update_info then
        wrapper:update(next(update_info))
        return Enum.ProductPurchaseDecision.PurchaseGranted
    else
        warn("Player attempting to purchase a product that is not recognized.")
    end
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

marketplace_service.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
    local wrapper = wrappers[player]
    if not purchased or not wrapper then return end
    wrapper:set(tostring(id), true)
end)

remotes.Chat_Color.OnServerEvent:Connect(function(player, index, value)
    local wrapper = wrappers[player]
    if type(index) ~= "number" or type(value) ~= "number" or not wrapper then return end
    wrapper:update_chat_color(index, value)
end)

remotes.RP_Name.OnServerEvent:Connect(function(player, name)
    local wrapper = wrappers[player]
    if not wrapper or type(name) ~= "string" or #name > 20 or #name < 1 then return end
    local success, new_name = pcall(text_service.FilterStringAsync, text_service, name, player.UserId)
    if success then
        success, new_name = pcall(new_name.GetNonChatStringForBroadcastAsync, new_name)
        if success then
            wrapper:update_rp_name(player, new_name)
            return
        end
    end
    wrapper:update_rp_name(player, "#####")
end)

remotes.RP_Name_Color.OnServerEvent:Connect(function(player, index, value)
    local wrapper = wrappers[player]
    if type(index) ~= "number" or type(value) ~= "number" or not wrapper then return end
    wrapper:update_rp_name_color(player, index, value)
end)

return function(player)
    local wrapper = wrappers[player]
    local player_id = player.UserId
    if not wrapper then return end
    if wrapper:get("12682646") then
        give_item(player, drone)
    else
        wrapper["12682646"]:OnUpdate(function(owns)
            if not owns then return end
            give_item(player, drone)
        end)
    end
    if wrapper:get("12682622") then
        give_item(player, whistle)
    else
        wrapper["12682622"]:OnUpdate(function(owns)
            if not owns then return end
            give_item(player, whistle)
        end)
    end
    if wrapper:get("12682668") then
        give_rp_tools(player)
    else
        wrapper["12682668"]:OnUpdate(function(owns)
            if not owns then return end
            give_rp_tools(player)
        end)
    end
    -- this will be disabled till live version for testing purposes
    --[[
    spawn(function()
        while wrapper do
            for id in pairs(gamepass_ids) do
                local success, has_pass = pcall(
                    marketplace_service.UserOwnsGamePassAsync,
                    marketplace_service,
                    player_id,
                    tonumber(id)
                )
                if not success then continue end
                wrapper:set(id, has_pass)
            end
            wait(15)
            wrapper = wrappers[player]
        end
    end)
    --]]
end
