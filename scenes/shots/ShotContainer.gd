class_name ShotContainer
extends Node

static var shots:Array[PackedScene] = [preload("res://scenes/shots/Shot.tscn")]

static func create_shot() -> Shot:
	var shot:Shot = shots[0].instantiate()
	
	return shot
