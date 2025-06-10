local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")

export type Spawn = {Pos : Vector3,player : Player}

local Services = script.Parent.Parent.Services

local Friends = require(ReplicatedStorage.Utils.Friends)
local Collision = require(ReplicatedStorage.Utils.Collision)
local GlobalInstanceComponent = require(ReplicatedStorage.Components.GlobalInstanceComponent)
local DataStoreService = require(Services.DataStoreService)

local MIN_TIME = 3
local MAX_TIME = 7;

local RESPAWN_MIN_TIME = 3;
local RESPAWN_MAX_TIME = 7;

local function BuildRig(parent)
	local Rig = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Clients").Rig:Clone()
	Rig.Parent = parent
	return Rig
end

local module = {}
module.__index = module

module.Spawn = function(v : Spawn)
	if(v[1]) then v.Pos = v[1] v[1] = nil end
	if(v[2]) then v.player = v[2] v[2] = nil end
	if(not v.Pos or not v.player) then return end
	local player = v.player
	local TycoonComponent = require(script.Parent.TycoonComponent)
	local tycoon = TycoonComponent.Get(TycoonComponent,player)
	if(not tycoon) then return end
	local rig : Model = BuildRig(tycoon.Parent)
	rig:PivotTo(CFrame.new(v.Pos))
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
		Friends.LoadHumanoidDescriptionToRig(rig,humanoidDescription)
		rig.Name = Players:GetNameFromUserIdAsync(getRandomUser.Id)
		Collision.setPartToCollisionGroup(rig:GetDescendants(),"RigCollisionGroup")
	end,function(err) 
		warn(err,debug.info(2,"sl"))
	end)
	local Items = GlobalInstanceComponent.Folder.Get(`Items{player.Name}`,tycoon.Parent)
	local Desks = {}
	for i,item in pairs(Items:GetChildren()) do
		if(item.Name == "Desk") then
			if(item:FindFirstChild("IsOccupied")) then continue end
			table.insert(Desks,item)
		elseif(string.find(item.Name,"Desk")) then
			if(item:FindFirstChild("IsOccupied")) then continue end
			table.insert(Desks,item)
		end
	end
	if(#Desks <= 0) then
		rig:Destroy()
		return
	end
	local desk : Model = Desks[math.random(1,#Desks)]
	local path : Path = PathfindingService:CreatePath({
		AgentCanJump = true
	})
	local posA,posB = rig:GetPivot().Position,desk:FindFirstChild("MoveToManager"):FindFirstChild("Attachment").WorldPosition
	path:ComputeAsync(posA,posB)
	if(path.Status == Enum.PathStatus.Success) then
		local waypoints = path:GetWaypoints()
		local idleAnimationTrack = rig:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(
			ReplicatedStorage.Emotes.Idle
		)
		local walkAnimationTrack = rig:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(
			ReplicatedStorage.Emotes.Walk
		)
		walkAnimationTrack.Looped = true
		walkAnimationTrack:Play()
		task.defer(function()
			for _,waypoint in pairs(waypoints) do
				rig:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
				rig:FindFirstChildOfClass("Humanoid").MoveToFinished:Wait()
			end
			walkAnimationTrack.Looped = false
			walkAnimationTrack:Stop()
			idleAnimationTrack:Play()
			local getManager = desk:FindFirstChildOfClass("Model")
			if(not getManager) then return end
			table.insert(tycoon.Clients,rig)
			local IsOccupied = Instance.new("BoolValue",desk)
			IsOccupied.Name = "IsOccupied"
			IsOccupied.Value = true;
			local chatEffect = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Clients").ChatEffect:Clone()
			local chatEffectB = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Clients").ChatEffect:Clone()
			chatEffect.Parent = rig.Head
			chatEffect.CFrame = CFrame.new(rig.Head.Position + Vector3.new(0,2,0))
			chatEffect.CanCollide = false
			chatEffect.Anchored = true
			chatEffectB.Parent = getManager.Head
			chatEffectB.CFrame = CFrame.new(getManager.Head.Position + Vector3.new(0,2,0))
			chatEffectB.CanCollide = false
			chatEffectB.Anchored = true
			local sound = SoundService["Success sound"]:Clone()
			sound.Parent = getManager.Head
			task.delay(tycoon.Managers[getManager.Name].Time,function()
				if(tycoon.Managers[getManager.Name].ChanceToFail >= math.random(1,100)) then
					chatEffectB:Destroy()
					IsOccupied:Destroy()
					chatEffect.Attachment.ParticleEmitter.Texture = "rbxassetid://10559008770"
					sound.SoundId = "rbxassetid://154157312"
					sound:Play()
					sound.Ended:Once(function() sound:Destroy() end) 
					task.delay(3,function()
						chatEffect:Destroy()
						module.Destroy(module,v,rig)
					end)
					return
				end
				sound:Play()
				sound.Ended:Once(function() sound:Destroy() end) 
				chatEffect:Destroy()
				chatEffectB:Destroy()
				IsOccupied:Destroy()
				local cashEarning = tycoon.Managers[getManager.Name].CashEarning
				if(tycoon.Managers[getManager.Name].TipsChance >= math.random(1,100)) then
					cashEarning *= 2
				end
				local dataStore = DataStoreService.GetDataStore(player)
				local orderedDataStoreObject = DataStoreService.GetOrderedDataStore(player)
				if(not dataStore or not orderedDataStoreObject) then return end
				if(script.Parent.Potions.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotion")) then
					local isActive = script.Parent.Potions.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotion")
					if(isActive.Value == true) then
						dataStore.Value.Cash += tonumber(cashEarning) * 2
					else
						dataStore.Value.Cash += tonumber(cashEarning)
					end
				else
					dataStore.Value.Cash += tonumber(cashEarning)
				end
				orderedDataStoreObject.Value = dataStore.Value.Cash
				player.leaderstats.Cash.Value = dataStore.Value.Cash
				module.ToRoom(module,v,rig)
			end)
		end)
	else
		print(path.Status)
	end
end

module.ToRoom = function(self,v : Spawn, rig : Model)
	if(not v.player or not v.Pos or not rig) then return end
	self.Destroy(self,v,rig)
end

module.Destroy = function(self,v : Spawn, rig : Model)
	if(not v.player or not v.Pos or not rig) then return end
	local player = v.player
	local TycoonComponent = require(script.Parent.TycoonComponent)
	local tycoon = TycoonComponent.Get(TycoonComponent,player)
	if(table.find(tycoon.Clients,rig)) then
		table.remove(tycoon.Clients,table.find(tycoon.Clients,rig))
	end
	if(rig) then rig:Destroy() end
	task.delay(math.random(RESPAWN_MIN_TIME,RESPAWN_MAX_TIME),module.Spawn,{v.Pos,v.player})
end

return module
