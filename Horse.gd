extends KinematicBody

export var player_path: NodePath

export var max_speed := 5.0
export var gallop_speed := 20.0
export var trot_speed := 10.0
export var rotation_speed := 8.0

var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * 0.05

onready var _model: Spatial = $Model
onready var _timer: Timer = $Timer
onready var _player := get_node(player_path) 

onready var _agent: NavigationAgent = $NavigationAgent
var riding := false

func _ready() -> void:
	_timer.connect("timeout", self, "_update_pathfinding")
	_agent.connect("velocity_computed", self, "_move")


func _physics_process(delta: float) -> void:
	if !riding:
		if _agent.is_navigation_finished():
			return
		
		var target_global_position := _agent.get_next_location()
		var direction := global_transform.origin.direction_to(target_global_position)
		var distance := global_transform.origin.distance_to(_player.global_transform.origin)
		
		_agent.max_speed = max_speed
		if distance > 20:
			_agent.max_speed = gallop_speed
		elif distance > 10:
			_agent.max_speed = trot_speed
		var desired_velocity = direction * _agent.max_speed

		var steering = (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		#_agent.set_velocity(_velocity)
		move_and_slide(desired_velocity)
	else:
		var input_left_right := (
			Input.get_action_strength("ui_right")
			- Input.get_action_strength("ui_left")
		)
		var input_forward_back := (
			Input.get_action_strength("ui_down")
			- Input.get_action_strength("ui_up")
		)
		var raw_input = Vector2(input_left_right, input_forward_back)
		var speed = max_speed
		if Input.is_action_pressed("sprint"):
			speed = gallop_speed
		
		move_and_slide(Vector3(raw_input.x,0,raw_input.y) * speed)
		
func rideHorse() -> Vector3:
	riding = true
	return $SaddlePos.global_translation

func getOffHorse() -> Vector3:
	riding = false
	return $StepDown.global_translation

func _move(velocity: Vector3) -> void:
	_velocity = move_and_slide(velocity, Vector3.UP)
	var direction := Vector3(velocity.x, 0, velocity.z).normalized()
	_orient_character_to_direction(direction)


func _orient_character_to_direction(direction: Vector3) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	#_model.transform.basis = _model.transform.basis.slerp(rotation_basis, get_physics_process_delta_time() * rotation_speed)
	move_and_slide(direction)
	pass

func _update_pathfinding() -> void:
	_agent.set_target_location(_player.global_transform.origin)
