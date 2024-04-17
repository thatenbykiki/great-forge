extends CharacterBody2D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")

@export var is_floating := true
@export var healing_amount : int

var item_type : int # 0: coin, 1: boots, 2: sword, 3: health

var coin_icon = preload("res://assets/icons/Chicken_of_the_Wood.png")
var boots_icon = preload("res://assets/icons/Boots_Icon.png")
var sword_icon = preload("res://assets/icons/Sword_Icon.png")
var health_icon = preload("res://assets/icons/health_icon.png")

var textures = [coin_icon, boots_icon, sword_icon, health_icon]

var tween
var spawn
var distance
var duration

func _ready():
	$Sprite2D.texture = textures[item_type]
	set_tween()


func _physics_process(delta):
	if !is_floating:
		update_tween()
		tween.stop()
		var dir = (player.position - position)
		var speed = 30
		dir = dir.normalized()
		velocity = dir * speed
		move_and_slide()
	if is_floating:
		update_tween()
		tween.play()
	


func update_tween():
	spawn = position
	distance = position + Vector2(0.0, 4.0)


func set_tween():
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	spawn = position
	distance = position + Vector2(0.0, 4.0)
	duration = 1.2
	tween.tween_property(self, "position", distance, duration)
	tween.tween_property(self, "position", spawn, duration)
	tween.set_loops()


func floating_animation():
	pass


func _on_pickup_area_entered(area):
	if item_type == 0:
		main.coins += 1
	elif item_type == 1:
		player.speed_boost()
	elif item_type == 2:
		player.dmg_boost()
	elif item_type == 3:
		player.heal_item()
	queue_free()
