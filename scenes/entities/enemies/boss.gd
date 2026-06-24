extends Enemy

const simple_attacks: Dictionary[Variant, Variant] = {
	'slice': '2H_Melee_Attack_Slice',
	'spin': '2H_Melee_Attack_Spin',
	'range': '1H_Melee_Attack_Stab'
}

@onready var spin_speed := 6
var spinning := false

var can_damage_toggle := false

func _process(_delta: float) -> void:
	attack_logic()

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < 5.0:
		melee_attack_animation()
	else: 
		if rng.randi() % 2:
			range_attack_animation()
		else:
			spin_attack_animtaion()
		
func spin_attack_animtaion():
	var tween: Tween = create_tween()
	tween.tween_property(self, "speed", spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	$Timers/AttackTimer.stop()
	spinning = true

func _spin_transition(value: float) -> void:
	$AnimationTree.set('parameters/SpinBlend/blend_amount', value)
	
func range_attack_animation():
	stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attacks['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
func melee_attack_animation() -> void:
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if spinning:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		var tween: Tween = create_tween()
		tween.tween_property(self, "speed", spin_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		spinning = true
		$Timers/AttackTimer.start()
		
func hit() -> void: 
	if not $Timers/InvulTimer.time_left:
		$Timers/InvulTimer.start()
		health -= 1
		var tween: Tween = create_tween()
		tween.tween_method(_hit_effect, 0.0, 0.5, 0.3)
		tween.tween_method(_hit_effect, 0.5, 0.0, 0.2)

func _hit_effect(value: float) -> void:
	$Skin/Rig/Skeleton3D/Nagonford_Body.material_overlay.set_shader_parameter('color', Color.LIGHT_GREEN)
	$Skin/Rig/Skeleton3D/Nagonford_Body.material_overlay.set_shader_parameter('alpha', value)

func can_damage(value: bool) -> void:
	can_damage_toggle = value
	
func attack_logic() -> void:
	if can_damage_toggle:
		var collider = $Skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/RayCast3D.get_collider()
		if collider and 'hit' in collider:
			collider.hit()

func shoot_fireball() -> void:
	var direction = (player.position - position).normalized()
	var dir_2d: Vector2 = Vector2(direction.x, direction.z)
	var pos = $Skin/Rig/Skeleton3D/Nagonford_Axe/Nagonford_Axe/Marker3D.global_position
	cast_spell.emit('fireball', pos, dir_2d, 3.0)
