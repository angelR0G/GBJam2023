extends Node2D

signal core_collected

var life 		= 80
var coreExposed = false

@onready var sprite 	:= $AnimatedSprite2D
@onready var barrier 	:= $BarrierCollider
@onready var coreSound	:= $CoreSound

func _ready():
	life 				= 80
	coreExposed 		= false
	sprite.animation 	= "breaking"
	

func damage(dp:int):
	life -= dp
	
	if life <= 0:
		# Check the broken event happens once
		if not coreExposed:
			coreExposed = true
			
			# Play animation and wait until it ends
			sprite.play("broken")
			await sprite.animation_finished
			
			# Disable barrier collision
			barrier.queue_free()
	elif life <= 10:
		sprite.frame = 4
	elif life <= 30:
		sprite.frame = 3
	elif life <= 50:
		sprite.frame = 2
	elif life <= 70:
		sprite.frame = 1


func _on_core_collider_body_entered(body):
	if body is Player:
		coreSound.play()
		await coreSound.finished
		
		core_collected.emit()
