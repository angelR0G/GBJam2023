extends CanvasLayer

#Signals
signal fadeOutEnded
signal fadeInEnded
signal transitionTopLevel
signal transitionBotLevel
signal transitionEnded

@onready var animationPlayer:AnimationPlayer 	= $AnimationPlayer
@onready var pSprite:AnimatedSprite2D 			= $AnimatedSprite2D
@onready var tiles:TileMap						= $TileMap

var levelNum:int 		= 1
var isLevelForward:bool = true

var currentPalette:GradientTexture1D

func resetTransition():
	changeNumLevel()
	levelNum = 1

func setCurrentPalette(palette:GradientTexture1D):
	currentPalette = palette
	var material = $Polygon2D.get_material()
	material.set_shader_parameter("colorPaletteCurr", currentPalette)
	
func setTransitionType(type:int):
	var material = $Polygon2D.get_material()
	material.set_shader_parameter("transitionType", type)

func setTextPalette(palette:GradientTexture1D):
	$Text/LevelNumber.get_material().set_shader_parameter("palette", palette)
	$Text2/LevelNumber.get_material().set_shader_parameter("palette", palette)

func transition():
	show()
	pSprite.play("walk_right")
	
#	animationPlayer.play("fade_in")
#	await animationPlayer.animation_finished
	
	animationPlayer.play("fade_in")
	
	tiles.show()
	
	animationPlayer.play("fade_out")
	await animationPlayer.animation_finished
	
	if(isLevelForward):
		animationPlayer.play("top_level")
		await animationPlayer.animation_finished
		
		await get_tree().create_timer(1).timeout
		
		animationPlayer.play("bottom_level")
		await animationPlayer.animation_finished
	else:
		animationPlayer.play("bottom_level_return")
		await animationPlayer.animation_finished
		
		await get_tree().create_timer(1).timeout
		
		animationPlayer.play("top_level_return")
		await animationPlayer.animation_finished
	
	animationPlayer.play("fade_in")
	await animationPlayer.animation_finished
	hide()
	emit_signal("transitionEnded")
	await get_tree().create_timer(1).timeout
	animationPlayer.play("fade_out")
	await animationPlayer.animation_finished
	

func changeNumLevel():
	$Text2/LevelNumber.text = str(levelNum)

