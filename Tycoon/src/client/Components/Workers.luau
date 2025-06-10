local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Packets = require(ReplicatedStorage.Packages.Packets)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)

local Scope = Fusion.scoped({
	new = Fusion.New;
	event = Fusion.OnEvent;
	changed = Fusion.OnChange;
})

local function initWorkerGui()
	if(Players.LocalPlayer.PlayerGui:FindFirstChild("WorkerGui")) then return Players.LocalPlayer.PlayerGui:FindFirstChild("WorkerGui") end
	local gui = Scope:new("ScreenGui"){
		Name = "WorkerGui";
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
		Name = "MainFrame";
		Parent = canvas;
	}
	local scroll = Scope:new("ScrollingFrame"){
		Size = UDim2.fromScale(0.95,0.85);
		Parent = frame;
		BackgroundTransparency = 1;
		Position = UDim2.fromScale(0.5,0.575);
		AnchorPoint = Vector2.new(0.5,0.5);
		AutomaticCanvasSize = Enum.AutomaticSize.XY;
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
		ScrollBarThickness = 7;
		CanvasSize = UDim2.fromScale(0,0);
	}
	Scope:new("UIGridLayout"){Parent = scroll,CellSize = UDim2.fromScale(0.375,0.5)}
	Scope:new("UICorner"){Parent = frame};
	Scope:new("UIStroke"){Parent = frame,Color = Color3.fromRGB(0,0,0),Thickness = 4}
	local label = Scope:new("TextLabel"){
		Size = UDim2.fromScale(0.2,0.1);
		AnchorPoint = Vector2.new(0,0.5);
		Position = UDim2.fromScale(0.05,0.075);
		BackgroundTransparency = 1;
		Text = "Workers";
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
	Scope:new("UIScale"){Parent = label};
	return gui
end

local function addWorkerToUi(data)
	local screenGui = Players.LocalPlayer.PlayerGui:FindFirstChild("WorkerGui")
	if(not screenGui) then  screenGui = initWorkerGui() end
	local mainframe = screenGui:WaitForChild("Canvas"):WaitForChild("MainFrame")
	local scrollingFrame = mainframe:FindFirstChildOfClass("ScrollingFrame")
	local frame = Scope:new("Frame"){
		Parent = scrollingFrame;
		Name = `Workers({data.Name})`;
		BackgroundTransparency = 1;
	}
	local sub = Scope:new("Frame"){
		Size = UDim2.fromScale(0.9,0.9);
		BackgroundTransparency = 1;
		AnchorPoint = Vector2.new(0.5,0.5);
		Parent = frame;
		Position = UDim2.fromScale(0.5,0.5);
	}
	Scope:new("UICorner"){Parent = sub;}
	Scope:new("UIStroke"){Parent = sub;Color = Color3.fromRGB(0, 116, 170),Thickness = 3}	
	local workerImage = Scope:new("ImageLabel"){
		Size = UDim2.fromScale(0.5,0.5);
		Position = UDim2.fromScale(0.5,0.35);
		Parent = sub;
		BackgroundTransparency = 1;
		Name = data.Name;
		AnchorPoint = Vector2.new(0.5,0.5);
	}	
	workerImage.Image = Players:GetUserThumbnailAsync(
		Players:GetUserIdFromNameAsync(data.Name),Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420
	)
	local workerNameLabel = Scope:new("TextLabel"){
		Size = UDim2.fromScale(1,0.1);
		Parent = sub;
		Text = frame.Name;
		TextScaled = true;
		BackgroundTransparency = 1;
		Font = Enum.Font.SourceSansSemibold;
		Position = UDim2.fromScale(0.5,0.1);
		AnchorPoint = Vector2.new(0.5,0.5);
		Name = data.Name;
	}
	local stats = Scope:new("TextLabel"){
		Size = UDim2.fromScale(1,0.2);
		Parent = sub;
		TextScaled = true;
		BackgroundTransparency = 1;
		Font = Enum.Font.SourceSansSemibold;
		Position = UDim2.fromScale(0.5,0.7);
		AnchorPoint = Vector2.new(0.5,0.5);
		Name = data.Name.."Stats";
	}
	stats.Text = `Earn: ${data.CashEarning},Cooldown: {data.Time}sec, FailChance: {data.ChanceToFail}%,Level: {data.Level}`;
	local upgrade = Scope:new("TextButton"){
		Size = UDim2.fromScale(0.8,0.15);
		Parent = sub;
		Text = `Upgrade: ${data.UpgradeCost}`;
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 0;
		BackgroundColor3 = Color3.fromRGB(170, 255, 127);
		Font = Enum.Font.SourceSansSemibold;
		Position = UDim2.fromScale(0.5,0.9);
		AnchorPoint = Vector2.new(0.5,0.5);
		Name = "Upgrade";
		[Scope.event("MouseEnter")] = function()
			SoundService:PlayLocalSound(SoundService.Hover);
			TweenService:Create(sub.Upgrade.UIScale,TweenInfo.new(0.2),{Scale = 0.95}):Play()
		end,
		[Scope.event("MouseLeave")] = function()
			TweenService:Create(sub.Upgrade.UIScale,TweenInfo.new(0.2),{Scale = 1}):Play()
		end,
		[Scope.event("Activated")] = function()
			SoundService:PlayLocalSound(SoundService.UiClick)
			local newData = Packets.UpdateWorkerPacket:InvokeServer(data)
			if(type(newData) ~= "table" and type(newData) ~= "boolean") then 
				SoundService:PlayLocalSound(SoundService.PurchaseFailed)
			elseif(type(newData) == "table") then
				stats.Text = `Earn: ${newData.CashEarning},Cooldown: {newData.Time}sec, FailChance: {newData.ChanceToFail}%,Level: {newData.Level}`;
				if(newData.Level >= 3) then
					sub.Upgrade.Active = false
					sub.Upgrade.Text = "MAX";
				else
					sub.Upgrade.Text = `Upgrade: ${newData.UpgradeCost}`;
				end
			elseif(type(newData) == "boolean") then
				sub.Upgrade.Active = false
				sub.Upgrade.Text = "MAX";
				SoundService:PlayLocalSound(SoundService.poof)
			end
		end,
	}
	Scope:new("UIScale"){Parent = upgrade,Scale = 1};
	Scope:new("UICorner"){Parent = upgrade};
	return frame;
end

local module = {}
module.__index = module

module.Construct = function(self,state)
	if(self.State == "Constructed") then return self:Destroy() end
	if(not self.Gui) then
		self.Gui = initWorkerGui()
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0.5,0.6),GroupTransparency = 0}):Play()
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

module.NewWorkerAddedSignal = Packets.SendNewWorkerData.OnClientEvent:Connect(function(data)
	if(not data) then return end
	addWorkerToUi(data)
end)

return module
