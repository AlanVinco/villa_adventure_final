extends Node2D

@export var has_seed = false

const plant = preload("res://scenes/plants/plant.tscn")

var ground_state = ""

var plant_selected = ""

@onready var audio = $AudioStreamPlayer2D

var can_plant = true
#func _ready() -> void:
	#Stats.player_action.connect(collect_item)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !has_seed and Stats.item_selected == "HOE" and ground_state == "" and can_plant:
		if event.is_action("mouse_action"):
			audio.stream = load("res://sonidos/sounds/arar_tierra.ogg")
			audio.play() 
			$Arada.visible = true
			$Normal.visible = false
			$Mojada.visible = false
			ground_state = "arada"
			Stats.expend_energy(2)
			$CPUParticles2D.emitting = true
			$CPUParticles2D.color = Color("534100")
			await get_tree().create_timer(0.5).timeout
			$CPUParticles2D.emitting = false
			
			
	if !has_seed and Stats.item_selected == "BUCKET" and ground_state == "arada":
		if event.is_action("mouse_action"):
			audio.stream = load("res://sonidos/sounds/regar_sound.ogg")
			audio.play()  
			$Arada.visible = false
			$Normal.visible = false
			$Mojada.visible = true
			ground_state = "mojada"
			Stats.expend_energy(2)
			$CPUParticles2D.emitting = true
			$CPUParticles2D.color = Color("1f00c6")
			await get_tree().create_timer(0.5).timeout
			$CPUParticles2D.emitting = false
			Stats.can_plant = true
			
			
	
	if !has_seed and (Stats.item_selected == "SEED" or Stats.item_selected == "SEED1") and ground_state == "mojada":
		plant_selected = Stats.item_name_selected
		if event.is_action("mouse_action"):
			use_hotbar_item(Stats.item_hot_bar_index)
			audio.stream = load("res://sonidos/sounds/plantar_sound.ogg")
			audio.play() 
			var item_instance = plant.instantiate()
			item_instance.position = position - Vector2(-8, -8)
			item_instance.plant_name = plant_selected
			get_parent().add_child(item_instance)
			item_instance.collected_plant.connect(start_ground)
			
			has_seed = true
			Stats.expend_energy(2)
			$CPUParticles2D.emitting = true
			$CPUParticles2D.color = Color("007f55")
			await get_tree().create_timer(0.5).timeout
			$CPUParticles2D.emitting = false
			

func start_ground():
	audio.stream = load("res://sonidos/sounds/plantar_sound.ogg")
	audio.play() 
	$Normal.visible = true
	$Arada.visible = false
	$Mojada.visible = false
	ground_state = ""
	has_seed = false


func _on_area_2d_mouse_entered() -> void:
	if ground_state == "mojada":
		Stats.can_plant = true
func _on_area_2d_mouse_exited() -> void:
	Stats.can_plant = false


func use_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			# Use item
			var item_usable = check_item_type(item)
			if item_usable:
				# Remove item
				item["quantity"] -= 1
				if item["quantity"] <= 0:
					Stats.item_selected = ""
					Stats.item_name_selected = ""
					Global.hotbar_inventory[slot_index] = null
					Global.remove_item(item["type"], item["effect"])
				Global.inventory_updated.emit()
				
func check_item_type(item):
	Stats.item_selected = item.type
	Stats.item_name_selected = item.name
	if item.type == "SEED" or item.type == "SEED1":
		return true
	else:
		return false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("object"):
		can_plant = false

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("object"):
		can_plant = true
