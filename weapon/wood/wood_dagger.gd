extends Node2D

func _ready():
	%AnimationPlayer.play("idle")


func play_idle():
	%AnimationPlayer.play("idle")


func play_walk():
	%AnimationPlayer.play("walk")


func play_death():
	%AnimationPlayer.play("death")
