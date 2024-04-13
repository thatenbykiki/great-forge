extends CharacterBody2D

@export var speed := 300.0

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var lastMove = get_last_motion()

# set facing
var FACE_UP : bool
var FACE_DOWN : bool
var FACE_LEFT : bool
var FACE_RIGHT : bool

# set sprite textures
var sprite_idle = preload("res://assets/sprites/player/idle.png")
var sprite_run = preload("res://assets/sprites/player/run.png")
var sprite_attack = preload("res://assets/sprites/player/attack1.png")

func _ready():
	pass

func _physics_process(delta):
	inputHandler()
	_facing()
	move_and_slide()
	update_anim()
	
	print(lastMove)

func inputHandler():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	
func _facing():
	# UP 	= (0 , -1)
	# DOWN 	= (0 , 1)
	# LEFT 	= (-1 , 0)
	# RIGHT = (1 , 0)

	if lastMove == Vector2(0, -1):
		FACE_UP = true
		print("facing up")
	elif lastMove == Vector2(0, 1):
		FACE_DOWN = true
		print("facing down")
	elif lastMove == Vector2(-1, 0):
		FACE_LEFT = true
		print("facing left")
	elif lastMove == Vector2(1, 0):
		FACE_RIGHT = true
		print("facing right")


func update_anim():
	if velocity.x > 0:
		sprite.texture = sprite_run
		sprite.flip_h = true
		anim.play("RUN_LEFT-RIGHT")
	elif velocity.x < 0:
		sprite.texture = sprite_run
		sprite.flip_h = false
		anim.play("RUN_LEFT-RIGHT")
	elif velocity.y > 0:
		sprite.texture = sprite_run
		anim.play("RUN_DOWN")
	elif velocity.y < 0:
		sprite.texture = sprite_run
		anim.play("RUN_UP")
	
	if velocity == Vector2(0.0, 0.0) && lastMove == Vector2(0, 1):
		sprite.texture = sprite_idle
		anim.play("IDLE_DOWN")	
	elif velocity == Vector2(0.0, 0.0) && lastMove == Vector2(0, -1):
		sprite.texture = sprite_idle
		anim.play("IDLE_UP")	
	elif velocity == Vector2(0.0, 0.0) && lastMove == Vector2(-1, 0):
		sprite.texture = sprite_idle
		sprite.flip_h = true
		anim.play("IDLE_LEFT-RIGHT")	
	elif velocity == Vector2(0.0, 0.0) && lastMove == Vector2(1, 0):
		sprite.texture = sprite_idle
		sprite.flip_h = false
		anim.play("IDLE_LEFT-RIGHT")	
