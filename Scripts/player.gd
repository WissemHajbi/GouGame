extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var attack_cooldown: Timer = $attackCooldown

const SPEED = 90
var health = 100
var alive = true

var enemyInAttackRange = false
var hurted = false

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
		
	# Movement ######################################
	if hurted:
		animated_sprite.play("hurt")
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if veloc:
			velocity.y = veloc * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		if direction + veloc != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	# Direction ######################################
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	# Animation ######################################
	move_and_slide()

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("orc"):
		enemyInAttackRange = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("orc"):
		enemyInAttackRange = false

func _on_animated_sprite_frame_changed() -> void:
	if animated_sprite.animation == "hurt":
		if animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("hurt") - 1:
			hurted = false
			animated_sprite.stop()
