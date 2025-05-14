--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Modules.t)

return function(tool: unknown): boolean
	return t.instanceIsA("Tool")(tool)
end
