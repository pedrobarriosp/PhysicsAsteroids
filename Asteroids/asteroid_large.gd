extends RigidBody2D

var asteroidSmall = preload("res://Asteroids/Asteroid_Small.tscn")
var asteroidDebris = preload("res://Effects/Thruster.tscn")
var velocity
var screen_size
var rootScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	global_position.x = wrapf(global_position.x, -$Width.position.x, screen_size.x+$Width.position.x)
	global_position.y = wrapf(global_position.y, -$Height.position.y, screen_size.y+$Height.position.y)

func _on_body_entered(body: Node) -> void:
	var debris: Array
	if !body.is_in_group("asteroids"):
		$CollisionArea.set_deferred("disabled",true)
		$ImpactSound.play()
		hide()
		if body.name != "Player":
			var smallOne = asteroidSmall.instantiate()
			var smallTwo = asteroidSmall.instantiate()
			smallOne.start(self.global_position + Vector2(0,25), rotation, velocity, 1, rootScene)
			smallTwo.start(self.global_position - Vector2(0,25), rotation, velocity, (-1), rootScene)
			get_tree().root.call_deferred("add_child",smallOne) 
			get_tree().root.call_deferred("add_child",smallTwo)
		for num in range(3): debris.append(asteroidDebris.instantiate())
		for trash in debris:
			trash.position = self.global_position
			trash.linear_velocity = Vector2(randf_range(-250.0, 250.0), randf_range(-250.0, 250.0))
			trash.setTimerTime(0.5)
			get_tree().root.call_deferred("add_child",trash) 
		await $ImpactSound.finished
		queue_free()
		

func get_velocity():
	return velocity

func set_velocity(_velocity):
	velocity = _velocity

func set_rootScene(_root):
	rootScene = _root
