local Utils = {}

Utils.SetProximityEvent = function(ProximityPromptInstance : ProximityPrompt,callback : (player : Player) -> ()) : RBXScriptConnection | unknown
	if(not ProximityPromptInstance or not callback) then return end
	return ProximityPromptInstance.Triggered:Connect(callback)
end

return Utils
