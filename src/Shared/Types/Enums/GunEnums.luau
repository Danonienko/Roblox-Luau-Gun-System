export type FireMode = "Semi" | "Auto" | "Double" | "Cyclic"
export type MagType = "Classic" | "Static"

type GunEnums = {
	FireMode: GunEnums_FireMode,
	MagType: GunEnums_MagType,
}

type GunEnums_FireMode = {
	Semi: "Semi",
	Auto: "Auto",
	Double: "Double",
	Cyclic: "Cyclic",
}

type GunEnums_MagType = {
	Classic: "Classic",
	Static: "Static",
}

local gunEnums: GunEnums = {
	FireMode = {
		Semi = "Semi",
		Auto = "Auto",
		Double = "Double",
		Cyclic = "Cyclic",
	},
	
	MagType = {
		Classic = "Classic",
		Static = "Static",
	},
}

return gunEnums
