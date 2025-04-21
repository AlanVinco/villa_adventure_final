extends Control

@onready var hotbar_container = $HBoxContainer

#Drag and drop
var dragged_slot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.inventory_updated.connect(update_hotbar_ui)
	update_hotbar_ui()


func update_hotbar_ui():
	clear_hotbar_container()
	for i in range(Global.hotbar_size):
		var slot = Global.inventory_slot_scene.instantiate()
		slot.set_slot_index(i)
		
		
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		
		hotbar_container.add_child(slot)
		#slot.outer_border.modulate = Color("852e00")
		if Global.hotbar_inventory[i] != null:
			slot.set_item(Global.hotbar_inventory[i])
		else: 
			slot.set_empty()
		slot.update_assignament_status()
	
func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()
		
# Store dragged slot reference
func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control
	print("Drag started from slot: ", dragged_slot)

func _on_drag_end():
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	elif dragged_slot != target_slot:
		var drop_position = Global.player_node.global_position
		var drop_offset = Vector2(50, 0)
		drop_offset = drop_offset.rotated(Global.player_node.rotation)
		Global.drop_item(dragged_slot.item, drop_position + drop_offset)
		if Global.valid_item:
			Global.unassign_hotbar_item(dragged_slot.item["type"], dragged_slot.item["effect"])
			Global.remove_item(dragged_slot.item["type"], dragged_slot.item["effect"])
	dragged_slot = null
		
# Get the current mouse position in the grid_container's coordinate system
func get_slot_under_mouse() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in hotbar_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null
	
# Find the index of a slot	
func get_slot_index(slot: Control) -> int:
	for i in range(hotbar_container.get_child_count()):
		if hotbar_container.get_child(i) == slot:
			# Valid slot found
			return i
	# Invalid slot
	return -1
	
# Drop slots
func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)	
	var slot2_index = get_slot_index(slot2)	
	if slot1_index == -1 or slot2_index == -1:
		print("Invalid slots found")
		return
	else:
		if Global.swap_hotbar_items(slot1_index, slot2_index):
			print("Drpping slot items: ", slot1, slot2_index)
			update_hotbar_ui()


#NEW COLOR HOTBAR SELECT

func _input(event):
	if event is InputEventKey and event.pressed and event.unicode != 0:
		var char_pressed = char(event.unicode)
		if char_pressed.is_valid_int():
			var number = char_pressed.to_int()
			
			toggle_panel(number)

func toggle_panel(panel_number: int):
	if panel_number == 1:
		hotbar_container.get_children()[0].outer_border.modulate = Color("852e00")
		hotbar_container.get_children()[1].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[2].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[3].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[4].outer_border.modulate = Color("98eecc")
	if panel_number == 2:
		hotbar_container.get_children()[1].outer_border.modulate = Color("852e00")
		hotbar_container.get_children()[0].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[2].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[3].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[4].outer_border.modulate = Color("98eecc")
	if panel_number == 3:
		hotbar_container.get_children()[2].outer_border.modulate = Color("852e00")
		hotbar_container.get_children()[1].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[0].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[3].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[4].outer_border.modulate = Color("98eecc")
	if panel_number == 4:
		hotbar_container.get_children()[3].outer_border.modulate = Color("852e00")
		hotbar_container.get_children()[1].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[2].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[0].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[4].outer_border.modulate = Color("98eecc")
	if panel_number == 5:
		hotbar_container.get_children()[4].outer_border.modulate = Color("852e00")
		hotbar_container.get_children()[1].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[2].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[3].outer_border.modulate = Color("98eecc")
		hotbar_container.get_children()[0].outer_border.modulate = Color("98eecc")
