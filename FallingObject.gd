extends CharacterBody2D

@export var fallSpeed = 385.0
@export var isGood = false

func _set_speed(num):
	fallSpeed = num

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y = fallSpeed
	move_and_slide()
