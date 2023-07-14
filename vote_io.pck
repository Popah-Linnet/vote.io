GDPC                                                                                            X   res://.godot/exported/133200997/export-0cb53d896fce5bb6032f4cfdf2da3deb-VoteOption.scn  �6            `�x\ƀ���3o
�    T   res://.godot/exported/133200997/export-7cd7e18b2f210ec110de26632df1f5cd-Bullet.scn  0      �      6����V;C�Ե+�V    P   res://.godot/exported/133200997/export-8e836f4621de545031f781562e7b3b7d-Menu.scnp      L      ��vJoց�?X��s½    P   res://.godot/exported/133200997/export-a0f6a5b975525e646798eedc44db42c9-Vote.scn 3      �      5����{U�
�$��    T   res://.godot/exported/133200997/export-e8220e74d1354b9e6b168b513689419c-Player.scn  0%      <	      {���~j��C�2�Wj    P   res://.godot/exported/133200997/export-ff8ceb9b2bd5b48777d3d52e811276ab-Game.scn       0      ���]R��|���R    ,   res://.godot/global_script_class_cache.cfg                 ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex:      ^      2��r3��MgB�[79       res://.godot/uid_cache.bin  �]      �       	6��\�X8pHd�7       res://icon.svg  `M      N      ]��s�9^w/�����       res://icon.svg.import   pG      K      *a�S�(k���h�q��       res://project.binary�^      !      ��&���x�m�to�       res://scenes/Bullet.gd                ��Er�7�\�;�        res://scenes/Bullet.tscn.remap  �J      c       ������Ñ����'o        res://scenes/BulletManager.gd          _       W��O�RW���L�>W�       res://scenes/Game.gd�      �      K�to��Xe�|/�[�       res://scenes/Game.tscn.remap0K      a       ;�6&��7��@���T_       res://scenes/Menu.gdP            �8{� b8���0���       res://scenes/Menu.tscn.remap�K      a       �,H͐qڊ6Ϡ�|,fg       res://scenes/Player.gd  �       p      �=�$#��:�8��h9�        res://scenes/Player.tscn.remap  L      c       ��7�O4���
�E����       res://scenes/Vote.gdp.      �      _����,�n��IK�+       res://scenes/Vote.tscn.remap�L      a       ��;��cl�F><ʊ�    $   res://scenes/VoteOption.tscn.remap  �L      g       t���N �£����    list=Array[Dictionary]([])
����extends Area2D

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
�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled           local://RectangleShape2D_cqtld +         local://PackedScene_lqd40 \         RectangleShape2D       
     �A   A         PackedScene          	         names "         Bullet    Area2D 
   ColorRect    offset_left    offset_top    offset_right    offset_bottom    color    CollisionShape2D    shape    Timer    	   variants            p�     ��     pA     �@   
�t>
�t>
�t>  �?                node_count             nodes     (   ��������       ����                      ����                                                    ����   	                  
   
   ����              conn_count              conns               node_paths              editable_instances              version             RSRCO+NoP��extends Node

var count = 0 :
	get:
		count += 1
		if count > 100:
			count = 1
		return count
�extends Node2D

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
���RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/Game.gd ��������      local://PackedScene_v0w13          PackedScene          	         names "   	      Game    script    Node2D 
   ColorRect    offset_left    offset_top    offset_right    offset_bottom    color    	   variants                      ��     �A   ���=���=���=  �?      node_count             nodes        ��������       ����                            ����                                           conn_count              conns               node_paths              editable_instances              version             RSRCextends Node2D

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
�I(��Lg��`iRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/Menu.gd ��������      local://PackedScene_i7t1v          PackedScene          	         names "         Server    z_index    script    Node2D    IPLabel    offset_left    offset_top    offset_right    offset_bottom    text    Label    IPInput 	   TextEdit 
   PortLabel 
   PortInput    PlayersLabel    PlayersInput    Log    custom_minimum_size    size_flags_horizontal    bbcode_enabled    scroll_following    RichTextLabel    StartServerButton    Button    StartClientButton    ConnectTimer 
   wait_time 	   one_shot    Timer    	   variants    )                        �A     A     �B     B   
   Server IP      �B     �@     rC     B   
   127.0.0.1      �@     DB     �B      Server port      0B     �B      23452      B     �B     �B     �B      Players      �B     �B      32 
         "D     zC    ��D     "D                 �@     �B     C      Start server      #C     CC      Start client      @@      node_count             nodes     �   ��������       ����                            
      ����                           	                        ����                  	      
   	                  
      ����                           	                        ����                  	         	                  
      ����                           	                        ����                  	         	                        ����                                                                 ����      !      "      	      #   	   $                     ����      !      %      	      &   	   '                     ����      (                    conn_count              conns               node_paths              editable_instances              version             RSRC�^extends Area2D

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
		rpc("spawn_bullet", position, $Body.rotation, name)
		spawn_bullet(position, $Body.rotation, name)

@rpc("any_peer")
func spawn_bullet(pos: Vector2, rot: float, shooter: StringName):
	var bullet = Bullet.instantiate()
	bullet.name = "Bullet" + str(BulletManager.count)
	bullet.position = pos
	bullet.rotation = rot
	bullet.shooter = shooter
	get_parent().add_child(bullet)
RSRC                     PackedScene            ��������                                                  . 	   position    Body    Head    color    health 	   rotation    resource_local_to_scene    resource_name    properties/0/path    properties/0/spawn    properties/0/sync    properties/1/path    properties/1/spawn    properties/1/sync    properties/2/path    properties/2/spawn    properties/2/sync    properties/3/path    properties/3/spawn    properties/3/sync    script    custom_solver_bias    radius 	   _bundled       Script    res://scenes/Player.gd ��������   %   local://SceneReplicationConfig_7o5j2 �         local://CircleShape2D_gyxrd �         local://PackedScene_pv01d �         SceneReplicationConfig    	               
                                                                                                                               CircleShape2D          33�A         PackedScene          	         names "         Player    script    Area2D 
   HealthBar    offset_left    offset_top    offset_right    offset_bottom    value    show_percentage    ProgressBar    Body    anchors_preset    anchor_left    anchor_top    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    pivot_offset 
   ColorRect    Head    layout_mode    color 	   Camera2D    enabled    MultiplayerSynchronizer    replication_config    CollisionShape2D    shape    	   variants                      �     �     B     ��     �B                   ?     ��     ��     �A     �A      
     �A  �A            �A     @A     B     �A                 �?                         node_count             nodes     i   ��������       ����                      
      ����                                 	                        ����                                    	      
                                                  ����                                                         ����                           ����                           ����                   conn_count              conns               node_paths              editable_instances              version             RSRC�Kextends CanvasLayer

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
�B5�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/Vote.gd ��������      local://PackedScene_rtynn          PackedScene          	         names "         Vote    script    CanvasLayer    Panel    anchors_preset    anchor_left    anchor_right    offset_left    offset_right    grow_horizontal    PanelContainer    List    layout_mode    VBoxContainer    Timer    	   variants                             ?    ���    ��C            node_count             nodes     ,   ��������       ����                      
      ����                                 	                       ����                           ����              conn_count              conns               node_paths              editable_instances              version             RSRC�l^�bG=����RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_ukw21 �          PackedScene          	         names "   	      VoteOption    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    size_flags_horizontal    text    horizontal_alignment    Label    	   variants            �?                  test             node_count             nodes        ��������       ����                                                         conn_count              conns               node_paths              editable_instances              version             RSRC���o��ʞ���D�GST2   �   �      ����               � �        &  RIFF  WEBPVP8L  /������!"2�H�l�m�l�H�Q/H^��޷������d��g�(9�$E�Z��ߓ���'3���ض�U�j��$�՜ʝI۶c��3� [���5v�ɶ�=�Ԯ�m���mG�����j�m�m�_�XV����r*snZ'eS�����]n�w�Z:G9�>B�m�It��R#�^�6��($Ɓm+q�h��6�4mb�h3O���$E�s����A*DV�:#�)��)�X/�x�>@\�0|�q��m֋�d�0ψ�t�!&����P2Z�z��QF+9ʿ�d0��VɬF�F� ���A�����j4BUHp�AI�r��ِ���27ݵ<�=g��9�1�e"e�{�(�(m�`Ec\]�%��nkFC��d���7<�
V�Lĩ>���Qo�<`�M�$x���jD�BfY3�37�W��%�ݠ�5�Au����WpeU+.v�mj��%' ��ħp�6S�� q��M�׌F�n��w�$$�VI��o�l��m)��Du!SZ��V@9ד]��b=�P3�D��bSU�9�B���zQmY�M~�M<��Er�8��F)�?@`�:7�=��1I]�������3�٭!'��Jn�GS���0&��;�bE�
�
5[I��=i�/��%�̘@�YYL���J�kKvX���S���	�ڊW_�溶�R���S��I��`��?֩�Z�T^]1��VsU#f���i��1�Ivh!9+�VZ�Mr�טP�~|"/���IK
g`��MK�����|CҴ�ZQs���fvƄ0e�NN�F-���FNG)��W�2�JN	��������ܕ����2
�~�y#cB���1�YϮ�h�9����m������v��`g����]1�)�F�^^]Rץ�f��Tk� s�SP�7L�_Y�x�ŤiC�X]��r�>e:	{Sm�ĒT��ubN����k�Yb�;��Eߝ�m�Us�q��1�(\�����Ӈ�b(�7�"�Yme�WY!-)�L���L�6ie��@�Z3D\?��\W�c"e���4��AǘH���L�`L�M��G$𩫅�W���FY�gL$NI�'������I]�r��ܜ��`W<ߛe6ߛ�I>v���W�!a��������M3���IV��]�yhBҴFlr�!8Մ�^Ҷ�㒸5����I#�I�ڦ���P2R���(�r�a߰z����G~����w�=C�2������C��{�hWl%��и���O������;0*��`��U��R��vw�� (7�T#�Ƨ�o7�
�xk͍\dq3a��	x p�ȥ�3>Wc�� �	��7�kI��9F}�ID
�B���
��v<�vjQ�:a�J�5L&�F�{l��Rh����I��F�鳁P�Nc�w:17��f}u}�Κu@��`� @�������8@`�
�1 ��j#`[�)�8`���vh�p� P���׷�>����"@<�����sv� ����"�Q@,�A��P8��dp{�B��r��X��3��n$�^ ��������^B9��n����0T�m�2�ka9!�2!���]
?p ZA$\S��~B�O ��;��-|��
{�V��:���o��D��D0\R��k����8��!�I�-���-<��/<JhN��W�1���(�#2:E(*�H���{��>��&!��$| �~�+\#��8�> �H??�	E#��VY���t7���> 6�"�&ZJ��p�C_j����	P:�~�G0 �J��$�M���@�Q��Yz��i��~q�1?�c��Bߝϟ�n�*������8j������p���ox���"w���r�yvz U\F8��<E��xz�i���qi����ȴ�ݷ-r`\�6����Y��q^�Lx�9���#���m����-F�F.-�a�;6��lE�Q��)�P�x�:-�_E�4~v��Z�����䷳�:�n��,㛵��m�=wz�Ξ;2-��[k~v��Ӹ_G�%*�i� ����{�%;����m��g�ez.3���{�����Kv���s �fZ!:� 4W��޵D��U��
(t}�]5�ݫ߉�~|z��أ�#%���ѝ܏x�D4�4^_�1�g���<��!����t�oV�lm�s(EK͕��K�����n���Ӌ���&�̝M�&rs�0��q��Z��GUo�]'G�X�E����;����=Ɲ�f��_0�ߝfw�!E����A[;���ڕ�^�W"���s5֚?�=�+9@��j������b���VZ^�ltp��f+����Z�6��j�`�L��Za�I��N�0W���Z����:g��WWjs�#�Y��"�k5m�_���sh\���F%p䬵�6������\h2lNs�V��#�t�� }�K���Kvzs�>9>�l�+�>��^�n����~Ěg���e~%�w6ɓ������y��h�DC���b�KG-�d��__'0�{�7����&��yFD�2j~�����ټ�_��0�#��y�9��P�?���������f�fj6͙��r�V�K�{[ͮ�;4)O/��az{�<><__����G����[�0���v��G?e��������:���١I���z�M�Wۋ�x���������u�/��]1=��s��E&�q�l�-P3�{�vI�}��f��}�~��r�r�k�8�{���υ����O�֌ӹ�/�>�}�t	��|���Úq&���ݟW����ᓟwk�9���c̊l��Ui�̸z��f��i���_�j�S-|��w�J�<LծT��-9�����I�®�6 *3��y�[�.Ԗ�K��J���<�ݿ��-t�J���E�63���1R��}Ғbꨝט�l?�#���ӴQ��.�S���U
v�&�3�&O���0�9-�O�kK��V_gn��k��U_k˂�4�9�v�I�:;�w&��Q�ҍ�
��fG��B��-����ÇpNk�sZM�s���*��g8��-���V`b����H���
3cU'0hR
�w�XŁ�K݊�MV]�} o�w�tJJ���$꜁x$��l$>�F�EF�޺�G�j�#�G�t�bjj�F�б��q:�`O�4�y�8`Av<�x`��&I[��'A�˚�5��KAn��jx ��=Kn@��t����)�9��=�ݷ�tI��d\�M�j�B�${��G����VX�V6��f�#��V�wk ��W�8�	����lCDZ���ϖ@���X��x�W�Utq�ii�D($�X��Z'8Ay@�s�<�x͡�PU"rB�Q�_�Q6  C�[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bwhvxs82ou1dx"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.svg"
dest_files=["res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false
Hf��[remap]

path="res://.godot/exported/133200997/export-7cd7e18b2f210ec110de26632df1f5cd-Bullet.scn"
����0U�e[�q�[remap]

path="res://.godot/exported/133200997/export-ff8ceb9b2bd5b48777d3d52e811276ab-Game.scn"
]7�zÚ=<��-ư�[remap]

path="res://.godot/exported/133200997/export-8e836f4621de545031f781562e7b3b7d-Menu.scn"
y��1��}L�@��YS[remap]

path="res://.godot/exported/133200997/export-e8220e74d1354b9e6b168b513689419c-Player.scn"
j��p���q��	�[remap]

path="res://.godot/exported/133200997/export-a0f6a5b975525e646798eedc44db42c9-Vote.scn"
ӆ�Sb�x$U���2[remap]

path="res://.godot/exported/133200997/export-0cb53d896fce5bb6032f4cfdf2da3deb-VoteOption.scn"
oz���s��<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
�J   >Q��ФN   res://scenes/Bullet.tscn�#��(   res://scenes/Game.tscnFsu��UA   res://scenes/Menu.tscn���#Y�sT   res://scenes/Player.tscntsր>Oyq   res://scenes/Vote.tscn�B��4��1   res://scenes/VoteOption.tscnUKp:�6   res://icon.svg?�y��~��ECFG      application/config/name         vote.io    application/run/main_scene          res://scenes/Menu.tscn     application/config/features(   "         4.0    GL Compatibility       application/config/icon         res://icon.svg     autoload/BulletManager(         *res://scenes/BulletManager.gd     input/move_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/move_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/move_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/move_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/option_1�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   1   	   key_label             unicode    1      echo          script         input/option_2�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   2   	   key_label             unicode    2      echo          script         input/option_3�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   3   	   key_label             unicode    3      echo          script         input/option_4�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   4   	   key_label             unicode    4      echo          script      #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility�3�V���zx��5