extends CharacterBody2D
class_name Player

@export var is_player : bool
@export_enum("PLAYER", "RED", "GREEN", "BLUE", "YELLOW") var character: String

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var atkTimer = $AttackTimer
@onready var atkPivot = $WeaponPivot

var player_speed : float
var mob_speed = player_speed - 10.0
const BASE_SPEED := 75.0

var lastMove := Vector2.ZERO

var idling := false
var attacking := false
var blocking := false
var hit := false

var sprite_idle
var sprite_run
var sprite_attack
var sprite_block
var sprite_hit

var _face : String

func _ready():
	set_input()
	set_sprites()
	sprite.texture = sprite_idle
	anim.play("IDLE_DOWN")
	atkTimer.timeout.connect(_on_attack_timeout)

func _physics_process(delta):
	if is_player:
		inputHandler()
		_facing()
		_rotate_atk_col()
		move_and_slide()
		update_anim()
		_debug()
	if !is_player:
		_facing()
		_rotate_atk_col()
		update_anim()

func _debug():
	print("Attacking: " + str(attacking))
	print("Blocking: " + str(blocking))
	print("HIT: " + str(hit))

func set_sprites():
	if is_player:
		sprite_idle = preload("res://assets/sprites/player/idle.png")
		sprite_run = preload("res://assets/sprites/player/run.png")
		sprite_attack = preload("res://assets/sprites/player/attack1.png")
		sprite_block = preload("res://assets/sprites/player/block.png")
		sprite_hit = preload("res://assets/sprites/player/hit.png")
	elif !is_player:
		if character == "RED":
			sprite_idle = preload("res://assets/sprites/mobs/red/idle.png")
			sprite_run = preload("res://assets/sprites/mobs/red/run.png")
			sprite_attack = preload("res://assets/sprites/mobs/red/attack.png")
			sprite_hit = preload("res://assets/sprites/mobs/red/hit.png")
		if character == "GREEN":
			pass
		if character == "BLUE":
			pass
		if character == "YELLOW":
			pass

func set_input():
	if is_player:
		set_process_input(true)
	if !is_player:
		set_process_input(false)

func inputHandler():
	set_input()
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_speed
	
	if Input.is_action_just_pressed("attack"):
		attacking = true
		attack()
	
	if Input.is_action_pressed("block"):
		blocking = true
		player_speed = BASE_SPEED / 5
	elif Input.is_action_just_released("block"):
		blocking = false
		player_speed = BASE_SPEED

func attack():
	sprite.texture = sprite_attack
	atkTimer.start()
	player_speed = 0
	set_process_input(false)

func _facing():
	var _real_velocity = get_real_velocity()
	
	if  _real_velocity.y > 0.0:
		_face = "DOWN"
	if _real_velocity.y < 0.0:
		_face = "UP"
	if _real_velocity.x < 0.0:
		_face = "LEFT"
	if _real_velocity.x > 0.0:
		_face = "RIGHT"

func _rotate_atk_col():
	if _face == "DOWN":
		atkPivot.rotation_degrees = 0
	if _face == "UP":
		atkPivot.rotation_degrees = 180
	if _face == "LEFT":
		atkPivot.rotation_degrees = 90
	if _face == "RIGHT":
		atkPivot.rotation_degrees = 270
	
func update_anim(): # Thanks to: thefinaldegreee, AnomAlison & Kas from GWJ discord!
	var _anim_name : String
	
	if !attacking && !blocking:
		sprite.texture = sprite_idle
		if velocity.is_zero_approx() && lastMove.y > 0.0:
		# if velocity.y >= 0 && lastMove.is_equal_approx(Vector2(0, 1)):
			_anim_name = "IDLE_DOWN"
		elif velocity.is_zero_approx() && lastMove.y < 0.0:
		#elif velocity.y <= 0 && lastMove.is_equal_approx(Vector2(0, -1)):
			_anim_name = "IDLE_UP"
		elif velocity.is_zero_approx() && lastMove.x < 0.0:	
		#elif velocity.x <=0 && lastMove.is_equal_approx(Vector2(-1, 0)):
			sprite.flip_h = false
			_anim_name = "IDLE_LEFT-RIGHT"
		elif velocity.is_zero_approx() && lastMove.x > 0.0:	
		#elif velocity.x >= 0 && lastMove.is_equal_approx(Vector2(1, 0)):
			sprite.flip_h = true
			_anim_name = "IDLE_LEFT-RIGHT"
		
		if velocity.x > 0:
			sprite.texture = sprite_run
			sprite.flip_h = true
			_anim_name = "RUN_LEFT-RIGHT"
		elif velocity.x < 0:
			sprite.texture = sprite_run
			sprite.flip_h = false
			_anim_name = "RUN_LEFT-RIGHT"
		elif velocity.y > 0:
			sprite.texture = sprite_run
			_anim_name = "RUN_DOWN"
		elif velocity.y < 0:
			sprite.texture = sprite_run
			_anim_name = "RUN_UP"
	elif attacking && !blocking:
		sprite.texture = sprite_attack
		if _face == "DOWN":
			_anim_name = "ATTACK_DOWN"
		elif _face == "UP":
			_anim_name = "ATTACK_UP"
		elif _face == "LEFT":
			_anim_name = "ATTACK_LEFT-RIGHT"
		elif _face == "RIGHT":
			_anim_name = "ATTACK_LEFT-RIGHT"
	elif !attacking && blocking:
		sprite.texture = sprite_block
		if _face == "DOWN":
			_anim_name = "BLOCK_DOWN"
		elif _face == "UP":
			_anim_name = "BLOCK_UP"
		elif _face == "LEFT":
			sprite.flip_h = false
			_anim_name = "BLOCK_LEFT-RIGHT"
		elif _face == "RIGHT":
			sprite.flip_h = true
			_anim_name = "BLOCK_LEFT-RIGHT"
	elif hit:
		sprite.texture = sprite_hit
		if _face == "DOWN":
			_anim_name = "HIT_DOWN"
		elif _face == "UP":
			_anim_name = "HIT_UP"
		elif _face == "LEFT":
			_anim_name = "HIT_LEFT-RIGHT"
		elif _face == "RIGHT":
			_anim_name = "HIT_LEFT-RIGHT"
			
		
	anim.play(_anim_name)
			
	lastMove = get_last_motion().normalized()

func _on_attack_timeout():
	set_process_input(true)
	player_speed = BASE_SPEED
	attacking = false
