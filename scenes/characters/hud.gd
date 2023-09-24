extends CanvasLayer

const MAX_HEAT		:float 	= 16
const MAX_LIFE		:int	= 16
const HEATBAR_X		:int	= 2

@onready var hearts 	:= $Node2D/Hearts
@onready var heatBar	:= $Node2D/HeatBarProgress

func _ready():
	updateLife(MAX_LIFE)
	updateHeat(0)
	
func updateLife(newLife:int):
	# Recover hearts' sprites
	var heartNodes = hearts.get_children()
	
	var index = 0
	# Modify sprites to match players life
	while index < heartNodes.size():
		if newLife >= 4:
			heartNodes[index].region_rect.position = Vector2(48, 0)
		elif newLife > 0:
			heartNodes[index].region_rect.position = Vector2(16 * (newLife-1), 0)
		else:
			heartNodes[index].region_rect.position = Vector2(0, 16)
			
		index 	+= 1
		newLife -= 4

func updateHeat(newHeat:int):
	# Calculate progress bar new dimensions
	var percent 	= 1 - newHeat/MAX_HEAT
	var newWidth 	= 64 * percent
	var newPosition	= 64 - newWidth
	
	# Update sprite
	heatBar.region_rect.size 		= Vector2(newWidth, 16)
	heatBar.region_rect.position	= Vector2(newPosition, 32)
	heatBar.position.x 				= HEATBAR_X + newPosition
