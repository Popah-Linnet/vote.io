extends Node2D

const Player = preload("res://scenes/Player.tscn")
const Vote = preload("res://scenes/Vote.tscn")

var players = []

# Ran on successful server connection
func _ready():
	var id = multiplayer.get_unique_id()
	if id != 1:
		_add_player(id)
	
	multiplayer.peer_connected.connect(func (id):
		if id != 1:
			_add_player(id)
			
			if is_multiplayer_authority():
				_update_vote(0)
	)
	multiplayer.peer_disconnected.connect(func (id):
		remove_child(get_node("Player" + str(id)))
		players = players.filter(func (p): p == id)
		
		if is_multiplayer_authority():
			_update_vote(-1)
	)
	
	if is_multiplayer_authority():
		_init_vote_timer()

func _add_player(id: int):
	players.append(id)
	
	var player = Player.instantiate()
	player.name = "Player" + str(id)
	player.set_multiplayer_authority(id)
	add_child(player)

func _init_vote_timer():
	var vote_timer = Timer.new()
	vote_timer.name = "VoteTimer"
	vote_timer.paused = true
	vote_timer.one_shot = true
	add_child(vote_timer)
	vote_timer.start(1)
	
	vote_timer.timeout.connect(_new_vote)

func _update_vote(delta: int):
	$VoteTimer.paused = players.size() < 2
	
	if get_node_or_null("Vote"):
		$Vote.players += delta

func _new_vote():
	var options = ["test 1", "test 2", "test 3"]
	rpc("start_vote", options)
	start_vote(options)

@rpc("any_peer")
func start_vote(options: Array):
	var vote = Vote.instantiate()
	add_child(vote)
	vote.init(10, players.size(), options)
