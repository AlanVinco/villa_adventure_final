extends Node2D

@onready var timer: Timer = $Timer
@onready var plant: AnimatedSprite2D = $AnimatedSprite2D

@onready var audio = $AudioStreamPlayer2D

signal collected_plant

@onready var inventory_item: Node2D = $Inventory_Item
@onready var inventory_item_2: Node2D = $Inventory_Item2


@export var plants_data: Dictionary = {
	"name": "",  # Máximo 5 botiquines por stack
	"days": 5,   # Máximo 10 comidas por stack
	"texture": "", # Dinero no tiene límite
	"drop": "",      # Las armas no se stackean
}

@export var plant_name = ""

func _ready() -> void:
	print(plant_name, "ESTA ES LA PLANTA")
	plants_info(plant_name)
	timer.start()
	inventory_item.picked_item.connect(collect_item)
	inventory_item_2.picked_item.connect(collect_item)
	$Inventory_Item/Area2D/CollisionShape2D.disabled = true
	$Inventory_Item2/Area2D/CollisionShape2D.disabled = true
	#plant.frame = 1

func _on_timer_timeout() -> void:
	plant.frame += 1

func _on_animated_sprite_2d_frame_changed() -> void:
	if plant.frame == 4:
		audio.stream = load("res://sonidos/sounds/pop_sound.ogg")
		audio.play()
		$Timer.stop()
		if plant_name == "CORN SEED":
			$Inventory_Item/Area2D/CollisionShape2D.disabled = false
			$Inventory_Item.visible = true
		if plant_name == "EGGPLANT SEED":
			$Inventory_Item2/Area2D/CollisionShape2D.disabled = false
			$Inventory_Item2.visible = true

func collect_item():
	collected_plant.emit()
	queue_free()

func plants_info(plant_name):
	match plant_name:
		"CORN SEED":
			plant.animation = "plant_corn"
		"EGGPLANT SEED":
			plant.animation = "plant_eggplant"
		_:
			pass
