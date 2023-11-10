local data = {
    ["Vibe Bux"] = 0;
    ["Song_Requests"] = 0;
}

local gamepass_ids = {
    ["12682638"] = false;
    ["12682631"] = false;
    ["12682642"] = false;
    ["12682622"] = false;
    ["12682646"] = false;
    ["12682668"] = false;
}

local remotes = game:GetService("ReplicatedStorage").Remotes
local player_ui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local request_id = player_ui:WaitForChild("MainUI").MusicFrame.SongID

remotes:WaitForChild("Vibe Bux").OnClientEvent:Connect(function(value)
    data["Vibe Bux"] = value
end)

remotes.Song_Requests.OnClientEvent:Connect(function(value)
    local increased = value > data.Song_Requests
    data.Song_Requests = value
    if increased then
        request_id.Text = remotes.Request_Song:InvokeServer(tonumber(request_id.Text))
    end
end)

for id, default in pairs(gamepass_ids) do
    data[id] = default
    remotes:WaitForChild(id).OnClientEvent:Connect(function(owned)
        data[id] = owned
    end)
end

return data
