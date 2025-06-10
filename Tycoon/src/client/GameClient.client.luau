--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Configuration = script.Parent:WaitForChild("Configuration")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Components = ReplicatedStorage:WaitForChild("Components")
local Controllers = script.Parent:WaitForChild("Controllers")

local Packets = require(Packages:WaitForChild("Packets"))
local ButtonsAnimationSettings = require(Configuration:WaitForChild("ButtonsAnimationSettings"))
local BillboardComponent = require(Components:WaitForChild("BillboardComponent"))
local GlobalInstanceComponent = require(Components:WaitForChild("GlobalInstanceComponent"))
local ButtonsComponent = require(script.Parent:WaitForChild("Components").ButtonsComponent)
local Emotes = require(ReplicatedStorage:WaitForChild("Utils").Emotes)
local UiTycoonComponent = require(script.Parent.Components.UiTycoonComponent)
local TycoonSlotBeamComponent = require(script.Parent.Components.TycoonSlotBeamComponent)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local LeaderboardController = require(Controllers:WaitForChild("LeaderboardController"))
local IconsComponent = require(script.Parent.Components:WaitForChild("IconsComponent"))
local FootstepSoundController = require(Controllers:WaitForChild("FootstepSoundController"))
local Tutorial = require(script.Parent.Components.Tutorial)

local TextLabel = GlobalInstanceComponent.TextLabel

local guide
task.spawn(function()
	FootstepSoundController:InitCharacterSounds()
	repeat
		task.wait()
	until ReplicatedStorage:WaitForChild(Players.LocalPlayer.Name.."Loaded").Value == true	
	guide = UiTycoonComponent.AddGuideFrame()
	UiTycoonComponent.AddLeaderboardBillboardGui()	
	IconsComponent.InitMainMenuIcon()
end)

TycoonSlotBeamComponent.Start()
LeaderboardController:Start()

Packets.AnimateModelPacket.OnClientEvent:Connect(function(instances: {string}) 
	if(not instances) then return end
	local getButtonsFolder = Packets.GetTycoonPacket:Fire() :: Instance
	for i,v in pairs(getButtonsFolder:FindFirstChild(`Buttons{Players.LocalPlayer.Name}`):GetChildren()) do
		if(v:IsA("Model")) then
			for j,k in pairs(v:GetDescendants()) do
				if(k:IsA("BasePart")) then
					TweenService:Create(
						k,
						TweenInfo.new(
							ButtonsAnimationSettings.Duration,
							ButtonsAnimationSettings.EasingStyle,
							ButtonsAnimationSettings.EasingDirection
						),
						{Transparency = 0}
					):Play()
				end
			end
			local object = BillboardComponent.Create(function() 
				return {
					StudsOffset = Vector3.new(0,5,0);
					Size = UDim2.fromScale(5,2);
					Brightness = 1;
					AlwaysOnTop = false;
					Name = v:GetAttribute("Item");
					Parent = v;
				}	
			end)
			local text_label = TextLabel.Create(function() 
				return {
					Size = UDim2.fromScale(1,1);
					BackgroundTransparency = 1;
					TextScaled = true;
					TextColor3 = Color3.fromRGB(255,255,255);
					Text = `{v:GetAttribute("Item")}, {tonumber(v:GetAttribute("Price"))}$`;
					Parent = object;
				}
			end)
			ButtonsComponent.ConstructButtonConnection(v)
		end
	end
end)

Packets.EmoteRigPacket.OnClientEvent:Connect(function(rig : Instance)
	if(not rig) then return end
	task.spawn(function()
		local tracker : AnimationTrack = Emotes.LoadAnimationToRig(rig :: Model,nil)
		tracker.Looped = true	
		tracker:Play()
	end)
end)

Packets.LoadUiComponentPacket.OnClientEvent:Connect(function()
	TweenService:Create(guide.UIScale,TweenInfo.new(0.2),{Scale = 0}):Play()
	Debris:AddItem(guide,.3)
	UiTycoonComponent.Start()
	UiTycoonComponent.UpdateGameVersion(
		Players.LocalPlayer.PlayerGui:WaitForChild("PrimaryGuiElements"):WaitForChild("GAME_VERSION"),
		`@{Players.LocalPlayer.Name}\nVersion: {require(ReplicatedStorage.VERSION)}`
	)
end)

Packets.StartTutorialPacket.OnClientEvent:Connect(function()
	repeat
		task.wait()
	until ReplicatedStorage:FindFirstChild(Players.LocalPlayer.Name.."Loaded") == nil	
	Tutorial.StartTutorial()
end)

Packets.AnimatePlayerCharacter.OnClientEvent:Connect(function(a0: Instance) 
	if(not a0) then return end
	local track : AnimationTrack = nil
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if(not humanoid or humanoid.Health <= 0) then return end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	for i,t in pairs(animator:GetPlayingAnimationTracks()) do
		if(t.Name == a0.Name) then
			track = t
			break	
		end
	end
	if(not track) then track = animator:LoadAnimation(a0) end
	track:Play()
	track:GetMarkerReachedSignal("DrinkKey"):Connect(function(...: any) 
		SoundService:PlayLocalSound(SoundService.use_potion)
	end)
	task.spawn(function()
		track.Ended:Wait()
		Packets.AnimatePlayerCharacter:Fire(a0)
	end)
end)