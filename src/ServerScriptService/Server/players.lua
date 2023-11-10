local player_wrapper = {}
player_wrapper.__index = player_wrapper

local server_script_service = game:GetService("ServerScriptService")
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local display_gui = replicated_storage.Display_Gui
local remotes = replicated_storage.Remotes

local datastore = require(server_script_service.Server["Roblox-ds2-1.3.0"].DataStore2)
local wrappers = require(server_script_service.Server.wrappers)
local chat_module = require(server_script_service:WaitForChild("ChatServiceRunner").ChatService)

local datastore_key = "Player-Data-Store"
local defaults = {
    ["Vibe Bux"] = 0;
    ["Song_Requests"] = 0;
    ["Chat_Color"] = {1, 1, 1};
    ["RP_Name_Color"] = {1, 1, 1};
    ["RP_Name"] = false;
    ["Last_Reward_Claim_Time"] = -1;
    -- gamepass ids here:
    ["12682638"] = false;
    ["12682631"] = false;
    ["12682642"] = false;
    ["12682622"] = false;
    ["12682646"] = false;
    ["12682668"] = false;
}

datastore.PatchGlobalSettings({
    ["SavingMethod"] = "Standard";
})

for key in pairs(defaults) do
    datastore.Combine(datastore_key, key)
    local remote = remotes:FindFirstChild(key)
    if not remote then continue end
    remote.OnServerEvent:Connect(function(player)
        if not wrappers[player] then return end
        remote:FireClient(player, wrappers[player]:get(key))
    end)
end

local function init_name_display(character, name, color)
    local head = character:WaitForChild("Head")
    local new_display_gui = head:FindFirstChild("Display_Gui") or display_gui:Clone()
    local frame = new_display_gui.Frame
    frame.Player_Display_Name.Text = name or character.Name
    frame.Player_Display_Name.TextColor3 = color
    new_display_gui.Parent = head
    wrappers[players:GetPlayerFromCharacter(character)]:set("RP_Name", name or character.Name)
end

function player_wrapper.init(player)
    local new_wrapper = {}
    setmetatable(new_wrapper, player_wrapper)
    local leaderstats = Instance.new("Folder")
    for key, default in pairs(defaults) do
        local store = datastore(key, player)
        local update_client
        if type(default) == "table" or remotes:FindFirstChild(key) then
            update_client = function(value)
                remotes[key]:FireClient(player, value)
            end
        else
            update_client = function(value)
                -- may want a more complex update function for larger numerical values
                -- doesn't matter that much since this system is only for leaderboard
                -- values
                leaderstats[key].Value = tostring(value) -- will probably format this value
                remotes[key]:FireClient(player, value)
            end
        end
        if type(default) == "table" then
            update_client(store:GetTable(default))
        else
            if not remotes:FindFirstChild(key) then
                local base_value = Instance.new("StringValue")
                base_value.Name = key
                base_value.Parent = leaderstats
                local remote = Instance.new("RemoteEvent")
                remote.Name = key
                remote.Parent = remotes
            end
            update_client(store:Get(default))
        end
        store:OnUpdate(update_client)
        new_wrapper[key] = store
    end
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player 
    new_wrapper.speaker_object = chat_module:GetSpeaker(player.Name)
    if not new_wrapper.speaker_object then
        local connection; connection = chat_module.SpeakerAdded:Connect(function(speaker_name)
            if speaker_name ~= player.Name then return end
            new_wrapper.speaker_object = chat_module:GetSpeaker(player.Name)
            if new_wrapper.speaker_thread then
                coroutine.resume(new_wrapper.speaker_thread)
            end
            connection:Disconnect()
        end)
    end
    wrappers[player] = new_wrapper
    player.CharacterAdded:Connect(function(character)
        init_name_display(character, new_wrapper:get("RP_Name"), Color3.new(table.unpack(new_wrapper:get("RP_Name_Color"))))
    end)
    local character = player.Character
    if character then
        init_name_display(character, new_wrapper:get("RP_Name"), Color3.new(table.unpack(new_wrapper:get("RP_Name_Color"))))
    end
    return new_wrapper
end

function player_wrapper:update(key, value)
    if type(defaults[key]) == "table" then
        local data = self[key]:GetTable(defaults[key])
        if data[key][value] then
            data[key][value] = nil
        else
            data[key][value] = true
        end
        self[key]:Set(data)
    elseif type(defaults[key]) == "number" then
        self[key]:Increment(value, defaults[key])
    end
end

function player_wrapper:set(key, value)
    self[key]:Set(value)
end

function player_wrapper:get(key)
    return self[key]:Get(defaults[key])
end

function player_wrapper:has(key, value)
    return self[key]:GetTable(defaults[key])[value]
end

function player_wrapper:update_chat_color(index, value)
    local speaker_object = self.speaker_object
    if not speaker_object then
        self.speaker_thread = coroutine.running()
        coroutine.yield()
        speaker_object = self.speaker_object
    end
    local chat_color = self:get("Chat_Color")
    chat_color[index] = value
    local new_chat_color = Color3.new(table.unpack(chat_color))
    speaker_object:SetExtraData("ChatColor", new_chat_color)
    self:set("Chat_Color", {new_chat_color.R, new_chat_color.G, new_chat_color.B})
end

function player_wrapper:update_rp_name(player, name)
    local character = player.Character or player.CharacterAdded:Wait()
    init_name_display(character, name, Color3.new(table.unpack(self:get("RP_Name_Color"))))
end

function player_wrapper:update_rp_name_color(player, index, value)
    local rp_name_color = self:get("RP_Name_Color")
    rp_name_color[index] = value
    local new_rp_name_color = Color3.new(table.unpack(rp_name_color))
    init_name_display(player.Character or player.CharacterAdded:Wait(), self:get("RP_Name"), new_rp_name_color)
    self:set("RP_Name_Color", {new_rp_name_color.R, new_rp_name_color.G, new_rp_name_color.B})
end

return player_wrapper
