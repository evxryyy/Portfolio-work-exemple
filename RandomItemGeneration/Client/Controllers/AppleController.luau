local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = script.Parent.Parent:WaitForChild("Components")

local Knit = require(ReplicatedStorage.Packages.Knit)

--//Components
local ApplePromptComponent = require(Components.ApplePromptComponent)

--//AppleUtils
local AppleUtils = require(Components.ApplePromptComponent.Utils)

--//Functions

local function __appleTriggered(self,appleToFire : Instance,player : Player)
	if(not player) then return end
	if(not appleToFire) then 
		return warn("No apple to fire")
	end
	self.AppleService.InitApple:Fire(appleToFire)
end

local AppleController = Knit.CreateController({
	Name = script.Name;
	Apples = {};
	ApplesEvents = {};
})

function AppleController:KnitInit()
	self.AppleService = Knit.GetService("AppleService")
end

function AppleController:KnitStart()
	if(not self.AppleService) then return warn("AppleService is not found correctly") end
	for i,apple in workspace:WaitForChild("Apples"):GetChildren() do
		self.Apples[apple] = ApplePromptComponent.new(apple)
		self.Apples[apple]:SetProximityPromptProps({
			RequiresLineOfSight = {Value = false};
			ActionText = {Value = "Pick"};
			ObjectText = {Value = apple.Name};
		})
		self.ApplesEvents[apple] = AppleUtils.SetProximityEvent(self.Apples[apple].Prompt,function(player : Player)
			self.ApplesEvents[apple]:Disconnect()
			self.ApplesEvents[apple] = nil
			self.Apples[apple]:Destroy()
			self.Apples[apple] = nil
			__appleTriggered(self,apple,player)
		end)
	end
	self.Apples.StrictAddedChildConnection = workspace:WaitForChild("Apples").ChildAdded:Connect(function(apple: Instance)
		if(self.Apples[apple]) then return end -- avoid double initialization
		self.Apples[apple] = ApplePromptComponent.new(apple)
		self.Apples[apple]:SetProximityPromptProps({
			RequiresLineOfSight = {Value = false};
			ActionText = {Value = "Pick"};
			ObjectText = {Value = apple.Name};
		})
		self.ApplesEvents[apple] = AppleUtils.SetProximityEvent(self.Apples[apple].Prompt,function(player : Player)
			self.ApplesEvents[apple]:Disconnect()
			self.ApplesEvents[apple] = nil
			self.Apples[apple]:Destroy()
			self.Apples[apple] = nil
			__appleTriggered(self,apple,player)
		end)
	end)
end

return AppleController
