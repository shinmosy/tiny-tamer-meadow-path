extends Node

var click_player: AudioStreamPlayer
var hit_player: AudioStreamPlayer
var skill_player: AudioStreamPlayer
var heal_player: AudioStreamPlayer
var encounter_player: AudioStreamPlayer
var throw_player: AudioStreamPlayer
var capture_player: AudioStreamPlayer

func _ready() -> void:
	click_player = _create_player("res://assets/audio/click.wav")
	hit_player = _create_player("res://assets/audio/hit.wav")
	skill_player = _create_player("res://assets/audio/skill.wav")
	heal_player = _create_player("res://assets/audio/heal.wav")
	encounter_player = _create_player("res://assets/audio/encounter.wav")
	throw_player = _create_player("res://assets/audio/throw.wav")
	capture_player = _create_player("res://assets/audio/capture.wav")

func _create_player(path: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	return player

func _can_play() -> bool:
	return SettingsManager.sound_enabled

func play_click() -> void:
	if _can_play(): click_player.play()

func play_hit() -> void:
	if _can_play(): hit_player.play()

func play_skill() -> void:
	if _can_play(): skill_player.play()

func play_heal() -> void:
	if _can_play(): heal_player.play()

func play_encounter() -> void:
	if _can_play(): encounter_player.play()

func play_throw() -> void:
	if _can_play(): throw_player.play()

func play_capture() -> void:
	if _can_play(): capture_player.play()
