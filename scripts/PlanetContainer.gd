extends Node

var planetStruct = preload("res://scripts/PlanetStruct.gd")

@onready var planets = 	[	
							[ planetStruct.new(Planet1, false), planetStruct.new(Planet2, false), planetStruct.new(Planet3, false) ],
							[ planetStruct.new(Planet4, false), planetStruct.new(Planet5, false), planetStruct.new(Planet6, false) ],
							[ planetStruct.new(Planet7, false), planetStruct.new(Planet8, false), planetStruct.new(Planet9, false) ]
						]
