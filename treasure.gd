extends Node3D

signal collected  # Сигнал за кога богатство ќе биде собрано

@export var textures: Array[Texture2D]  # Листа на текстури за различни богатства

func _ready():
	# Осигурај се дека Treasure има Sprite3D како дете
	var sprite = find_child("Sprite3D", true, false)  # Автоматско наоѓање на Sprite3D
	if not sprite:
		print("❌ ERROR: Sprite3D не е пронајден во Treasure сцената!")
		return

	# Избери случајна текстура од листата
	if textures.size() > 0:
		var random_texture = textures[randi() % textures.size()]
		sprite.texture = random_texture  # Постави текстура

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):  # Осигурај се дека играчот е во групата "player"
		print("Играчот собра богатство!")
		collected.emit()  # Испрати сигнал дека богатството е собрано
		queue_free()  # Избриши го богатството
