
extends Node3D
#https://www.youtube.com/watch?v=v4cfPaa1Gkw&t=96s

@export_category("agent")
@export var num_agents :int = 2000 
@export var agent_speed : float = 100;
@export var fade_speed : float = 0.25;
@export var blur_speed : float = 1.0;
@export var blur_radius : float = 15.0;
var positions: PackedVector3Array
var velocities: PackedVector3Array


		

@export_category("Scene Nodes")
@export var multi_mesh_inst: MultiMeshInstance3D
@export var positions_sprite : Sprite3D
@export var colors_sprite : Sprite3D

func _ready() -> void:
	pass

func _init_agents()->void:
	positions = []


	
