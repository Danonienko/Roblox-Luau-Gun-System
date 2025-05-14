--!strict
--!native
--!optimize 2

return function(
	origin: Vector3,
	destination: Vector3,
	spread: number,
	numberOfDirections: number,
	seed: number
): { Vector3 }
	local random = Random.new(seed * 100_000)

	local directions: { Vector3 } = table.create(numberOfDirections)

	for i = 1, numberOfDirections do
		local roll = random:NextNumber() * math.pi * 2
		local pitch = random:NextNumber() * math.rad(spread)

		local directionCFrame = CFrame.lookAt(origin, destination)
			* CFrame.Angles(0, 0, roll)
			* CFrame.Angles(0, pitch, 0)

		table.insert(directions, directionCFrame.LookVector)
	end

	return directions
end
