local tween_service = game:GetService("TweenService")
local wait = require(game:GetService("ReplicatedStorage").Shared.functions).wait
local respawn_cframe = workspace.SpleefRespawn.CFrame + Vector3.new(0, 5, 0)
local debounce_list = {}

for _, part in ipairs(workspace.Spleef:GetChildren()) do
    local debounce = false
    local transparency_tween = tween_service:Create(
        part,
        TweenInfo.new(0.5),
        {
            Transparency = 1;
            CanCollide = false
        }
    )
    part.Touched:Connect(function()
        if debounce then return end
        debounce = true
        transparency_tween:Play()
        transparency_tween.Completed:Wait()
        wait(3)
        debounce = false
        part.Transparency = 0
        part.CanCollide = true
    end)
end

workspace.SpleefDeath.Touched:Connect(function(hit)
    local character = hit.Parent
    if not character or debounce_list[character] then return end
    local root_part = hit.Parent:FindFirstChild("HumanoidRootPart")
    if not root_part then return end
    root_part.CFrame = respawn_cframe
    debounce_list[character] = true
    wait(1)
    debounce_list[character] = nil
end)

return true
