extends CharacterBody2D 

const speed = 495.0 
@onready var rayCast = $Sprite2D/CollisionShape2D/RayCast2D

func _physics_process(delta): 
	velocity.y = 0.0
	if(Input.get_axis("ui_left", "ui_right")):
		velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed) 
	
	move_and_slide()

func _process(delta):
	velocity.y = 0.0
