extends Node3D

@export var player_scene: PackedScene
const DEFAULT_PORT := 7777
var server_port: int = DEFAULT_PORT
const MAX_CLIENTS := 64
const ZONE_HALF_SIZE := 38.0
var is_server := false
var local_player_id := 0
var players: Dictionary = {}
var last_snapshot := 0.0

@onready var status_label: Label = $UI/Status
@onready var address_input: LineEdit = $UI/ConnectPanel/Address
@onready var port_input: LineEdit = $UI/ConnectPanel/Port

func _ready() -> void:
    var port_env := OS.get_environment("SERVER_PORT")
    if port_env.is_valid_int():
        server_port = clampi(int(port_env), 1, 65535)
    $UI/TouchControls.set_main(self)
    if "--server" in OS.get_cmdline_user_args():
        start_server()
    else:
        status_label.text = "Isla Eterna Online | Introduce IP y pulsa Conectar"
        if "--client" in OS.get_cmdline_user_args():
            connect_to_server("127.0.0.1", DEFAULT_PORT)

func start_server() -> void:
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_server(server_port, MAX_CLIENTS)
    if err != OK:
        status_label.text = "Error al crear servidor: %s" % error_string(err)
        push_error("No se pudo crear el servidor: %s" % error_string(err))
        return
    multiplayer.multiplayer_peer = peer
    is_server = true
    local_player_id = 1
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    status_label.text = "SERVIDOR activo en puerto %d" % server_port
    _spawn_player_local(1, Vector3.ZERO)
    print("Servidor iniciado en UDP %d" % server_port)

func connect_to_server(address: String, port: int) -> void:
    if address.strip_edges().is_empty() or port < 1 or port > 65535:
        status_label.text = "IP o puerto no válido"
        return
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_client(address.strip_edges(), port)
    if err != OK:
        status_label.text = "No se pudo iniciar conexión: %s" % error_string(err)
        return
    multiplayer.multiplayer_peer = peer
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    status_label.text = "Conectando a %s:%d..." % [address, port]

func _on_connect_pressed() -> void:
    var port := int(port_input.text)
    connect_to_server(address_input.text, port)

func _on_connected() -> void:
    local_player_id = multiplayer.get_unique_id()
    status_label.text = "Conectado | Jugador %d" % local_player_id
    $UI/ConnectPanel.hide()

func _on_connection_failed() -> void:
    status_label.text = "Conexión fallida. Revisa IP, puerto y servidor."

func _on_server_disconnected() -> void:
    status_label.text = "Conexión perdida con el servidor"

func _on_peer_connected(peer_id: int) -> void:
    if not is_server:
        return
    for id in players.keys():
        var p: Node3D = players[id]
        spawn_player.rpc(int(id), p.global_position)
    spawn_player.rpc(peer_id, Vector3(randf_range(-3, 3), 0, randf_range(-3, 3)))

func _on_peer_disconnected(peer_id: int) -> void:
    if is_server:
        remove_player.rpc(peer_id)

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, pos: Vector3) -> void:
    _spawn_player_local(peer_id, pos)

func _spawn_player_local(peer_id: int, pos: Vector3) -> void:
    if players.has(peer_id):
        return
    var p := player_scene.instantiate()
    p.name = "Player_%d" % peer_id
    p.set_multiplayer_authority(1)
    p.global_position = pos
    p.set("network_peer_id", peer_id)
    add_child(p)
    players[peer_id] = p
    p.set("display_name", "Aventurero %d" % peer_id)
    if peer_id == local_player_id:
        p.set("is_local_player", true)

@rpc("authority", "call_local", "reliable")
func remove_player(peer_id: int) -> void:
    if players.has(peer_id):
        players[peer_id].queue_free()
        players.erase(peer_id)

func get_local_input() -> Vector2:
    return $UI/TouchControls.get_move_vector()

func _physics_process(delta: float) -> void:
    if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
        _server_simulate(delta)
        last_snapshot += delta
        if last_snapshot >= 0.05:
            last_snapshot = 0.0
            var positions: Dictionary = {}
            for id in players.keys():
                positions[str(id)] = players[id].global_position
            update_positions.rpc(positions)
        return

    if not multiplayer.has_multiplayer_peer():
        return
    var peer := multiplayer.multiplayer_peer
    if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
        return
    if multiplayer.is_server():
        return
    var input_vec: Vector2 = get_local_input().limit_length(1.0)
    submit_input.rpc_id(1, input_vec)

func _server_simulate(delta: float) -> void:
    for id in players.keys():
        var p: Node = players[id]
        var input_vec: Vector2 = p.get("requested_input")
        p.server_move(input_vec, delta)
        var pos: Vector3 = p.global_position
        if absf(pos.x) > ZONE_HALF_SIZE or absf(pos.z) > ZONE_HALF_SIZE:
            pos.x = clampf(pos.x, -ZONE_HALF_SIZE, ZONE_HALF_SIZE)
            pos.z = clampf(pos.z, -ZONE_HALF_SIZE, ZONE_HALF_SIZE)
            p.global_position = pos

@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_input(input_vec: Vector2) -> void:
    if not multiplayer.has_multiplayer_peer() or not multiplayer.is_server():
        return
    var sender := multiplayer.get_remote_sender_id()
    if not players.has(sender):
        return
    players[sender].set("requested_input", input_vec.limit_length(1.0))

@rpc("authority", "call_remote", "unreliable_ordered")
func update_positions(positions: Dictionary) -> void:
    for key in positions.keys():
        var id := int(key)
        if players.has(id) and id != local_player_id:
            players[id].set_network_target(positions[key])

func request_zone_change() -> void:
    if is_server:
        _change_zone(local_player_id)
    else:
        request_zone_change_rpc.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func request_zone_change_rpc() -> void:
    if not is_server:
        return
    var sender := multiplayer.get_remote_sender_id()
    _change_zone(sender)

func _change_zone(peer_id: int) -> void:
    if players.has(peer_id):
        var p: Node3D = players[peer_id]
        p.global_position = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
        print("Jugador %d cambió a una nueva instancia de zona" % peer_id)
        if peer_id == local_player_id:
            $UI/ZoneLabel.text = "Zona: Pradera Inicial (instancia de prueba)"
