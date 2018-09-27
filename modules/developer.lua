-- i'll use this file for organized testing stuff

function bdCore_profile()

	local function profile(name, fn)
		local start = GetTime()

		fn()

		local finish = GetTime()
		local total = finish - start
		print(name.." took: "..total.." and ran from "..start.." to "..finish)
	end

	profile("table_set_loop", function()
		for i = 1, 1000000 do
			local a = {}
			a[1] = 1; a[2] = 2; a[3] = 3
		end
		print("ran")
	end)

	profile("optimized_table_set_loop", function()
		for i = 1, 1000000 do
			local a = {true, true, true}
			a[1] = 1; a[2] = 2; a[3] = 3
		end
	end)


	profile("aura_loop", function()
		for i = 1, 1000 do
			UnitAura("player", i)
		end
	end)

	profile("optimized_aura_loop", function()
		local UnitAura = UnitAura
		for i = 1, 1000 do
			UnitAura("player", i)
		end
	end)



	profile("unit_player", function()
		for i = 1, 1000 do
			local var = UnitIsPlayer('player')
		end
	end)
	profile("unit_tap_denied", function()
		for i = 1, 1000 do
			local var = UnitIsTapDenied('player')
		end
	end)
	profile("unit_player_controlled", function()
		for i = 1, 1000 do
			local var = UnitPlayerControlled('player')
		end
	end)
	profile("unit_unit", function()
		for i = 1, 1000 do
			local var = UnitHealth('player')
		end
	end)
	profile("unit_health_max", function()
		for i = 1, 1000 do
			local var = UnitHealthMax('player')
		end
	end)


	profile("optimized_unit_player", function()
		local UnitIsPlayer = UnitIsPlayer
		local var
		for i = 1, 1000 do
			var = UnitIsPlayer('player')
		end
		print(var)
	end)
	profile("optimized_unit_tap_denied", function()
		local UnitIsTapDenied = UnitIsTapDenied
		local var
		for i = 1, 1000 do
			var = UnitIsTapDenied('player')
		end
		print(var)
	end)
	profile("optimized_unit_player_controlled", function()
		local UnitPlayerControlled = UnitPlayerControlled
		local var
		for i = 1, 1000 do
			var = UnitPlayerControlled('player')
		end
		print(var)
	end)
	profile("optimized_unit_unit", function()
		local UnitHealth = UnitHealth
		local var
		for i = 1, 1000 do
			var = UnitHealth('player')
		end
		print(var)
	end)
	profile("optimized_unit_health_max", function()
		local UnitHealthMax = UnitHealthMax
		local var
		for i = 1, 1000 do
			var = UnitHealthMax('player')
		end
		print(var)
	end)
end

local tester = CreateFrame("frame", nil)
tester:RegisterEvent("LOADING_SCREEN_DISABLED")
tester:SetScript("OnEvent", bdCore_profile)