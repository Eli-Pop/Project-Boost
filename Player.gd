extends RigidBody3D
# Called when the node enters the scene tree for the first time.
## How much vertical force to apply when moving.
@export_range(750.0,3000.0) var thrust: float = 1000.0;

@export var torque_thrust: float = 100.0;

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio;
#dragged and then hit ctrl and dropped node to hear. We now have acces to the node and its properties.
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles



var is_transitioning: bool = false;
#func _ready() -> void:
	#pass # Replace with function body.
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		#position.y += delta;
		apply_central_force(basis.y * delta * thrust); #Multiplying it by delta, it makes it framerate dependent.
		#Multiplying delta by 1000 as delta is already sluggish.
		booster_particles.emitting = true; #emits the particles as boost visual
		if rocket_audio.playing == false: #If audio is already playing, it will not restart sound.
			rocket_audio.play(); #With this conditional, it will continuously play without restarting every frame.
	else:
		booster_particles.emitting = false; #stops the boost visual.
		rocket_audio.stop();
	
	if Input.is_action_pressed("rotate_left"):#rotates counter clockwise
		#rotate_z(delta); #it turns the model in radians
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))#z is a large number and times by delta to turn quicker.
		right_booster_particles.emitting = true;
	else: #otherwise do the following
		right_booster_particles.emitting = false; #stop emitting the right side booster.
	
	if Input.is_action_pressed("rotate_right"):#rotates clockwise
		#rotate_z(-delta);#using negative, I am rotating clockwise.
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta));
		left_booster_particles.emitting = true;
	else:
		left_booster_particles.emitting = false;
		
	#Will write code to exit out of game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit();


func _on_body_entered(body: Node) -> void:
	#pass # Replace with function body.
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path);
		if "Hazard" in body.get_groups():
			crash_sequence();


func crash_sequence() -> void:
	print("KABOOM");
	explosion_particles.emitting = true;
	explosion_audio.play(); #had to make the tween_interval time longer as it would cut off sound.
	set_process(false);#disables controls when crashing.
	is_transitioning = true;
	var tween = create_tween();
	tween.tween_interval(2.5);
	tween.tween_callback(get_tree().reload_current_scene);

func complete_level(next_level_file: String) -> void:
	print("Level Complete");
	success_particles.emitting = true;
	success_audio.play(); #Had to also increase time to hear whole of sound.
	set_process(false);#disables controls when crashing.
	is_transitioning = true;# rather this disables the controls.
	var tween = create_tween();
	tween.tween_interval(1.5);
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file));
