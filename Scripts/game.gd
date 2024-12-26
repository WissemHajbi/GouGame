extends Node2D

var orc = preload("res://Scenes/orc.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rng = RandomNumberGenerator.new()
	if Global.SpawnOrcs:
		for i in Global.NumOrcsToSpawn:
			addOrc(Vector2(rng.randi_range(-45,187),rng.randi_range(173,354)))
		Global.NumOrcSpawned += Global.NumOrcsToSpawn
		Global.SpawnOrcs = false
		

func addOrc(pos):
	var instance = orc.instantiate()
	instance.position = pos
	add_child(instance)
		
