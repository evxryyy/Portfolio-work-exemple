--!strict

export type AppleComponentState = "Running" | "Stopped" | "Constructed" | "Unconstructed"

export type AppleComponent = {
	State : AppleComponentState,
	GetState : (self : AppleComponent) -> AppleComponentState,
	SetState : (self : AppleComponent,StateEnum : AppleComponentState) -> ();
}

local Constructor = {}
Constructor.__index = Constructor

local AppleComponent = {}
AppleComponent.__index = AppleComponent

Constructor.new = function() : AppleComponent
	local self = setmetatable({
		State = "Constructed" :: AppleComponentState
	},AppleComponent)
	return self
end

AppleComponent.GetState = function(self : AppleComponent) : AppleComponentState
	if(not self.State) then return "Unconstructed" end
	return self.State :: AppleComponentState	
end

AppleComponent.SetState = function(self : AppleComponent,StateEnum : AppleComponentState) : ()
	self.State = StateEnum
end 

return table.freeze(Constructor)
