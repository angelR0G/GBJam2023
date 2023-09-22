extends Node2D

signal ladder_entered

@onready var sprite 	:= $AnimatedSprite2D
@onready var collider	:= $Area2D/CollisionShape2D

func _ready():
	# Hide ladder and deactivate collider
	sprite.visible 		= false
	collider.disabled 	= true

func showLadder():
	sprite.visible 		= true
	sprite.animation 	= "open_up"

func openLadder(down:bool):
	# Show ladder again
	sprite.visible = true
	
	# Play animation and wait
	if down:
		sprite.play("open_down")
	else:
		sprite.play("open_up")
	await sprite.animation_finished
	
	# Enable collider after animation finished
	collider.disabled = false
	

func _on_area_2d_body_entered(body):
	if body is Player:
		ladder_entered.emit()
