extends NavigationMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var object : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#bake_navigation_mesh()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var obj = object.instance()
	$Spatial.add_child(obj)
	bake_navigation_mesh(true)
	pass # Replace with function body.
