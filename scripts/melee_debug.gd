extends Node2D

@export var radius: float = 0.0:
    set = set_radius
@export var color: Color = Color(1, 0, 0, 0.25)

func _draw() -> void:
    if radius <= 0.0:
        return

    draw_circle(Vector2.ZERO, radius, color)

func set_radius(value: float) -> void:
    radius = value
    queue_redraw()
