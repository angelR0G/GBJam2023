extends Node

var backgroundStars

func _ready():
	backgroundStars = self
	# Play stars animation
	var stars = backgroundStars.get_children()
	var halfStars = (stars.size() / 2)
	while not stars.is_empty():
		var star = stars.pop_back()
		if stars.size() >= halfStars:
			star.play("short")
		else:
			star.play("long")
		
		star.set_frame_and_progress(8, randf())
