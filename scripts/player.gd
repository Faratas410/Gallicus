extends CharacterBody2D

signal health_changed(current, maximum)
signal died

@export var move_speed: float = 220.0
@export var acceleration: float = 1200.0
@export var max_hp: int = 100
@export var invuln_time: float = 0.5
@export var melee_damage: int = 20
@export var melee_cooldown: float = 0.35
@export var melee_offset: float = 26.0
@export var show_melee_hitbox: bool = false

var hp: int
var health: int:
    get:
        return hp

var max_health: int:
    get:
        return max_hp

var _cooldown: float = 0.0
var _invuln_timer: float = 0.0
var _flash_timer: float = 0.0
var _is_dimmed: bool = false

@onready var _melee_area: Area2D = $MeleeArea
@onready var _melee_shape: CollisionShape2D = $MeleeArea/MeleeShape
@onready var _melee_debug: Node2D = $MeleeArea/DebugHitbox

const FLASH_INTERVAL := 0.1
const FLASH_ALPHA := 0.35

func _ready() -> void:
    hp = max_hp
    add_to_group("player")
    _melee_area.monitoring = true
    _melee_area.monitorable = true
    emit_signal("health_changed", hp, max_hp)

func _physics_process(delta: float) -> void:
    _handle_movement(delta)
    _update_melee_area_transform()
    _update_debug_hitbox_visibility()
    _handle_melee(delta)

func _process(delta: float) -> void:
    _handle_invulnerability(delta)

func _handle_movement(delta: float) -> void:
    var input_vector := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )

    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()

    var target_velocity := input_vector * move_speed
    velocity = velocity.move_toward(target_velocity, acceleration * delta)
    move_and_slide()

func _handle_melee(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)
    if Input.is_action_just_pressed("attack") and _cooldown <= 0.0:
        _cooldown = melee_cooldown
        _perform_melee_attack()

func _perform_melee_attack() -> void:
    _swing_hits.clear()
    for body in _melee_area.get_overlapping_bodies():
        if body == self:
            continue
        if body.has_method("take_damage"):
            body.take_damage(melee_damage, global_position)

func take_damage(amount: int, from_position: Vector2 = global_position) -> void:
    if amount <= 0:
        return

    if _invuln_timer > 0.0:
        return

    _invuln_timer = invuln_time
    _flash_timer = FLASH_INTERVAL
    _set_flash_state(true)

    hp = clamp(hp - amount, 0, max_hp)
    emit_signal("health_changed", hp, max_hp)

    if hp <= 0:
        _on_death()

func _on_death() -> void:
    emit_signal("died")
    set_process(false)
    set_physics_process(false)
    queue_free()

func _handle_invulnerability(delta: float) -> void:
    if _invuln_timer <= 0.0:
        return

    _invuln_timer = max(_invuln_timer - delta, 0.0)
    _flash_timer = max(_flash_timer - delta, 0.0)

    if _flash_timer <= 0.0 and _invuln_timer > 0.0:
        _toggle_flash()
        _flash_timer = FLASH_INTERVAL

    if _invuln_timer <= 0.0:
        _set_flash_state(false)

func _toggle_flash() -> void:
    _set_flash_state(not _is_dimmed)

func _set_flash_state(dim: bool) -> void:
    _is_dimmed = dim
    modulate.a = FLASH_ALPHA if dim else 1.0
