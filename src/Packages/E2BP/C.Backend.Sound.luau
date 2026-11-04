--!strict
local SoundService = game:GetService("SoundService")

local SoundSoundGroup = SoundService:WaitForChild("SoundEffects")
local MusicSoundGroup = SoundService:WaitForChild("Music")

for _, v in SoundSoundGroup:GetChildren() do
	if v:IsA("Sound") then
		v.SoundGroup = SoundSoundGroup
	end
end

local ReadySongs = {}
for _, v in MusicSoundGroup:GetChildren() do
	if v:IsA("Sound") then
		table.insert(ReadySongs, v)
		v.SoundGroup = MusicSoundGroup
	end
end

local CooldownSongs = {}

local REINSERT_QUEUE_LENGTH = math.max(math.floor(#ReadySongs/3),1)

local function table_random(t): (unknown, number)
	local i = math.random(1, #t)
	return t[i], i
end


local function getNextSong(): Sound
	local nextSong: Sound, indexInTable: number = table_random(ReadySongs)
	table.remove(ReadySongs, indexInTable)
	table.insert(CooldownSongs, nextSong)
	if #ReadySongs <=REINSERT_QUEUE_LENGTH then
		table.insert(ReadySongs, CooldownSongs[1])
		table.remove(CooldownSongs, 1)
	end
	--print(ReadySongs, CooldownSongs)
	return nextSong
end

game:GetService("ContentProvider"):PreloadAsync(SoundService:GetChildren()) -- songs won't play 

local Playback: () -> () do
	local Connection
	local CurrentlyPlaying: Sound?

	Playback = function()
		if MusicSoundGroup.Volume > 0 then
			if CurrentlyPlaying and CurrentlyPlaying.Playing then print("Music: Already playing") return end

			local thisSong = getNextSong()
			CurrentlyPlaying = thisSong
			
			thisSong:Play()
			task.delay(0, function()
				if thisSong.TimeLength > 0 then -- if a song fails to play then this will happen
					thisSong.Ended:Once(Playback)
				else
					warn("Faulty Soundtrack: " .. thisSong.Name .. " destroyed")
					local i = table.find(CooldownSongs, CurrentlyPlaying)
					if i then table.remove(CooldownSongs, i) else error("nevermind, couldn't find it in the table.") return end -- error this
					thisSong:Destroy()
					thisSong = nil
					Playback()
				end
			end)
		else
			if CurrentlyPlaying then
				CurrentlyPlaying:Stop()
				CurrentlyPlaying = nil
			end
		end
	end



end

return Playback