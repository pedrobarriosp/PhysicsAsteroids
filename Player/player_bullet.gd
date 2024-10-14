extends RigidBody2D

var speed = 1000

func start(_position, _direction):
	rotation = _direction
	position = _position
	linear_velocity = Vector2.UP.rotated(rotation) * speed

func _on_screen_exit() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	queue_free()
