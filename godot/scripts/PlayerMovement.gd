extends CharacterBody2D

@export var speed := 180.0

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if GameState.mobile_move_vector.length() > 0.1:
		input_vector = GameState.mobile_move_vector
	velocity = input_vector.normalized() * speed
	move_and_slide()
	position.x = clamp(position.x, 20.0, 1580.0)
	position.y = clamp(position.y, 20.0, 1080.0)
	GameState.last_player_position = position
