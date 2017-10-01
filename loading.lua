local bdCore, c, s = select(2, ...):unpack()

bdCore:RegisterEvent("ADDON_LOADED")
bdCore:RegisterEvent("PLAYER_REGEN_ENABLED")
bdCore:RegisterEvent("PLAYER_REGEN_DISABLED")
bdCore:RegisterEvent("LOADING_SCREEN_DISABLED")
--bdCore:RegisterEvent("PLAYER_ENTERING_WORLD")
bdCore:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
	-- set UIScale manually, since the CVAR won't let you go beneath 0.64 (why blizz??)
	if (not InCombatLockdown()) then
		--SetCVar("uiScale", bdCore.scale)
		--SetCVar("useUIScale", 0)
		--SetCVar("uiScaleMultiplier", -1)
		UIParent:SetScale(bdCore.scale)
	end

	if (event == "ADDON_LOADED" and (arg1 == "bdCore" or arg1 == "bdcore")) then

		local first = false
		-- create default profile
		if (not BD_profiles) then
			BD_profiles = {}

			if (bdCoreData) then
				BD_profiles['default'] = bdCoreData
			else
				BD_profiles['default'] = c
			end

		end
		c.profiles = BD_profiles

		-- create this characters configuration
		if (not BD_user or not BD_user.profile) then
			BD_user = {}
			BD_user.profile = "default"

			first = true; -- trigger first time run screen
		end
		c.user = BD_user
		c.user.profile = c.user.profile or "default"

		-- Scope current profile
		c.profile = c.profiles[c.user.profile]
		c.profile.positions = c.profiles[c.user.profile].positions or {}

		-- add profile config here, before we set any defaults below
		bdCore:triggerEvent('profile_config')

		c.user.profile_spec = c.user.profile_spec or {}
		c.user.profile_spec.current = c.user.profile_spec.current or false
		c.user.profile_spec[1] = c.user.profile_spec[1] or false
		c.user.profile_spec[2] = c.user.profile_spec[2] or false
		c.user.profile_spec[3] = c.user.profile_spec[3] or false
		c.user.profile_spec[4] = c.user.profile_spec[4] or false

		-- things that are not profile specific
		if (not BD_persistent ) then
			BD_persistent = {}
		end

		c.persistent = BD_persistent
		c.persistent.auras = c.persistent.auras or {}
		c.persistent.raid = c.persistent.auras.raid or {}
		c.persistent.whitelist = c.persistent.auras.whitelist or {}
		c.persistent.blacklist = c.persistent.auras.blacklist or {}
		c.persistent.mine = c.persistent.auras.mine or {}
		c.persistent.auras.class = c.persistent.auras.class or {}
		c.persistent.auras.class[bdCore.class] = c.persistent.auras.class[bdCore.class] or {}
		
		c.persistent.gmotd = c.persistent.gmotd or {}
		c.persistent.goldtrack = c.persistent.goldtrack or {}
		
	
		-- we shouldn't need this since lua references automatically the same table?
		-- when we update the default configuration, those new configurations should be copied over
		--[[ for group, options in pairs(c) do
			if (bdCoreDataPerChar[group] == nil) then
				bdCoreDataPerChar[group] = c[group]
			end
			for option, value in pairs(options) do
				if (bdCoreDataPerChar[group][option] == nil) then
					bdCoreDataPerChar[group][option] = value
				end
			end
			
		end--]]
		
		--[[
		for group, options in pairs(c.sv) do
			for option, value in pairs(options) do
				if (not c[group]) then c[group] = {} end
				if (c[group][option] ~= value) then
					c[group][option] = value
				end
			end
		end--]]

		if (first) then
			bdCore:triggerEvent('bd_first_run')
			print("The latest bdCore update completely revamps the way it saves your configurations, and now supports profiles! Unfortuantely this means that part of your configurations have been reset. Type /bd config or click the minimap button to open the profiles page and start making changes.")
		end
		
		bdCore:addModule("General", bdCore.general)
		
		bdCore:triggerEvent('loaded_bdcore')
		
	elseif (event == "LOADING_SCREEN_DISABLED") then
		--bdCore:triggerEvent("bdcore_redraw")
		
	elseif (event == "PLAYER_REGEN_DISABLED") then
		bdCore:triggerEvent('combat_enter')
	elseif (event == "PLAYER_REGEN_ENABLED") then
		bdCore:triggerEvent('combat_exit')
	end
	
	return true
end)