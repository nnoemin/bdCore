local bdCore, c, f = select(2, ...):unpack()

bdCore.moving = false
bdCore.moveFrames = {}
-- add to our movable list
function bdCore:makeMovable(frame)
	local name = frame:GetName();
	local height = frame:GetHeight()
	local width = frame:GetWidth()
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

	local moveContainer = CreateFrame("frame", "bdCore_"..name, UIParent)
	moveContainer.text = moveContainer:CreateFontString(moveContainer:GetName().."_Text")
	moveContainer.frame = frame
	frame.moveContainer = moveContainer
	moveContainer:SetSize(width+4, height+4)
	moveContainer:SetBackdrop({bgFile = bdCore.media.flat})
	moveContainer:SetBackdropColor(0,0,0,.6)
	moveContainer:SetMovable(true)
	moveContainer:SetUserPlaced(true)
	moveContainer:SetFrameStrata("BACKGROUND")
	moveContainer:SetClampedToScreen(true)
	moveContainer:SetAlpha(0)
	bdCore:hookEvent("frames_resized", function()
		local frame = self.frame
		local height = frame:GetHeight()
		local width = frame:GetWidth()
		moveContainer:SetSize(width+4, height+4)
	end)
	
	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", moveContainer, "TOPRIGHT", -2, -2)
	
	moveContainer.text:SetFont(bdCore.media.font, 20)
	moveContainer.text:SetPoint("CENTER", moveContainer, "CENTER", 0, 0)
	moveContainer.text:SetText(name)
	moveContainer.text:SetJustifyH("CENTER")
	moveContainer.text:SetAlpha(0.8)
	moveContainer.text:Hide()
	
	if (spawn) then
		moveContainer:SetPoint(unpack(spawn))
	elseif (point) then
		moveContainer:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
	end
	
	bdCore.moveFrames[#bdCore.moveFrames+1] = moveContainer
	return moveContainer
end

function bdCore:toggleLock()
	local locked = true
	if (bdCore.moving == true) then
		locked = true
		bdCore.moving = false
		print(bdCore.colorString.."Core: Addons locked")
	else
		locked = false
		bdCore.moving = true
		print(bdCore.colorString.."Core: Addons unlocked")
	end
	

	for k, v in pairs(bdCore.moveFrames) do
		local frame = v
		
		if (locked == false) then
			frame:SetAlpha(1)
			frame.text:Show()
			frame:EnableMouse(true)
			frame:RegisterForDrag("LeftButton","RightButton")
			frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
			frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
			frame:SetFrameStrata("HIGH")
		elseif (locked == true) then
			frame:SetAlpha(0)
			frame.text:Hide()
			frame:EnableMouse(false)
			frame:SetScript("OnDragStart", function(self) self:StopMovingOrSizing() end)
			frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
			frame:SetFrameStrata("BACKGROUND")
			
		end
	end
end



-- custom events/hooks
bdCore.events = {}
function bdCore:hookEvent(event, func)
	if (not bdCore.events[event]) then
		bdCore.events[event] = {}
	end
	bdCore.events[event][#bdCore.events[event]+1] = func
end

function bdCore:triggerEvent(event)
	if (bdCore.events[event]) then
		for k, v in pairs(bdCore.events[event]) do
			v()
		end
	end
end

-- return class color
function bdCore:unitColor(unitToken)
	if not UnitExists(unitToken) then
		return unpack(bUI.media.unitColors.tapped)
	end
	
	if UnitIsPlayer(unitToken) then
		return unpack(bUI.media.unitColors.class[select(2, UnitClass(unitToken))])
	elseif UnitIsTapped(unitToken) and not UnitIsTappedByPlayer(unitToken) then
		return unpack(bUI.media.unitColors.tapped)
	else
		return unpack(bUI.media.unitColors.reaction[UnitReaction(unitToken, 'player')])
	end
end

-- xform r, g, b into rrggbb
function bdCore:RGBToHex(r, g, b)
	if type(r) ~= 'number' then
		g = r.g
		b = r.b
		r = r.r
	end
	
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format('%02x%02x%02x', r*255, g*255, b*255)
end

-- make it purdy
function bdCore:setBackdrop(frame)
	frame.background = CreateFrame('frame', nil, frame)
	frame.background:SetBackdrop({
		bgFile = bdCore.media.flat, 
		edgeFile = bdCore.media.flat, edgeSize = 2,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	frame.background:SetBackdropColor(.11,.15,.18, 1)
	frame.background:SetBackdropBorderColor(.06, .08, .09, 1)
	frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
	frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
	frame.background:SetFrameStrata(frame:GetFrameStrata())
	frame.background:SetFrameLevel(frame:GetFrameLevel())
	frame.background:SetFrameLevel(0)
	frame:SetFrameLevel(1)
end

-- lua doesn't have a good function for round
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- lua doesn't have a good function for finding a value in a table
function in_table ( e, t )
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

-- kill textures
function bdCore:stripTextures(object, text)
	for i = 1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif (text) then
			region:Hide(0)
			region:SetAlpha(0)
		end
	end
end

-- kill frame
function bdCore:kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = function() return end
	object:Hide()
end

-- set up slash commands
function bdCore:setSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    for i = 1, select('#', ...) do
        _G['SLASH_'..name..i] = '/'..select(i, ...)
    end
end


-- filter debuffs/buffs
function bdCore:filterAura(name,caster)
	local my_class = string.lower(select(1, UnitClass('player')))
	local spec_id = GetSpecialization()
	local my_spec = string.lower(select(2,GetSpecializationInfo(spec_id)))
	local my_role = string.lower(select(6,GetSpecializationInfo(spec_id)))

	local blacklist = c.auras.blacklist
	local whitelist = c.auras.whitelist
	local raid = c.auras.raid
	local mine = c.auras.mine
	local class = c.auras.player_class[my_class]['all']
	local spec = c.auras.player_class[my_class][my_spec] or {}
	
	local allow = false
	
	if (blacklist[name] == true) then
		allow = false
	elseif (whitelist[name] == true) then
		allow = true
	elseif (raid[name] == true) then
		allow = true
	elseif (mine[name] == true and caster == "player") then
		allow = true
	elseif (raid[name] == true) then
		allow = true
	elseif (class[name] == true) then
		allow = true
	elseif (spec[name] == true) then
		allow = true
	end
	
	return allow
end

bdCore:setSlashCommand('ReloadUI', ReloadUI, 'rl', 'reset')



SLASH_BDCORE1, SLASH_BDCORE2 = "/bdcore"
SlashCmdList["BDCORE"] = function(msg, editbox)
	if (msg == "" or msg == " ") then
		print(bdCore.colorString.." Options:")
		print("   "..bdCore.colorString.." lock - unlocks/locks moving bd addons")
		--print("-- /bui lock - locks the UI")
	elseif (msg == "unlock" or msg == "lock") then
		bdCore.toggleLock()
	else
		print(bdCore.colorString.." "..msg.." not recognized as a command.")
	end
end
