extends Node2D

func _ready():
	play_idle()


func play_idle():
	%Idle.visible = true
	%Walk.visible = false
	%Death.visible = false
	%AnimationPlayer.play("idle")
	%BoneLeftHand.play_idle()
	%WoodDagger.play_idle()
	%BoneRightGrip.play_idle()


func play_walk():
	%Idle.visible = false
	%Walk.visible = true
	%Death.visible = false
	%AnimationPlayer.play("walk")
	%BoneLeftHand.play_walk()
	%WoodDagger.play_walk()
	%BoneRightGrip.play_walk()


func play_death():
	%Idle.visible = false
	%Walk.visible = false
	%Death.visible = true
	%AnimationPlayer.play("death")
	%BoneLeftHand.play_death()
	%WoodDagger.play_death()
