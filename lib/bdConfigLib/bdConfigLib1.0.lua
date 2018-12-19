--[[======================================================




	curse.com/
	bdConfigLib Main Usage

	bdConfigLib:RegisterModule(settings, configuration, savedVariable[, savedVariableAcct])

	settings
		name : name of the module in the configuration window
		command : /command that opens configuration to your module
		init : function callback for when configuration is initialized
		callback : function callback for when a configuration changes
	configuration : table of the configuration options for this module
		tab
		text
		list
		dropdown
	savedVariable : Per character SavedVariable




========================================================]]

local addonName, addon = ...
local _G = _G
local version = 11

if _G.bdConfigLib and _G.bdConfigLib.version >= version then
	bdConfigLib = _G.bdConfigLib
	return -- a newer or same version has already been created, ignore this file
end

_G.bdConfigLib = {}
bdConfigLib = _G.bdConfigLib
bdConfigLib.version = version

--[[======================================================
	Create Library
========================================================]]
local function debug(...)
	print("|cffA02C2FbdConfigLib|r:", ...)
end
--[[======================================================
	Helper functions & variables
========================================================]]
bdConfigLib.dimensions = {
	left_column = 150
	, right_column = 600
	, height = 450
	, header = 30
}
bdConfigLib.media = {
	flat = "Interface\\Buttons\\WHITE8x8"
	, arrow = "Interface\\Buttons\\Arrow-Down-Down.PNG"
	, font = "fonts\\ARIALN.ttf"
	, fontSize = 14
	, fontHeaderScale = 1.1
	, border = {0.06, 0.08, 0.09, 1}
	, borderSize = 1
	, background = {0.11, 0.15, 0.18, 1}
	, red = {0.62, 0.17, 0.18, 1}
	, blue = {0.2, 0.4, 0.8, 1}
	, green = {0.1, 0.7, 0.3, 1}
}

-- main font object
bdConfigLib.font = CreateFont("bdConfig_font")
bdConfigLib.font:SetFont(bdConfigLib.media.font, bdConfigLib.media.fontSize)
bdConfigLib.font:SetShadowColor(0, 0, 0)
bdConfigLib.font:SetShadowOffset(1, -1)
bdConfigLib.foundBetterFont = false

bdConfigLib.arrow = UIParent:CreateTexture(nil, "OVERLAY")
bdConfigLib.arrow:SetTexture(bdConfigLib.media.arrow)
bdConfigLib.arrow:SetTexCoord(0.9, 0.9, 0.9, 0.6)
bdConfigLib.arrow:SetVertexColor(1,1,1,0.5)

-- dirty create shadow (no external textures)
local function CreateShadow(frame, size)
	if (frame.shadow) then return end

	frame.shadow = {}
	local start = 0.088
	for s = 1, size do
		local shadow = frame:CreateTexture(nil, "BACKGROUND")
		shadow:SetTexture(bdConfigLib.media.flat)
		shadow:SetVertexColor(0,0,0,1)
		shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -s, s)
		shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", s, -s)
		shadow:SetAlpha(start - ((s / size) * start))
		frame.shadow[s] = shadow
	end
end

-- create consistent with border
local function CreateBackdrop(frame)
	if (frame.bd_background) then return end

	local background = frame:CreateTexture(nil, "BORDER", -1)
	background:SetTexture(bdConfigLib.media.flat)
	background:SetVertexColor(unpack(bdConfigLib.media.background))
	background:SetAllPoints()
	
	local border = frame:CreateTexture(nil, "BACKGROUND", -8)
	border:SetTexture(bdConfigLib.media.flat)
	border:SetVertexColor(unpack(bdConfigLib.media.border))
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -bdConfigLib.media.borderSize, bdConfigLib.media.borderSize)
	border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", bdConfigLib.media.borderSize, -bdConfigLib.media.borderSize)

	frame.bd_background = background
	frame.bd_border = border

	return frame
end

-- creates basic button template
local function CreateButton(parent)
	if (not parent) then parent = bdConfigLib.window end
	local button = CreateFrame("Button", nil, parent)

	button.inactiveColor = bdConfigLib.media.blue
	button.activeColor = bdConfigLib.media.blue
	button:SetBackdrop({bgFile = bdConfigLib.media.flat})

	function button:BackdropColor(r, g, b, a)
		button.inactiveColor = self.inactiveColor or bdConfigLib.media.blue
		button.activeColor = self.activeColor or bdConfigLib.media.blue

		if (r and b and g) then
			self:SetBackdropColorOld(r, g, b, a)
		end
	end

	button.SetBackdropColorOld = button.SetBackdropColor
	button.SetBackdropColor = button.BackdropColor
	button.SetVertexColor = button.BackdropColor

	button:SetBackdropColor(unpack(bdConfigLib.media.blue))
	button:SetAlpha(0.6)
	button:SetHeight(bdConfigLib.dimensions.header)
	button:EnableMouse(true)

	button.text = button:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	button.text:SetPoint("CENTER")
	button.text:SetJustifyH("CENTER")
	button.text:SetJustifyV("MIDDLE")

	function button:Select()
		button.SetVertexColor(unpack(self.activeColor))
	end
	function button:Deselect()
		button.SetVertexColor(unpack(self.inactiveColor))
	end
	function button:OnEnter()
		if (self.active) then
			button:SetBackdropColor(unpack(self.activeColor))
		else
			if (self.hoverColor) then
				button:SetBackdropColor(unpack(self.hoverColor))
			else
				button:SetBackdropColor(unpack(self.inactiveColor))
			end
		end
		button:SetAlpha(1)
	end

	function button:OnLeave()
		if (self.active) then
			button:SetBackdropColor(unpack(self.activeColor))
			button:SetAlpha(1)
		else
			button:SetBackdropColor(unpack(self.inactiveColor))
			button:SetAlpha(0.6)
		end
	end
	function button:OnClickDefault()
		if (self.OnClick) then self.OnClick(self) end
		if (self.autoToggle) then
			if (self.active) then
				self.active = false
			else
				self.active = true
			end
		end

		button:OnLeave()
	end
	function button:GetText()
		return button.text:GetText()
	end
	function button:SetText(text)
		button.text:SetText(text)
		button:SetWidth(button.text:GetStringWidth() + bdConfigLib.dimensions.header)
	end

	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)
	button:SetScript("OnClick", button.OnClickDefault)

	return button
end

-- creates scroll frame and returns its content
function CreateScrollFrame(parent, width, height)
	width = width or parent:GetWidth()
	height = height or parent:GetHeight()

	-- scrollframe
	local scrollParent = CreateFrame("ScrollFrame", nil, parent) 
	scrollParent:SetPoint("TOPLEFT", parent) 
	scrollParent:SetSize(width, height) 
	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollParent, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -18) 
	scrollbar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -18, 18) 
	scrollbar:SetMinMaxValues(1, 600)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	CreateBackdrop(scrollbar)
	parent.scrollbar = scrollbar
	--content frame 
	local content = CreateFrame("Frame", nil, scrollParent) 
	content:SetPoint("TOPLEFT", parent, "TOPLEFT") 
	content:SetSize(width, height)
	scrollParent.content = content
	scrollParent:SetScrollChild(content)

	-- scripts
	scrollbar:SetScript("OnValueChanged", function (self, value) 
		scrollParent:GetParent():SetVerticalScroll(value) 
	end)
	scrollParent:SetScript("OnMouseWheel", function(self, delta)
		scrollbar:SetValue(scrollbar:GetValue() - (delta*20))
	end)
	-- auto resizing
	content.Update = function()
		local height = content:GetHeight()
		scrollbar:SetMinMaxValues(1, height)
	end
	content.SetSize = content.SetHeight
	content.Update = content.Update
	hooksecurefunc(content, "SetHeight", content.Update)
	hooksecurefunc(content, "SetSize", content.Update)

	-- store
	parent.scrollParent = scrollParent
	parent.scrollbar = scrollbar
	parent.content = content

	content.scrollParent = scrollParent
	content.scrollbar = scrollbar

	return content
end


--[[========================================================
	Create Frames
	For anyone curious, I use `do` statements just to 
		keep the code dileniated and easy to read
==========================================================]]
local function CreateFrames()
	local window = CreateFrame("Frame", "bdConfig Lib", UIParent)

	-- Parent
	do
		window:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
		window:SetSize(bdConfigLib.dimensions.left_column + bdConfigLib.dimensions.right_column, bdConfigLib.dimensions.height + bdConfigLib.dimensions.header)
		window:SetMovable(true)
		window:SetUserPlaced(true)
		window:SetFrameStrata("DIALOG")
		window:SetClampedToScreen(true)
		-- window:Hide()
		CreateShadow(window, 10)
	end

	-- Header
	do
		window.header = CreateFrame("frame", nil, window)
		window.header:SetPoint("TOPLEFT")
		window.header:SetPoint("TOPRIGHT")
		window.header:SetHeight(bdConfigLib.dimensions.header)
		window.header:RegisterForDrag("LeftButton", "RightButton")
		window.header:EnableMouse(true)
		window.header:SetScript("OnDragStart", function(self) window:StartMoving() end)
		window.header:SetScript("OnDragStop", function(self) window:StopMovingOrSizing() end)
		window.header:SetScript("OnMouseUp", function(self) window:StopMovingOrSizing() end)
		CreateBackdrop(window.header)

		window.header.text = window.header:CreateFontString(nil, "OVERLAY", "bdConfig_font")
		window.header.text:SetPoint("LEFT", 10, 0)
		window.header.text:SetJustifyH("LEFT")
		window.header.text:SetText("Addon Configuration")
		window.header.text:SetJustifyV("MIDDLE")
		window.header.text:SetScale(bdConfigLib.media.fontHeaderScale)

		window.header.close = CreateButton(window.header)
		window.header.close:SetPoint("TOPRIGHT", window.header)
		window.header.close:SetText("x")
		window.header.close.inactiveColor = bdConfigLib.media.red
		window.header.close:OnLeave()
		window.header.close.OnClick = function()
			window:Hide()
		end

		window.header.reload = CreateButton(window.header)
		window.header.reload:SetPoint("TOPRIGHT", window.header.close, "TOPLEFT", -bdConfigLib.media.borderSize, 0)
		window.header.reload:SetText("Reload UI")
		window.header.reload.inactiveColor = bdConfigLib.media.green
		window.header.reload:OnLeave()
		window.header.reload.OnClick = function()
			ReloadUI();
		end

		window.header.lock = CreateButton(window.header)
		window.header.lock:SetPoint("TOPRIGHT", window.header.reload, "TOPLEFT", -bdConfigLib.media.borderSize, 0)
		window.header.lock:SetText("Unlock")
		window.header.lock.autoToggle = true
		window.header.lock.OnClick = function(self)
			if (self:GetText() == "Lock") then
				self:SetText("Unlock")
			else
				self:SetText("Lock")
			end
		end
	end

	-- Left Column
	do
		window.left = CreateFrame( "Frame", nil, window)
		window.left:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -bdConfigLib.dimensions.header-bdConfigLib.media.borderSize)
		window.left:SetSize(bdConfigLib.dimensions.left_column, bdConfigLib.dimensions.height)
		CreateBackdrop(window.left)
	end

	-- Right Column
	do
		window.right = CreateFrame( "Frame", nil, window)
		window.right:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -bdConfigLib.dimensions.header-bdConfigLib.media.borderSize)
		window.right:SetSize(bdConfigLib.dimensions.right_column-bdConfigLib.media.borderSize, bdConfigLib.dimensions.height)
		CreateBackdrop(window.right)
		window.right.bd_background:SetVertexColor(unpack(bdConfigLib.media.border))
	end

	return window
end

local function FindBetterFont()
	if (bdConfigLib.foundBetterFont) then return end
	local font = false

	if (bdCore) then
		font = bdCore.media.font
	elseif (bdlc) then
		font = bdlc.font
	end

	if (font) then
		bdConfigLib.foundBetterFont = true
		bdConfigLib.font:SetFont(font, bdConfigLib.media.fontSize)
	end
end

local function RegisterModule(self, settings, configuration, savedVariable)
	local enabled, loaded = IsAddOnLoaded(addonName)
	if (not loaded) then
		debug("Addon", addonName, "saved variables not loaded yet, make sure you wrap your addon inside of an ADDON_LOADED event.")
		return
	end

	if (not settings.name) then 
		debug("When addind a module, you must include a name in the settings table.")
		return
	end
	if (not configuration) then 
		debug("When addind a module, you must include a configuration table to outline it's options.")
		return
	end
	-- if (not savedVariable) then 
	-- 	debug("When addind a module, you must include a savedVariable reference so that your settings can be saved.")
	-- 	return
	-- end

	-- see if we can upgrade font object here
	FindBetterFont()

	--[[======================================================
		Create Module Frame and Methods
	========================================================]]
	local module = {}
	module.settings = settings
	module.name = settings.name
	-- module.configuration = configuration
	-- module.savedVariable = savedVariable
	do
		module.tabs = {}
		module.tabContainer = false
		module.pageContainer = false
		module.link = false
		module.lastTab = false

		function module:Select()
			if (module.active) then return end

			-- Unselect all modules
			for name, otherModule in pairs(bdConfigLib.modules) do
				otherModule:Unselect()

				for k, t in pairs(otherModule.tabs) do
					t:Unselect()
				end
			end

			-- Show this module
			module.active = true
			module.link.active = true
			module.tabContainer:Show()

			-- Select first tab
			module.tabs[1]:Select()

			-- If there aren't additional tabs, act like non exist and fill up space
			local current_tab = module.tabs[#module.tabs]
			if (current_tab.text:GetText() == "General") then
				module.tabContainer:Hide()
				current_tab.page.scrollParent:SetHeight(bdConfigLib.dimensions.height - bdConfigLib.media.borderSize)
			end
		end

		-- for when hiding
		function module:Unselect()
			module.tabContainer:Hide()
			module.active = false
			module.link.active = false
			module.link:OnLeave()
		end

		-- Create page and tabs container
		do
			local tabContainer = CreateFrame("frame", nil, bdConfigLib.window.right)
			tabContainer:SetPoint("TOPLEFT")
			tabContainer:SetPoint("TOPRIGHT")
			tabContainer:Hide()
			tabContainer:SetHeight(bdConfigLib.dimensions.header)
			CreateBackdrop(tabContainer)
			local r, g, b, a = unpack(bdConfigLib.media.background)
			tabContainer.bd_border:Hide()
			tabContainer.bd_background:SetVertexColor(r, g, b, 0.5)

			module.tabContainer = tabContainer
		end
		
		-- Create page / tab
		function module:CreateTab(name)
			local index = #module.tabs + 1

			-- create scrollable page container to display tab's configuration options
			local page = CreateScrollFrame(bdConfigLib.window.right)
			page:Hide()

			-- create tab to link to this page
			local tab = CreateButton(module.tabContainer)
			tab.inactiveColor = {1,1,1,0}
			tab.hoverColor = {1,1,1,0.1}
			tab:OnLeave()

			function tab:Select()
				-- tab:Show()
				tab.page:Show()
				tab.active = true
				tab.page.active = true
				tab:OnLeave()

				module.activePage = page
			end
			function tab:Unselect()
				-- tab:Hide()
				tab.page:Hide()
				tab.active = false
				tab.page.active = false
				tab:OnLeave()

				module.activePage = false
			end
			tab.OnClick = function()
				-- unselect / hide other tabs
				for i, t in pairs(module.tabs) do
					t:Unselect()
				end
				-- select this tab
				tab:Select()
			end
			tab:SetText(name)
			if (index == 1) then
				tab:SetPoint("LEFT", module.tabContainer, "LEFT", 0, 0)
			else
				tab:SetPoint("LEFT", module.tabs[index - 1], "RIGHT", 1, 0)
			end

			-- give data to the objects
			tab.page, tab.name, tab.index = page, name, index
			page.tab, page.name, page.index = tab, name, index

			-- append to tab storage
			module.activePage = page
			module.tabs[index] = tab

			return index
		end

		-- Create module navigation link
		do
			local link = CreateButton(bdConfigLib.window.left)
			link.inactiveColor = {0, 0, 0, 0}
			link.hoverColor = {1, 1, 1, .2}
			link:OnLeave()
			link.OnClick = module.Select
			link:SetText(settings.name)
			link:SetWidth(bdConfigLib.dimensions.left_column)
			link.text:SetPoint("LEFT", link, "LEFT", 6, 0)
			if (not bdConfigLib.lastLink) then
				link:SetPoint("TOPLEFT", bdConfigLib.window.left, "TOPLEFT")
				bdConfigLib.firstLink = link
			else
				link:SetPoint("TOPLEFT", bdConfigLib.lastLink, "BOTTOMLEFT")
			end

			bdConfigLib.lastLink = link
			module.link = link
		end
	end

	-- Caps/hide the scrollbar as necessary
	function module:SetPageScroll()
		if (#module.tabs == 0) then return end
		local page = module.activePage or module.tabs[#module.tabs].page
		local height = 0
		if (page.rows) then
			for k, container in pairs(page.rows) do
				height = height + container:GetHeight()
			end
		end

		if (#module.tabs > 0) then
			-- make the scrollbar only scroll the height of the page
			page.scrollbar:SetMinMaxValues(1, math.max(1, height - bdConfigLib.dimensions.height - bdConfigLib.dimensions.header))

			-- if the size of the page is lesser than it's height. don't show a scrollbar
			if ((height  - bdConfigLib.dimensions.height - bdConfigLib.dimensions.header) < 2) then
				page.scrollbar:Hide()
			end
		end
	end

	--[[======================================================
		Module main frames have been created
		1: CREATE / SET SAVED VARIABLES
			This includes setting up profile support
			Persistent config (non-profile)
			Defaults
	========================================================]]
	_G[savedVariable] = _G[savedVariable] or {}
	_G[savedVariable][settings.name] = _G[savedVariable][settings.name] or {}
	module.save = _G[savedVariable][settings.name]
	
	-- module.save[settings.name] = module.save[settings.name] or {}

	module.save.persistent = module.save.persistent or {}
	module.save.user = module.save.user or {}
	module.save.profiles = module.save.profiles or {}
	module.save.profile = module.save.profile or {}
	-- module.save = savedVariable[settings.name]

	-- player configuration
	-- module.save.user = module.save.user or {}
	module.save.user.name = UnitName("player")
	module.save.user.profile = module.save.user.profile or "default"
	module.save.user.spec_profile = module.save.user.spec_profile or {}
	module.save.user.spec_profile[1] = module.save.user.spec_profile[1] or false
	module.save.user.spec_profile[2] = module.save.user.spec_profile[2] or false
	module.save.user.spec_profile[3] = module.save.user.spec_profile[3] or false
	module.save.user.spec_profile[4] = module.save.user.spec_profile[4] or false

	-- profile configuration
	-- module.save.profiles = module.save.profiles or {}
	module.save.profiles[module.save.user.profile] = module.save.profiles[module.save.user.profile] or {}
	module.save.profiles[module.save.user.profile].positions = module.save.profiles[module.save.user.profile].positions or {}

	module.save.profile = module.save.profiles[module.save.user.profile]

	-- persistent configuration
	-- module.save.persistent = module.save.persistent or {}
	module.save.persistent.bd_config = module.save.persistent.bd_config or {} -- todo : let the user decide how the library looks and behaves

	-- let's us access module inforomation quickly and easily
	function module:Save(option, value)
		-- module.save = savedVariable[settings.name]
		-- dump(savedVariable[settings.name].profiles["default"])
		-- module.save = savedVariable
		if (settings.persistent) then
			module.save.persistent[option] = value
		else
			print(option, value)
			-- module.save.profile[option] = value
			module.save.profiles[module.save.user.profile][option] = value
		end
	end
	function module:Get(option)
	-- dump(savedVariable[settings.name].profiles["default"])
		-- module.save = savedVariable[settings.name]
		if (settings.persistent) then
			return module.save.persistent[option]
		else
			return module.save.profiles[module.save.user.profile][option]
		end
	end

	-- dump(savedVariable[settings.name].profiles["default"])
	
	--[[======================================================
		2: CREATE INPUTS AND DEFAULTS
			This includes setting up profile support
			Persistent config (non-profile)
			Defaults
	========================================================]]
	for k, conf in pairs(configuration) do
		-- loop through the configuration table to setup, tabs, sliders, inputs, etc.
		for option, info in pairs(conf) do
			if (settings.persistent) then
				-- if variable is `persistent` its account-wide
				
				if (module.save.persistent[option] == nil) then
					if (info.value == nil) then
						info.value = {}
					end

					module.save.persistent[option] = info.value
				end
			else
				-- this is a per-character configuration
				if (module.save.profile[option] == nil) then
					if (info.value == nil) then
						info.value = {}
					end

					module.save.profile[option] = info.value
				end
			end

			-- Store callbacks and call them all togther
			local callbacks = {}
			if (info.callback) then
				callbacks[#callbacks + 1] = info.callback
			end
			if (settings.callback) then
				callbacks[#callbacks + 1] = settings.callback
			end

			info.callback = function()
				for k, fn in pairs(callbacks) do
					fn()
				end
			end
			
			-- If the very first entry is not a tab, then create a general tab/page container
			if (info.type ~= "tab" and #module.tabs == 0) then
				module:CreateTab("General")
			end

			-- Master Call (slider = bdConfigLib.SliderElement(config, module, option, info))
			local method = info.type:gsub("^%l", string.upper).."Element"
			if (bdConfigLib[method]) then
				bdConfigLib[method](bdConfigLib, module, option, info)
			else
				debug("No module defined for "..method)
			end
		end
	end
	

	--[[======================================================
		3: SETUP DISPLAY AND STORE MODULE
			If we only made 1 tab, hide the tabContianer an
			make the page take up the extra space
	========================================================]]
	module:SetPageScroll()
	module:Select()
	module:Unselect()

	-- store in config
	bdConfigLib.modulesIndex[#bdConfigLib.modulesIndex + 1] = module
	bdConfigLib.modules[settings.name] = module

	if (settings.init) then
		setting.init(module)
	end

	-- shortcuts
	bdConfigLib.saves[settings.name] = module.save
	-- bdConfigLib.saves[settings.name].user = module.save.user
	-- bdConfigLib.saves[settings.name].persistent = module.save.persistent
	-- bdConfigLib.saves[settings.name].profile = module.save.profile

	-- local save
	-- if (settings.persistent) then
	-- 	save = module.save.persistent[module.name][option]
	-- else
	-- 	save = module.save.profiles[module.save.user.profile][module.name][option]
	-- end

	-- print("test")
	-- dump(module.save)

	if (settings.persistent) then
		bdConfigLib.saves[settings.name] = module.save
		return module.save
	else
		bdConfigLib.saves[settings.name] = module.save.profiles[module.save.user.profile]
		return module.save.profiles[module.save.user.profile]
	end
end

--[[========================================================
	Load the Library Up
	For anyone curious, I use `do` statements just to 
	keep the code dileniated and easy to read.
==========================================================]]
do
	-- returns a list of modules currently loaded
	function bdConfigLib:GetSave(name)
		return bdConfigLib.saves[name]
	end
	function bdConfigLib:GetModules()

	end

	-- Selects first module, hides column if only 1
	function bdConfigLib:OnShow()

	end

	-- create tables
	bdConfigLib.modules = {}
	bdConfigLib.modulesIndex = {}
	bdConfigLib.saves = {}
	bdConfigLib.lastLink = false
	bdConfigLib.firstLink = false

	-- create frame objects
	bdConfigLib.window = CreateFrames()

	-- associate RegisterModule function
	bdConfigLib.RegisterModule = RegisterModule
end

--[[========================================================
	CONFIGURATION INPUT ELEMENT METHODS
	This is all of the methods that create user interaction 
	elements. When adding support for new modules, start here
==========================================================]]

--[[========================================================
	ELEMENT CONTAINER WITH `COLUMN` SUPPORT
==========================================================]]
function bdConfigLib:ElementContainer(module, info)
	local page = module.tabs[#module.tabs].page
	local element = info.type
	local container = CreateFrame("frame", nil, page)
	local padding = 10
	local sizing = {
		text = 1.0
		, table = 1.0
		, slider = 0.5
		, checkbox = 0.33
		, color = 0.33
		, dropdown = 0.5
		, clear = 1.0
		, button = 1.0
		, list = 1.0
		, textbox = 1.0
	}
	if (not sizing[element]) then
		print("size not found for "..element)
	end

	-- size the container ((pageWidth / %) - padding left)
	container:SetSize((page:GetWidth() * sizing[element]) - padding, 30)

	-- TESTING : shows a background around each container for debugging
	-- container:SetBackdrop({bgFile = bdConfigLib.media.flat})
	-- container:SetBackdropColor(.1, .8, .2, 0.1)

	-- place the container
	page.rows = page.rows or {}
	page.row_width = page.row_width or 0
	page.row_width = page.row_width + sizing[element]

	if (page.row_width > 1.0 or not page.lastContainer) then
		page.row_width = sizing[element]	
		if (not page.lastContainer) then
			container:SetPoint("TOPLEFT", page, "TOPLEFT", padding, -padding)
		else
			container:SetPoint("TOPLEFT", page.lastRow, "BOTTOMLEFT", 0, -padding)
		end

		-- used to count / measure rows
		page.lastRow = container
		page.rows[#page.rows + 1] = container
	else
		container:SetPoint("TOPLEFT", page.lastContainer, "TOPRIGHT", padding, 0)
	end
	
	page.lastContainer = container
	return container
end

--[[========================================================
	ADDING NEW TABS / SETTING SCROLLFRAME
==========================================================]]
function bdConfigLib:TabElement(module, option, info)
	-- We're done with the current page contianer, cap it's slider/height and start a new tab / height
	module:SetPageScroll()

	-- add new tab
	module:CreateTab(info.value)
end

--[[========================================================
	TEXT ELEMENT FOR USER INFO
==========================================================]]
function bdConfigLib:TextElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	local text = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")

	text:SetText(info.value)
	text:SetAlpha(0.8)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetAllPoints(container)

	local lines = math.ceil(text:GetStringWidth() / container:GetWidth())

	container:SetHeight( (lines * 14) + 10)

	return container
end

--[[========================================================
	CLEAR (clears the columns and starts a new row)
==========================================================]]
function bdConfigLib:ClearElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	container:SetHeight(5)

	return container
end

--[[========================================================
	TABLE ELEMENT
	lets you define a group of configs into a row, and allow for rows to be added
==========================================================]]
function bdConfigLib:ListElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)
	container:SetHeight(200)


	local title = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	title:SetText(info.label)

	local insertbox = CreateFrame("EditBox", nil, container)
	insertbox:SetFontObject("bdConfig_font")
	insertbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	insertbox:SetSize(container:GetWidth() - 66, 24)
	insertbox:SetTextInsets(6, 2, 2, 2)
	insertbox:SetMaxLetters(200)
	insertbox:SetHistoryLines(1000)
	insertbox:SetAutoFocus(false) 
	insertbox:SetScript("OnEnterPressed", function(self, key) button:Click() end)
	insertbox:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	CreateBackdrop(insertbox)

	insertbox.alert = insertbox:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	insertbox.alert:SetPoint("TOPRIGHT",container,"TOPRIGHT", -2, 0)
	insertbox.startFade = function()
		local total = 0
		self.alert:Show()
		self:SetScript("OnUpdate",function(self, elapsed)
			total = total + elapsed
			if (total > 2.5) then
				self.alert:SetAlpha(self.alert:GetAlpha()-0.02)
				
				if (self.alert:GetAlpha() <= 0.05) then
					self:SetScript("OnUpdate", function() return end)
					self.alert:Hide()
				end
			end
		end)
	end

	local button = CreateButton(container)
	button:SetPoint("TOPLEFT", insertbox, "TOPRIGHT", 0, 2)
	button:SetText("Add/Remove")
	insertbox:SetSize(container:GetWidth() - button:GetWidth() + 2, 24)
	button.OnClick = function()
		local value = insertbox:GetText()

		if (strlen(value) > 0) then
			list:addRemove(insertbox:GetText())
		end

		insertbox:SetText("")
		insertbox:ClearFocus()
	end

	local list = CreateFrame("frame", nil, container)
	list:SetPoint("TOPLEFT", insertbox, "BOTTOMLEFT", 0, -2)
	list:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT")
	CreateBackdrop(list)

	local content = CreateScrollFrame(list)

	list.text = content:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	list.text:SetPoint("TOPLEFT", content, "TOPLEFT", 5, 0)
	list.text:SetHeight(600)
	list.text:SetWidth(list:GetWidth() - 10)
	list.text:SetJustifyH("LEFT")
	list.text:SetJustifyV("TOP")
	list.text:SetText("test")
	

	-- show all config entries in this list
	function list:populate()
		local string = "";
		local height = 0;

		for k, v in pairs(module:Get(option)) do
			string = string..k.."\n";
			height = height + 14
		end

		local scrollheight = (height - 200) 
		scrollheight = scrollheight > 1 and scrollheight or 1

		list.scrollbar:SetMinMaxValues(1, scrollheight)
		if (scrollheight == 1) then 
			list.scrollbar:Hide()
		else
			list.scrollbar:Show()
		end

		list.text:SetHeight(height)
		list.text:SetText(string)
	end

	-- remove or add something, then redraw the text
	function list:addRemove(value)
		if (module:Get(option)) then
			insertbox.alert:SetText(value.." removed")
		else
			insertbox.alert:SetText(value.." added")
		end
		module:Save(option, value)
		insertbox:startFade()
		
		self:populate()
		info:callback()

		-- clear aura cache
		bdCore.caches.auras = {}
	end

	list:populate()

	return container
end
--[[========================================================
	BUTTON ELEMENT
	lets you define a group of configs into a row, and allow for rows to be added
==========================================================]]
function bdConfigLib:ButtonElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	local create = CreateButton(container)
	create:SetPoint("TOPLEFT", container, "TOPLEFT")
	create:SetText(info.value)

	create:SetScript("OnClick", function()
		info.callback()
	end)

	return container
end

--[[========================================================
	TEXTBOX ELEMENT
==========================================================]]
function bdConfigLib:TextBoxElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	local create = CreateFrame("EditBox", nil, container)
	create:SetSize(200,24)
	create:SetFontObject("bdConfig_font")
	create:SetText(info.value)
	create:SetTextInsets(6, 2, 2, 2)
	create:SetMaxLetters(200)
	create:SetHistoryLines(1000)
	create:SetAutoFocus(false) 
	create:SetScript("OnEnterPressed", function(self, key) create.button:Click() end)
	create:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	create:SetPoint("TOPLEFT", container, "TOPLEFT", 5, 0)
	CreateBackdrop(create)

	create.label = create:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	create.label:SetText(info.description)
	create.label:SetPoint("BOTTOMLEFT", create, "TOPLEFT", 0, 4)

	create.button = CreateButton(create)
	create.button:SetPoint("LEFT", create, "RIGHT", 4, 0)
	create.button:SetText(info.button)
	create.button.OnClick = function()
		info:callback(create:GetText())
		create:SetText("")
	end

	return container
end

--[[========================================================
	SLIDER ELEMENT
==========================================================]]
function bdConfigLib:SliderElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	local slider = CreateFrame("Slider", module.name.."_"..option, container, "OptionsSliderTemplate")
	slider:SetWidth(container:GetWidth())
	slider:SetHeight(14)
	slider:SetPoint("TOPLEFT", container ,"TOPLEFT", 0, -16)
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(info.min, info.max)
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(info.step)
	slider:SetValue(module:Get(option))
	slider.tooltipText = info.tooltip

	local low = _G[slider:GetName() .. 'Low']
	local high = _G[slider:GetName() .. 'High']
	local label = _G[slider:GetName() .. 'Text']
	low:SetText(info.min);
	low:SetFontObject("bdConfig_font")
	low:ClearAllPoints()
	low:SetPoint("TOPLEFT",slider,"BOTTOMLEFT",0,-1)

	high:SetText(info.max);
	high:SetFontObject("bdConfig_font")
	high:ClearAllPoints()
	high:SetPoint("TOPRIGHT",slider,"BOTTOMRIGHT",0,-1)

	label:SetText(info.label);
	label:SetFontObject("bdConfig_font")
	
	slider.value = slider:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -2)
	slider.value:SetText(module:Get(option))

	slider:Show()
	slider.lastValue = 0
	slider:SetScript("OnValueChanged", function(self)
		local newval = math.floor(slider:GetValue())

		if (slider.lastValue == newval) then return end
		slider.lastValue = newval

		if (module:Get(option) == newval) then -- throttle it changing on the same pixel
			return false
		end

		module:Save(option, newval)

		slider:SetValue(newval)
		slider.value:SetText(newval)
		
		info:callback()
	end)

	container:SetHeight(46)

	return container
end

--[[========================================================
	CHECKBOX ELEMENT
==========================================================]]
function bdConfigLib:CheckboxElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)
	container:SetHeight(25)

	local check = CreateFrame("CheckButton", module.name.."_"..option, container, "ChatConfigCheckButtonTemplate")
	check:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	local text = _G[check:GetName().."Text"]
	text:SetText(info.label)
	text:SetFontObject("bdConfig_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)
	check.tooltip = info.tooltip;
	check:SetChecked(module:Get(option))

	check:SetScript("OnClick", function(self)
		module:Save(option, self:GetChecked())

		info:callback(check)
	end)

	return container
end

--[[========================================================
	COLORPICKER ELEMENT
==========================================================]]
function bdConfigLib:ColorElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	local picker = CreateFrame("button", nil, container)
	picker:SetSize(20, 20)
	picker:SetBackdrop({bgFile = bdCore.media.flat, edgeFile = bdCore.media.flat, edgeSize = 2, insets = {top = 2, right = 2, bottom = 2, left = 2}})
	picker:SetBackdropColor(unpack(module:Get(option)))
	picker:SetBackdropBorderColor(0,0,0,1)
	picker:SetPoint("LEFT", container, "LEFT", 0, 0)
	
	picker.callback = function(self, r, g, b, a)
		module:Save(option, {r,g,b,a})
		picker:SetBackdropColor(r,g,b,a)

		info:callback()
		
		return r, g, b, a
	end
	
	picker:SetScript("OnClick",function()		
		HideUIPanel(ColorPickerFrame)
		local r, g, b, a = unpack(module:Get(option))

		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetClampedToScreen(true)
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.old = {r, g, b, a}
		
		ColorPickerFrame.colorChanged = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			picker:callback(r, g, b, a)
		end

		ColorPickerFrame.func = colorChanged
		ColorPickerFrame.opacityFunc = colorChanged
		ColorPickerFrame.cancelFunc = function()
			local r, g, b, a = unpack(ColorPickerFrame.old) 
			picker:callback(r, g, b, a)
		end

		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:EnableKeyboard(false)
		ShowUIPanel(ColorPickerFrame)
	end)
	
	picker.text = picker:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	picker.text:SetText(info.name)
	picker.text:SetPoint("LEFT", picker, "RIGHT", 8, 0)

	container:SetHeight(30)

	return container
end

--[[========================================================
	DROPDOWN ELEMENT
==========================================================]]
function bdConfigLib:DropdownElement(module, option, info)
	local container = bdConfigLib:ElementContainer(module, info)

	-- revert to blizzard dropdown for the time being
	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetPoint("TOPLEFT", container, "TOPLEFT")
	label:SetText(info.label)
	container:SetHeight(45)

	local dropdown = CreateFrame("Button", module.name.."_"..option, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -15, -2)

	UIDropDownMenu_SetWidth(dropdown, container:GetWidth() - 20)
	UIDropDownMenu_SetText(dropdown, module:Get(option) or "test")
	UIDropDownMenu_JustifyText(dropdown, "LEFT")

	-- initialize options
	UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
		local selected = 0
		for i, item in pairs(info.options) do
			local opt = UIDropDownMenu_CreateInfo()
			opt.text = item
			opt.value = item
			if (item == module:Get(option)) then selected = i end

			opt.func = function(self)
				UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
				CloseDropDownMenus()

				module:Save(option, info.options[i])

				info:callback()
			end

			UIDropDownMenu_AddButton(opt, level)
		end

		UIDropDownMenu_SetSelectedID(dropdown, selected)
	end)

	return container
end