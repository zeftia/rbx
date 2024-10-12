local Players = game:GetService("Players")
local Data = require(script.Parent.Data)

local PlayerService = {}
local DS = game:GetService("DataStoreService"):GetDataStore("PlayerData")
PlayerService.__index = PlayerService

local profiles = {}

local function addPlayer(player: Player)
	local profile = {
		Data = Data.new(DS:GetAsync("Player_" .. player.UserId) or {}),
		UserId = player.UserId,
	}
	profiles[player] = profile
end

local function saveProfile(profile)
	DS:SetAsync("Player_" .. profile.UserId, profile.Data.Data)
	print("saved", profile.UserId, profile.Data)
end

local function removePlayer(player: Player)
	local profile = profiles[player]
	profiles[player] = nil
	if not profile then
		return
	end
	saveProfile(profile)
end

function PlayerService:Start()
	task.spawn(function()
		while task.wait(5) do
			for player, profile in profiles do
				if player.Parent == Players then
					saveProfile(profile)
					continue
				end
				removePlayer(player)
			end
		end
	end)
	while task.wait(1) do
		for _, player in Players:GetPlayers() do
			if profiles[player] then
				continue
			end
			addPlayer(player)
		end
	end
end

function PlayerService:GetData(player)
	local profile = profiles[player]
	if not profile then
		return
	end
	local data = profile.Data
	return data
end

return PlayerService
