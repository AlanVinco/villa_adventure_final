### Player.gd
extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed = 100.0
var is_moving = false
@export var can_move = true
# Scene-Tree Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var interact_ui = $InteractUI
@onready var inventory_ui = $InventoryUI
@onready var inventory_hotbar = $InventoryHotbar
var last_direction := Vector2.DOWN

# Variables
@export var speed = 200

func _ready():
	# Set this node as the Player node
	Global.set_player_reference(self)
	Stats.stat_changed.connect(update_stats)
	update_stats()

# Movement & Animation
func _physics_process(delta: float) -> void:
	if is_moving:
		$AnimatedSprite2D.play("walk")
		if navigation_agent_2d.is_navigation_finished():
			velocity = Vector2.ZERO
			is_moving = false
			return

		var next_path_position = navigation_agent_2d.get_next_path_position()
		var new_velocity = global_position.direction_to(next_path_position) * movement_speed

		# 👉 Flip sprite si va a la derecha o izquierda
		if new_velocity.x != 0:
			$AnimatedSprite2D.flip_h = new_velocity.x > 0

		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
	else:
		$AnimatedSprite2D.play("idle")
		velocity = Vector2.ZERO

	move_and_slide()
	#if is_moving and can_move:
		#if navigation_agent_2d.is_navigation_finished():
			#velocity = Vector2.ZERO
			#is_moving = false
			## Reproducir animación idle según última dirección
			#_play_idle_animation()
			#return
#
		#var next_path_position = navigation_agent_2d.get_next_path_position()
		#var direction = global_position.direction_to(next_path_position)
		#
		## ⚠️ Evitar cambios erráticos de dirección
		#if direction.length() > 0.1:
			#last_direction = direction.normalized()
			#_play_walk_animation(last_direction)
#
		#var new_velocity = direction * movement_speed
#
		#if navigation_agent_2d.avoidance_enabled:
			#navigation_agent_2d.set_velocity(new_velocity)
		#else:
			#_on_navigation_agent_2d_velocity_computed(new_velocity)
	#else:
		#velocity = Vector2.ZERO
		#_play_idle_animation()
#
	#move_and_slide()

	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and can_move:
		var mouse_position = get_global_mouse_position()
		navigation_agent_2d.target_position = mouse_position
		is_moving = true
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
		inventory_hotbar.visible = !inventory_hotbar.visible
		
# Apply the effect of the item (if possible)
func apply_item_effect(item):
	match item["effect"]:
		"Stamina":
			speed += 50
			print("Speed increased to ", speed)
		"Slot Boost":
			Global.increase_inventory_size(5)
			print("Slots increased to ", Global.inventory.size())
		_:
			print("There is no effect for this item")
			
# Use hotbar items on key 1 - 5 press		
func use_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			# Use item
			var item_usable = check_item_type(item)
			if item_usable:
				apply_item_effect(item)
				# Remove item
				item["quantity"] -= 1
				if item["quantity"] <= 0:
					Stats.item_selected = ""
					Stats.item_name_selected = ""
					Global.hotbar_inventory[slot_index] = null
					Global.remove_item(item["type"], item["effect"])
				Global.inventory_updated.emit()
		else:
			Stats.item_selected = ""
			Stats.item_name_selected = ""

# Hotbar shortcuts
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		# Then check for specific keys
		for i in range(Global.hotbar_size):
			# Assuming keys 1-5 are mapped to actions "hotbar_1" to "hotbar_5" in the Input Map
			if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
				use_hotbar_item(i)
				Stats.item_hot_bar_index = i
				break


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func check_item_type(item):
	Stats.item_selected = item.type
	Stats.item_name_selected = item.name
	if item.type == "HOE":
		return false
	if item.type == "AXE":
		return false
	if item.type == "PICKAXE":
		return false
	if item.type == "BUCKET":
		return false
	if item.type == "SEED" or item.type == "SEED1":
		return false
	else:
		return true

func update_stats():
	$HUD/Progress/ProgressBarHP.value = Stats.life
	$HUD/Label/LabelHP.text = str(Stats.life, " %")
	
	$HUD/Progress/ProgressBarEnergy.value = Stats.energy
	$HUD/Label/LabelEnergy.text = str(Stats.energy, " %")
	
	$HUD/Progress/ProgressBarMana.value = Stats.mana
	$HUD/Label/LabelMana.text = str(Stats.mana, " %")


func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")


func _play_idle_animation() -> void:
	animated_sprite.play("idle")
	#if abs(last_direction.x) > abs(last_direction.y):
		#if last_direction.x > 0:
			#animated_sprite.play("idle_right")
		#else:
			#animated_sprite.play("idle_left")
	#else:
		#if last_direction.y > 0:
			#animated_sprite.play("idle_down")
		#else:
			#animated_sprite.play("idle_up")
