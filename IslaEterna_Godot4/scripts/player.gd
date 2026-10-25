extends CharacterBody3D

@export var move_speed := 6.0
var network_peer_id := 0
var is_local_player := false
var display_name := "Aventurero"
var requested_input := Vector2.ZERO
var network_target := Vector3.ZERO
var has_network_target := false

func _ready() -> void:
    $NameTag.text = display_name
    network_target = global_position

func server_move(input_vec: Vector2, _delta: float) -> void:
    var direction := Vector3(input_vec.x, 0.0, input_vec.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()
    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed
    velocity.y = 0.0
    move_and_slide()
    if direction.length_squared() > 0.01:
        $Body.rotation.y = atan2(direction.x, direction.z)

func set_network_target(position: Vector3) -> void:
    network_target = position
    has_network_target = true

func _process(delta: float) -> void:
    if is_local_player:
        return
    if has_network_target:
        global_position = global_position.lerp(network_target, minf(delta * 12.0, 1.0))
