## A Complete car system that can be handle really easily and editable.

Result:
-  [Video](https://youtu.be/tpuA_k4GWiI)

Note:
-  Springs and CylindricalConstraint can be edited at any time in the server
-  SetDefaultTorque can be changed at any time in the server
-  The Speed can only be edited by getting the VehicleSeat and change MaxSpeed (e.g CarClass.CarInit:FindFirstChildOfClass("VehicleSeat").MaxSpeed = num)

Info:
-  In the video you can see wheel (red thing) and the chassis but i just forgot to turn the transparency to 1 so dw about that
-  I didn't make a SpeedMotor UI cause i was just testing Car Physics but you can see the module provide a function (CarClient) called .GetCurrentVehicleSpeed() that return the actual speed.
