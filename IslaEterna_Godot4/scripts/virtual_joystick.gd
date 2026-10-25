extends Control

@export var radius := 70.0
var is_pressed := false
var pointer_id := -1
var knob := Vector2.ZERO
var output_vector := Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not is_pressed:
            is_pressed = true
            pointer_id = event.index
            _update_stick(event.position)
            accept_event()
        elif not event.pressed and event.index == pointer_id:
            _release_stick()
            accept_event()
    elif event is InputEventScreenDrag and is_pressed and event.index == pointer_id:
        _update_stick(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            is_pressed = true
            pointer_id = 0
            _update_stick(event.position)
        else:
            _release_stick()
    elif event is InputEventMouseMotion and is_pressed and pointer_id == 0:
        _update_stick(event.position)

func _update_stick(point: Vector2) -> void:
    var center := size * 0.5
    var offset := point - center
    knob = offset.limit_length(radius)
    output_vector = knob / maxf(radius, 1.0)
    queue_redraw()
    var controls := get_parent()
    if controls != null:
        controls.move_vector = Vector2(output_vector.x, output_vector.y)

func _release_stick() -> void:
    is_pressed = false
    pointer_id = -1
    output_vector = Vector2.ZERO
    knob = Vector2.ZERO
    queue_redraw()
    var controls := get_parent()
    if controls != null:
        controls.move_vector = Vector2.ZERO

func _draw() -> void:
    var c := size * 0.5
    draw_circle(c, radius + 12.0, Color(0.05, 0.08, 0.12, 0.45))
    draw_circle(c, radius, Color(0.55, 0.65, 0.75, 0.32))
    draw_circle(c + knob, 28.0, Color(0.85, 0.92, 1.0, 0.85))
