export type CarServerConstructor = {
	CarInit : Model;
	LastVehicleSeatOccupant : Humanoid?,
	CurrentVehicleSeatOccupant : Humanoid?,
	SitEventConnection : RBXScriptConnection | unknown,
	DefaultTorque : number,
	SpringConstraintInstance : {SpringConstraint};
	HingeConstraintInstance : {HingeConstraint};
	CylindricalConstraintInstance : {CylindricalConstraint};
	WeldConstraintInstance : {WeldConstraint};
	NoCollisionConstraintInstance : {NoCollisionConstraint};
	SetOwnership : (self : CarServerConstructor, player : Player?) -> ();
	SetDefaultTorque : (self : CarServerConstructor,Torque : number) -> ();
	OnSitEvent : (self : CarServerConstructor,callback : (Humanoid?) -> ()) -> RBXScriptConnection;
	Destroy : (self : CarServerConstructor,DestroyModel : boolean) -> ()
}

return nil
