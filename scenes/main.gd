extends Node2D

@onready var player = get_node("/root/Main/Player")
@onready var mobMgr = get_node("/root/Main/MobSpawner")

@onready var coin_count = get_node("/root/Main/HUD/CoinCount")
@onready var wave_count = get_node("/root/Main/HUD/WaveCounter")
@onready var heart3 = get_node("/root/Main/HUD/HeartContainer/Heart3")
@onready var heart2 = get_node("/root/Main/HUD/HeartContainer/Heart2")
@onready var heart1 = get_node("/root/Main/HUD/HeartContainer/Heart1")
@onready var heart0 = get_node("/root/Main/HUD/HeartContainer/Heart0")

@export var is_controller : bool

var max_mobs : int
var mobs_killed := 0
var coins : int
var wave : int

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	$GameOver/Button.pressed.connect(new_game)
	$UpgradeOptions/DamageUp.pressed.connect(damage_upgrade)
	$UpgradeOptions/SpeedUp.pressed.connect(speed_upgrade)


func new_game():
	get_tree().paused = false
	wave = 1
	max_mobs = 3
	player.reset()
	reset()


func reset():
	$UpgradeOptions.hide()
	$GameOver.hide()
	get_tree().paused = true
	$RestartTimer.start()


func damage_upgrade():
	print("DAMAGE")
	# play anim
	$UpgradeOptions.hide()
	get_tree().paused = false
	$WaveOverTimer.start()


func speed_upgrade():
	print("SPEED")
	# play anim
	$UpgradeOptions.hide()
	get_tree().paused = false
	$WaveOverTimer.start()


func _process(_delta):
	update_ui()
	if is_wave_completed():
		wave += 1
		mobs_killed = 0
		max_mobs += 2
		mobMgr.mobs_spawned = 0
		get_tree().paused = true
		$UpgradeOptions.show()
	
	#if $BGM.playing == false:
		#$BGM.play()


func is_wave_completed():
	
	var all_killed = true
	if mobs_killed >= max_mobs:
		return all_killed
	else:
		return false
	
	#var all_dead = true
	#var mobs = get_tree().get_nodes_in_group("mobs")
	##check if all mobs spawned 
	#if mobs.size() == max_mobs:
		#for m in mobs:
			#if m.alive:
				#all_dead = false
		#return all_dead
	#else:
		#return false


func game_over():
	get_tree().call_group("mobs", "queue_free")
	$GameOver/WavesLabel.text = "WAVES SURVIVED: " + str(wave - 1)
	get_tree().paused = true
	$GameOver.show()


func update_ui():
	coin_count.text = str(coins)
	wave_count.text = "WAVE " + str(wave)
	update_health()


func update_health():
	match player.health:
		4:
			heart3.frame = 0
			heart2.frame = 0
			heart1.frame = 0
			heart0.frame = 0
		3:
			heart3.frame = 2
			heart2.frame = 0
			heart1.frame = 0
			heart0.frame = 0
		2:
			heart3.frame = 2
			heart2.frame = 2
			heart1.frame = 0
			heart0.frame = 0
		1:
			heart3.frame = 2
			heart2.frame = 2
			heart1.frame = 2
			heart0.frame = 0
		0:
			heart3.frame = 2
			heart2.frame = 2
			heart1.frame = 2
			heart0.frame = 2
			game_over()
	


func _on_mob_spawner_hit_p():
	player.health -= 1
	print("player hit!")


func _on_restart_timer_timeout():
	get_tree().paused = false


func _on_wave_over_timer_timeout():
	reset()

