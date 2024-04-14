extends CharacterBody2D
class_name Player

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var atkTimer = $AttackTimer
@onready var atkPivot = $WeaponPivot
@onready var atkArea = $WeaponPivot/AtkArea

@export var debug := false

var player_speed : float
var dmg_rate = 1.0
const BASE_SPEED := 75.0

var lastMove := Vector2.ZERO

var is_idle := false
var is_attacking := false
var is_blocking := false
var is_hit := false

var sprite_idle = preload("res://assets/sprites/player/idle.png")
var sprite_run = preload("res://assets/sprites/player/run.png")
var sprite_attack = preload("res://assets/sprites/player/attack1.png")
var sprite_block = preload("res://assets/sprites/player/block.png")
var sprite_hit = preload("res://assets/sprites/player/hit.png")

var _face : String

signal attacking

func _ready():
	sprite.texture = sprite_idle
	anim.play("IDLE_DOWN")
	atkTimer.timeout.connect(_on_attack_timeout)
	atkArea.area_entered.connect(_on_atk_area_entered)
	


func _physics_process(delta):
		inputHandler()
		_facing()
		_rotate_atk_col()
		move_and_slide()
		update_anim()
		
		if debug:
			_debug()
		else:
			pass


func _debug():
	print("Attacking: " + str(is_attacking))
	print("Blocking: " + str(is_blocking))
	print("HIT: " + str(is_hit))
	print("FACING: " + str(_face))


func inputHandler():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_pressed("block"):
		is_blocking = true
		player_speed = BASE_SPEED / 5
	elif Input.is_action_just_released("block"):
		is_blocking = false
		player_speed = BASE_SPEED


func attack():
	var overlapping_objects = atkArea.get_overlapping_areas()
	
	for area in overlapping_objects:
		var parent = area.get_parent()
		parent.take_damage(dmg_rate)
	
	is_attacking = true
	emit_signal("attacking")
	sprite.texture = sprite_attack
	atkTimer.start()
	player_speed = 0
	update_anim()
	set_process_input(false)


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
	
	if !is_attacking && !is_blocking:
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
	elif is_attacking && !is_blocking:
		sprite.texture = sprite_attack
		if _face == "DOWN":
			_anim_name = "ATTACK_DOWN"
		elif _face == "UP":
			_anim_name = "ATTACK_UP"
		elif _face == "LEFT":
			_anim_name = "ATTACK_LEFT-RIGHT"
		elif _face == "RIGHT":
			_anim_name = "ATTACK_LEFT-RIGHT"
	elif !is_attacking && is_blocking:
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
	elif is_hit:
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
	is_attacking = false


func _on_atk_area_entered(area):
	pass
