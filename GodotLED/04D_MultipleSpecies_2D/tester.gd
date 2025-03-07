@tool
extends Node

@export var tester := false :
	set(value):
		tester = false
		test()
@export_range(1,3,1) var num_species :int = 2: 
	set(value):
		num_species = value
		test()
		
@export var color0:= Color.RED
@export var color1:= Color.GREEN

func test()->void:
	var sum : Color = color1*2
	print(sum)
