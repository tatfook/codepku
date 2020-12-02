--[[
Author:zouren
Date: 2020-11-22 16:05:02
Des: 特殊世界移动端tab ctrl shift alt功能键小键盘
use the lib:
------------------------------------
NPL.load("(gl)Mod/CodePku/cellar/Common/TouchMiniKeyboard/TouchFuncKeyboard.lua")
local TouchFuncKeyboard = commonlib.gettable("Mod.CodePku.Common.TouchMiniKeyboard.TouchFuncKeyboard")
TouchFuncKeyboard.getSingleton():show()
-----------------------------------
]]--


NPL.load("(gl)script/ide/System/Windows/Screen.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/TouchSession.lua")
NPL.load("(gl)script/ide/System/Windows/Keyboard.lua")
NPL.load("(gl)script/ide/System/Windows/Mouse.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua")
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua")
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager")   
local Mouse = commonlib.gettable("System.Windows.Mouse")
local Keyboard = commonlib.gettable("System.Windows.Keyboard")
local TouchSession = commonlib.gettable("MyCompany.Aries.Game.Common.TouchSession")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager")
local Screen = commonlib.gettable("System.Windows.Screen")

local Log = NPL.load("(gl)Mod/CodePku/util/Log.lua")
local Table = NPL.load("(gl)Mod/CodePku/util/Table.lua")
local Design = NPL.load("(gl)Mod/CodePku/util/Design.lua")
local mainFrameImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/mainFrameImageData.lua")
local funcKeyboardImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/funcKeyboardImageData.lua")

local TouchFuncKeyboard = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"),commonlib.gettable("Mod.CodePku.Common.TouchMiniKeyboard.TouchFuncKeyboard"))
TouchFuncKeyboard:Property("Name", "TouchFuncKeyboard");

TouchFuncKeyboard.name = "default_TouchFuncKeyboard";

function TouchFuncKeyboard:ctor()
	self.zorder = 31;
	self.keylayout = {
		{
			name = "Ctrl",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18, top = 64, width = 192, height = 80,
			key = {
				DIK_SCANCODE.DIK_LCONTROL,
			},
			type = 1, -- 1为切换状态按键 2为点击按键
		},
		{
			name = "Ctrl+C",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 64, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LCONTROL,
				DIK_SCANCODE.DIK_C,
			},
			type = 2,
		},
		{
			name = "Ctrl+Z",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18,top = 146,width = 192,height = 80,
			key = {	
				DIK_SCANCODE.DIK_LCONTROL,
				DIK_SCANCODE.DIK_Z,
			},
			type = 2,
		},
		{
			name = "Ctrl+V",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 146, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LCONTROL,
				DIK_SCANCODE.DIK_V,
				},
			type = 2,
		},
		{
			name = "Ctrl+Shift",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18, top = 228, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LCONTROL,
				DIK_SCANCODE.DIK_LSHIFT,
				},
			type = 1,
		},
		{
			name = "",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 228, width = 192, height = 80,
			key = {},
			type = 1,
		},
		{
			name = "Shift",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18, top = 310, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LSHIFT,
				},
			type = 1,
		},
		{
			name = "Shift+Tab",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 310, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LSHIFT,
				DIK_SCANCODE.DIK_TAB,
				},
			type = 2,
		},
		{
			name = "Alt",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18, top = 392, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LMENU,
				},
			type = 1,
		},
		{
			name = "Alt+Shift",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 392, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_LMENU,
				DIK_SCANCODE.DIK_LSHIFT,
				},
			type = 1,
		},
		{
			name = "Tab",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 18, top = 474, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_TAB,
				},
			type = 2,
		},
		{
			name = "DEL",
			background = funcKeyboardImageData:GetIconUrl("funckeyboard_key_bot.png"),
			clickedBackground = funcKeyboardImageData:GetIconUrl("funckeyboard_key_dark.png"),
			left = 219, top = 474, width = 192, height = 80,
			key = {	
				DIK_SCANCODE.DIK_BACK,
				},
			type = 2,
		},
	};

	self:initUIComponent()
end

function TouchFuncKeyboard:initUIComponent()
	self.name = name or self.name;
	local container = self:getContainer();
    container:RemoveAll();
	container.visible = false;
	
	for _, item in ipairs(self.keylayout) do
        if item.name then
            local width = Design:adapterWidth(item.width);
            local height = Design:adapterWidth(item.height);

            local left = Design:adapterWidth(item.left);
            local top = Design:adapterWidth(item.top);

            local button = ParaUI.CreateUIObject("button",
                item.name,
                "_lt",
                left,
                top,
                width,
                height);

            button.background = item.background;
			button.enabled = false;
			button.funcType = item.type
			button.funcKey = item.key

			item.id = button.id

            _guihelper.SetUIColor(button, "#FFFFFF");
            container:AddChild(button);
        end
    end
	return self;
end

function TouchFuncKeyboard:refreshUIComponent()
	self:getContainer()
	for _, item in ipairs(self.keylayout) do
        if item.name then
			local button = ParaUI.GetUIObject(item.id or item.name)
			local width = Design:adapterWidth(item.width)
            local height = Design:adapterWidth(item.height)

            local left = Design:adapterWidth(item.left)
			local top = Design:adapterWidth(item.top)
			
			button:Reposition("_lt", left, top, width, height)
        end
    end
end

function TouchFuncKeyboard:getContainer()
	local container = ParaUI.GetUIObject(self.id or self.name);
	self.alignment = "_lt";
	self.left = Design:adapterWidth(1354);
    self.top = Design:adapterWidth(58);
    self.width = Design:adapterWidth(429);
    self.height = Design:adapterWidth(577);
	
	if(not container:IsValid()) then
		container = ParaUI.CreateUIObject("container",self.name, self.alignment,self.left,self.top,self.width,self.height);
		container.background = funcKeyboardImageData:GetIconUrl("funckeyboard_bot.png");

		container:AttachToRoot();
		container.zorder = self.zorder;
		container:SetScript("ontouch", function() self:handleTouch(msg) end);
		container:SetScript("onmousedown", function() self:handleMouseDown() end);
		container:SetScript("onmouseup", function() self:handleMouseUp() end);
		container:SetScript("onmousemove", function() self:handleMouseMove() end);

		self.id = container.id;
	else
		container:Reposition(self.alignment,self.left,self.top,self.width,self.height);
	end
	return container;
end

--处理鼠标移动事件
function TouchFuncKeyboard:handleMouseMove()
    local touch = { type = "WM_POINTERUPDATE", x = mouse_x, y = mouse_y, id = -1, time = 0 };
    self:handleTouch(touch);
end

--处理鼠标点击事件
function TouchFuncKeyboard:handleMouseDown()
    local touch = { type = "WM_POINTERDOWN", x = mouse_x, y = mouse_y, id = -1, time = 0 };
    self:handleTouch(touch);
end

--处理鼠标弹起事件
function TouchFuncKeyboard:handleMouseUp()
    local touch = { type = "WM_POINTERUP", x = mouse_x, y = mouse_y, id = -1, time = 0 };
    self:handleTouch(touch);
end

--处理触摸事件
function TouchFuncKeyboard:handleTouch(touch)
	local touchSession = TouchSession.GetTouchSession(touch);
	
	GameLogic.AddBBS(nil, touch.type, 2000, "0 0 255", 21)
    if touch.type == "WM_POINTERDOWN" then

    elseif touch.type == "WM_POINTERUP" then

    elseif touch.type == "WM_POINTERUPDATE" then

    end
end

--控制显示功能键盘
function TouchFuncKeyboard:show(_show)
	-- GameLogic.AddBBS(nil, L"TouchFuncKeyboard:show", 2000, "0 0 255", 21)
	-- GameLogic.AddBBS(nil, tostring(false == (_show == false)), 2000, "0 0 255", 21)
	self:refreshUIComponent()
    local container = self:getContainer();
    container.visible = (false == (_show == false));
end

function TouchFuncKeyboard:Destroy()
    TouchFuncKeyboard._super.Destroy(self)
    ParaUI.Destroy(self.id or self.name)
    self.id = nil
end

TouchFuncKeyboard:InitSingleton()