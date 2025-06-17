local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

--//Components
local AppleStateComponent = require(script.Parent.Parent.Components.AppleStateComponent)

local RandomClass = Random.new()
local MaxGeneratedApples = 12 -- Max apple generation

local AppleService = Knit.CreateService({
	Name = script.Name;
	Apples = {};
	CurrentThreadForApples = nil;
	Client = {
		InitApple = Knit.CreateSignal();	
	};
	AppleState = AppleStateComponent.new()
})

function AppleService:KnitInit() 	
	self.AppleState:SetState("Running")
	self:ConnectInitedAppleRemote()
end

function AppleService:KnitStart()
	self.CurrentThreadForApples = task.spawn(function()
		local appleToGenerate = 5 -- current amount of apple to generate.
		local nextOperationShouldSubstractAppleGeneration = false
		while true do
			if(self.AppleState:GetState() == "Stopped") then break end -- making sure that when we cancel the thread the loop will close.
			if(#self.Apples >= MaxGeneratedApples) then task.wait() continue end
			if(nextOperationShouldSubstractAppleGeneration) then 
				appleToGenerate = MaxGeneratedApples - #self.Apples -- update the current amount (e.g if 10 apple and max is 12 then appleToGenerate is 2)
				nextOperationShouldSubstractAppleGeneration = false
			end
			if(appleToGenerate <= 0) then task.wait() continue end
			for i = 1,appleToGenerate do
				local apple = ReplicatedStorage.Assets.apple:Clone()
				apple.Parent = workspace.Apples
				apple.CFrame = CFrame.new(
					RandomClass:NextInteger(-50,50),
					10,
					RandomClass:NextInteger(-50,50)
				)
				table.insert(self.Apples,apple)
			end
			if(appleToGenerate < #self.Apples) then
				nextOperationShouldSubstractAppleGeneration = true
			end
			task.wait(5)
		end
	end)
end

function AppleService:ConnectInitedAppleRemote()
	return self.Client.InitApple:Connect(function(player,takenAppleInstance : PVInstance)
		if(not table.find(self.Apples,takenAppleInstance)) then return end
		table.remove(self.Apples,table.find(self.Apples,takenAppleInstance))
		takenAppleInstance:Destroy()
	end)
end

function AppleService:StopApplesThread()
	if(self.CurrentThreadForApples) then
		local s,e = pcall(task.cancel,self.CurrentThreadForApples)
		self.AppleState:SetState("Stopped")
		if(not s) then return false end
		return true
	end
	return false
end

return AppleService
