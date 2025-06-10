local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Packets = require(ReplicatedStorage.Packages.Packets)

local Scope = Fusion.scoped({
	event = Fusion.OnEvent;
	changed = Fusion.OnChange;
	new = Fusion.New;
})


local module = {}
module.__index = module

local function textAnimation(label,text)
	local len = string.len(text)
	label.Text = ""
	for i = 0,len do
		SoundService:PlayLocalSound(SoundService.KeyboardTyping)
		label.Text = string.sub(text,1,i)
		task.wait()
	end
end

local function initTutorialGui()
	local gui = Scope:new("ScreenGui"){
		Parent = Players.LocalPlayer.PlayerGui,
		Name = "TutorialGui",
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
	}
	local canvas = Scope:new("CanvasGroup"){
		GroupTransparency = 1;
		Size = UDim2.fromScale(0,0.6),
		BackgroundTransparency = 1;
		Parent = gui;
		Name = "Canvas";
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.fromScale(0.85,0.5);
	}
	local frame = Scope:new("Frame"){
		Size = UDim2.fromScale(0.9,0.2);
		Parent = canvas;
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		Name = "TutorialFrame";
		Position = UDim2.fromScale(0.5,0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
	}
	local image = Scope:new("ImageLabel"){
		Size = UDim2.fromScale(0.15,0.1);
		AnchorPoint = Vector2.new(0.5,0.5);
		BackgroundTransparency = 1;
		Position = UDim2.fromScale(0.85,0.335);
		Parent = canvas;
		Name = "PlayerImage";
	}
	local currentTutorialStep = Scope:new("TextButton"){
		Name = "TutorialStep";
		Position = UDim2.fromScale(0.5,0.5);
		Size = UDim2.fromScale(0.9,0.9);
		AnchorPoint = Vector2.new(0.5,0.5);
		BackgroundTransparency = 1;
		Text = "";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0,0,0);
		Font = Enum.Font.SourceSansSemibold;
		Parent = frame;
	}
	image.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420)
	Scope:new("UICorner"){Parent = frame};
	Scope:new("UIStroke"){Parent = frame,Color = Color3.fromRGB(0,0,0),Thickness = 4}
	TweenService:Create(canvas,TweenInfo.new(1),{Size = UDim2.fromScale(0.3,0.6),GroupTransparency = 0}):Play()
	textAnimation(currentTutorialStep,`Welcome @{Players.LocalPlayer.Name} to begin the tutorial go claim a tycoon by following arrow's.`)
	return gui
end

module.StartTutorial = function()
	local gui = initTutorialGui()
	Packets.NewTutorialStepPacket.OnClientEvent:Connect(function(a0: string) 
		textAnimation(gui:FindFirstChild("Canvas"):FindFirstChild("TutorialFrame"):FindFirstChild("TutorialStep"),a0)
		if(string.find(a0,"Very nice")) then
			task.delay(2,function()
				TweenService:Create(gui:FindFirstChild("Canvas"),TweenInfo.new(1),{Size = UDim2.fromScale(0,0.6),GroupTransparency = 1}):Play()
			end)			
		end
	end)
end

return module