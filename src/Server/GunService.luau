--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Modules.Net)
local Remotes = require(ReplicatedStorage.Remotes)
local GunTypes = require(ReplicatedStorage.Types.GunTypes)

local GunRemotes = Remotes.Server:GetNamespace("GunSystem")

local function _HandleHit(
	gunConfig: GunTypes.GunConfig,
	origin: Vector3,
	rayResults: { GunTypes.RayResult },
	seed: number
)
end

(GunRemotes:Get("Hit") :: Net.ServerListenerEvent):Connect(_HandleHit)

return {}
