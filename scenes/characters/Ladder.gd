extends Node2D

signal ladder_entered

@onready var sprite 	:= $AnimatedSprite2D
@onready var collider	:= $Area2D/CollisionShape2D
@onready var openSound	:= $OpenSound
@onready var enterSound	:= $EnterSound

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
	
	# Play sound
	openSound.play()
	
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
		# Play sound
		enterSound.play()
		await enterSound.finished
		
		ladder_entered.emit()
