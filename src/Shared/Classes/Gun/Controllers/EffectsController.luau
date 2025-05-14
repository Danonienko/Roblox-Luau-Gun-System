local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GunTypes = require(ReplicatedStorage.Types.GunTypes)

local Controller = {}

local ControllerMeta: GunTypes.IEffectsController = {} :: GunTypes.IEffectsController
ControllerMeta.__index = ControllerMeta
ControllerMeta.__tostring = function()
	return "EffectsController"
end

function Controller.new(gun: GunTypes.Gun): GunTypes.EffectsController
	local self: GunTypes.EffectsController = setmetatable({}, ControllerMeta) :: GunTypes.EffectsController

	self.Gun = gun

	return self
end

function ControllerMeta:DrawShot(origin: Vector3, rayResults: { GunTypes.RayResult }, gunConfig: GunTypes.GunConfig) end

function ControllerMeta:DrawImpact(at: Vector3, impactTemplate: Part) end

function ControllerMeta:DrawTracer(startPos: Vector3, endPos: Vector3, tracerTemplate: Part) end

function ControllerMeta:DebugHit(rayResults: { GunTypes.RayResult }): ()
	for index, rayResult in rayResults do
		local gunHit = Instance.new("Part")
		gunHit.Name = "GunHit"
		gunHit.BrickColor = BrickColor.new("Lime green")
		gunHit.Anchored = true
		gunHit.CanCollide = false
		gunHit.CanTouch = false
		gunHit.CanQuery = false
		gunHit.CastShadow = false
		gunHit.Size = Vector3.new(1, 1, 2)
		gunHit.CFrame = CFrame.lookAlong(rayResult.Position, rayResult.Normal)

		gunHit.Parent = Workspace

		task.delay(3, function()
			gunHit:Destroy()
		end)
	end
end

function ControllerMeta:Destroy() end

return Controller
