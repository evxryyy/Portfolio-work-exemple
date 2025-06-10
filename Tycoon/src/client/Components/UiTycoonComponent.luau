local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Packets = require(ReplicatedStorage.Packages.Packets)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local TycoonMenuComponent = require(script.Parent.TycoonMenuComponent)

local Scope = Fusion.scoped({
	New = Fusion.New;
	OnEvent = Fusion.OnEvent;
	OnChange = Fusion.OnChange;
})

local function screenGuiObject()
	if(Players.LocalPlayer.PlayerGui:FindFirstChild("PrimaryGuiElements")) then 
		return Players.LocalPlayer.PlayerGui:FindFirstChild("PrimaryGuiElements")
	end
	local object = Scope:New("ScreenGui"){
		Parent = Players.LocalPlayer.PlayerGui,
		Name = "PrimaryGuiElements";
		IgnoreGuiInset = true;
		Enabled = true;
		ResetOnSpawn = false;
	}
	return object
end

local module = {}
module.__index = module
module.screen = screenGuiObject()

local function createCashFrame()
	local frame = Scope:New("Frame"){
		Size = UDim2.fromScale(0.35,0.05);
		BackgroundTransparency = 0.15;
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		Position = UDim2.fromScale(0.5,0.925);
		AnchorPoint = Vector2.new(0.5,0.5);
		Parent = module.screen;
		[Scope.OnEvent("MouseEnter")] = function(MouseX, MouseY)
			module.screen.Frame.Caption.Text = "This is your current money."
			TweenService:Create(module.screen.Frame.Caption,TweenInfo.new(0.35),{
				TextTransparency = 0;
			}):Play()
			SoundService:PlayLocalSound(SoundService.Hover)
		end,
		[Scope.OnEvent("MouseLeave")] = function()
			TweenService:Create(module.screen.Frame.Caption,TweenInfo.new(0.25),{TextTransparency = 1}):Play()
		end,
	}
	Scope:New("UICorner"){CornerRadius = UDim.new(0,8),Parent = frame}
	Scope:New("UIStroke"){Thickness = 4,Color = Color3.fromRGB(0, 0, 0),Parent = frame}
	Scope:New("UIScale"){Scale = 0,Parent = frame}
	local label = Scope:New("TextLabel"){
		Size = UDim2.fromScale(1,1);
		Parent = frame;
		BackgroundTransparency = 1;
		Text = "";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Font = Enum.Font.SourceSansSemibold;
		Position = UDim2.fromScale(0.5,0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
	}
	Scope:New("TextLabel"){
		Size = UDim2.fromScale(1,1);
		Parent = frame;
		BackgroundTransparency = 1;
		Text = "This is your current money.";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255, 255, 255);
		Font = Enum.Font.SourceSansSemibold;
		Position = UDim2.fromScale(0.5,-0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
		TextTransparency = 1;
		Name = "Caption"		
	}
	Players.LocalPlayer.leaderstats.Cash:GetPropertyChangedSignal("Value"):Connect(function()
		label.Text = FormatNumber.FormatCompact(Players.LocalPlayer.leaderstats.Cash.Value,2) .. "$"
	end)
	return frame
end

local function createGameVersionFrame()
	local version = Scope:New("TextLabel"){
		Text = `test\nTest`;
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		TextTransparency = 0.5;
		Size = UDim2.fromScale(0.15,0.15);
		Position = UDim2.fromScale(0.15,0.925);
		AnchorPoint = Vector2.new(0.5,0.5);
		Parent = module.screen;
		BackgroundTransparency = 1;
		Name = "GAME_VERSION";
		Font = Enum.Font.SourceSansSemibold;
	}
	Scope:New("UIScale"){Parent = version,Scale = 0}
	return version
end

local function createGuideFrame()
	local guide = Scope:New("TextLabel"){
		Parent = module.screen;
		Text = "Claim a tycoon !";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		Size = UDim2.fromScale(1,0.05);
		Position = UDim2.fromScale(0.5,0.1);
		AnchorPoint = Vector2.new(0.5,0.5);
		BackgroundTransparency = 1;
		Name = "GuideLabel";
		Font = Enum.Font.SourceSansSemibold;
	}
	Scope:New("UIScale"){Scale = 1;Parent = guide};
	return guide
end

local function createLeaderboardBillboardGui()
	local leaderboard = Scope:New("BillboardGui"){
		Parent = workspace.Leaderboard.Part;
		Size = UDim2.fromScale(10,5);
		StudsOffset = Vector3.new(0,7.25,0);
		MaxDistance = math.huge;
		Active = true;
	}
	local label = Scope:New("TextLabel"){
		Parent = leaderboard;
		Text = "Leaderboad's";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		Size = UDim2.fromScale(1,1);
		BackgroundTransparency = 1;
		Font = Enum.Font.SourceSansSemibold
	}
	local gradient = Scope:New("UIGradient"){
		Color =  ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)))
		});
		Offset = Vector2.new(0,0);
		Parent = label
	}
	task.spawn(function()
		while(leaderboard) do
			local tween = TweenService:Create(gradient,TweenInfo.new(1.2),{Offset = Vector2.new(math.random() * 2 - 1,0)})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

function module.Start()
	TycoonMenuComponent.TycoonMenu()
	local objs = {}
	table.insert(objs,createCashFrame())
	table.insert(objs,createGameVersionFrame())
	for i,child in pairs(objs) do
		if(child.UIScale) then
			TweenService:Create(child.UIScale,TweenInfo.new(0.35),{Scale = 1}):Play()
			SoundService:PlayLocalSound(SoundService.poof)
			task.wait(0.35)
		end
	end	
end

function module.UpdateGameVersion(label : TextLabel,text : string)
	if(not label) then return end
	if(not text) then return end
	label.Text = text
	return label.Text
end

function module.AddGuideFrame()
	return createGuideFrame()
end

function module.AddLeaderboardBillboardGui()
	return createLeaderboardBillboardGui()
end

return module
