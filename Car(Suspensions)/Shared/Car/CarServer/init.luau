local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Types = require(script.Types)
local Utils = require(script.Utils)

local Constructor = {}
Constructor.__index = Constructor

local CarServer = {}
CarServer.__index = CarServer

function Constructor.InitCar<CarServerConstructor>(CarToSpawn : Model) : Types.CarServerConstructor 
	if(not CarToSpawn) then
		error("Please specify a car to init.",2)
	end
	local self = setmetatable({
		CarInit = CarToSpawn;
		LastVehicleSeatOccupant = nil;
		CurrentVehicleSeatOccupant = nil;
		DefaultTorque = CarToSpawn:FindFirstChildOfClass("VehicleSeat").Torque;
		SpringConstraintInstance = Utils.FindSpringConstraints(CarToSpawn);
		HingeConstraintInstance = Utils.FindHingeConstraints(CarToSpawn);
		CylindricalConstraintInstance = Utils.FindCylindricalConstraints(CarToSpawn);
		WeldConstraintInstance = Utils.FindWeldConstraints(CarToSpawn);
		NoCollisionConstraintInstance = Utils.FindNoCollisionConstraints(CarToSpawn);
	},CarServer)
	CarToSpawn:FindFirstChildOfClass("VehicleSeat"):SetAttribute("DefaultTorque",self.DefaultTorque)
	return self
end

function CarServer.SetDefaultTorque(self : Types.CarServerConstructor,Torque : number)
	if(not Torque or type(Torque) ~= "number") then return end
	local vehicleSeat = self.CarInit:FindFirstChildOfClass("VehicleSeat")
	if(not vehicleSeat) then return end
	vehicleSeat.Torque = Torque
	vehicleSeat:SetAttribute("DefaultTorque",Torque)
	self.DefaultTorque = Torque
end

function CarServer.SetOwnership(self : Types.CarServerConstructor ,player : Player?)
	if(not self.CarInit) then return end
	local vehicleSeat = self.CarInit:FindFirstChildOfClass("VehicleSeat")
	if(not vehicleSeat) then
		return warn("No vehicleSeat found no ownership will be set.")
	end
	if(player) then
		self.CarInit:SetAttribute("Ownership",player.UserId)
	else
		self.CarInit:SetAttribute("Ownership",player) -- if null then it means that is now controlled by the server and not any player.
	end
	vehicleSeat:SetNetworkOwner(player)
end

function CarServer.OnSitEvent(self : Types.CarServerConstructor, callback : (newOccupant : Humanoid?) -> ())
	if(not self.CarInit) then return end
	if(not callback) then
		error("a callback must be provided.")
	end
	local vehicleSeat = self.CarInit:FindFirstChildOfClass("VehicleSeat")
	if(not vehicleSeat) then error("A VehicleSeat must be provided inside the CarModel") end
	local ObjectValue = Instance.new("ObjectValue",vehicleSeat)
	ObjectValue.Name = "OccupantObject"
	ObjectValue.Value = nil
	self.SitEventConnection =  vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function(...: any)
		self.LastVehicleSeatOccupant = ObjectValue.Value
		ObjectValue.Value = vehicleSeat.Occupant
		self.CurrentVehicleSeatOccupant = vehicleSeat.Occupant
		callback(vehicleSeat.Occupant)
	end)
	return self.SitEventConnection
end

function CarServer.Destroy(self : Types.CarServerConstructor,DestroyModel : boolean)
	if(typeof(self.SitEventConnection) == "RBXScriptConnection") then
		self.SitEventConnection:Disconnect()
	end
	if(DestroyModel) then self.CarInit:Destroy() end
	self.SitEventConnection = nil
	table.clear(self)
	setmetatable(self,nil)
end

return table.freeze(Constructor)
