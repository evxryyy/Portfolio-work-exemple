export type CarClientConstructor = {
	__MaxAngularVelocity : number,
	__TweenConfiguration : TweenInfo,
	__Orientation : Vector3,
	__VehicleSeatPropertyChanged : RBXScriptConnection | unknown,
	__VehicleSeat : VehicleSeat,
	WheelFLAttachment : Attachment,
	WheelFRAttachment : Attachment,
	CylindricalBL : CylindricalConstraint,
	CylindricalBR : CylindricalConstraint,
	ConnectCar : (self : CarClientConstructor,callback : (CurrentAngularVelocity : number) -> number?) -> ();
	DisconnectCar : (self : CarClientConstructor) -> ();
	SetOrientation : (self : CarClientConstructor,Orientation : Vector3) -> (),
	SetTweenConfiguration : (self : CarClientConstructor,TweenConfiguration : TweenInfo) -> ();
	GetCurrentVehicleSpeed : (self : CarClientConstructor) -> number;
	IsBackward : (self : CarClientConstructor) -> number;
	IsForward : (self : CarClientConstructor) -> number;
	IsLeft : (self : CarClientConstructor) -> number;
	IsRight : (self : CarClientConstructor) -> number;
	Destroy : (self : CarClientConstructor) -> ();
}

return nil
