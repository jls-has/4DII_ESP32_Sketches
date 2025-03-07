@tool
extends Node


@export_range(-TAU, TAU, 0.1) var theta :float = 0 : 
	set(value):
		theta = value
		test()

func test()->void:
	var z_axis := Vector3(0,0,1)
	var direction_up := Vector3(0,1,0)
	print(direction_up.rotated(z_axis, theta))
	print(Vector2(0,1).rotated(theta))
