extends KinematicBody2D

signal take_damage(amount)


func take_damage(val):
	emit_signal("take_damage", val)