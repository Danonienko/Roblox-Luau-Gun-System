local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Classes.Gun)
local Constants = require(ReplicatedStorage.Classes.Gun.Constants)
local GunConfigs = require(ReplicatedStorage.Configurations.GunConfigs)

local function _HandleAdded(instance: Instance): ()
	if not instance:IsA("Tool") then
		return
	end

	local config = GunConfigs[instance.Name]

	Gun.new(instance, config or GunConfigs.Default)
end

local function _HandleRemoved(instance: Instance): ()
	if not instance:IsA("Tool") then
		return
	end

	local gun = Gun.GetGun(instance)

	if not gun then
		return
	end

	gun:Destroy()
end

CollectionService:GetInstanceAddedSignal(Constants.GUN_TAG):Connect(_HandleAdded)
CollectionService:GetInstanceRemovedSignal(Constants.GUN_TAG):Connect(_HandleRemoved)

return {}
