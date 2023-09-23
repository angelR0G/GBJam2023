extends Node

var planetStruct = preload("res://scripts/PlanetStruct.gd")

@onready var planets = 	[	
							[ planetStruct.new(Planet1, false), planetStruct.new(Planet1, false), planetStruct.new(Planet1, false) ],
							[ planetStruct.new(Planet1, false), planetStruct.new(Planet1, false), planetStruct.new(Planet1, false) ],
							[ planetStruct.new(Planet1, false), planetStruct.new(Planet1, false), planetStruct.new(Planet1, false) ]
						]
