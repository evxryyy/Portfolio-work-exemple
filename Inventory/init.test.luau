local Inventory = require(Somewhere.Backpack)

local backpack_class = Inventory.new()
backpack_class:AddExternalMetatable(Flashlight.new()) -- this add the Flashligh metatable to the inventory (required function :state),(required properties: Name,equip)
