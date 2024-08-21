extends AnimatableBody3D

@export var destination: Vector3; #x,y,z positions will be on the sidebar
@export var duration: float = 1.0; #default to 1.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body. Default line, don't need it.
	var tween = create_tween(); #creating a local tween variable
	tween.set_loops(); #will run the following lines in an indefinite loop.
	tween.set_trans(Tween.TRANS_SINE); #Will make the below line movements smoother.
	tween.tween_property(self,"global_position",global_position + destination, duration);
	tween.tween_property(self,"global_position",global_position, duration);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
