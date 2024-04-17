extends CharacterBody2D

signal swing_sword

@onready var main = get_node("/root/Main")

@onready var sprite = $AnimatedSprite2D
@onready var weapPivot = $WeaponPivot
@onready var atkArea = $WeaponPivot/AttackArea
@onready var swordSprite = $WeaponPivot/SwordSprite
@onready var atkTimer = $Timers/AttackTimer
@onready var dmgUpTimer = $Timers/DamageBuffTimer
@onready var spdUpTimer = $Timers/SpeedBoostTimer

@export var speed := 150
@export var dmg_rate := 20
@export var health := 4

var base_health = 4
var base_speed = speed
var base_dmg = dmg_rate

var is_attacking : bool
var can_attack := true
var spawn_point : Vector2

func _ready():
	spawn_point = get_viewport_rect().size / 2 
	reset()


func _physics_process(_delta):
	get_input()
	sprite.play()
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)


func reset():
	health = base_health
	position = spawn_point
	sprite.play("idle1")


func get_input():
	
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var mouse = get_local_mouse_position()
	var angle = snappedf(mouse.angle(), PI / 2) / (PI / 2)
	angle = wrapi(int(angle), 0, 4)
	
	if aim_dir != Vector2.ZERO:
		weapPivot.rotation = lerp_angle(rotation, aim_dir.angle(), 1)
	elif main.is_controller == false:
		weapPivot.rotation = lerpf(rotation, mouse.angle(), 1)
	velocity = move_dir.clamp(Vector2(-1, -1), Vector2(1, 1)).normalized() * speed
	
	if velocity.length() != 0:
		sprite.animation = "walk" + str(angle)
	else:
		sprite.animation = "idle" + str(angle)
	
	if Input.is_action_just_pressed("attack"):
		if can_attack:
			swing_sword.emit()
			attack()


func speed_boost():
	speed *= 1.5
	spdUpTimer.start(2)
	print("SPEED BOOST")


func _on_speed_boost_timer_timeout():
	speed = base_speed


func dmg_boost():
	dmg_rate *= 2
	dmgUpTimer.start(2)
	print("DAMAGE BOOST")


func _on_damage_buff_timer_timeout():
	dmg_rate = base_dmg


func heal_item():
	health += 1


func attack():
	is_attacking = true
	can_attack = false
	atkTimer.start(.5)
	$SFX/Slash.play()
	swordSprite.play("swing")


func _on_atktimer_timeout():
	is_attacking = false
	can_attack = true
	swordSprite.play("idle")

