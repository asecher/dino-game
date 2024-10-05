extends Camera2D

@onready var player = get_parent().get_node("Player")

func _process(delta: float) -> void:
	position.x = player.position.x
