extends Node2D

signal player_collision_spike

func _on_spike_body_entered(body):
	if body == $Player:
		emit_signal("player_collision_spike")
