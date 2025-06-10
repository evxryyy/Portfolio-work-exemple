local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local TweenService = game:GetService("TweenService")

local InventoryGuiTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("InventoryGuiTemplate")

local ScreenGui = Players.LocalPlayer.PlayerGui:WaitForChild("InventoryGui")
local Container = ScreenGui:WaitForChild("Container")
local Inventory = Container.Inventory
local ItemsContainer = Container.ItemsContainer
local OrderGroup = Container.OrderGroup

local Icon = require(ReplicatedStorage.Modules.Icon)

export type Backpack = {
    new : () -> Backpack,
    Items : {any},
    AddExternalMetatable : (self : Backpack,external_module : {any}) -> {any};
    RemoveExternalMetatable : (self : Backpack,external_class_name : string) -> nil,
    OnObjectAdded : RBXScriptConnection,
    clean : (self : Backpack) -> nil,
    RenderStepUpdate : RBXScriptConnection,
    Globals : {},
}

local module = {}
module.__index = module
local prototype = {}

function prototype.new()
    local self = {}
    self.Items = {}
    self.Globals = {}
    self.OnObjectAdded = Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child : Instance)

    end)
    self.RenderStepUpdate = RunService.RenderStepped:Connect(function(deltaTime : number)

    end)
    ScreenGui.Enabled  = true
    self.Globals.BackpackIcon = Icon.new();
    self.Globals.BackpackIcon:setName("Backpack")
    self.Globals.BackpackIcon:setImage("rbxassetid://6870729295")
    self.Globals.BackpackIcon:bindToggleKey(Enum.KeyCode.M)
    self.Globals.BackpackIcon:setCaption("Equip items here")
    self.Globals.BackpackIcon:bindEvent("toggled",function()
        SoundService:PlayLocalSound(SoundService["Backpack Equip"])
        if(Inventory.GroupTransparency == 1) then
            TweenService:Create(Inventory,TweenInfo.new(0.2),{GroupTransparency = 0}):Play()
            TweenService:Create(OrderGroup,TweenInfo.new(0.2),{GroupTransparency = 0}):Play()
        else
            TweenService:Create(Inventory,TweenInfo.new(0.2),{GroupTransparency = 1}):Play()
            TweenService:Create(OrderGroup,TweenInfo.new(0.2),{GroupTransparency = 1}):Play()
        end
    end)
    setmetatable(self,module)
    return self
end

function module.clean(self : Backpack)
    if(not self) then return end
    return
end

function module.AddExternalMetatable(self : Backpack,external_module : {any})
    if(not self) then return end
    self.Items[external_module.Name] = external_module
    local order_template = InventoryGuiTemplate.item_order_template:Clone()
    local template = InventoryGuiTemplate.ITEM_NAME:Clone()
    template.Name = external_module.Name
    if(ItemsContainer.ItemCount.Value >= 9) then
        template.Parent = Inventory.Container.ScrollingFrame
        template:SetAttribute("EquipLocked",true)
        order_template.Parent = InventoryGuiTemplate:WaitForChild("AwaitList")
    else
        template.Parent = ItemsContainer
        order_template.Parent = OrderGroup.OrderFrame.ScrollingFrame
        template:SetAttribute("EquipLocked",false)
        ItemsContainer.ItemCount.Value += 1
    end
    template.TextLabel.Text = external_module.key.Name
    template.ImageButton.Image = external_module.icon
    template.MouseEnter:Connect(function()
        if(external_module.equip == false) then
            TweenService:Create(template.UIStroke,TweenInfo.new(0.3),{Transparency = 0}):Play()
        end
        SoundService:PlayLocalSound(SoundService.Mouse_hover)
    end)
    template.MouseLeave:Connect(function()
        if(external_module.equip == false) then
            TweenService:Create(template.UIStroke,TweenInfo.new(0.3),{Transparency = 1}):Play()
        end
    end)
    template.ImageButton.Activated:Connect(function()
        SoundService:PlayLocalSound(SoundService.Click)
        if(template:GetAttribute("EquipLocked") == true) then
            if(ItemsContainer.ItemCount.Value < 9) then
                template.Parent = ItemsContainer
                ItemsContainer.ItemCount.Value += 1
                template:SetAttribute("EquipLocked",false)
                order_template.Parent = OrderGroup.OrderFrame.ScrollingFrame
            else
                warn("Max item detected in top bar")
            end
            return
        end
        external_module:state()
        if(external_module.equip == false) then
            TweenService:Create(template.UIStroke,TweenInfo.new(0.3),{Transparency = 0,Color = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(template.UIStroke,TweenInfo.new(0.3),{Transparency = 0,Color = Color3.fromRGB(130, 188, 147)}):Play()
        end
    end)
    order_template.ImageLabel.Image = external_module.icon
    order_template.TextLabel.Text = external_module.Name
    order_template.TextButton.Activated:Connect(function()
        SoundService:PlayLocalSound(SoundService.Click)
        if(template.Parent == ItemsContainer) then
            template.Parent = Inventory.Container.ScrollingFrame
            if(external_module.equip == true) then
                external_module:state()
            end
            template:SetAttribute("EquipLocked",true)
            ItemsContainer.ItemCount.Value -= 1
            order_template.Parent = InventoryGuiTemplate:WaitForChild("AwaitList")
        else
            return
        end
    end)
    return self.Items[external_module.Name]
end

function module.RemoveExternalMetatable(self : Backpack,external_class_name : string)
    if(not self or not external_class_name) then return end
    return
end
return prototype
