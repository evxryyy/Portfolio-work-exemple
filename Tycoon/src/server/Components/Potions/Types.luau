export type DoubleIncomePotion = {
	Duration : number;
	MultIncome : number;	
}

export type ReduceClientCooldownPotion = {
	Duration : number;
	ReduceCooldownBy : number;	
}

--[[
PotionType is a : callback(arg: number) 
[range between 0,1] 
(0  = DoubleIncomePotion ,1 = ReduceClientCooldownPotion)
]]

export type MysteryPotion = {
	Duration : number;
	PotionType : (number) -> DoubleIncomePotion | ReduceClientCooldownPotion;
}

return nil