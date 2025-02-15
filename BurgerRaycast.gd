extends RayCast2D

@onready var manager = $"../../Game Manager"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (is_colliding()):
		#print_debug("Hit, baby!") 
		#print_debug("Collided with " + str(get_collider())) 
		if (str(get_collider()).begins_with("F_")):
			if (get_collider().isGood):
				var name = str(get_collider()).split(":", false, 1)[0].split("_", false, 1)[1]
				#print_debug(name)
				manager._destroy_ingredient()
				manager._add_point()
				manager._stack_ingredient(name, get_collision_point())
				#print_debug("Collided at: " + str(get_collision_point()))
			else: 
				manager._destroy_ingredient()
				manager._lose_health()
		
