local bdCore, c, f = select(2, ...):unpack()
local media = bdCore.media

local configdims = {
	width = 634,
	left_col = 140,
	height = 430,
	rightwidth = 444
}

local cfg = CreateFrame( "Frame", "bdCore config", UIParent)
cfg:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
cfg:SetSize(configdims.width, configdims.height)
bdCore:setBackdrop(cfg)
cfg:SetMovable(true)
cfg:SetUserPlaced(true)
cfg:SetFrameStrata("DIALOG")
cfg:SetClampedToScreen(true)
bdCore:createShadow(cfg,10)
cfg:Hide()
cfg.header = CreateFrame("frame",nil,cfg)
cfg.header:SetPoint("TOPLEFT",cfg,"TOPLEFT",0,0)
cfg.header:SetSize(configdims.width,30)
cfg.header:RegisterForDrag("LeftButton","RightButton")
cfg.header:EnableMouse(true)
cfg.header:SetScript("OnDragStart", function(self) cfg:StartMoving() end)
cfg.header:SetScript("OnDragStop", function(self) cfg:StopMovingOrSizing() end)

cfg.header.title = CreateFrame( "Frame", nil, cfg.header)
cfg.header.title:SetSize(configdims.left_col,30)
cfg.header.title:SetBackdrop({bgFile = media.flat})
cfg.header.title:SetBackdropColor(1,1,1,.05)
cfg.header.title:SetPoint("LEFT", cfg.header, "LEFT")

cfg.header.title.t = cfg.header.title:CreateFontString(nil, "OVERLAY")
cfg.header.title.t:SetFont(media.font, 16)
cfg.header.title.t:SetTextColor(1, 1, 1, 1)
cfg.header.title.t:SetText("bdCore Config")
cfg.header.title.t:SetAllPoints(cfg.header.title)
cfg.header.title.t:SetJustifyH("CENTER")

-- exit button
cfg.header.close = CreateFrame("Button", nil, cfg.header)
cfg.header.close:SetPoint("TOPRIGHT", cfg.header, "TOPRIGHT", 0 ,0)
cfg.header.close:SetSize(30, 28)
cfg.header.close:SetBackdrop({bgFile = media.flat})
cfg.header.close:SetBackdropColor(unpack(media.red))
cfg.header.close:SetAlpha(0.6)
cfg.header.close:EnableMouse(true)
cfg.header.close:SetScript("OnEnter", function()
	cfg.header.close:SetAlpha(1)
end)
cfg.header.close:SetScript("OnLeave", function()
	cfg.header.close:SetAlpha(0.6)
end)
cfg.header.close:SetScript("OnClick", function()
	cfg:Hide()
end)
cfg.header.close.x = cfg.header.close:CreateFontString(nil)
cfg.header.close.x:SetFont(media.font, 12)
cfg.header.close.x:SetText("x")
cfg.header.close.x:SetPoint("CENTER", cfg.header.close, "CENTER", .5, 0)


-- reload button
cfg.header.reload = CreateFrame("Button", nil, cfg.header)
cfg.header.reload:SetPoint("RIGHT", cfg.header.close, "LEFT", -2 ,0)
cfg.header.reload:SetSize(70, 28)
cfg.header.reload:SetBackdrop({bgFile = media.flat})
cfg.header.reload:SetBackdropColor(unpack(media.blue))
cfg.header.reload:SetAlpha(0.6)
cfg.header.reload:EnableMouse(true)
cfg.header.reload:SetScript("OnEnter", function()
	cfg.header.reload:SetAlpha(1)
end)
cfg.header.reload:SetScript("OnLeave", function()
	cfg.header.reload:SetAlpha(0.6)
end)
cfg.header.reload:SetScript("OnClick", function()
	ReloadUI()
end)

cfg.header.reload.x = cfg.header.reload:CreateFontString(nil)
cfg.header.reload.x:SetFont(media.font, 12)
cfg.header.reload.x:SetText("Reload UI")
cfg.header.reload.x:SetPoint("CENTER", cfg.header.reload, "CENTER", 1, 0)

-- lock/unlock button
cfg.header.lock = CreateFrame("Button", nil, cfg.header)
cfg.header.lock:SetPoint("RIGHT", cfg.header.reload, "LEFT", -2 ,0)
cfg.header.lock:SetSize(70, 28)
cfg.header.lock:SetBackdrop({bgFile = media.flat})
cfg.header.lock:SetBackdropColor(unpack(media.green))
cfg.header.lock:SetAlpha(0.6)
cfg.header.lock:EnableMouse(true)
cfg.header.lock:SetScript("OnEnter", function()
	cfg.header.lock:SetAlpha(1)
end)
cfg.header.lock:SetScript("OnLeave", function()
	cfg.header.lock:SetAlpha(0.6)
end)
cfg.header.lock:SetScript("OnClick", function(self)
	bdCore.toggleLock()
	if (self.x:GetText() == "Lock") then
		self.x:SetText("Unlock")
	else
		self.x:SetText("Lock")
	end
end)

cfg.header.lock.x = cfg.header.lock:CreateFontString(nil)
cfg.header.lock.x:SetFont(media.font, 12)
cfg.header.lock.x:SetText("Unlock")
cfg.header.lock.x:SetPoint("CENTER", cfg.header.lock, "CENTER", 1, 0)

-- main window
cfg.main = CreateFrame("frame",nil,cfg)
cfg.main:SetPoint("TOPLEFT",cfg.header,"BOTTOMLEFT")
cfg.main:SetPoint("BOTTOMRIGHT",cfg,"BOTTOMRIGHT", 0, 0)
bdCore:setBackdrop(cfg.main)

-- left
cfg.left = CreateFrame( "Frame", nil, cfg)
cfg.left:SetPoint("TOPLEFT", cfg.main, "TOPLEFT", 0, 0)
cfg.left:SetPoint("BOTTOMRIGHT", cfg.main, "BOTTOMLEFT", configdims.left_col, 0)
cfg.left:SetBackdrop({bgFile = media.flat})
cfg.left:SetBackdropColor(1,1,1,.05)


-- functions
cfg.options = {}
cfg.panels = {}
cfg.config = {}
cfg.lastitem = false

function bdCore:toggleConfig()
	if (cfg:IsShown()) then
		cfg:Hide()
	else
		cfg:Show()
		cfg.first.select()
		if (bdCore.moving) then
			cfg.header.lock.x:SetText("Lock")
		else
			cfg.header.lock.x:SetText("Unlock")
		end
	end
end

--bdCore:hookEvent("bdcore_loaded",function() bdCore:toggleConfig() end)

bdCore.modules = {}
function bdCore:addModule(name,configs)
	local smartconf = {}
	bdCore.modules[name] = true
	local navitem = CreateFrame('frame', nil, cfg)
	navitem.name = name
	navitem:SetSize(configdims.left_col, 26)
	if (not cfg.lastitem) then
		navitem:SetPoint("TOP", cfg.left, "TOP", 0, 0)
		cfg.first = navitem
	else
		navitem:SetPoint("TOP", cfg.lastitem, "BOTTOM", 0, 0)
	end
	cfg.lastitem = navitem
	navitem:SetBackdrop({bgFile = media.flat})
	navitem:SetBackdropColor(0,0,0,0)
	navitem:EnableMouse(true)
	
	--parent frame 
	local panels = CreateFrame('frame', nil, cfg)
	panels:SetPoint("TOPLEFT", cfg.left, "TOPRIGHT", 0, -2)
	panels:SetPoint("BOTTOMRIGHT", cfg.main, "BOTTOMRIGHT", -2, 2)
	panels.name = name
	panels:Hide()
	cfg.config[name] = panels
	
	-- tabs and content
	panels.tabs = CreateFrame("frame",nil,panels)
	panels.tabs:SetPoint("TOPLEFT", panels, "TOPLEFT", 2, 0)
	panels.tabs:SetPoint("BOTTOMRIGHT", panels, "TOPRIGHT", 0, -30)
	panels.tabs:SetBackdrop({bdFile = bdCore.media.flat})
	panels.tabs:SetBackdropColor(1,1,1,1)
	
	panels.tabs.bottom = panels.tabs:CreateTexture(nil,"OVERLAY")
	panels.tabs.bottom:SetTexture(bdCore.media.flat)
	panels.tabs.bottom:SetVertexColor(unpack(bdCore.media.border))
	
	panels.tabs.bottom:SetPoint("BOTTOMLEFT", panels.tabs, "BOTTOMLEFT")
	panels.tabs.bottom:SetPoint("TOPRIGHT", panels.tabs, "BOTTOMRIGHT", 0, 2)
	
	navitem:SetScript("OnEnter", function()
		if (not navitem.active) then
			navitem:SetBackdropColor(1,1,1,0.1)
		end
	end)
	navitem:SetScript("OnLeave", function()
		if (not navitem.active) then
			navitem:SetBackdropColor(1,1,1,0)
		end
	end)
	
	navitem.select = function()
		if (navitem.active) then return end
		
		for k, v in pairs(cfg.options) do
			cfg.panels[k]:Hide()
			cfg.options[k].active = false
			cfg.options[k]:SetBackdropColor(0,0,0,0)
		end
		
		local c = {panels.tabs:GetChildren()}
		for i = 1, #c do
			c[i].active = nil
			c[i]:SetAlpha(0.6)
			c[i].backdrop:SetVertexColor(1,1,1,.1)
		end
		
		--[[for k, v in pairs(panels.tabs.children) do
			v:Hide()
		end
		local panel = c[0] or c[1]
		
		panel:Show()--]]
		local button = c[0] or c[1]
		button:Click()

		cfg.panels[navitem.name]:Show()
		navitem.active = true
		navitem:SetBackdropColor(unpack(media.red))
		cfg.first = navitem
	end
	
	navitem:SetScript("OnMouseUp", function()
		navitem.select()
	end)
	
	navitem.text = navitem:CreateFontString(nil, "OVERLAY")
	navitem.text:SetPoint("LEFT", navitem, "LEFT", 8, 0)
	navitem.text:SetFont(media.font, 14)
	navitem.text:SetText(name)
	
	--panels.tabs.children = {}
	--panels.tabs.last = nil
	panels.tabs.children = {}
	panels.tabs.addTab = function(self,tabname)
		local button = CreateFrame("Button", nil, self)
		local parent = self
		button:SetAlpha(0.6)
		
		if (panels.lastbutton) then
			button:SetPoint("LEFT", panels.lastbutton, "RIGHT", 2, 0)
		else
			button:SetPoint("LEFT", panels.tabs, "LEFT", 4, 0)
		end
		
		local panel = CreateFrame('frame', "bdConfig"..tabname, panels)
		panel:SetPoint("TOPLEFT", panels.tabs, "BOTTOMLEFT", 8, -8)
		panel:SetPoint("BOTTOMRIGHT", panels, "BOTTOMRIGHT", -8, 8)
		panel.name = name
		panel:Hide()

		button.text = button:CreateFontString(nil,"OVERLAY")
		button.text:SetFont(bdCore.media.font, 14)
		button.text:SetText(tabname)
		button.text:SetAllPoints()
		
		button:SetSize(button.text:GetWidth()+30,26)
		button.backdrop = button:CreateTexture(nil,"OVERLAY")
		button.backdrop:SetTexture(bdCore.media.flat)
		button.backdrop:SetVertexColor(1,1,1,.1)
		button.backdrop:SetAllPoints()
		
		button:SetScript("OnEnter",function()
			if (button.active) then return end
			button:SetAlpha(1)
		end)
		
		button:SetScript("OnLeave",function()
			if (button.active) then return end
			button:SetAlpha(0.6)
		end)
		
		button:SetScript("OnClick",function()
			local c = {parent:GetChildren()}
			for i = 1, #c do
				c[i].active = nil
				c[i]:SetAlpha(0.6)
				c[i].backdrop:SetVertexColor(1,1,1,.1)
			end
			for k, v in pairs(panels.tabs.children) do
				v:Hide()
				--print(v:GetName().." hidden")
				--v.text:GetText().." panel hidden"
				--v.scrollframe:Show()
				--v.scrollbar:Show()
				--v.content:Show()
			end
			panel:Show()
			--panel.scrollframe:Show()
			--panel.scrollbar:Show()
			--panel.content:Show()
			
			button:SetAlpha(1)
			button.backdrop:SetVertexColor(unpack(bdCore.media.blue))
			button.active = true
		end)
		
		--scrollframe 
		--[[local scrollframe = CreateFrame("ScrollFrame", nil, panel) 
		scrollframe:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0) 
		scrollframe:SetSize(panel:GetWidth(), panel:GetHeight()) 
		--scrollframe:SetAllPoints(panel) 
		panel.scrollframe = scrollframe 

		--scrollbar 
		local scrollbar = CreateFrame("Slider", nil, panel.scrollframe, "UIPanelScrollBarTemplate") 
		scrollbar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -18) 
		scrollbar:SetPoint("BOTTOMLEFT", panel, "BOTTOMRIGHT", -18, 18) 
		scrollbar:SetMinMaxValues(1, math.ceil(panel:GetHeight()+1)) 
		scrollbar:SetValueStep(1) 
		scrollbar.scrollStep = 1
		scrollbar:SetValue(0) 
		scrollbar:SetWidth(16) 
		scrollbar:SetScript("OnValueChanged", function (self, value) self:GetParent():SetVerticalScroll(value) self:SetValue(value) end) 
		scrollbar:SetBackdrop({bgFile = media.flat})
		scrollbar:SetBackdropColor(0,0,0,.2)
		panel.scrollbar = scrollbar 

		--content frame 
		panel.content = CreateFrame("Frame", nil, panel.scrollframe) 
		panel.content:SetSize(panel:GetWidth(), panel:GetHeight()) 
		--panel.content:SetAllPoints(panel) 
		scrollframe.content = panel.content 
		scrollframe:SetScrollChild(panel.content)
		
		panel:SetScript("OnMouseWheel", function(self, delta)
			self.scrollbar:SetValue(self.scrollbar:GetValue() - (delta*20))
		end)--]]
		
		--panels.lastcontent = panel.content
		--panel.scrollheight = panel.scrollheight or 0
		panels.lastbutton = button
		panels.lastpanel = panel
		panels.tabstarted = true
		table.insert(panels.tabs.children, panel)
		panel.lastFrame = nil
		return panel
	end
	
	cfg.options[name] = navitem
	cfg.panels[name] = panels
	
	if (configs) then
		local scrollheight = 0
		
		for i = 1, #configs do
			local conf = configs[i]		
			
			c[name] = c[name] or {}
			c.sv[name] = c.sv[name] or {}
			
			for option, info in pairs(conf) do
				if (c[name][option] == nil) then
					if (info.value == nil) then
						info.value = {}
					end
					c[name][option] = info.value
					c.sv[name][option] = info.value
				end
				
				-- Create a general tab for everything to anchor to if no other tab is started
				if (info.type ~= "tab" and not panels.tabstarted) then
					panels.tabs:addTab("General")
				end
				
				--scrollheight = panels.lastpanel.scrollheight
				
				if (info.type == "slider") then
					bdCore:createSlider(name, option, info)
					scrollheight = scrollheight + 56
				elseif (info.type == "checkbox") then
					bdCore:createCheckButton(name, option, info)
					scrollheight = scrollheight + 40
				elseif (info.type == "dropdown") then
					bdCore:createDropdown(name, option, info)
					scrollheight = scrollheight + 70
				elseif (info.type == "text") then
					bdCore:createText(name, info)
					scrollheight = scrollheight + 30 + ((strlen(info.value)/39)*12)
				elseif (info.type == "list") then
					bdCore:createList(name, option, info)
					scrollheight = scrollheight + 250
				elseif (info.type == "tab") then
					panels.tabs:addTab(info.value)
					tabstarted = true
				elseif (info.type == "color") then
					scrollheight = scrollheight + 40
					bdCore:colorPicker(name, option, info)
				end
				
				smartconf[option] = c[name][option]
			end

		end
		
		--[[scrollheight = scrollheight - 320
		if (scrollheight < 1) then 
			scrollheight = 1
			panels.lastpanel.scrollbar:Hide()
		else
			panels.lastpanel.scrollbar:Show()
		end--]]
		
		--panels.lastpanel.scrollbar:SetMinMaxValues(1, scrollheight) 
		--panels.lastpanel.content:SetHeight(scrollheight+320)
	end
	
	-- If there aren't additional tabs, act like non exist
	if (panels.lastbutton.text:GetText() == "General") then
		panels.tabs:Hide()
		panels.lastpanel:SetPoint("TOPLEFT", panels, "TOPLEFT", 8, -8)
		--panels.lastpanel.content:SetSize(panels:GetWidth()-20, panels:GetHeight())
		--panels.lastpanel.scrollframe:SetPoint("TOPRIGHT", panels, "TOPRIGHT", -30, -10) 
		--panels.lastpanel.scrollbar:SetPoint("TOPRIGHT", panels, "TOPRIGHT", -2, -18) 
	else
		panels.tabs:Show()
		--panels.lastpanel.content:SetSize(panels:GetWidth()-20, panels:GetHeight())
		--panels.lastpanel:SetPoint("TOPLEFT", panels.tabs "BOTTOMLEFT", 0, -2)
		--panels.lastpanel.scrollframe:SetPoint("TOPRIGHT", panels, "TOPRIGHT", -30, -40) 
		--panels.lastpanel.scrollbar:SetPoint("TOPRIGHT", panels, "TOPRIGHT", -2, -48) 
	end
	--collectgarbage()
	return bdCore.config[name]
	--return smartconf
end

--------------------------------------------------
-- functions here
--------------------------------------------------
function bdCore:colorPicker(group, option, info)
	local panel = cfg.config[group].lastpanel
	
	local container = CreateFrame("frame","bdCorepicker"..group,panel)
	container:SetSize(configdims.rightwidth, 24)
	
	local picker = CreateFrame("button",nil,container)
	picker:SetSize(20, 20)
	picker:SetBackdrop({bgFile = bdCore.media.flat, edgeFile = bdCore.media.flat, edgeSize = 2, insets = {top = 2, right = 2, bottom = 2, left = 2}})
	picker:SetBackdropColor(unpack(c[group][option]))
	picker:SetBackdropBorderColor(0,0,0,1)
	picker:SetPoint("LEFT", container, "LEFT", 0, 0)
	
	picker.callback = function(self, r, g, b, a)
		c[group][option] = {r,g,b,a}
		c.sv[group][option] = {r,g,b,a}
		self:SetBackdropColor(r,g,b,a)
		
		return r, g, b, a
	end
	
	picker:SetScript("OnClick",function()		
		HideUIPanel(ColorPickerFrame)
		local r,g,b,a = unpack(c.sv[group][option])
		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetClampedToScreen(true)
		ColorPickerFrame.hasOpacity = true
		
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.old = {r, g, b, a}
		
		ColorPickerFrame.func = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			picker:callback(r, g, b, a)
		end
		ColorPickerFrame.opacityFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			picker:callback(r, g, b, a)
		end
		
		--print(ColorPickerFrame:GetColorRGB())
		ColorPickerFrame:SetColorRGB(r, g, b)
		--print(ColorPickerFrame:GetColorRGB())
		--ColorPickerFrame.func()
		
		ColorPickerFrame.cancelFunc = function()
			local r, g, b, a = unpack(ColorPickerFrame.old) 
			picker:callback(r, g, b, a)
		end

		ColorPickerFrame:EnableKeyboard(false)
		ShowUIPanel(ColorPickerFrame)
	end)
	
	picker.text = picker:CreateFontString(nil,"OVERLAY")
	picker.text:SetFont(bdCore.media.font, 14)
	picker.text:SetText(info.name)
	picker.text:SetPoint("LEFT", picker, "RIGHT", 8, 0)
	
	if (not panel.lastFrame) then
		container:SetPoint("TOP", panel, "TOP", 0, 0)
	else
		container:SetPoint("TOP", panel.lastFrame, "BOTTOM", 0, -12)
	end
	panel.lastFrame = container
	panel.lastFrame.type = "color"
end
function bdCore:createText(group, info)
	--local panels = cfg.config[group]
	--local panel = cfg.config[group].lastcontent
	local panel = cfg.config[group].lastpanel
	local text = panel:CreateFontString(nil)
	text:SetFont(media.font, 14)
	text:SetText(info.value)
	text:SetTextColor(0.8,0.8,0.8)
	text:SetWidth(panel:GetWidth()-20)
	text:SetJustifyH("LEFT")
	
	if (not panel.lastFrame) then
		text:SetPoint("TOP", panel, "TOP", 0, 0)
	else
		text:SetPoint("TOP", panel.lastFrame, "BOTTOM", 0, -30)
	end
	panel.lastFrame = text
	panel.lastFrame.type = "text"
	
	return text
end
function bdCore:createList(group,option,info)
	--local panels = cfg.config[group]
	--local panel = cfg.config[group].lastcontent
	local panel = cfg.config[group].lastpanel
	
	local container = CreateFrame("frame",nil,panel)
	container:SetSize(configdims.rightwidth,200)
	bdCore:setBackdrop(container)
	container.background:SetVertexColor(.18,.22,.25,1)
	if (not panel.lastFrame) then
		container:SetPoint("TOP", panel, "TOP", 0, -50)
	else
		container:SetPoint("TOP", panel.lastFrame, "BOTTOM", 0, -70)
	end
	panel.lastFrame = container
	panel.lastFrame.type = "list"
	
	--scrollframe 
	local scrollframe = CreateFrame("ScrollFrame", nil, container) 
	scrollframe:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -6) 
	scrollframe:SetSize(container:GetWidth(), container:GetHeight()-12) 
	container.scrollframe = scrollframe 

	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPRIGHT", container, "TOPRIGHT", -2, -18) 
	scrollbar:SetPoint("BOTTOMLEFT", container, "BOTTOMRIGHT", -18, 18) 
	scrollbar:SetMinMaxValues(1, 600) 
	scrollbar:SetValueStep(1) 
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0) 
	scrollbar:SetWidth(16) 
	scrollbar:SetScript("OnValueChanged", function (self, value) self:GetParent():SetVerticalScroll(value) self:SetValue(value) end) 
	scrollbar:SetBackdrop({bgFile = media.flat})
	scrollbar:SetBackdropColor(0,0,0,.2)
	container.scrollbar = scrollbar 

	--content frame 
	container.content = CreateFrame("Frame", nil, scrollframe) 
	container.content:SetSize(container:GetWidth(), container:GetHeight()) 
	scrollframe.content = container.content 
	scrollframe:SetScrollChild(container.content)
	
	container.content.text = container.content:CreateFontString(nil)
	container.content.text:SetFont(media.font,12)
	container.content.text:SetPoint("TOPLEFT",container.content,"TOPLEFT",5,0)
	container.content.text:SetHeight(600)
	container.content.text:SetWidth(container:GetWidth()-10)
	container.content.text:SetJustifyH("LEFT")
	container.content.text:SetJustifyV("TOP")
	
	
	container.insert = CreateFrame("EditBox",nil,container)
	container.insert:SetPoint("BOTTOMLEFT", container, "TOPLEFT",0,2)
	container.insert:SetSize(configdims.rightwidth-66, 24)
	bdCore:setBackdrop(container.insert)
	container.insert.background:SetVertexColor(.10,.14,.17,1)
	container.insert:SetFont(media.font,12)
	container.insert:SetTextInsets(6, 2, 2, 2)
	container.insert:SetMaxLetters(200)
	container.insert:SetHistoryLines(1000)
	container.insert:SetAutoFocus(false) 
	container.insert:SetScript("OnEnterPressed", function(self, key) container.button:Click() end)
	container.insert:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	
	-- submit
	container.button = CreateFrame("Button", nil, container)
	container.button:SetPoint("TOPLEFT", container.insert, "TOPRIGHT", 0 ,2)
	container.button:SetSize(68, 28)
	container.button:SetBackdrop({
		bgFile = bdCore.media.flat, 
		edgeFile = bdCore.media.flat, edgeSize = 2,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	container.button:SetBackdropColor(unpack(media.blue))
	container.button:SetBackdropBorderColor(unpack(media.border))
	container.button:SetAlpha(0.8)
	container.button:EnableMouse(true)
	container.button:SetScript("OnEnter", function()
		container.button:SetAlpha(1)
	end)
	container.button:SetScript("OnLeave", function()
		container.button:SetAlpha(0.8)
	end)
	container.button:SetScript("OnClick", function()
		local value = container.insert:GetText()
		if (strlen(value) > 0) then
			container.addremove(container.insert:GetText())
		end
		container.insert:SetText("")
		container.insert:ClearFocus()
	end)

	container.button.x = container.button:CreateFontString(nil)
	container.button.x:SetFont(media.font, 12)
	container.button.x:SetText("Add/Remove")
	container.button.x:SetPoint("CENTER", container.button, "CENTER", 1, 0)
	
	container.insert.alert = container.insert:CreateFontString(nil)
	container.insert.alert:SetFont(bdCore.media.font,13)
	container.insert.alert:SetPoint("TOPLEFT",container,"BOTTOMLEFT", 2, -2)
	
	container.label = container:CreateFontString(nil)
	container.label:SetFont(media.font, 14)
	container.label:SetPoint("BOTTOMLEFT", container.insert, "TOPLEFT", 0, 4)
	container.label:SetText(info.label)
	
	function container.populate()
		local string = "";
		local height = 0;
		
		for k, v in pairs(c.sv[group][option]) do
			string = string..k.."\n";
			height = height + 13
			container.insert:AddHistoryLine(k)
		end
		local scrollheight = height-200
		if (scrollheight < 1) then 
			scrollheight = 1 
			container.scrollbar:Hide()
		else
			container.scrollbar:Show()
			container:SetScript("OnMouseWheel", function(self, delta) self.scrollbar:SetValue(self.scrollbar:GetValue() - (delta*30)) end)
		end
		container.scrollbar:SetMinMaxValues(1,scrollheight)
		container.content.text:SetHeight(height)
		container.content.text:SetText(string)
	end
	function container.startfade(self)
		local total = 0
		local alert = self.insert.alert
		alert:Show()
		container:SetScript("OnUpdate",function(self, elapsed)
			total = total + elapsed
			if (total > 1.5) then
				alert:SetAlpha(alert:GetAlpha()-0.02)
				
				if (alert:GetAlpha() <= 0.05) then
					container:SetScript("OnUpdate", function() return end)
					alert:Hide()
				end
			end
		end)
	end
	function container.addremove(value)
		--local value = string.lower(value)
		container.insert:AddHistoryLine(value)
		if(c.sv[group][option][value]) then
			c[group][option][value] = nil
			c.sv[group][option][value] = nil
			container.insert.alert:SetText(value.." removed")
			container.insert.alert:SetTextColor(1, .3, .3)
			container:startfade()
		else
			c[group][option][value] = true
			c.sv[group][option][value] = true
			container.insert.alert:SetText(value.." added")
			container.insert.alert:SetTextColor(.3, 1, .3)
			container:startfade()
		end
		container.populate()
	end
	
	container.populate()
	
	if (info.callback) then
		info:callback()
	end
end

function bdCore:createDropdown(group, option, info)
	--local panels = cfg.config[group]
	--local panel = cfg.config[group].lastcontent
	local panel = cfg.config[group].lastpanel
	--local items = {strsplit(",",info.options)}
	local items = info.options
	local container = CreateFrame("Button",nil, panel)
	local dropdown = CreateFrame("Frame", "bdCore_"..group..":"..option, panel)
	container:SetWidth(configdims.rightwidth-10)
	container:SetHeight(20)
	bdCore:setBackdrop(container)
	if (not panel.lastFrame) then
		container:SetPoint("TOP", panel, "TOP", 0, -30)
	else
		container:SetPoint("TOP", panel.lastFrame, "BOTTOM", 0, -30)
	end
	panel.lastFrame = container
	panel.lastFrame.type = "dropdown"
	
	container.arrow = container:CreateTexture(nil,"OVERLAY")
	container.arrow:SetTexture(media.arrowdown)
	container.arrow:SetSize(8, 6)
	container.arrow:SetVertexColor(1,1,1,.4)
	container.arrow:SetPoint("RIGHT", container, "RIGHT", -6, 1)
	container.arrow:Show()
	
	container.label = container:CreateFontString(nil)
	container.label:SetFont(media.font, 14)
	container.label:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 4)
	container.label:SetText(info.label)
	
	container.selected = container:CreateFontString(nil)
	container.selected:SetFont(media.font, 13)
	container.selected:SetPoint("LEFT", container, "LEFT", 6, 0)
	container.selected:SetText(c.sv[group][option])
	
	function container:click()
		if (dropdown.dropped) then
			dropdown:Hide()
			dropdown.dropped = false
			container.background:SetVertexColor(.11,.15,.18, 1)
			container.arrow:SetTexture(media.arrowdown)
		else
			dropdown:Show()
			dropdown.dropped = true
			container.background:SetVertexColor(1,1,1,.05)
			container.arrow:SetTexture(media.arrowup)
		end
	end
	
	container:SetScript("OnClick", function() container:click()end)

	dropdown:Hide()
	dropdown:SetFrameLevel(10)
	dropdown:SetBackdrop({
		bgFile = bdCore.media.flat, 
		edgeFile = bdCore.media.flat, edgeSize = 2,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	dropdown:SetBackdropColor(.18,.22,.25,1)
	dropdown:SetBackdropBorderColor(.06, .08, .09, 1)
	dropdown.dropped = false
	dropdown.lastframe = false
	dropdown:SetSize(container:GetWidth()+4, 22*#items)


	for i = 1, #items do
		local item = CreateFrame("Button", nil, dropdown)
		item:SetSize(dropdown:GetWidth()-4, 20)
		item:SetBackdrop({bgFile = bdCore.media.flat, })
		item:SetBackdropColor(0,0,0,0)
		item:SetScript("OnEnter",function() item:SetBackdropColor(.21,.25,.29,1) end)
		item:SetScript("OnLeave",function() item:SetBackdropColor(0,0,0,0) end)
		item.label = item:CreateFontString(nil)
		item.label:SetFont(media.font, 13)
		item.label:SetPoint("LEFT", item, "LEFT", 6, 0)
		item.label:SetText(items[i])
		item.id = i
		if (not dropdown.lastFrame) then
			item:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 2, -2)
		else
			item:SetPoint("TOPLEFT", dropdown.lastFrame, "BOTTOMLEFT", 0, 0)
		end
		
		item:SetScript("OnClick", function(self)
			c[group][option] = self.label:GetText()
			c.sv[group][option] = self.label:GetText()
			
			if (info.callback) then
				info:callback()
			end
		
			container.selected:SetText(c.sv[group][option])
			container:click()
		end)
		
		dropdown.lastFrame = item
	end

	dropdown:SetPoint("TOPLEFT", container, "BOTTOMLEFT", -2, 1)
	return dropdown
end

function bdCore:createSlider(group, option, info)
	--local panels = cfg.config[group]
	--local panel = cfg.config[group].lastcontent
	local panel = cfg.config[group].lastpanel
	local container = CreateFrame("frame",nil,panel)
	local slider = CreateFrame("Slider", "bdCore_"..group..":"..option, panel, "OptionsSliderTemplate")
	slider:SetWidth(configdims.rightwidth-20)
	slider:SetHeight(14)
	slider:SetPoint("CENTER",container,"CENTER")
	container:SetSize(configdims.rightwidth-20, 34)
	if (not panel.lastFrame) then
		container:SetPoint("TOP", panel, "TOP", 0, -10)
	else
		container:SetPoint("TOP", panel.lastFrame, "BOTTOM", 0, -16)
	end
	panel.lastFrame = container
	panel.lastFrame.type = "slider"
	
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(info.min,info.max)
	slider:SetValue(c.sv[group][option])
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(info.step)
	slider.tooltipText = info.tooltip
	_G[slider:GetName() .. 'Low']:SetText(info.min);
	_G[slider:GetName() .. 'Low']:SetTextColor(1,1,1);
	_G[slider:GetName() .. 'Low']:SetFont(media.font, 12)
	_G[slider:GetName() .. 'Low']:ClearAllPoints()
	_G[slider:GetName() .. 'Low']:SetPoint("TOP",slider,"BOTTOMLEFT",0,-1)
	_G[slider:GetName() .. 'High']:SetText(info.max);
	_G[slider:GetName() .. 'High']:SetTextColor(1,1,1);
	_G[slider:GetName() .. 'High']:SetFont(media.font, 12)
	_G[slider:GetName() .. 'High']:ClearAllPoints()
	_G[slider:GetName() .. 'High']:SetPoint("TOP",slider,"BOTTOMRIGHT",0,-1)
	_G[slider:GetName() .. 'Text']:SetText(info.label);
	_G[slider:GetName() .. 'Text']:SetTextColor(1,1,1);
	_G[slider:GetName() .. 'Text']:SetFont(media.font, 14)
	slider.value = slider:CreateFontString(nil)
	slider.value:SetFont(media.font, 12)
	slider.value:SetText(c.sv[group][option])
	slider.value:SetTextColor(1,1,1)
	slider.value:SetPoint("TOP", slider,"BOTTOM", 0, -2)
	slider:Show()
	slider:SetScript("OnValueChanged", function(self)
		local newval = round(slider:GetValue(), 1)
		if (c.sv[group][option] == newval) then -- throttle it changing on every pixel
			return false
		end
		slider:SetValue(newval)
		slider.value:SetText(newval)
		
		c[group][option] = newval
		c.sv[group][option] = newval
		
		if (info.callback) then
			info:callback()
		end
	end)
	return slider
end

function bdCore:createCheckButton(group, option, info)
	--local panels = cfg.config[group]
	--local panel = cfg.config[group].lastcontent
	local panel = cfg.config[group].lastpanel
	local check = CreateFrame("CheckButton", "bdCore_"..group..":"..option, panel, "ChatConfigCheckButtonTemplate")
	local container = CreateFrame("frame",nil,panel)
	container:SetSize(configdims.rightwidth, 20)
	check:SetPoint("LEFT", container, "LEFT", 0, 0)
	
	if (not panel.lastFrame) then
		container:SetPoint("TOP", panel, "TOP", -10, -8)
	else
		if (panel.lastFrame.type ~= "check") then
			container:SetPoint("TOPLEFT", panel.lastFrame, "BOTTOMLEFT", -10, -10)
		else
			container:SetPoint("TOPLEFT", panel.lastFrame, "BOTTOMLEFT", 0, -10)
		end
	end
	panel.lastFrame = container
	panel.lastFrame.type = "check"
	
	_G[check:GetName().."Text"]:SetText(info.label)
	_G[check:GetName().."Text"]:SetFont(bdCore.media.font, 14)
	_G[check:GetName().."Text"]:ClearAllPoints()
	_G[check:GetName().."Text"]:SetPoint("LEFT", check, "RIGHT", 2, 1)
	check.tooltip = info.tooltip;
	check:SetChecked(c.sv[group][option])
	check:SetScript("OnClick", function(self)
		c[group][option] = self:GetChecked()
		c.sv[group][option] = self:GetChecked()
		
		if (info.callback) then
			info:callback(check)
		end
	end)
	
	return check
end

f.config = cfg