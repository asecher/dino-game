extends Area2D

func _physics_process(delta: float) -> void:
	var current_speed = get_node("/root/Game").speed / 2
	position.x += Vector2.LEFT.x * current_speed * delta
