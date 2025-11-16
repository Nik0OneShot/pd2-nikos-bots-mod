	local is_server = Network:is_server()
	local is_offline = Global and Global.game_settings and Global.game_settings.single_player
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	local gang_member_damage = { HEALTH_INIT = 50 }
	gang_member_damage.BLEED_OUT_HEALTH_INIT = gang_member_damage.HEALTH_INIT * 0.5
	gang_member_damage.REGENERATE_TIME = 2
	gang_member_damage.REGENERATE_TIME_AWAY = 2
	gang_member_damage.DOWNED_TIME = tweak_data.player.damage.DOWNED_TIME
	gang_member_damage.TASED_TIME = tweak_data.player.damage.TASED_TIME
	gang_member_damage.ARRESTED_TIME = tweak_data.player.damage.ARRESTED_TIME * 0.5
	gang_member_damage.INCAPACITATED_TIME = tweak_data.player.damage.INCAPACITATED_TIME
	gang_member_damage.hurt_severity = deep_clone(tweak_data.character.presets.hurt_severities.base)
	gang_member_damage.hurt_severity.bullet = { health_reference = "full", zones = { { health_limit = 0.4, none = 0.6, light = 0.4, }, { light = 1, }, }, }
	gang_member_damage.MIN_DAMAGE_INTERVAL = 0.15
	gang_member_damage.respawn_time_penalty = 0
	gang_member_damage.base_respawn_time_penalty = 5
	
	local gang_member_speed = {
			stand = {
				walk = {
					ntl = { strafe = 200, fwd = 200, bwd = 200 },
					hos = { strafe = 300, fwd = 300, bwd = 300 },
					cbt = { strafe = 300, fwd = 300, bwd = 300 } },
				run = {
					hos = { strafe = 700, fwd = 700, bwd = 700 },
					cbt = { strafe = 700, fwd = 700, bwd = 700 } } },
			crouch = {
				walk = {
					hos = { strafe = 300, fwd = 300, bwd = 300 },
					cbt = { strafe = 300, fwd = 300, bwd = 300 } },
				run = {
					hos = { strafe = 500, fwd = 500, bwd = 500 },
					cbt = { strafe = 500, fwd = 500, bwd = 500 } } } }
					
	local gang_member_dodge = {
			speed = 1.2,
			occasions = {
				hit = {
					chance = 1,
					check_timeout = { 1, 2 },
					variations = {
						roll = { chance = 1, shoot_chance = 1, shoot_accuracy = 1, timeout = { 1, 2 } } } },
				preemptive = {
					chance = 1,
					check_timeout = { 1, 2 },
					variations = {
						roll = { chance = 1, shoot_chance = 1, shoot_accuracy = 1, timeout = { 1, 2 } } } },
				scared = {
					chance = 1,
					check_timeout = { 1, 2 },
					variations = {
						roll = { chance = 1, shoot_chance = 1, shoot_accuracy = 1, timeout = { 1, 2 } } } } } }

local gang_member_detection = { idle = {}, combat = {}, recon = {}, guard = {}, ntl = {} }
	gang_member_detection.idle.dis_max = 100000
	gang_member_detection.idle.angle_max = 240
	gang_member_detection.idle.delay = { 0, 0 }
	gang_member_detection.idle.use_uncover_range = true
	gang_member_detection.combat.dis_max = 100000
	gang_member_detection.combat.angle_max = 240
	gang_member_detection.combat.delay = { 0, 0 }
	gang_member_detection.combat.use_uncover_range = true
	gang_member_detection.recon.dis_max = 100000
	gang_member_detection.recon.angle_max = 240
	gang_member_detection.recon.delay = { 0, 0 }
	gang_member_detection.recon.use_uncover_range = true
	gang_member_detection.guard.dis_max = 100000
	gang_member_detection.guard.angle_max = 240
	gang_member_detection.guard.delay = { 0, 0 }
	gang_member_detection.ntl = tweak_data.character.presets.detection.normal.ntl
	
local gang_member_weapon = { is_pistol = {} }
	gang_member_weapon.is_pistol.aim_delay = { 0, 0 }
	gang_member_weapon.is_pistol.focus_delay = 0
	gang_member_weapon.is_pistol.focus_dis = 2000
	gang_member_weapon.is_pistol.spread = 25
	gang_member_weapon.is_pistol.miss_dis = 20
	gang_member_weapon.is_pistol.RELOAD_SPEED = 2
	gang_member_weapon.is_pistol.melee_speed = 3
	gang_member_weapon.is_pistol.melee_dmg = 3
	gang_member_weapon.is_pistol.melee_retry_delay = tweak_data.character.presets.weapon.normal.is_pistol.melee_retry_delay
	gang_member_weapon.is_pistol.range = { optimal = 2500, far = 6000, close = 1500 }
	gang_member_weapon.is_pistol.FALLOFF = {
		{ dmg_mul = 5, r = 700, acc = { 1, 1 }, recoil = { 0.25, 0.45 }, mode = { 0.1, 0.3, 4, 7 } },
		{ dmg_mul = 5, r = 1200, acc = { 1, 1 }, recoil = { 0.4, 0.7 }, mode = { 0.1, 0.3, 4, 7 } },
		{ dmg_mul = 5, r = 10000, acc = { 1, 1 }, recoil = { 0.7, 1 }, mode = { 0.1, 0.3, 4, 7 } } }
	gang_member_weapon.is_revolver = deep_clone(tweak_data.character.presets.weapon.gang_member.is_pistol)
	gang_member_weapon.is_revolver.FALLOFF = {
		{ dmg_mul = 7.5, r = 700, acc = { 1, 1 }, recoil = { 0.5, 0.9 }, mode = { 0.1, 0.3, 4, 7 } },
		{ dmg_mul = 7.5, r = 1200, acc = { 1, 1 }, recoil = { 0.9, 1.4 }, mode = { 0.1, 0.3, 4, 7 } },
		{ dmg_mul = 7.5, r = 10000, acc = { 1, 1 }, recoil = { 1.5, 2 }, mode = { 0.1, 0.3, 4, 7 } } }
	gang_member_weapon.is_rifle = {
		aim_delay = { 0, 0 },
		focus_delay = 1,
		focus_dis = 3000,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 0.85,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = tweak_data.character.presets.weapon.normal.is_rifle.melee_retry_delay,
		range = { optimal = 2500, far = 6000, close = 1500 },
		autofire_rounds = tweak_data.character.presets.weapon.normal.is_rifle.autofire_rounds,
		FALLOFF = {
			{ dmg_mul = 5, r = 300, acc = { 0.5, 0.8 }, recoil = { 0.25, 0.45 }, mode = { 0.1, 0.3, 4, 7 } },
			{ dmg_mul = 5, r = 1000, acc = { 0.5, 0.8 }, recoil = { 0.6, 1.1 }, mode = { 0.1, 0.3, 4, 7 } },
			{ dmg_mul = 5, r = 10000, acc = { 0.5, 0.8 }, recoil = { 1, 1.5 }, mode = { 0.1, 0.3, 4, 7 } } } }
	gang_member_weapon.is_sniper = {
		aim_delay = { 0, 0 },
		focus_delay = 1,
		focus_dis = 3000,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = tweak_data.character.presets.weapon.normal.is_rifle.melee_retry_delay,
		range = { optimal = 4000, far = 6000, close = 2000 },
		FALLOFF = {
			{ dmg_mul = 10, r = 500, acc = { 0.75, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
			{ dmg_mul = 10, r = 1000, acc = { 0.75, 1 }, recoil = { 2, 3 }, mode = { 1, 0, 0, 0 } },
			{ dmg_mul = 10, r = 10000, acc = { 0.75, 1 }, recoil = { 4, 5 }, mode = { 1, 0, 0, 0 } } } }
	gang_member_weapon.is_lmg = {
		aim_delay = { 0, 0 },
		focus_delay = 1,
		focus_dis = 3000,
		spread = 30,
		miss_dis = 10,
		RELOAD_SPEED = 0.7,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = tweak_data.character.presets.weapon.normal.is_lmg.melee_retry_delay,
		range = { optimal = 2500, far = 6000, close = 1500 },
		autofire_rounds = tweak_data.character.presets.weapon.normal.is_lmg.autofire_rounds,
		FALLOFF = {
			{ dmg_mul = 5, r = 100, acc = { 0.5, 0.8 }, recoil = { 0.25, 0.45 }, mode = { 0, 0, 0, 1 } },
			{ dmg_mul = 5, r = 1000, acc = { 0.5, 0.8 }, recoil = { 0.4, 0.65 }, mode = { 0, 0, 0, 1 } },
			{ dmg_mul = 5, r = 10000, acc = { 0.5, 0.8 }, recoil = { 2, 3 }, mode = { 0, 0, 0, 1 } } } }
	gang_member_weapon.is_shotgun_pump = {
		aim_delay = { 0, 0 },
		focus_delay = 1,
		focus_dis = 2000,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 2,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = tweak_data.character.presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = tweak_data.character.presets.weapon.normal.is_shotgun_pump.range,
		FALLOFF = {
			{ dmg_mul = 5, r = 300, acc = { 0.75, 1 }, recoil = { 0.5, 0.9 }, mode = { 0.1, 0.3, 4, 7 } },
			{ dmg_mul = 5, r = 1000, acc = { 0.75, 1 }, recoil = { 0.9, 1.6 }, mode = { 0.1, 0.3, 4, 7 } },
			{ dmg_mul = 5, r = 10000, acc = { 0.75, 1 }, recoil = { 1.5, 2 }, mode = { 0.1, 0.3, 4, 7 } } } }
	gang_member_weapon.is_shotgun_mag = {
		aim_delay = { 0, 0 },
		focus_delay = 1,
		focus_dis = 2000,
		spread = 18,
		miss_dis = 10,
		RELOAD_SPEED = 1.6,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = tweak_data.character.presets.weapon.normal.is_shotgun_mag.melee_retry_delay,
		range = tweak_data.character.presets.weapon.normal.is_shotgun_mag.range,
		autofire_rounds = { 4, 8 },
		FALLOFF = {
			{ dmg_mul = 5, r = 100, acc = { 0.75, 1 }, recoil = { 0.1, 0.1 }, mode = { 1, 1, 4, 6 } },
			{ dmg_mul = 5, r = 500, acc = { 0.75, 1 }, recoil = { 0.1, 0.1 }, mode = { 1, 1, 4, 5 } },
			{ dmg_mul = 5, r = 10000, acc = { 0.75, 1 }, recoil = { 0.5, 1 },mode = { 2, 1, 0, 0 } } } }
	gang_member_weapon.is_smg = tweak_data.character.presets.weapon.gang_member.is_rifle
	gang_member_weapon.is_revolver = tweak_data.character.presets.weapon.gang_member.is_pistol
	gang_member_weapon.is_bullpup = tweak_data.character.presets.weapon.gang_member.is_rifle
	gang_member_weapon.mac11 = tweak_data.character.presets.weapon.gang_member.is_smg
	gang_member_weapon.rifle = deep_clone(tweak_data.character.presets.weapon.gang_member.is_rifle)
	gang_member_weapon.rifle.autofire_rounds = nil
	gang_member_weapon.akimbo_pistol = tweak_data.character.presets.weapon.gang_member.is_pistol
	gang_member_weapon.is_flamethrower = tweak_data.character.presets.weapon.normal.is_flamethrower

for _, v in pairs(tweak_data.character) do
	if type(v) == "table" and v.access == "teamAI1" then
		v.no_run_start = true
		v.no_run_stop = true
		v.always_face_enemy = true
		v.crouch_move = false
		v.damage = gang_member_damage
		v.dodge = gang_member_dodge
		v.detection = gang_member_detection
		v.move_speed = gang_member_speed
		v.weapon = clone(gang_member_weapon)
		v.weapon.weapons_of_choice = { primary = "wpn_fps_ass_amcar_npc" }
		if difficulty_index < 4 then
			v.damage.HEALTH_INIT = 100
			v.damage.BLEED_OUT_HEALTH_INIT = 50
		elseif difficulty_index < 6 then
			v.damage.HEALTH_INIT = 200
			v.damage.BLEED_OUT_HEALTH_INIT = 100
		else
			v.damage.HEALTH_INIT = 300
			v.damage.BLEED_OUT_HEALTH_INIT = 150
		end
			tweak_data.team_ai.stop_action.distance = 9999999999
	end

end




