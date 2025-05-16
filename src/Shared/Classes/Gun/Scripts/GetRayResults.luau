--!strict
--!native
--!optimize 2

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Classes.Gun.Constants)
local GunTypes = require(ReplicatedStorage.Types.GunTypes)

return function(player: Player, origin: Vector3, directions: { Vector3 }): { GunTypes.RayResult }
	local exclude: { Instance } = CollectionService:GetTagged(Constants.Tags.RAY_EXCLUDE_TAG)

	if player.Character then
		table.insert(exclude, player.Character)
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	params:AddToFilter(exclude)

	local rayResults: { GunTypes.RayResult } = table.create(#directions)

	for index, direction in directions do
		local raycastResult = Workspace:Raycast(origin, direction, params)
		local rayResult: GunTypes.RayResult = {
			Distance = (origin + direction).Magnitude,
			Normal = direction.Unit,
			Material = Enum.Material.Air,
			Position = origin + direction,
		}

		if raycastResult then
			rayResult.Instance = raycastResult.Instance
			rayResult.Distance = raycastResult.Distance
			rayResult.Normal = raycastResult.Normal
			rayResult.Material = raycastResult.Material
			rayResult.Position = raycastResult.Position

			local humanoid: Humanoid? = raycastResult.Instance.Parent
				and raycastResult.Instance.Parent:FindFirstChildOfClass("Humanoid")

			if humanoid then
				rayResult.HitHumanoid = humanoid
			end
		end

		table.insert(rayResults, rayResult)
	end

	return rayResults
end
