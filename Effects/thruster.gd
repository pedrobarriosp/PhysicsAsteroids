extends RigidBody2D

func _on_timer_timeout() -> void:
	queue_free()

func setTimerTime(value):
	$Timer.wait_time = value
