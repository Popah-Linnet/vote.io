extends Area2D

const Bullet = preload("res://scenes/Bullet.tscn")

const MAX_SPEED = 400
const FRICTION = 10

var speed = Vector2.ZERO

var health = 100 :
	set(h):
		health = h
		$HealthBar.value = health

func _ready():
	if not is_multiplayer_authority():
		set_process(false)
		return
	
	$Camera2D.enabled = true
	$Body/Head.color = Color.from_hsv(randf(), 0.5, 0.5)

func _process(delta: float):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	speed = lerp(direction * MAX_SPEED, speed, 1 / (1 + FRICTION * delta))
	position += speed * delta
	
	$Body.rotation = Vector2.RIGHT.angle_to(get_global_mouse_position() - position)
	
	if Input.is_action_just_pressed("ui_accept"):
		var count = IdManager.get_id("bullet")
		rpc("spawn_bullet", count, position, $Body.rotation)
		spawn_bullet(count, position, $Body.rotation)

@rpc("any_peer")
func spawn_bullet(count: int, pos: Vector2, rot: float):
	var bullet = Bullet.instantiate()
	bullet.name = name + str(count)
	bullet.shooter = name
	bullet.position = pos
	bullet.rotation = rot
	get_parent().add_child(bullet)
