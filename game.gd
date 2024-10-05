extends Node

const SCORE_MODIFIER = 1000
const SPEED_MODIFIER := 3000 * 100
const MAX_DIFFICULTY := 3
const SPAWN_DISTANCE := 1152
const SPAWN_THRESHOLD := 500
const STUMP = preload("res://obstacles/stump.tscn")
const ROCK = preload("res://obstacles/rock.tscn")
const BARREL = preload("res://obstacles/barrel.tscn")
const BIRD = preload("res://obstacles/bird.tscn")
const BAT = preload("res://obstacles/bat.tscn")
const OBSTACLE_TYPES := [STUMP, ROCK, BARREL]
const FLYING_TYPES := [BIRD, BAT]
const FLY_HEIGHTS := [200, 390]

@export var start_speed := 425.0
@export var acceleration := 12.0
@export var max_speed := 1150.0

var game_is_running = false
var speed := start_speed
var score := 0
var high_score := 0
var difficulty := 0
var last_obs 

@onready var camera: Camera2D = $Camera2D 
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var game_over_hud: CanvasLayer = $GameOver
@onready var floor: StaticBody2D = $Floor
@onready var obstacles: Node = %Obstacles
var start_button: Button
var restart_button: Button
var score_label: Label
var highscore_label: Label

func _ready() -> void:
	start_button = hud.get_node("StartButton")
	start_button.pressed.connect(start_game)
	
	restart_button = game_over_hud.get_node("RestartButton")
	restart_button.pressed.connect(new_game)
	
	score_label = hud.get_node("ScoreLabel")
	highscore_label = hud.get_node("HighScoreLabel")
	

func _physics_process(delta: float) -> void:
	if game_is_running:
		#speed up and adjust difficulty
		speed = min(speed + acceleration * delta, max_speed)
		
		difficulty = score / SPEED_MODIFIER
		if difficulty > MAX_DIFFICULTY:
			difficulty = MAX_DIFFICULTY
		
		generate_obstacles()
		
		#update score
		score += speed
		show_score()
		
		#remove obstacles that have gone off screen
		for obs in obstacles.get_children():
			if obs.position.x < (camera.position.x - get_viewport().size.x):
				obs.queue_free()

	else: 
		if Input.is_action_just_pressed("ui_accept"):
			start_game()

func start_game() -> void:
	game_is_running = true
	start_button.hide()

func new_game() -> void:
	score = 0
	show_score()
	difficulty = 0
	speed = start_speed
	
	get_tree().paused = false
	
	for obs in obstacles.get_children():
		obs.queue_free()
	
	floor.reset_floor()
	player.position = Vector2(72, 300)
	game_over_hud.hide()
	game_is_running = true

func generate_obstacles() -> void:
	if obstacles.get_children().size() == 0 or player.position.distance_to(last_obs.position) < SPAWN_THRESHOLD:
		var obs_type = OBSTACLE_TYPES[randi() % OBSTACLE_TYPES.size()]
		var max_obs = difficulty + 1
		var rand_distance = randi_range(250, 800)
		for i in range(randi() % max_obs + 1):
			var obs: Node = obs_type.instantiate()
			var sprite: Sprite2D = obs.get_node("Sprite2D")
			var obs_x: int = SPAWN_DISTANCE + player.position.x + rand_distance + (i * 100)
			var obs_y: int = floor.position.y - sprite.get_rect().size.y - 15
			obs.position = Vector2(obs_x, obs_y)
			obstacles.add_child(obs)
			obs.body_entered.connect(hit_obs)
			last_obs = obs
			print("spawn: ", obs.name)
		
		#additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate flying obstacles
				var flying_type = FLYING_TYPES[randi() % FLYING_TYPES.size()]
				var obs = flying_type.instantiate()
				var obs_x: int = SPAWN_DISTANCE + player.position.x + 100
				var obs_y: int = FLY_HEIGHTS[randi() % FLY_HEIGHTS.size()]
				obs.position = Vector2(obs_x, obs_y)
				obs.body_entered.connect(hit_obs)
				obstacles.add_child(obs)
				print("spawn birb: ", obs.name)

	
func hit_obs(body: Node2D) -> void:
	if body.name == "Player":
		game_over()

func game_over() -> void:
	if score > high_score:
		high_score = score
		highscore_label.text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
	get_tree().paused = true
	game_is_running = false
	game_over_hud.show()

func show_score() -> void:
	score_label.text = "SCORE: " + str(score / SCORE_MODIFIER)
	
