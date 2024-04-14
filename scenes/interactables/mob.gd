extends CharacterBody2D
class_name Mob

@onready var player = $/root/Playground/Player
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var hitArea = $hitArea

@export var health := 3
@export var debug : bool

var speed := 15
var _face : String

var sprite_idle = preload("res://assets/sprites/mobs/red/idle.png")
var sprite_run = preload("res://assets/sprites/mobs/red/run.png")
var sprite_attack = preload("res://assets/sprites/mobs/red/attack.png")
var sprite_hit = preload("res://assets/sprites/mobs/red/hit.png")

func _ready():
	pass


func _physics_process(delta):
	var direction =  global_position.direction_to(player.global_position)
	velocity = direction * speed
	_facing()
	update_anim()
	move_and_slide()
	
	if debug:
		_debug()
	else:
		pass

func _debug():
	print("========( M O B )========")
	print("FACE: " + str(_face))
	print("HEALTH: " + str(health))

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


func attack():
	pass

func update_anim():
	var _anim_name : String
	
	if velocity.x > 0 && _face == "RIGHT":
		sprite.texture = sprite_run
		sprite.flip_h = true
		_anim_name = "RUN_LEFT-RIGHT"
	elif velocity.x < 0 && _face == "LEFT":
		sprite.texture = sprite_run
		sprite.flip_h = false
		_anim_name = "RUN_LEFT-RIGHT"
	elif velocity.y > 0 && _face == "DOWN":
		sprite.texture = sprite_run
		_anim_name = "RUN_DOWN"
	elif velocity.y < 0 && _face == "UP":
		sprite.texture = sprite_run
		_anim_name = "RUN_UP"
		
