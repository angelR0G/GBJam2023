extends Node

var planetStruct = preload("res://scripts/PlanetStruct.gd")

var planets:Array[PlanetStruct] = [ planetStruct.new(Planet1, false)
								  , planetStruct.new(Planet2, false)
								  ]
