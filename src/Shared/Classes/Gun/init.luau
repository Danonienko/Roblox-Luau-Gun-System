--!strict
--!native
--!optimize 2

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(script.Constants)
local EffectsController = require(script.Controllers.EffectsController)
local Net = require(ReplicatedStorage.Modules.Net)
local ExtractMuzzlePoint = require(script.Scripts.ExtractMuzzlePoint)
local GetDirections = require(script.Scripts.GetDirections)
local GetRayResults = require(script.Scripts.GetRayResults)
local Trove = require(ReplicatedStorage.Modules.Trove)
local Remotes = require(ReplicatedStorage.Remotes)
local GunEnums = require(ReplicatedStorage.Types.Enums.GunEnums)
local ValidateConfig = require(script.Validation.ValidateConfig)
local ValidateTool = require(script.Validation.ValidateTool)
local GunTypes = require(ReplicatedStorage.Types.GunTypes)

local Gun = {}

local GunMeta: GunTypes.IGun = {} :: GunTypes.IGun
GunMeta.__index = GunMeta
GunMeta.__tostring = function(): string
	return "Gun"
end

local private = {}

local GunRemotes = Remotes.Client:GetNamespace("GunSystem")

local player = Players.LocalPlayer
local gunCollection: { [Tool]: GunTypes.Gun } = {}

function Gun.GetGun(tool: Tool): GunTypes.Gun?
	return gunCollection[tool]
end

function Gun.new(tool: Tool, gunConfig: GunTypes.GunConfig): GunTypes.Gun
	assert(ValidateTool(tool), "Constructor expects a tool instance")
	assert(ValidateConfig(gunConfig), "Passed config is invalid")

	local self: GunTypes.Gun = setmetatable({}, GunMeta) :: GunTypes.Gun

	private[self] = {
		Trove = Trove.new(),
		Humanoid = nil :: Humanoid?,
		MuzzlePoint = ExtractMuzzlePoint(tool),

		Ammo = gunConfig.MaxAmmo,
		Reserve = gunConfig.MaxReserve,
		FireMode = gunConfig.FireModes[1],

		IsShooting = false,
		IsReloading = false,
		IsAiming = false,
		IsEquipped = false,
		IsActivated = false,
		IsResting = false,
	}

	self.Tool = tool
	self.Configuration = gunConfig

	private[self].Trove:Connect(tool.Equipped, function()
		self:Equip()
	end)
	private[self].Trove:Connect(tool.Unequipped, function()
		self:Unequip()
	end)
	private[self].Trove:Connect(tool.Activated, function()
		self:Activate()
	end)
	private[self].Trove:Connect(tool.Deactivated, function()
		self:Deactivate()
	end)

	ContextActionService:BindAction(
		Constants.Actions.CHANGE_FIRE_MODE_ACTION,
		function(
			actionName: string,
			inputState: Enum.UserInputState,
			inputObject: InputObject
		): Enum.ContextActionResult?
			if inputState == Enum.UserInputState.Begin then
				self:ChangeFireMode()
			end

			return Enum.ContextActionResult.Sink
		end,
		true,
		Enum.KeyCode.V
	)

	self.EffectsController = private[self].Trove:Construct(EffectsController, self)

	gunCollection[tool] = self

	print(`Gun '{tool.Name}' successfully instantiated`)

	return self
end

function GunMeta:Shoot(): ()
	local origin = private[self].MuzzlePoint.WorldPosition
	local destination = player:GetMouse().Hit.Position
	local seed = Workspace:GetServerTimeNow()

	local directions =
		GetDirections(origin, destination, self.Configuration.Spread, self.Configuration.BulletsPerShot, seed)
	for index, direction in directions do
		directions[index] = direction * self.Configuration.Range
	end

	local rayResults = GetRayResults(player, origin, directions)

	local hit: { GunTypes.RayResult } = {}

	for index, rayResult in rayResults do
		if rayResult.HitHumanoid ~= nil then
			table.insert(hit, rayResult)
		end
	end

	(GunRemotes:Get("Hit") :: Net.ClientSenderEvent):SendToServer(self.Configuration, origin, hit, seed)

	self.EffectsController:DebugHit(rayResults)
end

function GunMeta:PushTrigger(): ()
	if private[self].IsShooting then
		return
	end

	local fireMode: GunEnums.FireMode = private[self].FireMode

	if fireMode == GunEnums.FireMode.Semi then
		private[self].IsShooting = true

		self:Shoot()

		task.delay(60 / self.Configuration.FireRate, function()
			private[self].IsShooting = false
		end)
	end

	if fireMode == GunEnums.FireMode.Auto then
		private[self].IsShooting = true

		while self:CanShoot() and self:IsActivated() do
			self:Shoot()

			task.wait(60 / self.Configuration.FireRate)
		end

		private[self].IsShooting = false
	end
end

function GunMeta:Aim() end

function GunMeta:Reload() end

function GunMeta:Rest() end

function GunMeta:ChangeFireMode(): ()
	if not self:CanChangeFireMode() then
		return
	end

	local current: GunEnums.FireMode = private[self].FireMode

	local index = table.find(self.Configuration.FireModes, current)

	if not index then
		return warn(`Could not find '{current}' fire mode in configuration table`)
	end

	index += 1

	private[self].FireMode = index > #self.Configuration.FireModes and self.Configuration.FireModes[1]
		or self.Configuration.FireModes[index]

	print(`[{self.Tool.Name}]: Changed fire mode from '{current}' to '{private[self].FireMode}'`)
end

function GunMeta:Equip(): ()
	if private[self].IsEquipped then
		return
	end

	private[self].IsEquipped = true

	private[self].Humanoid = self.Tool.Parent and self.Tool.Parent:FindFirstChildOfClass("Humanoid")

	print(`[{self.Tool.Name}]: Gun equipped`)
end

function GunMeta:Unequip(): ()
	if not private[self].IsEquipped then
		return
	end

	private[self].IsEquipped = false

	private[self].Humanoid = nil

	print(`[{self.Tool.Name}]: Gun unequipped`)
end

function GunMeta:Activate(): ()
	if private[self].IsActivated then
		return
	end

	private[self].IsActivated = true

	print(`[{self.Tool.Name}]: Gun activated`)

	self:PushTrigger()
end

function GunMeta:Deactivate(): ()
	if not private[self].IsActivated then
		return
	end

	private[self].IsActivated = false

	print(`[{self.Tool.Name}]: Gun deactivated`)
end

function GunMeta:IsShooting(): boolean
	return private[self].IsShooting
end

function GunMeta:IsReloading(): boolean
	return private[self].IsReloading
end

function GunMeta:IsAiming(): boolean
	return private[self].IsAiming
end

function GunMeta:IsEquipped(): boolean
	return private[self].IsEquipped
end

function GunMeta:IsActivated(): boolean
	return private[self].IsActivated
end

function GunMeta:IsResting(): boolean
	return private[self].IsResting
end

function GunMeta:IsHumanoidAlive(): boolean
	local humanoid: Humanoid? = private[self].Humanoid

	return humanoid and humanoid.Health > 0 or false
end

function GunMeta:CanShoot(): boolean
	return self:IsHumanoidAlive() and self:IsEquipped() and private[self].Ammo > 0 and not self:IsReloading()
end

function GunMeta:CanReload(): boolean
	return self:IsHumanoidAlive()
		and self:IsEquipped()
		and private[self].Ammo < self.Configuration.MaxAmmo
		and private[self].Reserve > 0
end

function GunMeta:CanAim(): boolean
	return self:IsHumanoidAlive() and self:IsEquipped() and not self:IsReloading()
end

function GunMeta:CanRest(): boolean
	return self:IsHumanoidAlive() and self:IsEquipped()
end

function GunMeta:CanChangeFireMode(): boolean
	return self:IsHumanoidAlive() and self:IsEquipped() and not self:IsActivated() and not self:IsReloading()
end

function GunMeta:Destroy(): ()
	self:Unequip()

	for key: string, value: string in pairs(Constants.Actions) do
		ContextActionService:UnbindAction(value)
	end

	private[self].Trove:Destroy()

	table.clear(self :: any)
end

return Gun
