local lighting_service = game:GetService("Lighting")
local tween_service = game:GetService("TweenService")
local spawn = require(game:GetService("ReplicatedStorage").Shared.functions).spawn

local day_tween = tween_service:Create(
    lighting_service,
    TweenInfo.new(750, Enum.EasingStyle.Linear),
    {
        ["ClockTime"] = 24;
    }
)

local night_tween = tween_service:Create(
    lighting_service,
    TweenInfo.new(1050, Enum.EasingStyle.Linear),
    {
        ["ClockTime"] = 14;
    }
)

spawn(function()
    while true do
        day_tween:Play()
        day_tween.Completed:Wait()
        night_tween:Play()
        night_tween.Completed:Wait()
    end
end)

return true
