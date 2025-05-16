--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunEnums = require(ReplicatedStorage.Types.Enums.GunEnums)
local GunTypes = require(ReplicatedStorage.Types.GunTypes)

local config: GunTypes.GunConfig = {
	Damage = 10,
	FireRate = 600,
	Range = 1000,
	Spread = 4,
	SpeedBoost = 0,
	MaxAmmo = 30,
	MaxReserve = 300,
	ReloadSpeed = 1,
	BulletsPerShot = 1,

	FireModes = { GunEnums.FireMode.Semi, GunEnums.FireMode.Auto, GunEnums.FireMode.Double, GunEnums.FireMode.Cyclic },

	ImpactTemplate = ReplicatedStorage.Assets.VFX.GunEffectTemplates.Default.ImpactTemplate,
	TracerTemplate = ReplicatedStorage.Assets.VFX.GunEffectTemplates.Default.TracerTemplate,
}

return config
