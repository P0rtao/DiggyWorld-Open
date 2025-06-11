extends Node2D

@onready var u: AnimatedSprite2D = $U
@onready var d: AnimatedSprite2D = $D
@onready var c: AnimatedSprite2D = $C

@export var display_num : int = 2
var number : int = 0
var digit_sprites : Array[AnimatedSprite2D]

func _ready() -> void:
	# Remove unused sprites
	match (display_num):
		1 :
			digit_sprites.append(u)
			d.queue_free()
			c.queue_free()
		2 :
			digit_sprites.append(u)
			digit_sprites.append(d)
			c.queue_free()
		3 :
			digit_sprites.append(u)
			digit_sprites.append(d)
			digit_sprites.append(c)

func set_number(n: int) -> void :
	if n != number :
		number = n
		update_digits()

func update_digits() -> void :
	# Where digits to display are stored
	var digits : Array[int] = []
	if number > 0 :
		var tmp_number : int = number
		
		# Dividing the number by 10 to get every digit until result is lower than 0
		for i in range(digit_sprites.size()) :
			if tmp_number % 10 > 0 :
				digits.append(tmp_number % 10)
			else :
				digits.append(0)
			tmp_number /= 10
	else :
		# Set everything to 0, just to be sure
		for i in range(digit_sprites.size()) :
			digits.append(0)
	
	show_digits(digits)
	
func show_digits(digit_array: Array) -> void :
	# Take the current digit and set the sprite to it
	for i in range(digit_array.size()) :
		var digit: int = digit_array[i]
		if digit_sprites[i] :
			var digit_sprite : AnimatedSprite2D = digit_sprites[i]
			digit_sprite.set_frame(digit)
		
