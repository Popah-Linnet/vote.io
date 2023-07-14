extends Node2D

const Game = preload("res://scenes/Game.tscn")

func _log(text: String):
	var time = Time.get_time_dict_from_system()
	$Log.append_text("[color=#aaaaaa][%02d:%02d:%02d][/color] " % [time.hour, time.minute, time.second])
	$Log.append_text(text)
	$Log.newline()

@onready var peer = ENetMultiplayerPeer.new()

func _ready():
	$StartServerButton.pressed.connect(_start_server)
	$StartClientButton.pressed.connect(_start_client)
	
	$ConnectTimer.timeout.connect(func ():
		_log("[color=#ee9999]Connection to server [b]" + $IPInput.text + ":" + $PortInput.text + "[/b] timed out[/color]")
	)

func _start_client():
	var err = peer.create_client($IPInput.text, int($PortInput.text))
	if err != Error.OK:
		_log("[color=#ee9999]Error starting client: " + error_string(err) + "[/color]")
		return
	multiplayer.multiplayer_peer = peer
	
	$ConnectTimer.start()
	
	multiplayer.connection_failed.connect(func ():
		_log("[color=#ee9999]Couldn't connect to server at [b]" + $IPInput.text + ":" + $PortInput.text + "[/b][/color]")
	)
	multiplayer.connected_to_server.connect(func ():
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
	)

func _start_server():
	var port = int($PortInput.text)
	var err = peer.create_server(port, int($PlayersInput.text))
	if err != Error.OK:
		_log("[color=#ee9999]Error initializing server: " + error_string(err) + "[/color]")
		return
	multiplayer.multiplayer_peer = peer
	
	_log("[color=#9999ee]Server started on port [b]" + str(port) + "[/b][/color]")
	
	var game = Game.instantiate()
	get_tree().root.add_child(game)
	game.set_process(false)
	
	$StartServerButton.disabled = true
	$StartClientButton.disabled = true
	$IPInput.editable = false
	$PortInput.editable = false
	$PlayersInput.editable = false
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _peer_connected(id):
	_log("New peer with id [b]" + str(id) + "[/b] connected")

func _peer_disconnected(id):
	_log("[color=#ee9999]Peer with id [b]" + str(id) + "[/b] disconnected[/color]")
