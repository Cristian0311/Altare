extends Control

var main_node: Node
var move_vector := Vector2.ZERO

func set_main(node: Node) -> void:
    main_node = node

func get_move_vector() -> Vector2:
    return move_vector

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE and main_node != null:
            main_node.request_zone_change()

func _process(_delta: float) -> void:
    var v := Vector2.ZERO
    v.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    v.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    if v.length() > 0.05:
        move_vector = v.normalized()
    elif not $Joystick.is_pressed:
        move_vector = Vector2.ZERO
