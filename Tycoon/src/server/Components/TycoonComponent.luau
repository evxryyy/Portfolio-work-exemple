local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Services = script.Parent.Parent.Services

local Packets = require(ReplicatedStorage.Packages.Packets)
local BillboardComponent = require(ReplicatedStorage.Components.BillboardComponent)
local GlobalInstanceComponent = require(ReplicatedStorage.Components.GlobalInstanceComponent)
local CashComponent = require(ReplicatedStorage.Components.CashComponent)
local Friends = require(ReplicatedStorage.Utils.Friends)
local Collision = require(ReplicatedStorage.Utils.Collision)
local DataStoreService = require(Services.DataStoreService)
local ClientsComponent = require(script.Parent.ClientsComponent)

Collision.setCollisionGroupCollidable("RigCollisionGroup","RigCollisionGroup",false)

local module = {}
module.__index = module
module.Tycoons = {}
	
function module.Create(player : Player,callbackForBillboardGui : () -> {any})
	local self = setmetatable({},module)
	self[player] = {
		Parent = callbackForBillboardGui().Parent	;
		CashPerPurchasedItem = 1;
		Index = 1;
		Managers = {}
	}
	module.Tycoons[player] = self[player]
	BillboardComponent.Create(callbackForBillboardGui)
	Collision.setPartToCollisionGroup(player.Character:GetDescendants(),"RigCollisionGroup")
	xpcall(function(...)
		local ImageId = Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420)
		local object : ImageLabel = BillboardComponent.AddImage(BillboardComponent.Get(player.Name),ImageId);
	end,function(err)
		warn(err)
	end)
	local getParent = self[player].Parent
	if(getParent) then
		GlobalInstanceComponent.ObjectValue.Create(player,getParent)
		GlobalInstanceComponent.Folder.Create(`Buttons{player.Name}`,getParent)
		GlobalInstanceComponent.Folder.Create(`Items{player.Name}`,getParent)
		GlobalInstanceComponent.Folder.Create(`Systems{player.Name}`,getParent)
	end
	for i,Buttons in pairs(workspace.Default.Buttons:GetChildren()) do
		if(Buttons:IsA("Model")) then
			if(Buttons:GetAttribute("Index") > self[player].Index) then continue end
			local button = Buttons:Clone()
			button.Parent = GlobalInstanceComponent.Folder.Get(`Buttons{player.Name}`)
			local relativeButtonCFrame = workspace.Default.Tycoon1.CFrame:ToObjectSpace(Buttons:GetPivot())
			local worldCFrameOfNewPlot = getParent.CFrame:ToWorldSpace(relativeButtonCFrame)
			button:PivotTo(worldCFrameOfNewPlot)
			for i,part in pairs(button:GetDescendants()) do
				if(part:IsA("BasePart")) then 
					part.Anchored = true
					part.CanCollide = false
					part.CanTouch = true
					part.Transparency = 1 
				end
			end	
		else
			continue
		end
	end
	local strings = {}
	for i,child in pairs(GlobalInstanceComponent.Folder.Get(`Buttons{player.Name}`):GetChildren()) do
		table.insert(strings,child.Name)
	end
	Packets.AnimateModelPacket:FireClient(player,strings)
	GlobalInstanceComponent.Folder.Create("leaderstats",player)
	local dataStoreObject = DataStoreService.AddToDataStore(player,player:WaitForChild("leaderstats"),"Leaderstats")
	local orderedDataStoreObject = DataStoreService.GetOrderedDataStore(player)
	local CashObject : NumberValue = CashComponent.Create(
		"Cash",
		dataStoreObject.Value.Cash,
		player:WaitForChild("leaderstats")
	)
	orderedDataStoreObject.Value = dataStoreObject.Value.Cash
	task.spawn(function()
		while(player) do
			if(not dataStoreObject) then break end
			if(dataStoreObject.State == nil) then break end
			if(not CashObject) then break end
			if(not self[player]) then break end
			xpcall(function() 
				if(script.Parent.Potions.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotion")) then
					local isActive = script.Parent.Potions.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotion")
					if(isActive.Value == true) then
						dataStoreObject.Value.Cash += (self[player].CashPerPurchasedItem * 2)
					else
						dataStoreObject.Value.Cash += self[player].CashPerPurchasedItem
					end
				else
					dataStoreObject.Value.Cash += self[player].CashPerPurchasedItem
				end
				CashObject.Value = dataStoreObject.Value.Cash
				orderedDataStoreObject.Value = dataStoreObject.Value.Cash
			end,warn)
			task.wait(1) 
		end
	end)
	if(not dataStoreObject.Value.AlreadyJoined) then
		Packets.NewTutorialStepPacket:FireClient(player,"Go now buy your first worker by walking on the button.")
	end
	return self
end

function module.AddManagerToPlayer(self,player : Player,Rig : Model)
	local getTycoon = module.Get(self,player)
	if(not getTycoon) then return end
	if(not Rig) then return end
	local list = Friends.GetFriendListOf(player)
	if(not list) then return end
	local friends = {}
	repeat
		for i,plr in pairs(list:GetCurrentPage()) do
			if(plr.Id == player.UserId) then continue end
			if(plr.Username == "Account Deleted") then continue end
			table.insert(friends,plr)
		end
		if(list.IsFinished == false) then
			list:AdvanceToNextPageAsync()
		end
	until list.IsFinished == true
	local getRandomUser : Player = friends[math.random(1,#friends)]
	xpcall(function(...) 
		local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(getRandomUser.Id)
		Friends.LoadHumanoidDescriptionToRig(Rig,humanoidDescription)
		Rig.Name = Players:GetNameFromUserIdAsync(getRandomUser.Id) .. "/" ..game:GetService("HttpService"):GenerateGUID(false)
		Collision.setPartToCollisionGroup(Rig:GetDescendants(),"RigCollisionGroup")
		getTycoon.Managers[Rig.Name] = {
			Time = 7;
			TipsChance = 2;
			CashEarning = 5;
			ChanceToFail = 35;
			Name = Players:GetNameFromUserIdAsync(getRandomUser.Id);
			Id = Rig.Name;
			Level = 1;
			UpgradeCost = 150;
			__sub = {
				Instance = Rig;
				ParentOfInstance = Rig.Parent;
			}
		}
		local managers = 0
		for i,v in pairs(getTycoon.Managers) do
			if(v) then managers += 1 end
		end
		if(managers <= 1) then
			local dataStoreObject = DataStoreService.GetDataStore(player)
			if(not dataStoreObject.Value.AlreadyJoined) then
				Packets.NewTutorialStepPacket:FireClient(player,
					`Very nice @{player.Name}, you finished the tutorial dont forget to upgrade workers from the tycoon menu on the top right of your screen.`
				)
			end
		end
		if(not getTycoon.Clients) then
			getTycoon.Clients = {}
			ClientsComponent.Spawn({
				getTycoon.Parent:FindFirstChild("Spawn").WorldPosition,
				player
			})	
		end
		Packets.SendNewWorkerData:FireClient(player,getTycoon.Managers[Rig.Name])
		return true
	end,function(err) 
		warn(err)
	end)
	Packets.EmoteRigPacket:FireClient(player,Rig)
	table.clear(friends)
	return true
end

function module.Get(self,player : Player)
	if(self[player]) then return self[player] end
	if(module.Tycoons[player]) then return module.Tycoons[player] end
	return nil
end

function module.Delete(self,player)
	local getClass = self.Get(self,player)
	if(not getClass) then return end
	GlobalInstanceComponent.ObjectValue.Delete(player.Name)
	GlobalInstanceComponent.Folder.Delete(`Buttons{player.Name}`)
	GlobalInstanceComponent.Folder.Delete(`Items{player.Name}`)
	GlobalInstanceComponent.Folder.Delete(`Systems{player.Name}`)
	BillboardComponent.Delete(player.Name)
	table.clear(getClass)
	getClass = nil
	self = nil
	if(module.Tycoons[player]) then module.Tycoons[player] = nil end
end

return module
