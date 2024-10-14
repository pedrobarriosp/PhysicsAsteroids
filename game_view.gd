extends Node

@export var asteroidLarge: PackedScene
var currentLargeAsteroids
var currentSmallAsteroids
var largeAsteroidLimit: int = 4
var largeAsteroidCount: int
var gameScore: int
var playerLives: int

signal gameOver
signal gameStart

func startGame() -> void:
	largeAsteroidCount = 0
	gameScore = 0
	playerLives = 3
	$UI/Score.text = "0"
	set_livesLabel(playerLives)
	$AsteroidTimer.start()
	$UI.visible = true
	gameStart.emit()

func set_livesLabel(lives):
	$UI/Lives.text = ""
	for num in range(lives):
		$UI/Lives.text += "X " 

func remove_playerLive():
	playerLives -= 1
	set_livesLabel(playerLives)

func game_over():
	$AsteroidTimer.stop()
	$GameOver/FinalScore.text = str(gameScore)
	$GameOver.visible = true
	$UI.visible = false
	$Player.visible = false
	gameOver.emit()
		
func _on_asteroid_timer_timeout() -> void:
	if largeAsteroidCount < largeAsteroidLimit:
		var asteroid = asteroidLarge.instantiate()
		var asteroid_spawn_location = $AsteroidPath/AsteroidSpawn
		var asteroid_velocity = Vector2(randf_range(150.0, 250.0), 0.0)
		asteroid.set_velocity(asteroid_velocity)
		asteroid.set_rootScene(self)
		asteroid_spawn_location.progress_ratio = randf()
		# Set the mob's direction perpendicular to the path direction.
		var asteroid_direction = asteroid_spawn_location.rotation + PI / 2
		# Set the mob's position to a random location.
		asteroid.position = asteroid_spawn_location.position
		# Add some randomness to the direction.
		asteroid_direction += randf_range(-PI / 4, PI / 4)
		asteroid.rotation = asteroid_direction
		asteroid.linear_velocity = asteroid_velocity.rotated(asteroid_direction)
		asteroid.angular_velocity = randf_range(-PI / 6, PI / 2)
		# Spawn the mob by adding it to the Main scene.
		asteroid.tree_exited.connect(_on_large_asteroid_tree_exit)
		add_child(asteroid)
		largeAsteroidCount += 1

func _on_small_asteroid_tree_exit() -> void:
	gameScore += 25
	$UI/Score.text = str(gameScore)

func _on_large_asteroid_tree_exit() -> void:
	largeAsteroidCount -= 1
	gameScore += 50
	$UI/Score.text = str(gameScore)

func _on_player_player_hit() -> void:
	$Player.set_collisionDisabled(true)
	get_tree().call_group("asteroids","queue_free")
	largeAsteroidCount = 0
	remove_playerLive()
	if playerLives <= 0:
		game_over()
	else:
		$Player.set_collisionDisabled(false)


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	$Menu.visible = false
	$Player.visible = true
	$GameStartTimerLabel.visible = true
	$GameStartTimer.start()

func _on_game_start_timer_timeout() -> void:
	$GameStartTimerLabel.visible = false
	startGame()

func _on_menu_button_pressed() -> void:
	$Menu.visible = true
	$GameOver.visible = false
