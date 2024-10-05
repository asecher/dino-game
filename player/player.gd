extends CharacterBody2D

const JUMP_VELOCITY = -1800.0

@onready var sprite = $AnimatedSprite2D
@onready var jumpSound = $JumpSound
@onready var runCollisionBox = $RunCollisionBox
@onready var duckCollisionBox = $DuckCollisionBox
@onready var game: Node = $".."
@onready var jump_button = get_node("/root/Game/HUD/Jump")
@onready var duck_button = get_node("/root/Game/HUD/Duck")

var is_ducking = false

func _physics_process(delta: float) -> void:
	if !game.game_is_running:
		sprite.play("idle")
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite.play("jump")
	else:
		runCollisionBox.disabled = false 
		
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") or jump_button.is_pressed():
			jump()
		elif Input.is_action_pressed("ui_down") or duck_button.is_pressed() or is_ducking:
			sprite.play("duck")
			runCollisionBox.disabled = true
		else: 
			sprite.play("run")
		
	velocity.x = Vector2.RIGHT.x * game.speed
	move_and_slide()

func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumpSound.play()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var size = get_viewport_rect().size
		if event.position.x < size.x / 2.0:
			is_ducking = false
			jump()
		else:
			if event.is_pressed():
				is_ducking = true
			else:
				is_ducking = false
