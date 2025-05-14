export type Gun = typeof(setmetatable(
	{} :: {
		Tool: Tool,
		Configuration: GunConfig,

		EffectsController: EffectsController,
	},
	{} :: IGun
))

export type IGun = {
	__index: IGun,
	__tostring: () -> string,

	Shoot: (self: Gun) -> (),
	PushTrigger: (self: Gun) -> (),
	Aim: (self: Gun) -> (),
	Reload: (self: Gun) -> (),
	Rest: (self: Gun) -> (),
	Destroy: (self: Gun) -> (),

	Equip: (self: Gun) -> (),
	Unequip: (self: Gun) -> (),
	Activate: (self: Gun) -> (),
	Deactivate: (self: Gun) -> (),

	IsShooting: (self: Gun) -> boolean,
	IsReloading: (self: Gun) -> boolean,
	IsAiming: (self: Gun) -> boolean,
	IsEquipped: (self: Gun) -> boolean,
	IsActivated: (self: Gun) -> boolean,
	IsResting: (self: Gun) -> boolean,

	CanShoot: (self: Gun) -> boolean,
	CanReload: (self: Gun) -> boolean,
	CanAim: (self: Gun) -> boolean,
	CanRest: (self: Gun) -> boolean,
	IsHumanoidAlive: (self: Gun) -> boolean,
}

export type EffectsController = typeof(setmetatable(
	{} :: {
		Gun: Gun,
	},
	{} :: IEffectsController
))

export type IEffectsController = {
	__index: IEffectsController,
	__tostring: () -> string,

	DrawShot: (self: EffectsController, origin: Vector3, rayResults: { RayResult }, gunConfig: GunConfig) -> (),
	DrawImpact: (self: EffectsController, at: Vector3, impactTemplate: Part) -> (),
	DrawTracer: (self: EffectsController, startPos: Vector3, endPos: Vector3, tracerTemplate: Part) -> (),

	DebugHit: (self: EffectsController, rayResults: { RayResult }) -> (),

	Destroy: (self: EffectsController) -> (),
}

export type GunConfig = {
	Damage: number,
	Range: number,
	FireRate: number,
	Spread: number,
	ReloadSpeed: number,
	SpeedBoost: number,
	MaxAmmo: number,
	MaxReserve: number,
	BulletsPerShot: number,

	ImpactTemplate: Part,
	TracerTemplate: Part,
}

export type RayResult = {
	Instance: Instance?,
	Distance: number,
	Position: Vector3,
	Normal: Vector3,
	Material: Enum.Material,
	HitHumanoid: Humanoid?,
}

return nil
