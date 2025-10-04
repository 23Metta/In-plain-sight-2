--LUNA
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local Window = Luna:CreateWindow({
	Name = "In plain sight 2",
	Subtitle = nil,
	LogoID = "18552636285",
	LoadingEnabled = true,
	LoadingTitle = "Meta Hub",
	LoadingSubtitle = "by Metta",
	ConfigSettings = {
		RootFolder = nil,
		ConfigFolder = "Big Hub"
	},
	KeySystem = false,
	KeySettings = {
		Title = "Luna Example Key",
		Subtitle = "Key System",
		Note = "Best Key System Ever!",
		SaveInRoot = false,
		SaveKey = true,
		Key = {"Example Key"},
		SecondAction = {
			Enabled = true,
			Type = "Link",
			Parameter = ""
		}
	}
})
Luna:LoadAutoloadConfig()
--TAB
local PlayerTab = Window:CreateTab({
	Name = "Player",
	Icon = "accessibility",
	ImageSource = "Lucide",
	ShowTitle = true
})

local EspTab = Window:CreateTab({
	Name = "Esp",
	Icon = "cctv",
	ImageSource = "Lucide",
	ShowTitle = true
})

--PLAYER
local Input = PlayerTab:CreateInput({
	Name = "Player's Speed",
	Description = "Change player's speed",
	PlaceholderText = "20 is recommended",
	CurrentValue = "",
	Numeric = true,
	MaxCharacters = nil,
	Enter = false,
	Callback = function(Text)
		local newSpeed = tonumber(Text)
		if newSpeed then
			local player = game.Players.LocalPlayer
			
			-- Функция для установки скорости
			local function setWalkSpeed(character)
				local humanoid = character:WaitForChild("Humanoid")
				humanoid.WalkSpeed = newSpeed
			end
			
			-- Устанавливаем для текущего персонажа
			if player.Character then
				setWalkSpeed(player.Character)
			end
			
			-- Устанавливаем для будущих персонажей
			player.CharacterAdded:Connect(setWalkSpeed)
			
			print("WalkSpeed set to: " .. newSpeed)
		else
			warn("Please enter a valid number!")
		end
	end,
	Flag = "SpeedInput"
})

--ESP
local Toggle1 = EspTab:CreateToggle({
	Name = "Players' Esp",
	Description = nil,
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			if not _G.PlayerESPData then
				_G.PlayerESPData = {
					Highlights = {},
					Connections = {}
				}
			end

			local function isValidPlayer(player)
				return player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid")
			end

			local function updateESP()
				for player, highlight in pairs(_G.PlayerESPData.Highlights) do
					if isValidPlayer(player) then
						local humanoid = player.Character.Humanoid
						if humanoid.Health > 0 then
							highlight.Adornee = player.Character
							highlight.Enabled = true
						else
							highlight.Enabled = false
						end
					else
						highlight.Enabled = false
					end
				end
			end

			local function createPlayerESP(player)
				if player == game.Players.LocalPlayer then return end
				
				local highlight = Instance.new("Highlight")
				highlight.Name = player.Name .. "_PlayerESP"
				highlight.FillColor = Color3.fromRGB(0, 255, 0)
				highlight.FillTransparency = 0.6
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineTransparency = 0.2
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = game.CoreGui
				
				_G.PlayerESPData.Highlights[player] = highlight

				local charAddedConn = player.CharacterAdded:Connect(function()
					task.wait(0.3)
					updateESP()
				end)
				
				local charRemovingConn = player.CharacterRemoving:Connect(function()
					if highlight then
						highlight.Enabled = false
					end
				end)
				
				_G.PlayerESPData.Connections[player] = {
					charAdded = charAddedConn,
					charRemoving = charRemovingConn
				}
			end

			for _, player in pairs(game.Players:GetPlayers()) do
				createPlayerESP(player)
			end

			local playerAddedConn = game.Players.PlayerAdded:Connect(function(player)
				createPlayerESP(player)
			end)

			local playerRemovingConn = game.Players.PlayerRemoving:Connect(function(player)
				if _G.PlayerESPData.Highlights[player] then
					_G.PlayerESPData.Highlights[player]:Destroy()
					_G.PlayerESPData.Highlights[player] = nil
				end
				if _G.PlayerESPData.Connections[player] then
					_G.PlayerESPData.Connections[player].charAdded:Disconnect()
					_G.PlayerESPData.Connections[player].charRemoving:Disconnect()
					_G.PlayerESPData.Connections[player] = nil
				end
			end)

			_G.PlayerESPData.MainConnections = {
				playerAdded = playerAddedConn,
				playerRemoving = playerRemovingConn
			}

			_G.PlayerESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
				updateESP()
			end)

		else
			if _G.PlayerESPData then
				if _G.PlayerESPData.UpdateLoop then
					_G.PlayerESPData.UpdateLoop:Disconnect()
				end

				if _G.PlayerESPData.MainConnections then
					_G.PlayerESPData.MainConnections.playerAdded:Disconnect()
					_G.PlayerESPData.MainConnections.playerRemoving:Disconnect()
				end

				for player, connections in pairs(_G.PlayerESPData.Connections) do
					connections.charAdded:Disconnect()
					connections.charRemoving:Disconnect()
				end

				for player, highlight in pairs(_G.PlayerESPData.Highlights) do
					highlight:Destroy()
				end

				_G.PlayerESPData = nil
			end
		end
	end,
	Flag = "PlayerESPToggle"
})

local Toggle2 = EspTab:CreateToggle({
	Name = "Cameras' Esp",
	Description = nil,
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			if not _G.CameraESPData then
				_G.CameraESPData = {
					Highlights = {},
					Connections = {}
				}
			end

			local function isCamera(model)
				return model:IsA("Model") and model.Name == "ActiveCamModel" and model.Parent and model.Parent.Name == "RoundDebris" and model.Parent.Parent == game.Workspace
			end

			local function updateCameraESP()
				for camera, highlight in pairs(_G.CameraESPData.Highlights) do
					if camera and camera.Parent then
						highlight.Adornee = camera
						highlight.Enabled = true
					else
						highlight.Enabled = false
					end
				end
			end

			local function createCameraESP(camera)
				if not isCamera(camera) then return end
				
				local highlight = Instance.new("Highlight")
				highlight.Name = camera.Name .. "_CameraESP"
				highlight.FillColor = Color3.fromRGB(0, 0, 255)
				highlight.FillTransparency = 0.6
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineTransparency = 0.2
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = game.CoreGui
				
				_G.CameraESPData.Highlights[camera] = highlight
			end

			local function scanForCameras()
				local roundDebris = game.Workspace:FindFirstChild("RoundDebris")
				if roundDebris then
					for _, camera in pairs(roundDebris:GetDescendants()) do
						if camera:IsA("Model") and camera.Name == "ActiveCamModel" then
							createCameraESP(camera)
						end
					end
				end
			end

			scanForCameras()

			local function handleDescendantAdded(descendant)
				if descendant:IsA("Model") and descendant.Name == "ActiveCamModel" then
					local parent = descendant.Parent
					if parent and parent.Name == "RoundDebris" and parent.Parent == game.Workspace then
						createCameraESP(descendant)
					end
				end
			end

			local function handleDescendantRemoving(descendant)
				if _G.CameraESPData.Highlights[descendant] then
					_G.CameraESPData.Highlights[descendant]:Destroy()
					_G.CameraESPData.Highlights[descendant] = nil
				end
			end

			local descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
			local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

			_G.CameraESPData.MainConnections = {
				descendantAdded = descendantAddedConn,
				descendantRemoving = descendantRemovingConn
			}

			_G.CameraESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
				updateCameraESP()
			end)

		else
			if _G.CameraESPData then
				if _G.CameraESPData.UpdateLoop then
					_G.CameraESPData.UpdateLoop:Disconnect()
				end

				if _G.CameraESPData.MainConnections then
					_G.CameraESPData.MainConnections.descendantAdded:Disconnect()
					_G.CameraESPData.MainConnections.descendantRemoving:Disconnect()
				end

				for camera, highlight in pairs(_G.CameraESPData.Highlights) do
					highlight:Destroy()
				end

				_G.CameraESPData = nil
			end
		end
	end,
	Flag = "CameraESPToggle"
})

local Toggle3 = EspTab:CreateToggle({
	Name = "Camera Location",
	Description = "Searching if camera is in 30 studs",
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			if not _G.CameraAlertData then
				_G.CameraAlertData = {
					Connections = {},
					LastNotification = 0
				}
			end

			local function isCamera(model)
				return model:IsA("Model") and model.Name == "ActiveCamModel" and 
					   model.Parent and model.Parent.Name == "RoundDebris" and 
					   model.Parent.Parent == game.Workspace
			end

			local function checkCameraProximity()
				local player = game.Players.LocalPlayer
				local character = player.Character
				if not character then return end
				
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then return end
				
				local playerPosition = humanoidRootPart.Position
				
				local roundDebris = game.Workspace:FindFirstChild("RoundDebris")
				if not roundDebris then return end
				
				for _, camera in pairs(roundDebris:GetDescendants()) do
					if isCamera(camera) then
						local cameraPart = camera:FindFirstChildWhichIsA("BasePart")
						if cameraPart then
							local distance = (playerPosition - cameraPart.Position).Magnitude
							
							if distance <= 30 then
								if os.time() - _G.CameraAlertData.LastNotification > 3 then
									game:GetService("StarterGui"):SetCore("SendNotification", {
										Title = "⚠️ CAMERA ALERT",
										Text = "Camera is within 30 studs!",
										Duration = 3,
										Icon = "rbxassetid://4458901886"
									})
									
									_G.CameraAlertData.LastNotification = os.time()
								end
								return
							end
						end
					end
				end
			end

			local roundDebris = game.Workspace:FindFirstChild("RoundDebris")
			if roundDebris then
				for _, camera in pairs(roundDebris:GetDescendants()) do
					if isCamera(camera) then
						checkCameraProximity()
						break
					end
				end
			end

			local function handleDescendantAdded(descendant)
				if isCamera(descendant) then
					checkCameraProximity()
				end
			end

			_G.CameraAlertData.descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)

			_G.CameraAlertData.proximityLoop = game:GetService("RunService").Heartbeat:Connect(function()
				checkCameraProximity()
			end)

		else
			if _G.CameraAlertData then
				if _G.CameraAlertData.proximityLoop then
					_G.CameraAlertData.proximityLoop:Disconnect()
				end
				
				if _G.CameraAlertData.descendantAddedConn then
					_G.CameraAlertData.descendantAddedConn:Disconnect()
				end
				
				_G.CameraAlertData = nil
			end
		end
	end,
	Flag = "CameraAlertToggle"
})
