local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Modules.Net)

return Net.CreateDefinitions({
	GunSystem = Net.Definitions.Namespace({
		Hit = Net.Definitions.ClientToServerEvent(),
	}),
})
