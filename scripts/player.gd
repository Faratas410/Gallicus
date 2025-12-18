extends CharacterBody2D

signal health_changed(current, maximum)
signal died

@export var move_speed: float = 220.0
@export var max_health: int = 100
@export var melee_damage: int = 20
@export var melee_cooldown: float = 0.35
@export var melee_offset: float = 26.0
@export var show_melee_hitbox: bool = false

var health: int
var _cooldown: float = 0.0
var _last_input_direction: Vector2 = Vector2.RIGHT
var _swing_hits: Array[Node] = []

@onready var _melee_area: Area2D = $MeleeArea
@onready var _melee_shape: CollisionShape2D = $MeleeArea/MeleeShape
@onready var _melee_debug: Node2D = $MeleeArea/DebugHitbox

func _ready() -> void:
    health = max_health
    add_to_group("player")
    _melee_area.monitoring = true
    _melee_area.monitorable = true
    _update_melee_area_transform()
    _update_debug_hitbox()
    _update_debug_hitbox_visibility()
    emit_signal("health_changed", health, max_health)

func _physics_process(delta: float) -> void:
    _handle_movement(delta)
    _update_melee_area_transform()
    _update_debug_hitbox_visibility()
    _handle_melee(delta)

func _handle_movement(delta: float) -> void:
    var input_vector := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )

    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()

    if input_vector != Vector2.ZERO:
        _last_input_direction = input_vector.normalized()

    velocity = input_vector * move_speed
    move_and_slide()

func _handle_melee(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)
    if Input.is_action_just_pressed("attack") and _cooldown <= 0.0:
        _cooldown = melee_cooldown
        _perform_melee_attack()

func _perform_melee_attack() -> void:
    _swing_hits.clear()
    for body in _melee_area.get_overlapping_bodies():
        _apply_melee_hit(body)

func _apply_melee_hit(body: Node) -> void:
    if body == self:
        return

    if body in _swing_hits:
        return

    if not body.is_in_group("enemies"):
        return

    if body.has_method("take_damage"):
        body.take_damage(melee_damage)
        _swing_hits.append(body)

func _update_melee_area_transform() -> void:
    if _last_input_direction == Vector2.ZERO:
        return

    _melee_area.position = _last_input_direction * melee_offset
    _melee_area.rotation = _last_input_direction.angle()

func _update_debug_hitbox() -> void:
    if _melee_shape.shape is CircleShape2D:
        var circle := _melee_shape.shape as CircleShape2D
        if _melee_debug.has_method("set_radius"):
            _melee_debug.call("set_radius", circle.radius)

func _update_debug_hitbox_visibility() -> void:
    if _melee_debug:
        _melee_debug.visible = show_melee_hitbox

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    emit_signal("health_changed", health, max_health)

    if health <= 0:
        _on_death()

func _on_death() -> void:
    emit_signal("died")
    set_process(false)
    set_physics_process(false)
    queue_free()
