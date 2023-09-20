extends Node

static var shots:Array[PackedScene] = [
	preload("res://scenes/shots/Shot.tscn"),
	preload("res://scenes/shots/MoleShot.tscn")]

func create_shot(index:int = 0) -> Shot:
	index = clampi(index, 0, shots.size())
	
	var shot:Shot = shots[index].instantiate()
	
	return shot
