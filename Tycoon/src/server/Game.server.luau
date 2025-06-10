local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")

local Components = script.Parent.Components
local Services = script.Parent.Services
local Utils = script.Parent.Utils

local TycoonComponent = require(Components.TycoonComponent)
local Packets = require(ReplicatedStorage.Packages.Packets)
local GlobalInstanceComponent = require(ReplicatedStorage.Components.GlobalInstanceComponent)
local DataStoreService = require(Services.DataStoreService)
local Settings = require(Utils.Settings)
local PotionsComponent = require(Components.PotionsComponent)

local tycoons_data = {}
local tycoons_name_data = {}
local tycoonsAvailables = {}

for i,tycoon in pairs(workspace.Templates:GetChildren()) do
	if(tycoon:FindFirstChildOfClass("Folder")) then continue end
	table.insert(tycoonsAvailables,tycoon)
end

local function CreateTycoon(player : Player,part : BasePart)
	if(not part) then return end
	local tycoon = TycoonComponent.Create(player,function() : {any} 	
		return {
			StudsOffset = Vector3.new(0,50,0);
			Size = UDim2.fromScale(5,5);
			Brightness = 1;
			AlwaysOnTop = false;
			Name = player.Name;
			Parent = part;
			Adornee = part
		}
	end)
	if(table.find(tycoonsAvailables,part)) then
		table.remove(tycoonsAvailables,table.find(tycoonsAvailables,part))
		local InstanceToString = {}
		for i,part in pairs(tycoonsAvailables) do	
			table.insert(InstanceToString,part.Name)
		end
		table.insert(InstanceToString,part.Name)
		for i,plr in pairs(Players:GetPlayers()) do
			if(plr == player) then
				Packets.RemoveArrowFromPlayer:FireClient(player,InstanceToString)
			else
				Packets.RemoveArrowFromPlayer:FireClient(plr,{part.Name})
			end
		end
	end
	Packets.LoadUiComponentPacket:FireClient(player)
	return tycoon
end

local function DeleteTycoon(player)
	local getTycoon = TycoonComponent.Get(TycoonComponent,player)
	local datastore = DataStoreService.GetDataStore(player)
	if(getTycoon) then
		TycoonComponent.Delete(TycoonComponent,player)
		table.insert(tycoonsAvailables,getTycoon.Parent)
	end
	local InstanceToString = {}
	for i,part in pairs(tycoonsAvailables) do
		table.insert(InstanceToString,part.Name)
	end
	for i,plr in pairs(Players:GetPlayers()) do
		if(TycoonComponent.Get(TycoonComponent,plr)) then continue end
		Packets.CreateArrowForPlayer:FireClient(plr,InstanceToString);
	end
	for i,activesPotions in pairs(Components.Potions.DoubleIncomeActivesPotions:GetChildren()) do
		if(string.match(activesPotions.Name,player.Name)) then
			local getActivePotion = PotionsComponent.DoubleIncomePotion.Get(player)
			if(getActivePotion.PotionInitialized) then
				getActivePotion.PotionInitialized.StopUsage(player)
				if(getActivePotion.DurationObserver) then
					getActivePotion.DurationObserver:stopObserver()
				end
				table.clear(getActivePotion)
				getActivePotion = nil
			end
			if(datastore) then
				datastore.Value[activesPotions.Name] = activesPotions.Value
			end
			activesPotions:Destroy()
		end
	end
	TycoonComponent.Delete(TycoonComponent,player)
	DataStoreService.OnPlayerRemoving(player)
end

Players.PlayerAdded:Connect(function(player: Player)
	local data = DataStoreService.OnPlayerAdded(player)
	print(data.Value)
	data.Value.Cash = 0
	local InstanceToString = {}
	for i,part in pairs(tycoonsAvailables) do
		table.insert(InstanceToString,part.Name)
	end
	if(not data.Value.AlreadyJoined) then
		task.delay(2,function()
			Packets.StartTutorialPacket:FireClient(player)
		end)	
	end
	task.delay(2,function()
		Packets.CreateArrowForPlayer:FireClient(player,InstanceToString);
		if(not data.Value.Potions) then
			Packets.AddInventoryElementToPlayer:FireClient(player,{
				ElementName = "x2 Cash Potion",
				ElementType = "DoubleIncomePotion";
			})
			Packets.AddInventoryElementToPlayer:FireClient(player,{
				ElementName = "x2 Cash Potion",
				ElementType = "DoubleIncomePotion";
			})
			data.Value.Potions = {}
			data.Value.Potions["DoubleIncomePotion"] = 2
		else
			if(data.Value.Potions["DoubleIncomePotion"]) then
				local name = "2x Cash Potion"
				local type = "DoubleIncomePotion"
				for i = 1,data.Value.Potions["DoubleIncomePotion"] do
					Packets.AddInventoryElementToPlayer:FireClient(player,{
						ElementName = name,
						ElementType = type
					})
				end
			end
		end
		task.spawn(function()
			xpcall(function()
				local data = DataStoreService.GetDataStore(player)
				if(not data) then return end
				for i,potionDurationValue in pairs(data.Value) do
					if(i == player.Name.."DoubleIncomePotionDuration") then
						local getValue = potionDurationValue
						local potionCount = math.ceil(getValue/30)
						for i = 1,potionCount do
							PotionsComponent.DoubleIncomePotion.new(player):Activate()
						end
					end
				end
			end,warn)
		end)
	end)
end)

Players.PlayerRemoving:Connect(DeleteTycoon)

game:BindToClose(function()
	for i,player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			DeleteTycoon(player)
		end)
	end
	while(next(Players:GetPlayers()) ~= nil) do task.wait() end
end)

for i,part in pairs(CollectionService:GetTagged("Tycoons")) do
	if(part) then
		tycoons_data[part.Name] = {}
		table.insert(tycoons_data[part.Name],part.Touched:Connect(function(hit : BasePart)
			if(not hit.Parent) then return end
			local character = hit.Parent
			if(not Players:GetPlayerFromCharacter(character)) then return end
			local player = Players:GetPlayerFromCharacter(character)
			if(TycoonComponent.Get(TycoonComponent,player)) then return end
			if(part:FindFirstChildOfClass("ObjectValue")) then return end
			print("Tycoon created for :",player,"at ",part.Name)
			CreateTycoon(player,part)
		end))
	end
end

Packets.ButtonIsPurchased.OnServerEvent:Connect(function(player: Player, info: { Item: string, Price: number, Type: string }) 
	if(not player or not info) then return end
	local leaderstats = player:WaitForChild("leaderstats")
	local tycoon = TycoonComponent.Get(TycoonComponent,player)
	if(not tycoon) then return end
	local PurchasedItem = workspace.Default.Items:FindFirstChild(info.Item)
	if(not PurchasedItem) then return end
	local dataStore = DataStoreService.GetDataStore(player)
	local orderedDataStoreObject = DataStoreService.GetOrderedDataStore(player)
	if(not dataStore or not orderedDataStoreObject) then return end
	dataStore.Value.Cash -= tonumber(info.Price)
	orderedDataStoreObject.Value = dataStore.Value.Cash
	leaderstats.Cash.Value = dataStore.Value.Cash
	local cloneItem = PurchasedItem:Clone()
	cloneItem.Parent = GlobalInstanceComponent.Folder.Get(`Items{player.Name}`)
	local relativeButtonCFrame = workspace.Default.Tycoon1.CFrame:ToObjectSpace(cloneItem:GetPivot())
	local worldCFrameOfNewPlot = tycoon.Parent.CFrame:ToWorldSpace(relativeButtonCFrame)
	cloneItem:PivotTo(worldCFrameOfNewPlot)
	if(string.find(cloneItem.Name,"Desk") or cloneItem.Name == "Desk") then
		TycoonComponent.AddManagerToPlayer(TycoonComponent,player,cloneItem:FindFirstChild("Manager"))
	end
	tycoon.CashPerPurchasedItem += 1
	tycoon.Index += 1
	local nextButtons = {}
	for i,Buttons in pairs(workspace.Default.Buttons:GetChildren()) do
		if(GlobalInstanceComponent.Folder.Get(`Items{player.Name}`):FindFirstChild(Buttons:GetAttribute("Item"))) then continue end
		if(Buttons:GetAttribute("Index") > tycoon.Index) then continue end
		if(GlobalInstanceComponent.Folder.Get(`Buttons{player.Name}`):FindFirstChild(Buttons.Name)) then continue end
		local button = Buttons:Clone()
		button.Parent = GlobalInstanceComponent.Folder.Get(`Buttons{player.Name}`)
		local relativeButtonCFrame = workspace.Default.Tycoon1.CFrame:ToObjectSpace(Buttons:GetPivot())
		local worldCFrameOfNewPlot = tycoon.Parent.CFrame:ToWorldSpace(relativeButtonCFrame)
		button:PivotTo(worldCFrameOfNewPlot)
		for i,part in pairs(button:GetDescendants()) do
			if(part:IsA("BasePart")) then 
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = true
				part.Transparency = 1 
			end
		end
		table.insert(nextButtons,button)
		task.wait()
	end
	if(#nextButtons <= 0) then return end
	local strings = {}
	for i,child in pairs(nextButtons) do
		table.insert(strings,child.Name)
	end
	xpcall(function(...) 
		Packets.AnimateModelPacket:FireClient(player,strings)
	end,function(err) 
		warn(err)
	end)
	table.clear(nextButtons)
end)

--Destroy button on purchase

Packets.DestroyButtonOnPurchase.OnServerEvent:Connect(function(a0: Player, a1: Instance) 
	if(not a0 or not a1) then return end
	a1:Destroy()	
end)

Packets.GetTycoonPacket.OnServerInvoke = function(player : Player)
	if(not player) then return end
	return TycoonComponent.Get(TycoonComponent,player).Parent
end

Packets.GetLeaderboardPagesPacket.OnServerInvoke = function(player : Player)
	if(not player) then return end
	local pages = {}
	local sortedAsync = DataStoreService.OrderedDataStoreInstance.SortAsync(
		DataStoreService.OrderedDataStoreInstance,
		false,
		100
	)
	while(true) do
		for i,data in pairs(DataStoreService.OrderedDataStoreInstance.GetCurrentPage(sortedAsync)) do
			if(pages[data.key]) then continue end
			pages[data.key] = data.value
		end
		DataStoreService.OrderedDataStoreInstance.AdvanceToNextPageAsync(sortedAsync)
		if(sortedAsync.IsFinished == true) then
			break
		end
		task.wait()	
	end
	return pages
end

Packets.IsSettingPacket.OnServerInvoke = function(player : Player,setting_name : string)
	if(not player) then return false end
	if(table.find(Settings,setting_name)) then return true end
	return false	
end

Packets.AddSettingToDataStorePacket.OnServerEvent:Connect(function(player: Player, setting: string,state : any) 
	if(not player or not setting) then return false end
	local getStorage = DataStoreService.GetDataStore(player)
	if(not getStorage) then return false end
	if(not getStorage.Value.Settings) then getStorage.Value.Settings = {} end
	if(table.find(getStorage.Value.Settings,setting)) then
		table.remove(getStorage.Value.Settings,table.find(getStorage.Value.Settings,setting))
	end
	getStorage.Value.Settings[setting] = state	
	return true
end)

Packets.GetDataStoreSettingsPacket.OnServerInvoke = function(player : Player)
	if(not player) then return end
	local getStorage = DataStoreService.GetDataStore(player)
	if(not getStorage) then return false end
	if(not getStorage.Value) then return false end
	if(not getStorage.Value.Settings) then return false end
	return getStorage.Value.Settings
end

Packets.UpdateWorkerPacket.OnServerInvoke = function(player : Player,WorkerData)
	if(not player or not WorkerData) then return end
	local dataStore = DataStoreService.GetDataStore(player)
	local orderedDataStoreObject = DataStoreService.GetOrderedDataStore(player)
	if(not dataStore or not orderedDataStoreObject) then return end
	local tycoon = TycoonComponent.Get(TycoonComponent,player)
	if(not tycoon) then return end
	if(not tycoon.Managers[WorkerData.Id]) then return end
	local managerData = tycoon.Managers[WorkerData.Id]
	if(managerData.Level >= 3) then return end
	if(dataStore.Value.Cash < tycoon.Managers[WorkerData.Id].UpgradeCost) then return end
	dataStore.Value.Cash -= tonumber(tycoon.Managers[WorkerData.Id].UpgradeCost)
	orderedDataStoreObject.Value = dataStore.Value.Cash
	player:FindFirstChild("leaderstats").Cash.Value = dataStore.Value.Cash
	local newData = managerData
	newData.Time -= 1.5;
	newData.CashEarning += 5;
	newData.ChanceToFail -= 7.5;
	newData.UpgradeCost += 120;
	newData.Level += 1
	newData.__sub = {
		Instance = tycoon.Managers[WorkerData.Id].__sub.Instance;
		ParentOfInstance = tycoon.Managers[WorkerData.Id].__sub.Instance.Parent;
	}
	managerData = newData
	tycoon.Managers[WorkerData.Id] = managerData;
	local effect = ReplicatedStorage.Assets.Games.UpgradeEffect:Clone()
	effect.Parent = newData.__sub.Instance.PrimaryPart
	effect.CFrame = newData.__sub.Instance.Head.CFrame
	effect.Anchored = true
	effect.CanCollide = false
	effect.Transparency = 1;
	effect.Name = game:GetService("HttpService"):GenerateGUID(false)
	Debris:AddItem(effect,1.25);
	task.delay(0.05,function()
		for i,vfx in pairs(effect.Main:GetChildren()) do
			if(vfx:IsA("ParticleEmitter")) then
				vfx:Emit(vfx:GetAttribute("EmitCount"))
			end
		end
	end)
	return tycoon.Managers[WorkerData.Id];
end

Packets.UsePotion.OnServerEvent:Connect(function(player: Player, data: { ElementName: string, ElementType: string }) 
	if(not player or not data) then return end
	if(PotionsComponent[data.ElementType]) then
		PotionsComponent[data.ElementType].new(player):Activate()
	else
		return
	end
end)