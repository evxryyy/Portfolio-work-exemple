local function _getSprings(model : Model)
	if(not model) then return end
	local t_springs = {}
	for i,springs in pairs(model:GetDescendants()) do
		if(springs:IsA("SpringConstraint")) then
			table.insert(t_springs,springs)
		end
	end
	return t_springs
end

local function _getHinges(model : Model)
	if(not model) then return end
	local t_hinges = {}
	for i,hinges in pairs(model:GetDescendants()) do
		if(hinges:IsA("HingeConstraint")) then
			table.insert(t_hinges,hinges)
		end
	end
	return t_hinges
end

local function _getCylindricals(model : Model)
	if(not model) then return end
	local t_cylindricals = {}
	for i,cylindricals in pairs(model:GetDescendants()) do
		if(cylindricals:IsA("CylindricalConstraint")) then
			table.insert(t_cylindricals,cylindricals)
		end
	end
	return t_cylindricals
end

local function _getWelds(model : Model)
	if(not model) then return end
	local t_welds = {}
	for i,weld in pairs(model:GetDescendants()) do
		if(weld:IsA("WeldConstraint")) then
			table.insert(t_welds,weld)
		end
	end
	return t_welds
end

local function _getNoCollisions(model : Model)
	if(not model) then return end
	local t_noColl = {}
	for i,noColl in pairs(model:GetDescendants()) do
		if(noColl:IsA("NoCollisionConstraint")) then
			table.insert(t_noColl,noColl)
		end
	end
	return t_noColl
end

local module = {}
module.__index = module

module.FindSpringConstraints = _getSprings
module.FindHingeConstraints = _getHinges
module.FindCylindricalConstraints = _getCylindricals
module.FindWeldConstraints = _getWelds
module.FindNoCollisionConstraints = _getNoCollisions

return module
