local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Scope = Fusion.scoped({
	OnChange = Fusion.OnChange;
	OnEvent = Fusion.OnEvent;
	New = Fusion.New;
})

local module = {}
module.__index = module

local function initScrollingFrame()
	local scroll = Scope:New("ScrollingFrame"){
		Size = UDim2.fromScale(1,1);
		Parent = Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui");
		Name = "DataStorePageUi";
		AutomaticCanvasSize = Enum.AutomaticSize.XY;
		CanvasSize = UDim2.fromScale(0,0);
		BackgroundTransparency = 1;
	}
	Scope:New("UIListLayout"){
		Parent = scroll;
		Padding = UDim.new(0.025,0);
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		Wraps = false;
	}
	return scroll
end

local function initFrameData(key,value)
	if(not key or not value) then return end
	if(not pcall(Players.GetNameFromUserIdAsync,Players,tonumber(key))) then return end
	local frame = Scope:New("Frame"){
		Size = UDim2.fromScale(0.95,0.1);
		BackgroundColor3 = Color3.fromRGB(10,10,10);
		BackgroundTransparency = 0.15;
		Name = Players:GetNameFromUserIdAsync(tonumber(key));
		Parent = Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui"):WaitForChild("DataStorePageUi");
		[Scope.OnEvent("MouseEnter")] = function(_)
			TweenService:Create(
				Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui"):WaitForChild("DataStorePageUi"):WaitForChild(Players:GetNameFromUserIdAsync(tonumber(key))).UIScale,
				TweenInfo.new(0.2),
				{Scale = 1.1}
			):Play()
			SoundService:PlayLocalSound(SoundService.Hover)
		end,
		[Scope.OnEvent("MouseLeave")] = function(frame_)
			TweenService:Create(
				Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui"):WaitForChild("DataStorePageUi"):WaitForChild(Players:GetNameFromUserIdAsync(tonumber(key))).UIScale,
				TweenInfo.new(0.2),
				{Scale = 1}
			):Play()
		end,
	}
	Scope:New("UIScale"){Parent = frame,Scale = 0}
	Scope:New("UICorner"){Parent = frame}
	TweenService:Create(frame.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
	local label = Scope:New("TextLabel"){
		Size = UDim2.fromScale(0.85,0.85);
		Parent = frame;
		Text = `@{Players:GetNameFromUserIdAsync(tonumber(key))},Cash = {tonumber(value)}`;
		TextScaled = true;
		Font = Enum.Font.SourceSansSemibold;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		Position = UDim2.fromScale(0.5,0.5);
		AnchorPoint = Vector2.new(0.5,0.5)
	}
	return frame
end

function module:InitLeaderboard(Pages : DataStorePages)
	if(not Pages) then return end
	if(not Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui"):FindFirstChild("DataStorePageUi")) then
		initScrollingFrame()
	end
	for i,frame in pairs(Players.LocalPlayer.PlayerGui:WaitForChild("SurfaceGui"):FindFirstChild("DataStorePageUi"):GetChildren()) do
		if(frame:IsA("Frame")) then
			frame:Destroy()
		end
	end
	for key,value in ipairs(Pages) do
		initFrameData(key,value)
	end
	print(Pages)
end

return module