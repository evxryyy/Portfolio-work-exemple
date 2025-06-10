local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Packets = require(ReplicatedStorage.Packages.Packets)


local Scope = Fusion.scoped({
	OnChange = Fusion.OnChange;
	OnEvent = Fusion.OnEvent;
	New = Fusion.New;
})

local function constructSettingGui(state)
	local gui = Scope:New("ScreenGui"){
		Parent = Players.LocalPlayer.PlayerGui;
		Name = "SettingGui";
		Enabled = true;
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
	}
	local canvas = Scope:New("CanvasGroup"){
		GroupTransparency = 1;
		Size = UDim2.fromScale(0,0.6),
		BackgroundTransparency = 1;
		Parent = gui;
		Name = "Canvas";
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.fromScale(0.5,0.5);
	}
	local frame = Scope:New("Frame"){
		Size = UDim2.fromScale(0.9,0.9);
		Parent = canvas;
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		Name = "Setting";
		Position = UDim2.fromScale(0.5,0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
	}
	Scope:New("UICorner"){Parent = frame};
	Scope:New("UIStroke"){Parent = frame,Color = Color3.fromRGB(0,0,0),Thickness = 4}
	local label = Scope:New("TextLabel"){
		Text = "Optimize your performance here.";
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Size = UDim2.fromScale(1,0.1);
		BackgroundTransparency = 1;
		Font = Enum.Font.SourceSansSemibold;
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.fromScale(0.5,0.1);
		Parent = frame;
		TextScaled = true;
	}
	local scroll = Scope:New("ScrollingFrame"){
		Size = UDim2.fromScale(1,0.85);
		Parent = frame;
		BackgroundTransparency = 1;
		Position = UDim2.fromScale(0.5,0.575);
		AnchorPoint = Vector2.new(0.5,0.5);
		AutomaticCanvasSize = Enum.AutomaticSize.XY;
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
		ScrollBarThickness = 7;
		CanvasSize = UDim2.fromScale(0,0);
	}
	Scope:New("UIListLayout"){
		Parent = scroll;
		Padding = UDim.new(0.025,0);
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		Wraps = false;
	}
	local MusicFrameToggle = Scope:New("Frame"){
		Size = UDim2.fromScale(0.95,0.125);
		BackgroundTransparency = 1;
		AnchorPoint = Vector2.new(0.5,0.5);
		Name = "MusicToggleFrame";
		Parent = scroll
	}
	local MusicLabel = Scope:New("TextLabel"){
		Text = "Music";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Parent = MusicFrameToggle;
		Position = UDim2.fromScale(0,0.5);
		BackgroundTransparency = 1;
		AnchorPoint = Vector2.new(0,0.5);
		Size = UDim2.fromScale(0.35,1);
		Font = Enum.Font.SourceSansSemibold;
	}
	local MusicFrame = Scope:New("Frame"){
		Size = UDim2.fromScale(0.5,1);
		AnchorPoint = Vector2.new(0.5,0.5);
		Name = "Toggle";
		BackgroundTransparency = 0.15;
		Parent = MusicFrameToggle;
		BackgroundColor3 = Color3.fromRGB(10,10,10);
		Position = UDim2.fromScale(0.75,0.5);
	}
	local MusicState = Scope:New("BoolValue"){Name = "MusicState",Value = true,Parent = MusicFrameToggle}
	local MusicButton = Scope:New("TextButton"){
		Text = "";
		TextScaled = true;
		Font = Enum.Font.SourceSansSemibold;
		TextColor3 = Color3.fromRGB(255,255,255);
		Size = UDim2.fromScale(0.3,1);
		Parent = MusicFrame;
		BackgroundColor3 = Color3.fromRGB(0, 255, 127);
		Position = UDim2.fromScale(0.85,0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
		[Scope.OnEvent("Activated")] = function()
			SoundService:PlayLocalSound(SoundService.UiClick)
			if(MusicState.Value) then
				TweenService:Create(MusicFrame:FindFirstChild("TextButton"),
					TweenInfo.new(0.5),
					{Position = UDim2.fromScale(0.15,0.5),BackgroundColor3 = Color3.fromRGB(255, 16, 68)}
				):Play()
				for i,music in pairs(SoundService.Playlist:GetChildren()) do
					music.Volume = 0
				end
 				MusicState.Value = false;
			else
				TweenService:Create(MusicFrame:FindFirstChild("TextButton"),
					TweenInfo.new(0.5),
					{Position = UDim2.fromScale(0.85,0.5),BackgroundColor3 = Color3.fromRGB(0,255,127)}
				):Play()
				for i,music in pairs(SoundService.Playlist:GetChildren()) do
					music.Volume = 0.2
				end
				MusicState.Value = true;
			end
			local IsSettingResponse = Packets.IsSettingPacket:Fire("Music")
			if(IsSettingResponse) then
				Packets.AddSettingToDataStorePacket:Fire("Music",MusicState.Value)
			end			
		end,
	}
	Scope:New("UICorner"){Parent = MusicFrame};
	Scope:New("UICorner"){Parent = MusicButton};
	TweenService:Create(canvas,TweenInfo.new(0.5),{Size = UDim2.fromScale(0.3,0.6),GroupTransparency = 0}):Play()
	if(state ~= nil) then gui.Enabled = state else gui.Enabled = true end
	return gui;
end

local module = {}
module.__index = module

module.Construct = function(self,state)
	if(self.State == "Constructed") then
		return self:Destroy()
	end
	self.State = "Constructed"
	if(not self.Gui) then
		self.Gui = constructSettingGui(state)
		local getData = Packets.GetDataStoreSettingsPacket:InvokeServer()
		if(getData) then
			for setting,state in pairs(getData) do
				if(setting == "Music") then
					local object = self.Gui:FindFirstChild("Canvas"):FindFirstChild("Setting"):FindFirstChild("ScrollingFrame"):FindFirstChild("MusicToggleFrame")
					if(state == false) then
						TweenService:Create(
							object:FindFirstChild("Toggle"):FindFirstChild("TextButton"),
							TweenInfo.new(0.2),
							{Position = UDim2.fromScale(0.15,0.5),BackgroundColor3 = Color3.fromRGB(255, 16, 68)}
						):Play()
						for i,music in pairs(SoundService.Playlist:GetChildren()) do
							music.Volume = 0
						end
						object:FindFirstChild("MusicState").Value = false;
					else
						TweenService:Create(
							object:FindFirstChild("Toggle"):FindFirstChild("TextButton"),
							TweenInfo.new(0.2),
							{Position = UDim2.fromScale(0.85,0.5),BackgroundColor3 = Color3.fromRGB(0, 255, 127)}
						):Play()
						for i,music in pairs(SoundService.Playlist:GetChildren()) do
							music.Volume = 0.2
						end
						object:FindFirstChild("MusicState").Value = true;
					end
				end
			end
		end
	else
		if(state) then self.Gui.Enabled = state else self.Gui.Enabled = true end
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0.3,0.6),GroupTransparency = 0}):Play()
	end
	return self	
end

module.Destroy = function(self)
	if(self.Gui) then 
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0,0.6),GroupTransparency = 1}):Play()
	end
	if(self.State == "Constructed") then self.State = nil end
end

return module