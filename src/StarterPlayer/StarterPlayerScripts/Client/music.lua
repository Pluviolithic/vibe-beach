local marketplace_service = game:GetService("MarketplaceService")
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local data = require(client.data)
local player = game:GetService("Players").LocalPlayer

local main_ui = player:WaitForChild("PlayerGui").MainUI
local music_frame = main_ui.MusicFrame
local request_id = music_frame.SongID
local audio = require(client.openable_ui).new(main_ui.Music, music_frame)

local remotes = game:GetService("ReplicatedStorage").Remotes
local request_song = remotes.Request_Song

local sound = Instance.new("Sound")
local current_id

sound.Volume = 1
sound.Parent = workspace
audio.Muted = false

remotes.Play_Song.OnClientEvent:Connect(function(song_info)
    local id = song_info.ID
    if current_id == id then return end
    current_id = id
    sound.SoundId = "rbxassetid://"..id
    sound:Play()
    music_frame.CurrentSong.Text = song_info.Name
    music_frame.PlayedBy.Text = song_info.Player
end)
remotes.Play_Song:FireServer()

music_frame.Confirm.Activated:Connect(function()
    if not tonumber(request_id.Text) then
        request_id.Text = "Please input a number."
        return
    end
    if data.Song_Requests < 1 then
        marketplace_service:PromptProductPurchase(player, 1089738095)
        return
    end
    request_id.Text = request_song:InvokeServer(tonumber(request_id.Text))
end)

function audio:switch() -- if we have a ui to mute music in future
    self.Muted = not self.Muted
    sound.Volume = self.Muted and 0 or 1
end

return audio

