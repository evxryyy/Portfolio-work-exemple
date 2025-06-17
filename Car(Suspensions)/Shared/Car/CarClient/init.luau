local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Types = require(script.Types)
local Utils = require(script.Utils)

local Constructor = {}
Constructor.__index = Constructor

local CarClient = {}
CarClient.__index = CarClient

function Constructor.GetCar<CarClientConstructor>(CarModel : Model) : Types.CarClientConstructor
	if(not CarModel) then 
		error("a model must be provided")
	end
	local self = setmetatable({
		__MaxAngularVelocity = Utils.GetMaxAngularVelocity(
			CarModel,
			CarModel:WaitForChild("WheelBR").Size.Y -- you can change the name to your wheel
		);
		__VehicleSeat = Utils.GetVehicleSeat(CarModel);
		WheelFLAttachment = Utils.GetAttachment(CarModel,"WheelFLAttachment"); -- Search your front left wheel attachment
		WheelFRAttachment = Utils.GetAttachment(CarModel,"WheelFRAttachment"); -- Search your front right wheel attachment
		CylindricalBL = Utils.GetCylindrical(CarModel,"WheelBLCylindricalConstraint"); -- Search your back left wheel Cylindrical
		CylindricalBR = Utils.GetCylindrical(CarModel,"WheelBRCylindricalConstraint"); -- Search your back right wheel Cylindrical
	},CarClient)
	return self
end

function CarClient.ConnectCar(self : Types.CarClientConstructor,callback : (CurrentAngularVelocity : number) -> number?)
	if(not self.__VehicleSeat or self.__VehicleSeatPropertyChanged) then return end
	if(not self.__Orientation) then return end
	if(not self.__TweenConfiguration) then return end
	self.__VehicleSeatPropertyChanged = self.__VehicleSeat.Changed:Connect(function(property: string) 
		if(not self.__MaxAngularVelocity) then return end
		if(self.__VehicleSeat.Occupant == nil) then return end
		if(not self.CylindricalBL or not self.CylindricalBR) then return end
		if(not self.WheelFLAttachment or not self.WheelFRAttachment) then return end
		if(property == "SteerFloat") then
			local orientation = Vector3.new(self.__Orientation.X,-self.__VehicleSeat.SteerFloat * self.__VehicleSeat.TurnSpeed,self.__Orientation.Z)
			TweenService:Create(self.WheelFLAttachment,self.__TweenConfiguration,{Orientation = orientation}):Play()
			TweenService:Create(self.WheelFRAttachment,self.__TweenConfiguration,{Orientation = orientation}):Play()
		elseif(property == "ThrottleFloat") then
			local torque = math.abs(self.__VehicleSeat.ThrottleFloat) * self.__VehicleSeat.Torque
			if(torque == 0) then torque = self.__VehicleSeat:GetAttribute("DefaultTorque") end
			self.CylindricalBL.MotorMaxTorque = torque
			self.CylindricalBR.MotorMaxTorque = torque
			local AngularVelocity = math.sign(self.__VehicleSeat.ThrottleFloat) * self.__MaxAngularVelocity
			local NewAngularVelocity = callback(AngularVelocity)
			if(type(NewAngularVelocity) == "number") then AngularVelocity = NewAngularVelocity end
			self.CylindricalBL.AngularVelocity = AngularVelocity
			self.CylindricalBR.AngularVelocity = AngularVelocity
		end
	end)
end

function CarClient.SetOrientation(self : Types.CarClientConstructor,Orientation : Vector3)
	if(not Orientation) then return end
	if(typeof(Orientation) ~= "Vector3") then return end
	self.__Orientation = Orientation
end

function CarClient.SetTweenConfiguration(self : Types.CarClientConstructor,TweenConfiguration : TweenInfo)
	if(not TweenConfiguration) then return end
	if(typeof(TweenConfiguration) ~= "TweenInfo") then return end
	self.__TweenConfiguration = TweenConfiguration
end

function CarClient.GetCurrentVehicleSpeed(self : Types.CarClientConstructor)
	return math.abs(math.floor(self.__VehicleSeat.Velocity.X))
end

function CarClient.IsBackward(self : Types.CarClientConstructor)
	return self.__VehicleSeat.Throttle == -1
end

function CarClient.IsForward(self : Types.CarClientConstructor)
	return self.__VehicleSeat.Throttle == 1
end

function CarClient.IsLeft(self : Types.CarClientConstructor)
	return self.__VehicleSeat.Steer == -1
end

function CarClient.IsRight(self : Types.CarClientConstructor)
	return self.__VehicleSeat.Steer == 1
end

function CarClient.DisconnectCar(self : Types.CarClientConstructor)
	if(typeof(self.__VehicleSeatPropertyChanged) == "RBXScriptConnection") then
		self.__VehicleSeatPropertyChanged:Disconnect()
	end
	TweenService:Create(self.WheelFLAttachment,self.__TweenConfiguration,{Orientation = self.__Orientation}):Play()
	TweenService:Create(self.WheelFRAttachment,self.__TweenConfiguration,{Orientation = self.__Orientation}):Play()
	self.CylindricalBL.AngularVelocity = 0
	self.CylindricalBR.AngularVelocity = 0
end

function CarClient.Destroy(self : Types.CarClientConstructor)
	self:DisconnectCar()
	table.clear(self)
	setmetatable(self,nil)
end

return table.freeze(Constructor)
