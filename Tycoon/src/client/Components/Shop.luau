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

local function constructShop()
	local gui = Scope:new("ScreenGui"){
		Name = "ShopGui";
		Enabled = true;
		Parent = Players.LocalPlayer.PlayerGui;
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
		Position = UDim2.fromScale(0.5,0.5);
	}
	local frame = Scope:new("Frame"){
		Size = UDim2.fromScale(0.9,0.9);
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.fromScale(0.5,0.5);
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		BackgroundTransparency = 0.15;
		Name = "ShopFrame";
		Parent = canvas;
	}
	Scope:new("UICorner"){Parent = frame};
	Scope:new("UIStroke"){Parent = frame,Color = Color3.fromRGB(0,0,0),Thickness = 4}
	local label = Scope:new("TextLabel"){
		Size = UDim2.fromScale(0.2,0.1);
		AnchorPoint = Vector2.new(0,0.5);
		Position = UDim2.fromScale(0.05,0.075);
		BackgroundTransparency = 1;
		Text = "Shop";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Font = Enum.Font.SourceSansSemibold;
		Name = "ShopLabel";
		Parent = frame;
		[Scope.event("MouseEnter")] = function()
			TweenService:Create(frame.ShopLabel.UIScale,TweenInfo.new(0.1),{Scale = 1.1}):Play()
		end,
		[Scope.event("MouseLeave")] = function()
			TweenService:Create(frame.ShopLabel.UIScale,TweenInfo.new(0.1),{Scale = 1}):Play()
		end,
	}
	local pointA = Scope:new("ImageLabel"){
		Size = UDim2.fromScale(0.1,0.125);
		Position = UDim2.fromScale(0.29,0.08);
		AnchorPoint = Vector2.new(0.5,0.5);
		BackgroundTransparency = 1;
		Parent = frame;
		Image = "rbxassetid://9237268783";
		ImageColor3 = Color3.fromRGB(0,0,0);
	}
	local boostButton = Scope:new("TextButton"){
		Size = UDim2.fromScale(0.2,0.1);
		AnchorPoint = Vector2.new(0,0.5);
		Position = UDim2.fromScale(0.35,0.075);
		BackgroundTransparency = 1;
		Text = "Boosts";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Font = Enum.Font.SourceSansSemibold;
		Name = "BoostButton";
		TextTransparency = 0;
		Parent = frame;
		[Scope.event("MouseEnter")] = function()
			TweenService:Create(frame.BoostButton.UIScale,TweenInfo.new(0.1),{Scale = 1.1}):Play()
		end,
		[Scope.event("MouseLeave")] = function()
			TweenService:Create(frame.BoostButton.UIScale,TweenInfo.new(0.1),{Scale = 1}):Play()
		end,
	}
	local pointB = Scope:new("ImageLabel"){
		Size = UDim2.fromScale(0.1,0.125);
		Position = UDim2.fromScale(0.6,0.08);
		AnchorPoint = Vector2.new(0.5,0.5);
		BackgroundTransparency = 1;
		Parent = frame;
		Image = "rbxassetid://9237268783";
		ImageColor3 = Color3.fromRGB(0,0,0);
	}
	local PassesButton = Scope:new("TextButton"){
		Size = UDim2.fromScale(0.2,0.1);
		AnchorPoint = Vector2.new(0,0.5);
		Position = UDim2.fromScale(0.65,0.075);
		BackgroundTransparency = 1;
		Text = "Passes";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Font = Enum.Font.SourceSansSemibold;
		Name = "PassesButton";
		TextTransparency = 0;
		Parent = frame;
		[Scope.event("MouseEnter")] = function()
			TweenService:Create(frame.PassesButton.UIScale,TweenInfo.new(0.1),{Scale = 1.1}):Play()
		end,
		[Scope.event("MouseLeave")] = function()
			TweenService:Create(frame.PassesButton.UIScale,TweenInfo.new(0.1),{Scale = 1}):Play()
		end,
	}
	Scope:new("UIScale"){Parent = PassesButton};
	Scope:new("UIScale"){Parent = label};
	Scope:new("UIScale"){Parent = boostButton};
	TweenService:Create(canvas,TweenInfo.new(0.5),{Size = UDim2.fromScale(0.5,0.6),GroupTransparency = 0}):Play()
	return gui
end

local module = {}
module.__index = module

module.Construct = function(self,state)
	if(self.State == "Constructed") then return self:Destroy() end
	if(not self.Gui) then
		self.Gui = constructShop()
	else
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0.5,0.6),GroupTransparency = 0}):Play()
	end	
	self.State = "Constructed"
end

module.Destroy = function(self)
	if(self.Gui) then
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0,0.6),GroupTransparency = 1}):Play()
	end
	if(self.State == "Constructed") then self.State = nil end
	return self	
end

return module