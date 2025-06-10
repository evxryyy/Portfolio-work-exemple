local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Packets = require(ReplicatedStorage.Packages.Packets)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

local Scope = Fusion.scoped({
	event = Fusion.OnEvent;
	changed = Fusion.OnChange;
	new = Fusion.New;
})

local function initInventoryGui()
	if(Players.LocalPlayer.PlayerGui:FindFirstChild("Inventory")) then return Players.LocalPlayer.PlayerGui:FindFirstChild("Inventory") end
	local gui = Scope:new("ScreenGui"){
		Name = "Inventory";
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
		Name = "InventoryFrame";
		Parent = canvas;
	}
	local scroll = Scope:new("ScrollingFrame"){
		Size = UDim2.fromScale(0.95,0.85);
		Parent = frame;
		BackgroundTransparency = 1;
		Position = UDim2.fromScale(0.5,0.55);
		AnchorPoint = Vector2.new(0.5,0.5);
		AutomaticCanvasSize = Enum.AutomaticSize.XY;
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
		ScrollBarThickness = 7;
		CanvasSize = UDim2.fromScale(0,0);
	}
	Scope:new("UICorner"){Parent = frame};
	Scope:new("UIGridLayout"){Parent = scroll,CellSize = UDim2.fromScale(0.275,0.4)}
	Scope:new("UIStroke"){Parent = frame,Color = Color3.fromRGB(0,0,0),Thickness = 4}
	local label = Scope:new("TextLabel"){
		Size = UDim2.fromScale(0.2,0.1);
		AnchorPoint = Vector2.new(0,0.5);
		Position = UDim2.fromScale(0.05,0.075);
		BackgroundTransparency = 1;
		Text = "Inventory";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(0, 0, 0);
		Font = Enum.Font.SourceSansSemibold;
		Name = "InventoryLabel";
		Parent = frame;
	}
	return gui
end

local function _Time(num)
	if(not num) then return end
	return math.floor(num / 60) .. ":" .. math.floor(num % 60)
end

local gui = {}
gui.__index = gui

local function initPotionListFrame(Data : {any})
	if(type(Data) == "table") then
		local frame = Scope:new("Frame"){
			Size = UDim2.fromScale(0.3,0.95);
			Parent = Data.Parent;
			BackgroundTransparency = 1;
			AnchorPoint = Vector2.new(0.5,0.5);
			Position = UDim2.fromScale(0.95,0.5);
			Name = "PotionList";
		}
		Scope:new("UIListLayout"){
			Parent = frame;
			FillDirection = Enum.FillDirection.Horizontal;
			VerticalAlignment = Enum.VerticalAlignment.Bottom;
		}
		return frame
	end
end

local function addPotionDurationFrame(potionType : string , duration : number)
	if(not duration) then return end
	if(not potionType) then return end
	local screenGui = Players.LocalPlayer.PlayerGui:FindFirstChild("Inventory")
	local PotionList = screenGui:FindFirstChild("PotionList")
	if(not PotionList) then return end
	if(PotionList:FindFirstChild(potionType)) then return PotionList:FindFirstChild(potionType) end
	local frame = Scope:new("Frame"){
		Name = potionType;
		Size = UDim2.fromScale(1,0.075);
		BackgroundTransparency = 1;
		Parent = PotionList;
	}
	local image = Scope:new("ImageLabel"){
		Size = UDim2.fromScale(0.2,1);
		Image = gui.RefPotionImageById[potionType];
		BackgroundTransparency = 1;
		Parent = frame;
	}
	local durationLabel = Scope:new("TextLabel"){
		Size = UDim2.fromScale(0.7,0.5);
		BackgroundTransparency = 1;
		Text = _Time(duration);
		TextScaled = true;
		Parent = frame;
		Position = UDim2.fromScale(0.425,0.5);
		AnchorPoint = Vector2.new(0.5,0.5);
		TextColor3 = Color3.fromRGB(255,255,255);
		Name = "DurationLabel";
		Font = Enum.Font.SourceSansSemibold;
	}
end


local function addElementToList(ElementData)
	if(gui.RefPotionImageById[ElementData.ElementType]) then
		local screenGui = Players.LocalPlayer.PlayerGui:FindFirstChild("Inventory")
		local mainframe = screenGui:WaitForChild("Canvas"):WaitForChild("InventoryFrame")
		local scrollingFrame = mainframe:FindFirstChildOfClass("ScrollingFrame")
		if(scrollingFrame:FindFirstChild(ElementData.ElementName)) then
			local amount : IntValue
			if(not scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount")) then
				amount = Instance.new("IntValue",scrollingFrame:FindFirstChild(ElementData.ElementName))
				amount.Value = 2;
				amount.Name = "Amount"
			else
				amount = scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount")
				amount.Value += 1;
			end 
			local label = scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Frame"):FindFirstChild(ElementData.ElementName)
			label.Text = ElementData.ElementName .. `(x{amount.Value})`
			return
		end
		local frame = Scope:new("Frame"){
			Parent = scrollingFrame;
			Name = `{ElementData.ElementName}`;
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
		Scope:new("UIStroke"){Parent = sub;Color = gui.RefPotionColorById[ElementData.ElementType],Thickness = 3}	
		local Image = Scope:new("ImageLabel"){
			Size = UDim2.fromScale(0.5,0.5);
			Position = UDim2.fromScale(0.5,0.475);
			Parent = sub;
			BackgroundTransparency = 1;
			Name = "Image";
			AnchorPoint = Vector2.new(0.5,0.5);
		}	
		Image.Image = gui.RefPotionImageById[ElementData.ElementType]
		local label = Scope:new("TextLabel"){
			Size = UDim2.fromScale(1,0.175);
			Parent = sub;
			Text = frame.Name;
			TextScaled = true;
			BackgroundTransparency = 1;
			Font = Enum.Font.SourceSansSemibold;
			Position = UDim2.fromScale(0.5,0.1);
			AnchorPoint = Vector2.new(0.5,0.5);
			Name = ElementData.ElementName;
		}
		local upgrade = Scope:new("TextButton"){
			Size = UDim2.fromScale(0.8,0.2);
			Parent = sub;
			Text = `Use`;
			TextScaled = true;
			TextColor3 = Color3.fromRGB(255,255,255);
			BackgroundTransparency = 0;
			BackgroundColor3 = Color3.fromRGB(170, 255, 127);
			Font = Enum.Font.SourceSansSemibold;
			Position = UDim2.fromScale(0.5,0.85);
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
				local amount : IntValue
				if(not screenGui:FindFirstChild("PotionList")) then
					ElementData.Parent = screenGui
					initPotionListFrame(ElementData)
				end
				if(not scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount")) then
					Packets.UsePotion:Fire(ElementData)
					frame:Destroy()
				elseif(scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount").Value > 1) then
					amount = scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount")
					amount.Value -= 1;
					label.Text = ElementData.ElementName .. `(x{amount.Value})`
					Packets.UsePotion:Fire(ElementData)
				else
					amount = scrollingFrame:FindFirstChild(ElementData.ElementName):FindFirstChild("Amount")
					amount.Value -= 1;
					frame:Destroy()
					Packets.UsePotion:Fire(ElementData)
				end
			end,
		}
		Scope:new("UIScale"){Parent = upgrade,Scale = 1};
		Scope:new("UICorner"){Parent = upgrade};
		return frame;
	else
		return
	end
end

gui.RefPotionImageById = {
	DoubleIncomePotion = "rbxassetid://99340282332020";
}

gui.RefPotionColorById = {
	DoubleIncomePotion = Color3.fromRGB(93, 0, 139)
}

gui.Construct = function(self,state)
	if(self.State == "Constructed") then return self:Destroy() end
	if(not self.Gui) then
		self.Gui = initInventoryGui()
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0.5,0.6),GroupTransparency = 0}):Play()
	else
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0.5,0.6),GroupTransparency = 0}):Play()
	end	
	self.State = "Constructed"
end

gui.Destroy = function(self)
	if(self.Gui) then
		TweenService:Create(self.Gui:FindFirstChild("Canvas"),TweenInfo.new(0.5),{Size = UDim2.fromScale(0,0.6),GroupTransparency = 1}):Play()
	end
	if(self.State == "Constructed") then self.State = nil end
	return self	
end

gui.AddObjectToList = function(self,ElementData)
	if(not self.Gui) then self.Gui = initInventoryGui() end
	addElementToList(ElementData)
end

gui.AddPotionToList = function(self,type,duration)
	if(not self.Gui) then self.Gui = initInventoryGui() end
	if(not self.Gui:FindFirstChild("PotionList")) then initPotionListFrame({Parent = self.Gui}) end
	if(duration <= 0) then return end
	local frame = addPotionDurationFrame(type,duration)	
	if(frame) then
		frame:FindFirstChild("DurationLabel").Text = _Time(duration)
	end	
end

gui.RemovePotionFromList = function(self,type)
	if(not self.Gui) then self.Gui = initInventoryGui() end
	if(not self.Gui:FindFirstChild("PotionList")) then initPotionListFrame({Parent = self.Gui}) end
	if(self.Gui:FindFirstChild("PotionList"):FindFirstChild(type)) then
		self.Gui:FindFirstChild("PotionList"):FindFirstChild(type):Destroy()
	end
end

return gui