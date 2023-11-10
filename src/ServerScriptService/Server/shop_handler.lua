local replicated_storage = game:GetService("ReplicatedStorage")
local wrappers = require(game:GetService("ServerScriptService").Server.wrappers)

local remotes = replicated_storage.Remotes
local foods = replicated_storage.Foods.Classes
local gears = replicated_storage.Gear

remotes.Buy_Perishable.OnServerEvent:Connect(function(player, name)
    local wrapper = wrappers[player]
    if not wrapper or type(name) ~= "string" then return end
    local perishable = foods:FindFirstChild(name) or gears:FindFirstChild(name)
	if not perishable or not perishable:IsA("Tool") or not perishable:IsA("ModuleScript") then return end
    local cost = perishable:FindFirstChild("Price")
	if not cost or wrapper:get("Vibe Bux") < cost.Value then return end
	
	if perishable:IsA("ModuleScript") then
		perishable.new().ToolModel.Parent = player.Backpack
	else
		perishable:Clone().Parent = player.Backpack
	end
  
    wrapper:update("Vibe Bux", -cost.Value)
end)

return {}