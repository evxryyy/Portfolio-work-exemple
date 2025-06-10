local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local Types = require(script.Parent.ButtonsTypes)
local Packets = require(ReplicatedStorage.Packages.Packets)
local Signal = require(ReplicatedStorage.Packages.Signal)

local function searchButtonFromName(name : string)
	if(not name) then return end
	local button = nil
	for i,item in pairs(workspace:GetDescendants()) do
		if(item.Name == name) then
			button = item
			break
		elseif(string.find(item.Name,name)) then
			button = item
			break
		end
	end
	return button
end

local module = {}
module.__index = {}

function module:Construct(Button : Instance | string) 
	if(not Button) then return end
	if(type(Button) == "string") then
		Button = searchButtonFromName(Button)
	end
	if(not Button) then return end
	local part = Button:WaitForChild("Button")
	if(not part) then
		warn(
			"Could not find `Button` part from ",
			if(type(Button) == "string") then Button else Button.Name,
			debug.traceback("Path not valid",2)
		)
		return
	end
	local itemPurchasedSignal = Signal.new()
	local touchEvent = part.Touched:Connect(function(hit : BasePart)
		if(not hit.Parent) then return end
		if(not Players:GetPlayerFromCharacter(hit.Parent)) then return end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		local getPrice = Button:GetAttribute("Price")
		if(tonumber(getPrice) <= player:WaitForChild("leaderstats").Cash.Value) then
			itemPurchasedSignal:Fire()
		else
			SoundService:PlayLocalSound(SoundService.PurchaseFailed)
		end
	end)
	itemPurchasedSignal:Once(function(...: any)
		SoundService:PlayLocalSound(SoundService.ItemPurchased)
		local effect = ReplicatedStorage.Assets.Buttons["ForceField-Break-01"]:Clone()
		effect.Parent = Players.LocalPlayer.Character.PrimaryPart
		effect.CFrame = Players.LocalPlayer.Character:GetPivot()
		effect.Anchored = true
		effect.CanCollide = false
		effect.Transparency = 1;
		effect.Name = HttpService:GenerateGUID(false)
		task.spawn(function()
			for i,vfx in pairs(effect.Main:GetChildren()) do
				if(vfx:IsA("ParticleEmitter")) then
					vfx:Emit(vfx:GetAttribute("EmitCount"))
				end
			end
			Debris:AddItem(effect,1);
		end)
		Packets.ButtonIsPurchased:Fire(self:GetButtonInfo(Button))
		self:Delete(Button)
	end)
end

function module:GetButtonInfo(Button:  Instance | string)
	if(not Button) then return end
	if(type(Button) == "string") then
		Button = searchButtonFromName(Button)
	end
	if(not Button) then return end
	local GetPrice = Button:GetAttribute("Price") or 0
	local Item = Button:GetAttribute("Item") or "Empty"
	local Type = Button:GetAttribute("Type") or "None"
	return {Price = tonumber(GetPrice),Item = Item,Type = Type}
end

function module:Delete(Button:  Instance | string)
	if(not Button) then return end
	if(type(Button) == "string") then
		Button = searchButtonFromName(Button)
	end
	if(not Button) then return end
	Packets.DestroyButtonOnPurchase:Fire(Button)
end

return module :: Types.ButtonNormal
