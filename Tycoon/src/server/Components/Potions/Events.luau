local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Race = require(ReplicatedStorage.Packages.Race)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Scope = Fusion.scoped({
	Value = Fusion.Value;
	Observer = Fusion.Observer;
	Event = Fusion.OnEvent;
})

local module = {}
module.__index = module

module.newObserver = function(value : ValueBase,observerCallback : () -> any | {any})
	if(not value or not observerCallback) then return end
	local self = setmetatable({},module)
	self.value = Scope:Value(value)
	self.observer = Scope:Observer(self.value)
	self.connectedObserverCallback = self.observer:onChange(observerCallback,self.value)
	return self
end

module.stopObserver = function(self)
	if(not self.observer) then return end
	if(not self.connectedObserverCallback) then return end
	self.connectedObserverCallback()
	setmetatable(self,nil)
	self = nil
	return
end

return module
