extends CanvasLayer

const VoteOption = preload("res://scenes/VoteOption.tscn")

var players: int
var options: Array
var selected := -1 : 
	set(s):
		var opts = $Panel/List.get_children()
		if selected >= 0:
			opts[selected].remove_theme_color_override("font_color")
		opts[s].add_theme_color_override("font_color", Color.GREEN_YELLOW)
		selected = s
var results = []

func _ready():
	if is_multiplayer_authority():
		set_process(false)

func init(time: int, _players: int, _options: Array):
	options = _options
	for i in range(options.size()):
		var option = VoteOption.instantiate()
		option.text = str(i + 1) + ". " + options[i]
		$Panel/List.add_child(option)
	
	players = _players
	
	if not is_multiplayer_authority():
		$Timer.timeout.connect(_end_vote)
		$Timer.start(time)

func _process(_delta):
	for i in range(options.size()):
		if Input.is_action_just_pressed("option_" + str(i + 1)):
			selected = i

func _end_vote():
	rpc_id(1, "collect_vote", selected)
	queue_free()

# TODO: Make it work with "authority"
@rpc("any_peer")
func collect_vote(i: int):
	results.append(i)
	
	# End vote
	if results.size() == players:
		print(results)
		queue_free()
