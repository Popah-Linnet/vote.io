extends Area2D

const Player = preload("res://scenes/Player.gd")

var speed = 1000
var time = 1
var shooter: StringName

func _ready():
	if multiplayer.get_unique_id() != 1:
		return
	
	area_entered.connect(_area_entered)
	
	$Timer.start(time)
	$Timer.timeout.connect(func ():
		rpc("delete")
		queue_free()
	)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _area_entered(area: Area2D):
	if area is Player and shooter != area.name:
		var player = area as Player
		rpc_id(player.get_multiplayer_authority(), "damage", player.get_path(), 5)
		rpc("delete")
		queue_free()

@rpc("any_peer")
func delete():
	queue_free()

@rpc
func damage(path: NodePath, value: int):
	var player = get_parent().get_node(path) as Player
	player.health -= value
