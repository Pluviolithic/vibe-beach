local server = game:GetService("ServerScriptService").Server
local shared = game:GetService("ReplicatedStorage").Shared

local wrappers = require(server.wrappers)
local wait = require(shared.functions).wait

local obby_entrance = workspace["TP1"].CFrame
local respawn_point = workspace["TP2"].CFrame

local debounce_list = {}

for _, death_block in ipairs(game:GetService("CollectionService"):GetTagged("Death")) do
    death_block.Touched:Connect(function(hit)
        local character = hit.Parent
        if debounce_list[character] then return end
        local root_part = character:FindFirstChild("HumanoidRootPart")
        if not root_part then return end
        root_part.CFrame = respawn_point
        debounce_list[character] = true
        wait(1)
        debounce_list[character] = nil
    end)
end

workspace["TP1"].Touched:Connect(function(hit)
    local character = hit.Parent
    if not character or debounce_list[character] then return end
    local root_part = character:FindFirstChild("HumanoidRootPart")
    if not root_part then return end
    root_part.CFrame = respawn_point
    debounce_list[character] = true
    wait(1)
    debounce_list[character] = nil
end)

workspace["TP2"].Touched:Connect(function(hit)
    local character = hit.Parent
    if not character or debounce_list[character] then return end
    local root_part = character:FindFirstChild("HumanoidRootPart")
    if not root_part then return end
    root_part.CFrame = obby_entrance
    debounce_list[character] = true
    wait(1)
    debounce_list[character] = nil
end)

workspace.Reward.ClickDetector.MouseClick:Connect(function(player)
    local wrapper = wrappers[player]
    if not wrapper then return end
    if os.time() - wrapper:get("Last_Reward_Claim_Time") < 86400 then return end
    wrapper:update("Vibe Bux", wrapper:get("12682622") and 400 or 200)
    wrapper:set("Last_Reward_Claim_Time", os.time())
end)

return true
