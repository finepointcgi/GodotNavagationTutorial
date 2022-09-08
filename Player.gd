extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 10
var horseObject
var ridingHorse : bool
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !ridingHorse:
		var input_left_right := (
			Input.get_action_strength("ui_right")
			- Input.get_action_strength("ui_left")
		)
		var input_forward_back := (
			Input.get_action_strength("ui_down")
			- Input.get_action_strength("ui_up")
		)
		var raw_input = Vector2(input_left_right, input_forward_back)
		move_and_slide(Vector3(raw_input.x, 0, raw_input.y) * speed, Vector3.UP)
	if Input.is_action_just_pressed("ui_select"):
		if ridingHorse:
			leave_horse(horseObject)
			ridingHorse = false
			$CollisionShape.disabled = false
		else:
			var space_state = get_world().direct_space_state
			var result : Dictionary = space_state.intersect_ray(global_translation, Vector3(0,0,5) + global_translation, [self])
			print(result)
			if result.size() > 0:
				if result.collider.name == "Horse":
					$CollisionShape.disabled = true
					ride_horse(result)
					horseObject = result
					ridingHorse = true
	
	pass

func ride_horse(horse):
	var translation = horse.collider.rideHorse()
	get_parent().remove_child(self)
	horse.collider.add_child(self)
	global_translation = translation 
	
func leave_horse(horse):
	var translation = horse.collider.getOffHorse()
	var root = get_tree().get_root()
	get_parent().remove_child(self)
	root.add_child(self)
	global_translation = translation
