if(not game:IsLoaded()) then game.Loaded:Wait() end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
Knit.AddControllers(script.Parent:WaitForChild("Controllers"))
Knit.Start({ServicePromises = true}):catch(warn)
