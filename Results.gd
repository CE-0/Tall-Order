extends Node2D

@onready var youScored = $"../You Scored"


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"]) 
		new_object.set_score(node_data["score"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "pos_x" or i == "pos_y" or i == "score":
				continue
			new_object.set(i, node_data[i]) 
		
		return new_object

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if (Input.is_key_pressed(KEY_SPACE)):
		get_tree().change_scene_to_file("res://Title Screen.tscn")
	elif (Input.is_key_pressed(KEY_R)):
		get_tree().change_scene_to_file("res://Game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	var loader = load_game()
	youScored.text = "You scored " + str(loader.get_score()) + " points"
