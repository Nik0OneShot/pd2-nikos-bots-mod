Hooks:PostHook(WeaponTweakData, "init", "chicken_tendies", function(self)
function WeaponTweakData:_init_data_amcar_crew()
	  self.amcar_crew.categories = clone(self.amcar.categories)
	  self.amcar_crew.sounds.prefix = "amcar_npc"
	  self.amcar_crew.use_data.selection_index = SELECTION.PRIMARY
	  self.amcar_crew.DAMAGE = 2
	  self.amcar_crew.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	  self.amcar_crew.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	  self.amcar_crew.CLIP_AMMO_MAX = 30
	  self.amcar_crew.NR_CLIPS_MAX = 69420
	  self.amcar_crew.pull_magazine_during_reload = "rifle"
	  self.amcar_crew.auto.fire_rate = 60 / 800
	  self.amcar_crew.hold = "rifle"
	  self.amcar_crew.alert_size = 5000
	  self.amcar_crew.suppression = 1
	  self.amcar_crew.FIRE_MODE = "auto"
   end
end)
