extends Node3D

@export var treasure_scene: PackedScene  # Додај ја сцената за богатство преку инспектор
@export var num_treasures: int = 7  # Колку богатства да се генерираат

var score = 0
var total_treasures = 0

@onready var timer = $Timer  # Поврзување со Timer Node
@onready var player = $CharacterBody3D  # Поврзување со играчот
@onready var ground = $StaticBody3D  # Поврзување со земјата (површина каде се појавуваат богатствата)
@onready var score_label = $CanvasLayer/Control/ScoreLabel  # UI скор
@onready var timer_label = $CanvasLayer/Control/TimerLabel  # UI тајмер
@onready var game_over_screen = $CanvasLayer/Control/GameOverScreen  # Game Over Screen
@onready var game_over_text = $CanvasLayer/Control/GameOverScreen/GameOverText  # Текст во крајниот екран
@onready var retry_button = $CanvasLayer/Control/GameOverScreen/RetryButton  # Копче за рестарт

func _ready():
	if player == null:
		print("❌ ERROR: Играчот не е пронајден! Проверете го името во сцената.")
		return

	game_over_screen.visible = false  # Сокриј го Game Over Screen на старт
	retry_button.pressed.connect(_restart_game)  # Поврзи го копчето за рестарт

	spawn_treasures()
	total_treasures = num_treasures
	timer.start(60)  # Започнува 1 минута одбројување
	update_ui()

func spawn_treasures():
	if ground == null:
		print("❌ ERROR: StaticBody3D не е пронајден! Проверете ја вашата сцена.")
		return

	var ground_size = ground.get_child(0).mesh.size  # Добиј големина ако користиш MeshInstance3D
	var player_pos = player.global_transform.origin

	for i in range(num_treasures):
		var treasure = treasure_scene.instantiate()  # Создавање ново богатство

		# Намален опсег на X и Z координати за да не се создаваат предалеку
		var x = randf_range(-ground_size.x * 0.3, ground_size.x * 0.3)  
		var z = randf_range(-ground_size.z * 0.3, ground_size.z * 0.3)  

		# Проверка за минимална оддалеченост од играчот за да се избегне премногу блиско создавање
		if abs(z) < 1.5:  
			z += sign(z) * 1.5  

		var position = player_pos + Vector3(x, 0.1, z)  
		treasure.transform.origin = position

		add_child(treasure)  # Додавање во сцената
		treasure.add_to_group("treasures")  # Додавање во група за следење
		treasure.collected.connect(_on_treasure_collected)  # Поврзување на сигнал

func _on_treasure_collected():
	score += 1
	update_ui()
	print("Score:", score)

	if score >= total_treasures:
		game_over(true)  # Победа ако се соберат сите богатства

func _on_timer_timeout():
	game_over(false)  # Пораз ако истече времето

func game_over(won: bool):
	timer.stop()
	game_over_screen.visible = true  # Прикажи го крајниот екран

	if won:
		print("🏆 Победа! Сите богатства се собрани!")
		game_over_text.text = "🏆 Победа! Сите богатства се собрани!"
	else:
		print("⏳ Времето истече!")
		game_over_text.text = "⏳ Времето истече!"

func _restart_game():
	# Рестартирање на сите параметри
	score = 0
	timer.start(60)
	game_over_screen.visible = false  # Сокриј го крајниот екран
	update_ui()

	# Отстрани ги старите богатства
	for treasure in get_tree().get_nodes_in_group("treasures"):
		treasure.queue_free()

	spawn_treasures()  # Повторно генерирај богатства

func _process(delta):
	if timer.time_left > 0:
		timer_label.text = "⏳ Time: " + str(round(timer.time_left))  # Ажурирање на тајмер

func update_ui():
	score_label.text = "💰 Score: " + str(score)  # Ажурирање на скор во UI
