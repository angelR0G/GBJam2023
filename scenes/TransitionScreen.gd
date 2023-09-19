extends CanvasLayer

#Signals
signal fadeOutEnded
signal fadeInEnded

var currentPalette:GradientTexture1D
var prevPalette:GradientTexture1D

func setTransitionPalette(palette:GradientTexture1D):
	prevPalette = currentPalette
	currentPalette = palette
	if prevPalette == null:
		prevPalette = palette
	var material = $Polygon2D.get_material()
	material.set_shader_parameter("colorPalettePrev", prevPalette)
	material.set_shader_parameter("colorPaletteCurr", currentPalette)

func transition():
	$AnimationPlayer.play("fade_in")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		emit_signal("fadeInEnded")
		$AnimationPlayer.play("fade_out")
	if anim_name == "fade_out":
		emit_signal("fadeOutEnded")
		prevPalette = currentPalette
