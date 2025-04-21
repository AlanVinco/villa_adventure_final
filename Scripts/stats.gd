extends Node2D

# Variables con setters
@export var life: int = 100:
	set(value):
		life = value
		emit_signal("stat_changed")
		#emit_signal("stat_changed", "life", value)

@export var damage: int = 5:
	set(value):
		damage = value
		emit_signal("stat_changed")

@export var armor: int = 0:
	set(value):
		armor = value
		emit_signal("stat_changed")

@export var speed: int = 200:
	set(value):
		speed = value
		emit_signal("stat_changed")

@export var day: int = 0:
	set(value):
		day = value
		emit_signal("stat_changed")

@export var time: String = "day":
	set(value):
		time = value
		emit_signal("stat_changed")
		emit_signal("time_changed")

@export var actions_left: int = 3:
	set(value):
		actions_left = value
		emit_signal("stat_changed")

@export var hearts: int = 3:
	set(value):
		hearts = value
		emit_signal("stat_changed")

@export var visualNovel = "":
	set(value):
		visualNovel = value
		if value not in unlocked_scenes:  # Verifica si el valor ya existe
			unlocked_scenes.append(value)  # Solo agrega si no está en la lista
		print(unlocked_scenes)

@export var unlocked_scenes = [

]

##--------------------------------------------NEW STATS

@export var item_selected: = "":
	set(value):
		item_selected = value
		emit_signal("stat_changed")
		
@export var item_name_selected: = "":
	set(value):
		item_name_selected = value
		emit_signal("stat_changed")
		
@export var energy: int = 100:
	set(value):
		energy = value
		emit_signal("stat_changed")

@export var mana: int = 100:
	set(value):
		mana = value
		emit_signal("stat_changed")
		
@export var can_plant: = false:
	set(value):
		can_plant = value
		emit_signal("stat_changed")
		
@export var player_action = "":
	set(value):
		player_action = value
		emit_signal("player_action_signal")
		
@export var item_hot_bar_index: = 0:
	set(value):
		item_hot_bar_index = value
		emit_signal("stat_changed")

# Función para avanzar el tiempo según la acción realizada
signal playerNOEnergy 
signal playerLocura
signal havanyMoney
signal player_action_signal
signal stat_changed
signal time_changed

func advance_time():
	#hunger(20)
	if actions_left > 1:
		actions_left -= 1
		match time:
			"day":
				#GlobalTransitions.transition()
				await get_tree().create_timer(0.5).timeout
				time = "afternoon"
			"afternoon":
				#GlobalTransitions.transition()
				await get_tree().create_timer(0.5).timeout
				time = "night"
	else:
		# Si ya no hay acciones, resetea el día
		reset_day()

	print("Nuevo tiempo:", time, "- Acciones restantes:", actions_left)

# Función para reiniciar el día al dormir
func reset_day():
	#Stats.HUSBAND -= 1
	day += 1
	time = "day"
	actions_left = 3
	#GlobalTransitions.nex_day_animation()
	print("Nuevo día iniciado")

func expend_energy(value):
	energy -=value
	if energy <=0:
		energy = 1
		emit_signal("playerNOEnergy")
