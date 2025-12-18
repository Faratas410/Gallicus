extends CharacterBody2D

signal defeated

@export var move_speed: float = 140.0
@export var max_health: int = 30
@export var contact_damage: int = 10

var health: int
var _target: Node2D

func _ready() -> void:
    health = max_health
    _target = get_tree().get_first_node_in_group("player")
    add_to_group("enemies")

func _physics_process(delta: float) -> void:
    if not is_instance_valid(_target):
        _target = get_tree().get_first_node_in_group("player")
        return

    var direction := _target.global_position - global_position
    if direction.length() > 1.0:
        velocity = direction.normalized() * move_speed
    else:
        velocity = Vector2.ZERO

    var collision := move_and_collide(velocity * delta)
    if collision and collision.get_collider().has_method("take_damage"):
        collision.get_collider().take_damage(contact_damage)

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        emit_signal("defeated")
        queue_free()
