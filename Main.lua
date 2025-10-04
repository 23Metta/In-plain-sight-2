--LUNA
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local Window = Luna:CreateWindow({
	Name = "In plain sight 2", -- This Is Title Of Your Window
	Subtitle = nil, -- A Gray Subtitle next To the main title.
	LogoID = "nil", -- The Asset ID of your logo. Set to nil if you do not have a logo for Luna to use.
	LoadingEnabled = true, -- Whether to enable the loading animation. Set to false if you do not want the loading screen or have your own custom one.
	LoadingTitle = "Meta Hub", -- Header for loading screen
	LoadingSubtitle = "by Metta", -- Subtitle for loading screen

	ConfigSettings = {
		RootFolder = nil, -- The Root Folder Is Only If You Have A Hub With Multiple Game Scripts and u may remove it. DO NOT ADD A SLASH
		ConfigFolder = "Big Hub" -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
	},

	KeySystem = false, -- As Of Beta 6, Luna Has officially Implemented A Key System!
	KeySettings = {
		Title = "Luna Example Key",
		Subtitle = "Key System",
		Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass",
		SaveInRoot = false, -- Enabling will save the key in your RootFolder (YOU MUST HAVE ONE BEFORE ENABLING THIS OPTION)
		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
		Key = {"Example Key"}, -- List of keys that will be accepted by the system, please use a system like Pelican or Luarmor that provide key strings based on your HWID since putting a simple string is very easy to bypass
		SecondAction = {
			Enabled = true, -- Set to false if you do not want a second action,
			Type = "Link", -- Link / Discord.
			Parameter = "" -- If Type is Discord, then put your invite link (DO NOT PUT DISCORD.GG/). Else, put the full link of your key system here.
		}
	}
})
--TAB
local PlayerTab = Window:CreateTab({
	Name = "Player",
	Icon = "view_in_ar",
	ImageSource = "Material",
	ShowTitle = true -- This will determine whether the big header text in the tab will show
})
local EspTab = Window:CreateTab({
	Name = "Esp",
	Icon = "view_in_ar",
	ImageSource = "Material",
	ShowTitle = true -- This will determine whether the big header text in the tab will show
})
--PLAYER
local Input = PlayerTab:CreateInput({
	Name = "Player's Speed",
	Description = Change player's speed,
	PlaceholderText = "20 is recommended",
	CurrentValue = "", -- the current text
	Numeric = false, -- When true, the user may only type numbers in the box (Example walkspeed)
	MaxCharacters = nil, -- if a number, the textbox length cannot exceed the number
	Enter = false, -- When true, the callback will only be executed when the user presses enter.
    	Callback = function(Text)
local newSpeed = tonumber(Text)
       if newSpeed then
           _G.CustomWalkSpeed = newSpeed
           
           local player = game.Players.LocalPlayer
           local function updateSpeed(character)
               local humanoid = character:WaitForChild("Humanoid")
               humanoid.WalkSpeed = newSpeed
           end
           
           -- Применяем к текущему персонажу
           if player.Character then
               updateSpeed(player.Character)
           end
           
           -- Применяем к новым персонажам
           player.CharacterAdded:Connect(updateSpeed)
           
           print("Speed set to: " .. newSpeed)
       else
           print("Invalid speed value")
       end
   end,
})
       	 -- The function that takes place when the input is changed
	 -- The variable (Text) is a string for the value in the text box
    	end
}, "Input") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
--ESP
local Toggle = EspTab:CreateToggle({
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
})
       	 -- The function that takes place when the toggle is switched
       	 -- The variable (Value) is a boolean on whether the toggle is true or false
    	end
}, "Toggle") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
local Toggle = EspTab:CreateToggle({
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
})
       	 -- The function that takes place when the toggle is switched
       	 -- The variable (Value) is a boolean on whether the toggle is true or false
    	end
}, "Toggle") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
local Toggle = EspTab:CreateToggle({
	Name = "Camera Location",
	Description = Searching if camera is in 30 studs,
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
               
               -- Ищем камеры в RoundDebris
               local roundDebris = game.Workspace:FindFirstChild("RoundDebris")
               if not roundDebris then return end
               
               for _, camera in pairs(roundDebris:GetDescendants()) do
                   if isCamera(camera) then
                       local cameraPart = camera:FindFirstChildWhichIsA("BasePart")
                       if cameraPart then
                           local distance = (playerPosition - cameraPart.Position).Magnitude
                           
                           if distance <= 30 then
                               -- Проверяем чтобы не спамить уведомлениями
                               if os.time() - _G.CameraAlertData.LastNotification > 3 then
                                   -- Отправляем уведомление
                                   game:GetService("StarterGui"):SetCore("SendNotification", {
                                       Title = "⚠️ CAMERA ALERT",
                                       Text = "Camera is within 30 studs!",
                                       Duration = 3,
                                       Icon = "rbxassetid://4458901886"
                                   })
                                   
                                   _G.CameraAlertData.LastNotification = os.time()
                               end
                               return -- Достаточно одной камеры для уведомления
                           end
                       end
                   end
               end
           end

           -- Сканируем существующие камеры
           local roundDebris = game.Workspace:FindFirstChild("RoundDebris")
           if roundDebris then
               for _, camera in pairs(roundDebris:GetDescendants()) do
                   if isCamera(camera) then
                       checkCameraProximity()
                       break
                   end
               end
           end

           -- Отслеживаем новые камеры
           local function handleDescendantAdded(descendant)
               if isCamera(descendant) then
                   checkCameraProximity()
               end
           end

           _G.CameraAlertData.descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)

           -- Основной цикл проверки
           _G.CameraAlertData.proximityLoop = game:GetService("RunService").Heartbeat:Connect(function()
               checkCameraProximity()
           end)

       else
           -- Выключаем систему
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
})
       	 -- The function that takes place when the toggle is switched
       	 -- The variable (Value) is a boolean on whether the toggle is true or false
    	end
}, "Toggle") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
