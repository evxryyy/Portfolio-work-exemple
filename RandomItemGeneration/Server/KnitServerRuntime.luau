local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddServices(ServerScriptService.Server.Services)
Knit.Start():catch(warn)

--Stop apple exemple.
--task.wait(7)
--local AppleService = Knit.GetService("AppleService")
--AppleService:StopApplesThread()
