extends RigidBody2D

var velocity
var screen_size
var asteroidDebris = preload("res://Effects/Thruster.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	global_position.x = wrapf(global_position.x, -$Width.position.x, screen_size.x+$Width.position.x)
	global_position.y = wrapf(global_position.y, -$Height.position.y, screen_size.y+$Height.position.y)

func start(_position, _direction, _velocity, rotation_mult, rootScene):
	rotation = _direction
	position = _position
	velocity = _velocity
	rotation += rotation_mult * randf_range(deg_to_rad(15), deg_to_rad(45))
	linear_velocity = velocity.rotated(rotation)
	angular_velocity = randf_range(PI / 6, PI / 4)
	tree_exited.connect(rootScene._on_small_asteroid_tree_exit)

func _on_body_entered(body: Node) -> void:
	var debris: Array
	if !body.is_in_group("asteroids"):
		$CollisionArea.set_deferred("disabled",true)
		$ImpactSound.play()
		hide()
		for num in range(3): debris.append(asteroidDebris.instantiate())
		for trash in debris:
			trash.position = self.global_position
			trash.linear_velocity = Vector2(randf_range(-250.0, 250.0), randf_range(-250.0, 250.0))
			trash.setTimerTime(0.5)
			get_tree().root.call_deferred("add_child",trash) 
		await $ImpactSound.finished
		queue_free()
