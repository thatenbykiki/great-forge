extends CharacterBody2D
class_name Mob

@onready var player = $/root/Playground/Player
@onready var hitArea = $hitArea
@export var health := 3

var speed := 15
var _face : String

func _ready():
	pass


func _physics_process(delta):
	var direction =  global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func _facing():
	var _real_velocity = get_real_velocity().normalized()
	
	if  _real_velocity.y > 0.0:
		_face = "DOWN"
	if _real_velocity.y < 0.0:
		_face = "UP"
	if _real_velocity.x < 0.0:
		_face = "LEFT"
	if _real_velocity.x > 0.0:
		_face = "RIGHT"


func take_damage(dmg_amount):
	if health <= 0:
		die()
	else:
		health -= dmg_amount
	

func die():
	#play death anim
	#drop loot
	queue_free()


func idle():
	pass


func chase():
	pass


func attack():
	pass
