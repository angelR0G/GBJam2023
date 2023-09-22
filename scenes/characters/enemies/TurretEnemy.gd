extends "res://scenes/characters/enemies/BasicEnemy.gd"

var SHOT_INTERVAL_TIME 	= 3.5
var SHOT_SPEED			= 30.0
var ANGLE_DIFFERENCE	= PI/4.0
var ENEMY_LIFE			= 25

@onready var sprite		:= $AnimatedSprite2D
@onready var collider 	:= $CollisionShape2D
@onready var timer		:= $ShootTimer

func _ready():
	getPlayer()
	timer.start(SHOT_INTERVAL_TIME)
	life = ENEMY_LIFE

func _process(_delta):
	var orientation = Vector2(player.global_position - global_position).angle()
	
	updateAnimation(orientation)
	

func updateAnimation(orientation:float):
	while orientation < 0:
		orientation += TAU
	
	# Modify sprite depending on facing orientation
	if orientation <= PI/4.0 || orientation >= TAU-PI/4.0:
		sprite.play("right")
		sprite.flip_h = false
	elif orientation <= 3.0/4.0 * PI:
		sprite.play("down")
	elif orientation <= 5.0/4.0 * PI:
		sprite.play("right")
		sprite.flip_h = true
	else:
		sprite.play("up")


func shoot():
	# Create three shots
	var shot1 := ShotContainer.create_shot(1)
	var shot2 := ShotContainer.create_shot(1)
	var shot3 := ShotContainer.create_shot(1)
	
	# Get player direction to shoot them
	var shotDirection = Vector2(player.global_position - global_position)
	
	# Update shots speed and direction
	shot1.setVelocity(SHOT_SPEED)
	shot2.setVelocity(SHOT_SPEED)
	shot3.setVelocity(SHOT_SPEED)
	shot1.setShotDirection(shotDirection.angle())
	shot2.setShotDirection(shotDirection.angle() + ANGLE_DIFFERENCE)
	shot3.setShotDirection(shotDirection.angle() - ANGLE_DIFFERENCE)
	
	# Set shot initial position
	shot1.global_position = global_position + shot1.linear_velocity.normalized() * 4
	shot2.global_position = global_position + shot2.linear_velocity.normalized() * 4
	shot3.global_position = global_position + shot3.linear_velocity.normalized() * 4
	
	# Add them to the game
	add_sibling(shot1)
	add_sibling(shot2)
	add_sibling(shot3)
