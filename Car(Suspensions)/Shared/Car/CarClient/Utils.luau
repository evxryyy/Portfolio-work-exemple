local function getVehicleSeatFromCar(model : Model)
	if(not model) then return end
	local vehicleSeat = nil
	for i,child in pairs(model:GetDescendants()) do
		if(child.ClassName == "VehicleSeat") then
			vehicleSeat = child
			break
		end
	end
	return vehicleSeat
end

local module = {}

function module.GetMaxAngularVelocity(FromCar : Model,WheelDiameter : number) : number | unknown
	if(not FromCar) then return end
	local getVehicleSeat : VehicleSeat = getVehicleSeatFromCar(FromCar)
	if(not getVehicleSeat) then return end
	local maxAngularVelocity = getVehicleSeat.MaxSpeed / (WheelDiameter / 2)
	return maxAngularVelocity
end

function module.GetCylindrical(FromCar : Model,CylindricalName : string) : CylindricalConstraint | unknown
	if(not FromCar) then return end
	if(not CylindricalName) then return end
	local Cylindrical = nil
	for i,CylindricalInstance in pairs(FromCar:GetDescendants()) do
		if(CylindricalInstance.ClassName ~= "CylindricalConstraint") then continue end
		if(CylindricalInstance.Name == CylindricalName) then
			Cylindrical = CylindricalInstance
			break
		end
	end
	return Cylindrical
end

function module.GetAttachment(FromCar : Model,AttachmentName : string) : Attachment | unknown
	if(not FromCar) then return end
	if(not AttachmentName) then return end
	local Attachment = nil
	for i,AttachmentInstance in pairs(FromCar:GetDescendants()) do
		if(AttachmentInstance.ClassName ~= "Attachment") then continue end
		if(AttachmentInstance.Name == AttachmentName) then
			Attachment = AttachmentInstance
			break
		end
	end
	return Attachment
end

module.GetVehicleSeat = getVehicleSeatFromCar

return module
