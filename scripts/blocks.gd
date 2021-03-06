""" Singleton for different block classes
Author:			Florian Winkler (Fju)
Created:		13.11.2018
Description:
	This script contains three different Block classes (two inherit from the base class `Block`).
	- Block: base class, contains functionalities like rotating the block matrix or customized position setters/getters.
	- GhostBlock: extends Block, is rendered in a translucent white color instead of a type specific color
	- AnimatedBlock: extends Block, can play an animation where it "flies" from one point to another
	Further more it contains static functions that return a new instance of a specific Block class
"""

extends Node

static func new_block(type):
	# create new `Block` instance
	return Block.new(type)
	
static func new_ghost_block(type):
	# create new `GhostBlock` instance
	return GhostBlock.new(type)
	
static func new_animated_block(type):
	# create new `AnimatedBlock` instance
	return AnimatedBlock.new(type)

static func pick_random_block():
	var sum = 0
	var probs = []
	for t in range(1, len(tetrout.BLOCK_TYPES)):
		var p = tetrout.get_block_probability(t)
		sum += p
		probs.append(p)
	
	var random = randf()
	var r = 0
	for t in range(len(probs)):
		r += probs[t] / float(sum)
		if r > random:
			# re-use r variable for storing the blocks id
			r = t
			break
	
	# add 1 to skip empty block
	return r + 1

class Block extends Control:
	var width
	var height
	
	var box_width
	var box_height
	
	var type
	var matrix
	var color
	
	var rotation setget set_rotation, get_rotation
	
	func _init(_type):
		# store type
		type = _type
		# obtain original matrix
		matrix = tetrout.get_block_matrix(type)
		update_size()
		
		# make transparent if it's a ghost block
		# note: this has no effect on blocks that have been added to the TetrisCanvas
		color = tetrout.get_block_color(type)
		rotation = 0
		
	
	func update_size():
		height = len(matrix)
		width = len(matrix[0])
		
		box_width = width * tetrout.BLOCK_SIZE
		box_height = height * tetrout.BLOCK_SIZE
		
		set_size(Vector2(box_width, box_height))
		
		redraw = true
		update()
	
	func get_block_name():
		return tetrout.get_block_name(type)
		
	func get_block_score():
		return tetrout.get_block_score(type)
	
	func set_position(pos, center=true):
		""" override function, centers the object """
		if center:
			pos.x -= box_height / 2
			pos.y -= box_width / 2
		
		# call super function of inherited class
		.set_position(pos)
	
	func get_global_position():	
		var pos = .get_global_position()
		
		pos.y += box_width
		return pos
		
	func set_global_position(pos):
		pos.y -= box_width	
		.set_global_position(pos)
	
	func turn():
		""" rotate block by 90 degrees clock wise """
		set_rotation((rotation + 1) % 4)
	
	func set_rotation(rot):
		var m = tetrout.get_block_matrix(type)
		var m_size = Vector2(len(m[0]), len(m))
		
		matrix = []
		
		if rot % 2 == 1:
			for x in range(m_size.x):
				var row = []
				for y in range(m_size.y):
					var item = m[m_size.y - y - 1][m_size.x - x - 1] if rot == 1 else m[y][x]
					# add item to row
					row.append(item)
				# add row to matrix
				matrix.append(row)
		else:
			for y in range(m_size.y):
				var row = []
				for x in range(m_size.x):
					#
					var item = m[m_size.y - y - 1][m_size.x - x - 1] if rot == 2 else m[y][x]
					# add item to row
					row.append(item)
				# add row to matrix
				matrix.append(row)
		
		rotation = rot
		update_size()
	
	func get_rotation():
		return rotation
		
	var redraw = false
	func _draw():
		""" draw function, renders all blocks """
		for y in range(height):
			for x in range(width):
				var _x = (height - y - 1) * tetrout.BLOCK_SIZE
				var _y = x * tetrout.BLOCK_SIZE
				
				if matrix[y][x] == 1:
					draw_texture(tetrout.block_texture, Vector2(_x, _y), color)

# simple class for ghost block that inherits from Block
class GhostBlock extends Block:
	# GDScript, wtf is that ugly super call
	func _init(_type).(_type):
		# use transparent white color instead because it's a ghost block
		color = Color(1, 1, 1, 0.25)


class AnimatedBlock extends Block:	
	var start_pos
	var desired_pos
	var duration
	var t
	var finished
	
	signal animation_end
	
	func _init(_type).(_type):
		t = 0
		finished = false
		
	func set_animation(_start_pos, _desired_pos, _duration):
		# TODO: maybe remove duration with a singleton constant
		start_pos = _start_pos
		desired_pos = _desired_pos
		duration = _duration
		
		set_global_position(start_pos)

	func _process(delta):
		if finished:
			return
		
		if start_pos and desired_pos:
			if t < 1:
				t += delta / duration
				set_global_position(start_pos.linear_interpolate(desired_pos, min(t, 1)))							
			else:
				finished = true
				emit_signal("animation_end")