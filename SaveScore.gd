extends Node2D

var score = 0

func set_score(num):
	score = num

func get_score():
	return score

func save():
	var save_dict = {
		"filename" : get_scene_file_path(), 
		"pos_x" : position.x, 
		"pos_y" : position.y,
		"score" : score
	} 
	return save_dict

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
