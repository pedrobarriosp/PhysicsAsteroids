extends CharacterBody2D

var Bullet = preload("res://Player/Player_bullet.tscn")
var Thruster = preload("res://Effects/Thruster.tscn")
var acceleration: int = 5
var deceleration: int = 1
var maxSpeed: Vector2 = Vector2(300,300)
var minSpeed: Vector2 = Vector2(-300,-300)
var angular_speed = PI
var screen_size

signal playerHit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	print(screen_size)
	print()

func start(startPosition) -> void:
	position = startPosition
	show()
	$PlayerArea/Collision.set_deferred("disabled",false)
	$PhysicsCollision.set_deferred("disabled",false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("play_shoot") and visible:
		shoot()

func get_input(delta: float):
	var input_dir = Input.get_axis("ui_up","ui_down")
	var rotation_dir = Input.get_axis("ui_left","ui_right")
	
	if input_dir != 0 and input_dir != 1:
		velocity += transform.y * input_dir * acceleration
		velocity = velocity.clamp(minSpeed,maxSpeed)
		if !$ThrusterSound.is_playing():
			$ThrusterSound.play()
	else:
		$ThrusterSound.stop()
		velocity = velocity.lerp(Vector2.ZERO,0.05)
	
	rotation += angular_speed * rotation_dir * delta

func shoot():
	var b = Bullet.instantiate()
	b.start($Muzzle.global_position, rotation)
	$ShootSound.play()
	get_tree().root.add_child(b)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input(delta)
	move_and_collide(velocity * delta)

func set_collisionDisabled(value):
	$PlayerArea/Collision.set_deferred("disabled",value)
	$PhysicsCollision.set_deferred("disabled",value)

func _on_screen_notifier_screen_exited() -> void:
	global_position.x = wrapf(global_position.x, -$Width.position.x, screen_size.x+$Width.position.x)
	global_position.y = wrapf(global_position.y, -$Height.position.y, screen_size.y+$Height.position.y)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self:
		$ShieldSound.play()
		playerHit.emit()

func _on_game_over() -> void:
	$PlayerArea/Collision.set_deferred("disabled",true)
	$PhysicsCollision.set_deferred("disabled",true)


func _on_game_view_game_start() -> void:
	$PlayerArea/Collision.set_deferred("disabled",false)
	$PhysicsCollision.set_deferred("disabled",false)


func _on_thruster_timer_timeout() -> void:
	var thruster
	if Input.get_axis("ui_up","ui_down") != 0:
		thruster = Thruster.instantiate()
		thruster.position = $Thruster.global_position
		thruster.linear_velocity = (self.velocity*0.25)*(-1)
		thruster.setTimerTime(0.25)
		get_tree().root.add_child(thruster)
