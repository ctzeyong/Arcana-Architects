extends Node2D

func _ready():
	%AnimationPlayer.play("walk")
	%AnimationPlayer.stop()

func idle_anim():
	%AnimationPlayer.stop()

func walk_anim():
	%AnimationPlayer.play("walk")

func attack_anim():
	%AnimationPlayer.play("attack")
