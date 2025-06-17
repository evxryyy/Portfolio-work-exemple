local RunService = game:GetService("RunService")

if(RunService:IsServer()) then
	return require(script.CarServer)
elseif(RunService:IsClient()) then
	return require(script.CarClient)
end
