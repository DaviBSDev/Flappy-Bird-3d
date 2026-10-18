extends Node3D



var player
var ground
var ground2
var ground3
var pipe1
var pipe2
var pipe3
var pipe4
var seed = RandomNumberGenerator.new()
var spacing = 7.5
var speed = 1
var points = 0
var points_text
var detection
var detection2
var roof
var start = true
var start_screen
var gameover_screen
var bird_c = 0
var model = 1
var bird1
var bird2
var bird3
var sfx_wing
var sfx_wooshing
var sfx_point
var sfx_hit
var sfx_die
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("CharacterBody3D")
	ground = get_node("ground")
	ground2 = get_node("ground2")
	ground3 = get_node("ground3")
	pipe1 = get_node("pipe")
	pipe2 = get_node("pipe2")
	pipe3 = get_node("pipe4")
	pipe4 = get_node("pipe3")
	pipe1.position.y = seed.randf_range(-3, 0)
	pipe2.position.y = seed.randf_range(pipe1.position.y + spacing, 6)
	pipe3.position.y = seed.randf_range(-3,0)
	pipe4.position.y = seed.randf_range(pipe3.position.y + spacing, 6)
	detection = get_node("detection")
	detection2 = get_node("detection2")
	points_text = get_node("points_text")
	points_text.text = "0"
	roof = get_node("roof")
	start_screen = get_node("start")
	gameover_screen = get_node("gameover")
	bird1 = get_node("CharacterBody3D/bird1")
	bird2 = get_node("CharacterBody3D/bird2")
	bird3 = get_node("CharacterBody3D/bird3")
	sfx_wing = get_node("sfx_wing")
	sfx_wooshing = get_node("sfx_wooshing")
	sfx_point = get_node("sfx_point")
	sfx_hit = get_node("sfx_hit")
	sfx_die = get_node("sfx_die")

var is_pressed = false
var is_spin = false
var counter = 0
var gameover = false
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed() and is_spin == false:
		is_pressed = true
		if !(gameover):
			sfx_wing.play()
	else:
		is_pressed = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
var already_1 = false
var already_2 = false
var already_play = false
func _process(delta: float) -> void:
	bird_c += 2 * delta
	if start:
		pipe1.visible = false
		pipe2.visible = false
		pipe3.visible = false
		pipe4.visible = false
		start_screen.visible = true
	else:
		pipe1.visible = true
		pipe2.visible = true
		pipe3.visible = true
		pipe4.visible = true
		start_screen.visible = false
	if is_pressed and start:
		start = false
		sfx_wooshing.play()
	if is_pressed and !(gameover) and !(start):
		if player.rotation.z - 4.5  * delta >= -1:
			player.rotation.z -= 4.5 * delta
		player.position.y += 5 * delta
		is_spin = true
	elif !(is_pressed) and !(start):
		if player.rotation.z + 1.5 * delta <= 1.6:
			player.rotation.z += 1.5 * delta
		player.position.y -= 5 * delta
	if is_spin:
		counter += 60 * delta
	if counter >= 15:
		is_pressed = false
		is_spin = false
		counter = 0
	player.move_and_slide()
	for i in range(player.get_slide_collision_count()):
		var collision = player.get_slide_collision(i)
		var body = collision.get_collider()
		if body == ground or body == ground2 or body == pipe1 or body == pipe2 or body == pipe3 or body == pipe4 or body == roof:
			if !(already_play):
				sfx_hit.play()
				await get_tree().create_timer(0.2).timeout
				sfx_die.play()
				already_play = true
			gameover = true
	for body in detection.get_overlapping_bodies():
		if body == player and !(already_1):
			points += 1
			points_text.text = str(points)
			already_1 = true
			already_2 = false
			speed += 0.005
			spacing -= 0.005
			sfx_point.play()
	for body in detection2.get_overlapping_bodies():
		if body == player and !(already_2):
			points += 1
			points_text.text = str(points)
			already_2 = true
			already_1 = false
			speed += 0.005
			spacing -= 0.005
			sfx_point.play()
	if gameover:
		speed = 0
		gameover_screen.visible = true
		if is_pressed:
			get_tree().reload_current_scene()
	ground.position.x += 1.5 * delta * speed
	ground2.position.x += 1.5 * delta * speed
	ground3.position.x += 1.5 * delta * speed
	if ground.position.x >= 13:
		ground.position.x = -27.12
	elif ground2.position.x >= 13:
		ground2.position.x = -27.12
	elif ground3.position.x >= 13:
		ground3.position.x = -27.12
	if !(start):
		pipe1.position.x += 1.5 * delta * speed
		pipe2.position.x += 1.5 * delta * speed
		pipe3.position.x += 1.5 * delta * speed
		pipe4.position.x += 1.5 * delta * speed
		detection.position.x += 1.5 * delta * speed
		detection2.position.x += 1.5 * delta * speed
	
	if pipe1.position.x >= 1.2:
		pipe1.position.x = pipe3.position.x + -6
		pipe2.position.x = pipe4.position.x + -6
		detection2.position.x = pipe1.position.x
		detection2.position.y = detection2.position.y
		pipe1.position.y = seed.randf_range(-3, 0)
		pipe2.position.y = seed.randf_range(pipe1.position.y + spacing, 6)
	if pipe3.position.x >= 1.2:
		pipe3.position.x = pipe1.position.x + -6
		pipe4.position.x = pipe2.position.x + -6
		detection.position.x = pipe3.position.x
		detection.position.y = pipe3.position.y
		pipe3.position.y = seed.randf_range(-3,0)
		pipe4.position.y = seed.randf_range(pipe3.position.y + spacing, 6)
	if bird_c >= 1:
		model += 1
		if model >= 4:
			model = 1
		bird_c = 0
	if model == 1:
		bird2.visible = false
		bird3.visible = false
		bird1.visible = true
	elif model == 2:
		bird1.visible = false
		bird3.visible = false
		bird2.visible = true
	elif model == 3:
		bird1.visible = false
		bird2.visible = false
		bird3.visible = true
