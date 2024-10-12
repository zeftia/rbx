local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SceneController = {}
SceneController.__index = SceneController

local UI = Instance.new("ScreenGui")
UI.ResetOnSpawn = false
UI.Name = "SceneController"
UI.Parent = Players.LocalPlayer.PlayerGui
local currentScene

local scenes = {}
local containers = {}
local activeContainers = {}

-- Classes
local Scene = {}
Scene.__index = Scene
function Scene.new(name: string)
	local self = setmetatable({}, Scene)
	self.Name = name
	scenes[self.Name] = self
	return self
end

local Container = {}
Container.__index = Container
function Container.new(frame, name, modal)
	local self = setmetatable({}, Container)
	self.ID = name or HttpService:GenerateGUID(false)
	self.Instance = frame
	self.Active = false
	self.Modal = modal == true
	frame.Parent = nil
	frame.Visible = true
	containers[self.ID] = self
	return self
end
function Container:Open()
	if self.Active then
		self.Active = false
		self.Instance.Parent = nil
		local pos = table.find(activeContainers, self)
		if pos then
			table.remove(activeContainers, pos)
		end
		return
	end

	local containersToClose = {}
	for _, container in activeContainers do
		if container.Modal then
			table.insert(containersToClose, container)
		end
	end
	for _, container in containersToClose do
		container:Close()
	end

	self.Active = true
	if self.Update and typeof(self.Update) == "function" then
		self:Update()
	end
	self.Instance.Parent = UI
	table.insert(activeContainers, self)
end
function Container:Close()
	if self.Active then
		self:Open()
	end
end
function Container:Destroy()
	if self.Active then
		self:Open()
	end
	containers[self.ID] = nil
end

--

function SceneController:GetContainer(name: string)
	return containers[name]
end

function SceneController:Start()
	RunService.RenderStepped:Connect(function()
		if currentScene.Update and typeof(currentScene.Update) == "function" then
			currentScene:Update()
		end
		for _, container in activeContainers do
			if container.Update and typeof(container.Update) == "function" then
				container:Update()
			end
		end
	end)
end

SceneController.Scene = Scene
SceneController.Container = Container
currentScene = Scene.new("Default")
return SceneController
