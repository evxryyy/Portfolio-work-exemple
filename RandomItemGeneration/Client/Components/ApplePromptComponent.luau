--!strict

export type ApplePromptStruct = {
	Prompt : ProximityPrompt,
	SetProximityPromptProps : (self : ApplePromptStruct,props : {PROPS_NAME : {Value : any}}) -> ();
	Destroy : (self : ApplePromptStruct) -> ();
}

local Constructor = {}
Constructor.__index = Constructor

local ApplePromptComponent = {}
ApplePromptComponent.__index = ApplePromptComponent

Constructor.new = function(promptParent : Instance) : ApplePromptStruct
	local self = setmetatable({
		Prompt = Instance.new("ProximityPrompt",promptParent)
	},ApplePromptComponent)
	return self
end

ApplePromptComponent.SetProximityPromptProps = function(self : ApplePromptStruct,props : {PROPS_NAME : {Value : any}}) : ()
	if(not props or type(props) ~= "table") then return end
	if(not self.Prompt) then return end
	for i,property in pairs(props) do
		if(self.Prompt[i]) then
			self.Prompt[i] = property.Value
		else
			warn("Property not found in ProximityPrompt: ",i)
		end
	end
end

ApplePromptComponent.Destroy = function(self : ApplePromptStruct)
	if(not self.Prompt) then
	else
		self.Prompt:Destroy()
	end
	table.clear(self)
	setmetatable(self,nil)
end


return table.freeze(Constructor)
