--功能按钮
--author:John mai
--date: 2020-05-29 15:55:40
NPL.load("(gl)script/ide/System/Windows/Screen.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/TouchSession.lua")
NPL.load("(gl)script/ide/System/Windows/Keyboard.lua")
NPL.load("(gl)script/ide/System/Windows/Mouse.lua")
local Mouse = commonlib.gettable("System.Windows.Mouse")
local Keyboard = commonlib.gettable("System.Windows.Keyboard")
local TouchSession = commonlib.gettable("MyCompany.Aries.Game.Common.TouchSession")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager")
local Screen = commonlib.gettable("System.Windows.Screen")

local Log = NPL.load("(gl)Mod/CodePku/util/Log.lua");
local Table = NPL.load("(gl)Mod/CodePku/util/Table.lua");
local Design = NPL.load("(gl)Mod/CodePku/util/Design.lua");
local mainFrameImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/mainFrameImageData.lua")

local FeatKeyboard = commonlib.inherit(
        commonlib.gettable("System.Core.ToolBase"),
        commonlib.gettable("Mod.CodePku.Common.TouchMiniKeyboard.FeatKeyboard")
);

FeatKeyboard.align = "_lt";
FeatKeyboard.zorder = -10;
FeatKeyboard.colors = { normal = "#ffffff", pressed = "#888888" };

function FeatKeyboard:ctor()

end

--单例实例化
local newInstance;
function FeatKeyboard.getSingleton()
    if (not newInstance) then
        newInstance = FeatKeyboard:new():init()
    end
    return newInstance
end

function FeatKeyboard:init()
    local jumpBtn = self:getJumpBtn();
    local fBtn = self:getFBtn();
    local xBtn = self:getXBtn();
    local shiftBtn = self:getShiftBtn();
    -- local zoomBtn = self:getZoomBtn();
    local chatBtn = self:getChatBtn();

    jumpBtn.visible = false;
    fBtn.visible = false;
    xBtn.visible = false;
    shiftBtn.visible = false;
    -- zoomBtn.visible = false;
    chatBtn.visible = false;

    return self;
end

function FeatKeyboard:show(show, jumpBtnShow, fBtnShow, xBtnShow, shiftBtnShow, chatBtnShow)
    local jumpBtn = self:getJumpBtn();
    local fBtn = self:getFBtn();
    local xBtn = self:getXBtn();
    local shiftBtn = self:getShiftBtn();
    -- local zoomBtn = self:getZoomBtn();
    local chatBtn = self:getChatBtn();

    show = not not show;

    jumpBtn.visible = false;
    fBtn.visible = false;
    xBtn.visible = false;
    shiftBtn.visible = false;
    -- zoomBtn.visible = false;
    chatBtn.visible = false;

    ParaUI.GetUIObject("jump").visible = false;
    ParaUI.GetUIObject("FLY").visible = false;
    ParaUI.GetUIObject("XBtn").visible = false;
    ParaUI.GetUIObject("ShiftBtn").visible = false;
    ParaUI.GetUIObject("Chat").visible = false;

    if show then
        jumpBtn.visible = jumpBtnShow;
        fBtn.visible = fBtnShow;
        xBtn.visible = xBtnShow;
        shiftBtn.visible = shiftBtnShow;
        -- zoomBtn.visible = zoomBtnShow;
        chatBtn.visible = chatBtnShow;
        -- ParaUI.GetUIObject

        ParaUI.GetUIObject("jump").visible = jumpBtnShow;
        ParaUI.GetUIObject("FLY").visible = fBtnShow;
        ParaUI.GetUIObject("XBtn").visible = xBtnShow;
        ParaUI.GetUIObject("ShiftBtn").visible = shiftBtnShow;
        ParaUI.GetUIObject("Chat").visible = chatBtnShow;
    end
end

--创建跳跃按钮
function FeatKeyboard:getJumpBtn()

    local name = "jump";

    local button = ParaUI.GetUIObject(name);

    local left = Design:adapterWidth(1554);
    local top = Design:adapterHeight(852);
    local width = Design:adapterWidth(134);
    local height = Design:adapterWidth(134);

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                name,
                self.align,
                left,
                top,
                width,
                height
        );

        button.background = mainFrameImageData:GetIconUrl("main_icon_tiao.png");
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        button.zorder = self.zorder;
        button:SetScript("ontouch", function()
            Keyboard:SendKeyEvent("keyDownEvent", DIK_SCANCODE.DIK_SPACE);
            _guihelper.SetUIColor(button, self.colors.pressed);

            commonlib.TimerManager.SetTimeout(function()
                Keyboard:SendKeyEvent("keyUpEvent", DIK_SCANCODE.DIK_SPACE);
                _guihelper.SetUIColor(button, self.colors.normal);
            end, 300)
        end)

        button:AttachToRoot();
    else
        button:Reposition(self.align, left, top, width, height);
    end

    return button;
end

--创建 F 按钮
function FeatKeyboard:getFBtn()
    local name = "FLY";

    local button = ParaUI.GetUIObject(name);

    local left = Design:adapterWidth(1348);
    local top = Design:adapterHeight(906);
    local width = Design:adapterWidth(134);
    local height = Design:adapterWidth(134);

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                name,
                self.align,
                left,
                top,
                width,
                height
        );

        button.background = mainFrameImageData:GetIconUrl("main_icon_fly.png");
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        button.zorder = self.zorder;
        button:SetScript("onclick", function()
            Keyboard:SendKeyEvent("keyDownEvent", DIK_SCANCODE.DIK_F);
            _guihelper.SetUIColor(button, self.colors.pressed);

            commonlib.TimerManager.SetTimeout(function()
                Keyboard:SendKeyEvent("keyUpEvent", DIK_SCANCODE.DIK_F);
                _guihelper.SetUIColor(button, self.colors.normal);
            end, 300)
        end)

        button:AttachToRoot();
    else
        button:Reposition(self.align, left, top, width, height);
    end

    return button;
end

--创建 X 按钮
function FeatKeyboard:getXBtn()
    local name = "XBtn";

    local button = ParaUI.GetUIObject(name);

    local left = Design:adapterWidth(1597);
    local top = Design:adapterHeight(648);
    local width = Design:adapterWidth(134);
    local height = Design:adapterWidth(134);

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                name,
                self.align,
                left,
                top,
                width,
                height
        );

        button.background = mainFrameImageData:GetIconUrl("main_icon_x.png");
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        button.zorder = self.zorder;
        button:SetScript("onclick", function()
            Keyboard:SendKeyEvent("keyDownEvent", DIK_SCANCODE.DIK_X);
            _guihelper.SetUIColor(button, self.colors.pressed);

            commonlib.TimerManager.SetTimeout(function()
                Keyboard:SendKeyEvent("keyUpEvent", DIK_SCANCODE.DIK_X);
                _guihelper.SetUIColor(button, self.colors.normal);
            end, 300)
        end)

        button:AttachToRoot();
    else
        button:Reposition(self.align, left, top, width, height);
    end

    return button;
end

--创建 X 按钮
function FeatKeyboard:getShiftBtn()
    local name = "ShiftBtn";

    local button = ParaUI.GetUIObject(name);

    local left = Design:adapterWidth(1419);
    local top = Design:adapterHeight(724);
    local width = Design:adapterWidth(134);
    local height = Design:adapterWidth(134);

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                name,
                self.align,
                left,
                top,
                width,
                height
        );

        button.background = mainFrameImageData:GetIconUrl("main_icon_shift.png");
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        button.zorder = self.zorder;
        button:SetScript("onclick", function()
            Keyboard:SendKeyEvent("keyDownEvent", DIK_SCANCODE.DIK_LSHIFT);
            _guihelper.SetUIColor(button, self.colors.pressed);

            commonlib.TimerManager.SetTimeout(function()
                Keyboard:SendKeyEvent("keyUpEvent", DIK_SCANCODE.DIK_LSHIFT);
                _guihelper.SetUIColor(button, self.colors.normal);
            end, 300)
        end)

        button:AttachToRoot();
    else
        button:Reposition(self.align, left, top, width, height);
    end

    return button;
end

--创建 交互 按钮
function FeatKeyboard:getChatBtn()
    local name = "Chat";

    local button = ParaUI.GetUIObject(name);

    local left = Design:adapterWidth(1464);
    local top = Design:adapterHeight(566);
    local width = Design:adapterWidth(94);
    local height = Design:adapterWidth(94);

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                name,
                self.align,
                left,
                top,
                width,
                height
        );

        button.background = mainFrameImageData:GetIconUrl("main_icon_talk.png");
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        button.zorder = self.zorder;
        button:SetScript("onclick", function()
            
            Keyboard:SendKeyEvent("keyDownEvent", DIK_SCANCODE.DIK_LSHIFT);
            _guihelper.SetUIColor(button, self.colors.pressed);

            commonlib.TimerManager.SetTimeout(function()
                Keyboard:SendKeyEvent("keyUpEvent", DIK_SCANCODE.DIK_LSHIFT);
                _guihelper.SetUIColor(button, self.colors.normal);
            end, 300)
        end)

        button:AttachToRoot();
    else
        button:Reposition(self.align, left, top, width, height);
    end

    return button;
end

--创建 缩放 按钮
function FeatKeyboard:getZoomBtn()
    local buttonName = "zoom-button";
    local containerName = "zoom-container";

    local button = ParaUI.GetUIObject(buttonName);
    local container = ParaUI.GetUIObject(containerName);

    local left = Design:adapterWidth(75);
    local top = Design:adapterHeight(361);
    local width = Design:adapterWidth(150);
    local height = Design:adapterWidth(200);

    if not container:IsValid() then
        container = ParaUI.CreateUIObject(
                "container",
                containerName,
                self.align,
                left,
                top,
                width,
                height
        );

        container.enabled = true;
        container.background = "";
        container.zorder = self.zorder;

        container:AttachToRoot();
    else
        container:Reposition(self.align, left, top, width, height);
    end

    if not button:IsValid() then
        button = ParaUI.CreateUIObject(
                "button",
                buttonName,
                self.align,
                Design:adapterWidth(25),
                Design:adapterHeight(50),
                Design:adapterWidth(100),
                Design:adapterWidth(100)
        );

        button.background = "codepku/image/textures/keyboard/zoom_btn.png";
        _guihelper.SetUIColor(button, self.colors.normal);
        button.enabled = true;
        --button.zorder = self.zorder - 2;

        container:AddChild(button);
    end

    container:SetScript("onmousedown", function()
        local touchSession = TouchSession.GetTouchSession({ type = "WM_POINTERDOWN", x = mouse_x, y = mouse_y, id = -1, time = 0 });

        local buttonUI = container:GetChild(buttonName);
        _guihelper.SetUIColor(buttonUI, self.colors.pressed);

        touchSession:SetField("cameraDist", GameLogic.options:GetCameraObjectDistance());
    end);

    container:SetScript("onmousemove", function()

        Mouse:SetTouchButtonSwapped(true);

        local touchSession = TouchSession.GetTouchSession({ type = "WM_POINTERUPDATE", x = mouse_x, y = mouse_y, id = -1, time = 0 });

        local dx,dy = touchSession:GetOffsetFromStartLocation();

        local cameraStartDist = touchSession:GetField("cameraDist");
        if (cameraStartDist) then
            local delta;
            local fingerSize = touchSession:GetFingerSize();
            if (dy >= 0) then
                delta = (dy + fingerSize * 5) / (fingerSize * 5);
            else
                delta = (fingerSize * 5) / (-dy + fingerSize * 5);
            end
            GameLogic.options:SetCameraObjectDistance(cameraStartDist * delta);
        end
    end);

    container:SetScript("onmouseup", function()

        local buttonUI = container:GetChild(buttonName);
        _guihelper.SetUIColor(buttonUI, self.colors.normal);

        Mouse:SetTouchButtonSwapped(false);
    end);

    return button;
end


function FeatKeyboard:Destroy()
    FeatKeyboard._super.Destroy(self)
    ParaUI.Destroy("zoom-container")
    ParaUI.Destroy("Shift")
    ParaUI.Destroy("X")
    ParaUI.Destroy("F")
    ParaUI.Destroy("jump")
end
