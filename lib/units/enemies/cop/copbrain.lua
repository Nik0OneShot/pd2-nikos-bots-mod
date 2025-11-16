Hooks:PostHook(CopBrain, "convert_to_criminal", "copbrain_convert_to_criminal", function(self, ...)
	if self._logic_data and self._logic_data.char_tweak then
		local char_tweak = deep_clone(self._logic_data.char_tweak)
		char_tweak.access = "teamAI1"
		char_tweak.always_face_enemy = true
		char_tweak.no_run_start = true
		char_tweak.no_run_stop = true
		char_tweak.suppression = nil
		char_tweak.crouch_move = false
		char_tweak.damage.hurt_severity = tweak_data.character.presets.hurt_severities.only_light_hurt
		char_tweak.damage.hurt_severity.explosion = { health_reference = 1, zones = { { light = 1 } } }
		self._logic_data.char_tweak = char_tweak
		self._unit:base()._char_tweak = char_tweak
		self._unit:character_damage()._char_tweak = char_tweak
		self._unit:movement()._tweak_data = char_tweak
		self._unit:movement()._action_common_data.char_tweak = char_tweak
	end
end)