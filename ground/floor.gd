extends StaticBody2D

@onready var camera_2d: Camera2D = %Camera2D

const GROUND = preload("res://ground/ground.tscn")

# at all time it holds only 3 ground instances
var floor: Array[Sprite2D] = []
var ground_width: int = 0
var spawn_position := global_position

func _ready() -> void:
	# add initial ground on floor
	init_floor()

func _physics_process(delta: float) -> void:
	if spawn_position.distance_to(camera_2d.global_position) < ground_width:
		spawn_ground()
		

func spawn_ground() -> void:
	var ground = GROUND.instantiate()
	add_child(ground)
	floor.append(ground)
	
	ground.global_position.x = spawn_position.x
	spawn_position.x += ground_width
	
	cleanup_older_grounds()

func cleanup_older_grounds() -> void:
	if floor.size() == 4:
		var old_ground = floor.pop_front()
		old_ground.queue_free()

func reset_floor() -> void:
	for g in floor:
		g.queue_free()
	floor.clear()
	spawn_position = Vector2(0, 552)
	init_floor()

func init_floor() -> void:
	var ground = GROUND.instantiate()
	add_child(ground)
	floor.append(ground)
	ground_width = ground.texture.get_size().x
