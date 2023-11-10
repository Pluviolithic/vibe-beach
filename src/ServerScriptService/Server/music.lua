local replicated_storage = game:GetService("ReplicatedStorage")
local marketplace_service = game:GetService("MarketplaceService")
local server_storage = game:GetService("ServerStorage")
local server = game:GetService("ServerScriptService").Server
local play_song = replicated_storage.Remotes.Play_Song

local playlist = require(server.playlist)
local wrappers = require(server.wrappers)
local functions = require(replicated_storage.Shared.functions)
local queue = require(replicated_storage.Shared.queue)

local wait, spawn, shuffle = functions.wait, functions.spawn, functions.shuffle
local last_call_time = os.time()
local request_queue = queue.new()
local server_queue = {}
local last_song_was_request = false
local song_info

local function play_next_song(call_time)
    song_info = request_queue:unqueue()
    if song_info then
        last_song_was_request = true
    else
        last_song_was_request = false
        if #server_queue < 1 then
            server_queue = shuffle({table.unpack(playlist)})
            if song_info and server_queue[#server_queue] == song_info.ID then
                server_queue[1], server_queue[#server_queue] = server_queue[#server_queue], server_queue[1]
            end
        end
        local new_song = table.remove(server_queue)
        song_info = {
            Player = "Server";
            ID = new_song[1];
            Name = new_song[2];
        }
    end
    play_song:FireAllClients(song_info)
    local sound_obj = Instance.new("Sound")
    sound_obj.SoundId = "rbxassetid://"..song_info.ID
    sound_obj.Parent = server_storage
    if sound_obj.IsLoaded then
        wait(sound_obj.TimeLength)
    else
        wait(3)
        if sound_obj.IsLoaded then
            wait(sound_obj.TimeLength - 3)
        end
    end
    if call_time ~= last_call_time then return end
    last_call_time = os.time()
    play_next_song(last_call_time)
end

play_song.OnServerEvent:Connect(function(player)
    play_song:FireClient(player, song_info)
end)

replicated_storage.Remotes.Request_Song.OnServerInvoke = function(player, id)
    if type(id) ~= "number" then return "Invalid song id." end
    if wrappers[player]:get("Song_Requests") < 1 then return "Error" end
    local success, id_info = pcall(marketplace_service.GetProductInfo, marketplace_service, id)
    if not success or id_info.AssetTypeId ~= 3 then return "Invalid song id." end
    wrappers[player]:update("Song_Requests", -1)
    request_queue:queue({
            Player = player.Name;
            ID = id;
            Name = id_info.Name;
        })
    spawn(function()
        if request_queue:length() > 1 or last_song_was_request then return end
        last_call_time = os.time()
        play_next_song(last_call_time)
    end)
    return "Song added to queue successfully!"
end

spawn(function()
    play_next_song(last_call_time)
end)

return true
