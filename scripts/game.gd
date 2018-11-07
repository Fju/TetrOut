extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")

func _ready():
	var canvas = TetrisCanvas.new()
	
	add_child(canvas)