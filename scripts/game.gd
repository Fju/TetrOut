extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")
var Block = preload("res://scripts/block.gd")


func _ready():
	var canvas = TetrisCanvas.new()
	var block = Block.new(tetrout.TETRIS_BLOCK_TYPES.CYAN)
		
	add_child(canvas)
	add_child(block)