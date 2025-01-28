extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var attack_cooldown: Timer = $attackCooldown

const SPEED = 90
var health = 100
var alive = true

var enemyInAttackRange = false
var hurted = false
var attacking = false

var meeleAttackOnCooldown = false

var minatorInAttacKRange = false
var orcInAttackRange = false

func player():
	pass

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var veloc := Input.get_axis("move_up", "move_down")
	
	if Global.OrcAttackedPlayer:
		hurted = true
		health -= Global.Damage["OrcAttack"]
		Global.OrcAttackedPlayer = false
		
	if Global.MinatorAttacked1Player:
		hurted = true
		health -= Global.Damage["MinatorAttack1"]
		Global.MinatorAttacked1Player = false
	
	if Global.MinatorAttacked2Player:
		hurted = true
		health -= Global.Damage["MinatorAttack2"]
		Global.MinatorAttacked2Player = false
	
	if hurted:
		animated_sprite.play("hurt")
		return
	
	if Input.is_action_just_pressed("attack"):
		if !meeleAttackOnCooldown:
			attack()
		return 
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Movement ######################################	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if veloc:
		velocity.y = veloc * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if !attacking:
		if direction + veloc != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
		
	# Direction ######################################
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	move_and_slide()

func attack():
	attacking = true
	animated_sprite.play("attack_meele")
	meeleAttackOnCooldown = true
	attack_cooldown.start()

func _on_animated_sprite_frame_changed() -> void:
	if animated_sprite.animation == "hurt":
		if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("hurt") - 1:
			hurted = false
			animated_sprite.stop()
	if animated_sprite.animation == "attack_meele":
		if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack_meele") - 2:
			if orcInAttackRange:
				Global.PlayerMeeleAttackedMinator = true
			if minatorInAttacKRange:
				Global.PlayerMeeleAttackedMinator = true
			attacking = false
			animated_sprite.stop()

func _on_attack_cooldown_timeout() -> void:
	meeleAttackOnCooldown = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("orc"):
		orcInAttackRange = true
	if body.has_method("minator"):
		minatorInAttacKRange = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.has_method("orc"):
		orcInAttackRange = false
	if body.has_method("minator"):
		minatorInAttacKRange = false

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("orc"):
		enemyInAttackRange = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("orc"):
		enemyInAttackRange = false
