extends CharacterBody2D

@onready var detecetion_area: Area2D = $DetecetionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var single_attack_timer: Timer = $SingleAttackTimer

var speed = 30
var playerChase = false
var player = null

var health = 0
var alive = true

var playerInAttackRange = false
var attackCooldown = false
var attacking = false

func orc():
	pass

func _physics_process(delta: float) -> void:
	if !attacking:
		if playerInAttackRange:
				enemyAttack()
		elif playerChase:
			position += (player.position - position) / speed
			animated_sprite.play("walk")
			if player.position.x > position.x:
				animated_sprite.flip_h = false
			else:
				animated_sprite.flip_h = true
		else:
			animated_sprite.play("idle")

func enemyAttack():
	if playerInAttackRange and attackCooldown == false:
		attacking = true
		animated_sprite.play("attack")
		single_attack_timer.start()
		attackCooldown = true
		attack_cooldown.start()
		
func _on_detecetion_area_body_entered(body: Node2D) -> void:
	player = body
	playerChase = true

func _on_detecetion_area_body_exited(body: Node2D) -> void:
	player = null
	playerChase = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		playerInAttackRange = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	playerInAttackRange = false

func _on_attack_cooldown_timeout() -> void:
	attackCooldown = false

func _on_animated_sprite_2d_frame_changed() -> void:
	if attacking and animated_sprite.animation == "attack":		
		if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack") - 7:
			if playerInAttackRange:
				Global.OrcAttackedPlayer = true				
		if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack") - 1:
			#if playerInAttackRange:
				#Global.OrcAttackedPlayer = true
			attacking = false
			animated_sprite.stop()
			
