export type ButtonClass = {
	Construct : (Button : Instance | string) -> nil,
	Destroy : (Button : Instance | string) -> boolean,
	GetButtonInfo : (Button : Instance | string) -> {Price : number,Item : string, Type : string};	
}

export type ButtonRobux = {
	Construct : (Button : Instance | string) -> nil,
	Destroy : (Button : Instance | string) -> boolean,
	GetButtonInfo : (Button : Instance | string) -> {Price : number,Item : string, Type : string};	
	PromptPurchase : (ButtonProductId : number) -> nil;
	OnPurchase : (callback : (any) -> nil) -> nil;
}

export type ButtonNormal = ButtonClass;

export type ButtonTypes = {
	Robux : ButtonRobux,
	Normal : ButtonNormal
}


return nil