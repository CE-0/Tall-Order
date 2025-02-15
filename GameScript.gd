extends Node2D

var score = 0
const maxHealth = 5
var health = maxHealth
var gameLevel = 1 
var ingredient 
var ingredientOnScreen = false 
var lastIngredientX 
var gameOverMusicPlayed = false

#const spawnPointY = -500.0 

var itemArray = [preload("res://F_Cheese.tscn"), preload("res://F_Ketchup.tscn"), 
	preload("res://F_Mustard.tscn"), preload("res://F_Lettuce.tscn"), preload("res://F_Onion.tscn"), 
	preload("res://F_Pickle.tscn"), preload("res://F_Tomato.tscn"), preload("res://F_Boot.tscn"), 
	preload("res://F_Fishbone.tscn"), preload("res://F_Sweatsocks.tscn")] 
var chosenItem 

var stackedItemDict = {
	"Cheese" : preload("res://S_Cheese.tscn"), 
	"Ketchup" : preload("res://S_Ketchup.tscn"), 
	"Mustard" : preload("res://S_Mustard.tscn"), 
	"Lettuce" : preload("res://S_Lettuce.tscn"), 
	"Onion" : preload("res://S_Onion.tscn"), 
	"Pickle" : preload("res://S_Pickle.tscn"), 
	"Tomato" : preload("res://S_Tomato.tscn")
} 

var intro = preload("res://SFX/Intro.mp3")
var catch = preload("res://SFX/Hell yeah.mp3")
var lose = preload("res://SFX/Oh no.mp3")
var end = preload("res://SFX/Game over.mp3")

@onready var player = $"../Burger"
@onready var scoreboard = $"../Camera2D/Score Display"
@onready var hearts = [$"../Camera2D/Heart", $"../Camera2D/Heart2", $"../Camera2D/Heart3", 
$"../Camera2D/Heart4", $"../Camera2D/Heart5"]
@onready var camera = $"../Camera2D" 
@onready var cast = $"../Burger/RayCast2D" 
@onready var audPlayer = $"../AudioStreamPlayer2D" 
@onready var saver = $"../Save Data Manager"
#@onready var heart1 = $"../Heart"
#@onready var heart2 = $"../Heart2"
#@onready var heart3 = $"../Heart3"
#@onready var heart4 = $"../Heart4"
#@onready var heart5 = $"../Heart5"

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func _add_point(): 
	score += 1 
	saver.set_score(score)
	scoreboard.text = str(score) 

#func _get_child_by_class(node, cl):
#	for c in node.get_children():
#		if c.get_class() == cl:
#			return c

func _spawn_ingredient(spawnPointY, condition):
	if (!ingredientOnScreen):
		var spawnPointX = randf_range(-280.0, 280.0)
		if (condition):
			while (abs(spawnPointX-lastIngredientX) < 30):
				spawnPointX  = randf_range(-280.0, 280.0)
		var spawnPoint = Vector2(spawnPointX, spawnPointY) 
		lastIngredientX = spawnPointX
		var rNum = (randi() % itemArray.size())
		#print_debug("Item No. " + str(rNum))
		chosenItem = itemArray[rNum]
		var itemInst = chosenItem.instantiate() 
		ingredient = itemInst 
		#print_debug(ingredient.isGood)
		itemInst.position = spawnPoint
		add_child(itemInst) 
		ingredientOnScreen = true
		#print_debug("Spawned at (" + str(spawnPoint.x) + ", " + str(spawnPoint.y) + ")")

func _stack_ingredient(name, pos): 
	var toStack = stackedItemDict[name].instantiate()
	toStack.position = player.to_local(pos) 
	player.add_child(toStack) 
	cast.target_position.y -= toStack.texture.get_height()
	#print_debug("Height: " + str(toStack.texture.get_height()))
	_shift_camera(toStack.texture.get_height())
	player.get_child(1, false).shape.extents.y -= toStack.texture.get_height() 
	if (!audPlayer.is_playing()):
		audPlayer.stream = catch
		audPlayer.play()
	#print_debug("New parent of raycast: " + str(cast.get_parent()))

func _destroy_ingredient():
	var ingredientPtr = ingredient 
	ingredientPtr.queue_free() 
	ingredient = null 
	ingredientOnScreen = false

func _auto_destroy_ingredient(): 
	if (ingredient.position.y > camera.position.y + 325):
		if (ingredient.isGood):
			_lose_health() 
		_destroy_ingredient() 

func _lose_health():
	if (health > 0):
		hearts[health-1].hide()
		#print_debug("Lost life no. " + str(health))
		health -= 1 
		if (health >= 1):
			if (!audPlayer.is_playing()):
				audPlayer.stream = lose
				audPlayer.play()

func _shift_camera(num):
	camera.position.y -= num

func _go_to_results():
	get_tree().change_scene_to_file("res://Results.tscn")

func _game_over(): 
	save_game()
	get_tree().paused = true 
	audPlayer.stream = end
	audPlayer.play()
	await get_tree().create_timer(end.get_length()).timeout
	get_tree().paused = false
	_go_to_results()


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	#await get_tree().create_timer(3).timeout
	audPlayer.stream = intro
	audPlayer.play()
	await get_tree().create_timer(intro.get_length()).timeout
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#cast.set_process(false)
	#cast.set_physics_process(false)
	for i in range(0, health, 1):
		hearts[i].show()
	var pointY = camera.position.y - 350
	if (health != 0): 
		_spawn_ingredient(pointY, lastIngredientX != null) 
		_auto_destroy_ingredient()
	else: 
		_game_over() 
	
	
