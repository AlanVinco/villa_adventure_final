extends Node2D

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var rock_state = ""

@export var durability = 10

#func _ready() -> void:
	#
	#await get_tree().create_timer(1.0).timeout
	#spawn_item(Global.spawnable_items[0], position)

func spawn_item(data, position):
	var item_scene = preload("res://Scenes/Inventory_Item.tscn")
	var item_instance = item_scene.instantiate()
	item_instance.initiate_items(data["type"], data["name"], data["effect"], data["texture"])
	item_instance.global_position = position
	get_parent().add_child(item_instance)
	#items.add_child(item_instance)
	

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Stats.item_selected == "PICKAXE" and rock_state == "":
		if event.is_action("mouse_action"):
			if durability > 0:
				durability -= 1
				audio.stream = load("res://sonidos/sounds/hit_rock1.ogg")
				audio.pitch_scale = randf_range(1.0, 2.0)
				audio.play() 
				Stats.expend_energy(1)
				$CPUParticles2D.emitting = true
				await get_tree().create_timer(0.5).timeout
				$CPUParticles2D.emitting = false
			else:
				$Area2D/CollisionShape2D.disabled = true
				Stats.expend_energy(1)
				$TextureRect.visible = false
				spawn_item(Global.spawnable_items[0], position)
				rock_state = "destroy"
				audio.stream = load("res://sonidos/sounds/rock_destroy.ogg")
				audio.play()
				await get_tree().create_timer(3.0).timeout
				queue_free()
