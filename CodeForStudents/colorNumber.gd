@tool
extends Label3D

var color : Color

@export var num : int = 0  :
	set(value):
		num = value
		text = str(num)


func _ready() -> void:
	
	$Area3D.area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D )->void:
	print(area.name)
	if area.name == "Touch":
		modulate = get_random_color()
		
func get_random_color()->Color:
	var c := Color(randf(), randf(), randf(), 1)
	return c
