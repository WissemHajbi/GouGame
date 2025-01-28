extends CharacterBody2D

var playerChase = false
var player = null

var speed = 40

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detecetion_area: Area2D = $DetecetionArea
@onready var attack_cooldown: Timer = $AttackCooldown

var playerInAttackRange = false
var attackCooldown = false
var attacking = false
var taunting = false

var anger = 60

func minator():
	pass

func _process(delta: float) -> void:
	if Global.PlayerMeeleAttackedMinator:
		animated_sprite.play("hurt")
		
	if taunting:
		attacking = false
		animated_sprite.play("taunt")
		Global.MinatorTaunted = true
		return
	if !attacking:
		if playerInAttackRange:
			enemyAttack()
			return
		elif playerChase:
			var direction = (player.position - position).normalized() 
			position += direction * speed * delta
			animated_sprite.play("run")
			if player.position.x > position.x:
				animated_sprite.flip_h = false
			else:
				animated_sprite.flip_h = true
		else:
			animated_sprite.play("idle")

func enemyAttack():
	var attackType = (randi() % 2)+1
	if attackCooldown == false:
		attacking = true
		match attackType:
			1: animated_sprite.play("attack1")
			2: animated_sprite.play("attack2")
		attackCooldown = true
		attack_cooldown.start()

func Anger(value: int):
	anger += value
	speed += 1
	Global.Damage["MinatorAttack1"] += anger
	Global.Damage["MinatorAttack2"] += anger
	
	if anger > 50 and anger % 10 == 0 and anger % 2 == 0 : 
		taunting = true

func _on_animated_sprite_2d_frame_changed() -> void:
	match animated_sprite.animation:
		"attack1" : 
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack1") - 3:
				match(playerInAttackRange):
					true:
						Global.MinatorAttacked1Player = true	
						Anger(5)
					false:
						Anger(15)
			#stop attack			
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack1") - 2:
				attacking = false
				animated_sprite.stop()
		"attack2":
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack2") - 3 :
				match(playerInAttackRange):
					true:
						Global.MinatorAttacked2Player = true	
						Anger(5)
					false:
						Anger(20)
			#stop attack				
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack2") - 1:
				attacking = false
				animated_sprite.stop()
		"taunt":
			if animated_sprite.frame == 3:
				Global.SpawnOrcs = true
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("taunt") - 1:
				taunting = false
				animated_sprite.stop()
				Global.MinatorTaunted = false
		"hurt":
			if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("hurt") - 1:
				Global.PlayerMeeleAttackedMinator = false
				animated_sprite.stop()
				attacking = false
				taunting = false

func _on_detecetion_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		playerChase = true

func _on_detecetion_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		playerChase = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		playerInAttackRange = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	playerInAttackRange = false

func _on_attack_cooldown_timeout() -> void:
	attackCooldown = false
