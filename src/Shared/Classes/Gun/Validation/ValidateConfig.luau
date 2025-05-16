--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Modules.t)
local GunEnums = require(ReplicatedStorage.Types.Enums.GunEnums)

local isGunConfigInterface = t.strictInterface({
	Damage = t.number,
	Range = t.number,
	FireRate = t.number,
	Spread = t.number,
	ReloadSpeed = t.number,
	SpeedBoost = t.number,
	MaxAmmo = t.number,
	MaxReserve = t.number,
	BulletsPerShot = t.number,

	FireModes = t.array(t.keyOf(GunEnums.FireMode)),

	ImpactTemplate = t.instanceIsA("Part"),
	TracerTemplate = t.instanceIsA("Part"),
})

return function(gunConfig: unknown): boolean
	return isGunConfigInterface(gunConfig)
end
