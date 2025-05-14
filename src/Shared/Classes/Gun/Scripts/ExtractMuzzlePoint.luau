--!strict
--!optimize 2

return function(tool: Tool): Attachment
	local muzzlePoint: Instance? = tool:FindFirstChild("MuzzlePoint", true)

	assert(muzzlePoint and muzzlePoint:IsA("Attachment"), "A gun must have a 'MuzzlePoint' attachment instance")

	return muzzlePoint
end
