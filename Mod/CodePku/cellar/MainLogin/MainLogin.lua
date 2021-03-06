--[[
Title: Main Login
Author: big  
Date: 2019.12.25
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local MainLogin = NPL.load("(gl)Mod/CodePku/cellar/MainLogin/MainLogin.lua")
------------------------------------------------------------
]]
local ParaWorldLessons = commonlib.gettable("MyCompany.Aries.Game.MainLogin.ParaWorldLessons")
local GameMainLogin = commonlib.gettable("MyCompany.Aries.Game.MainLogin")

local CodePkuServiceSession = NPL.load("(gl)Mod/CodePku/service/CodePkuService/Session.lua")
local CodePkuService = NPL.load("(gl)Mod/CodePku/service/CodePkuService.lua")
local SessionsData = NPL.load("(gl)Mod/CodePku/database/SessionsData.lua")

local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow");

local MainLogin = NPL.export()

MainLogin.MainLoginPage = nil
MainLogin.LoginBGPage = nil
MainLogin.isPassword = nil
MainLogin.accountNum = ''  --记录输入的号码,切换登录方式保留
MainLogin.verifyCode = ''  --记录输入的验证码,切换登录方式保留
MainLogin.check = GameLogic.GetPlayerController():LoadLocalData('privacyPolicyState',false,true);  --记录复选框状态

function MainLogin:Show(index)     
    self:CloseLoadingPage()
    local PWDInfo = CodePkuServiceSession:LoadSigninInfo()
    echo(PWDInfo)
    local token = System.User.codepkuToken or PWDInfo and PWDInfo.token    
       
    if token then
        -- Mod.CodePku.MsgBox:Show(L"正在登录，请稍候...", 8000, L"链接超时", 300, 120)
        CodePkuServiceSession:LoginWithToken(
            token,
            function(response, err)
                Mod.CodePku.MsgBox:Close()
                if err == 200 then                    
                    local userId = response["data"]["id"] or 0    
                    local nickname = response["data"]["nickname"] or ""
                    local mobile = response["data"]["mobile"] or ""
                    local SetUserinfo = Mod.CodePku.Store:Action("user/SetUserinfo")

                    SetUserinfo(token, response.data)
               
                    Mod.CodePku.Utils.SetTimeOut(function()
                        self:EnterUserConsole()
                    end, 100)  
                else
                    -- auto login failed
                    if PWDInfo and PWDInfo.account then
                        SessionsData:RemoveSession(PWDInfo.account)
                    end
                    local params = {url = "Mod/CodePku/cellar/MainLogin/MainLogin.html", 
                        name = "MainLogin", 
                        isShowTitleBar = false,
                        DestroyOnClose = true,
                        allowDrag = false,
                        enable_esc_key = true,
                        -- bShow = bShow,
                        click_through = false, 
                        zorder = 20,
                        directPosition = true,
                        alignment = "_ctt",
                        width = 944,
                        height = 944                                                
                    }
                    MainLogin.MainLoginPage = AdaptWindow:QuickWindow(params)
                end
            end
        )         
    else                
        if index ~= nil then
            IsPassword = tonumber(index)
        else
            IsPassword = 1
        end
        local params = {
            [1] = {url = "Mod/CodePku/cellar/MainLogin/MainLogin.html", 
                    name = "MainLogin", 
                    isShowTitleBar = false,
                    DestroyOnClose = true,
                    allowDrag = false,
                    enable_esc_key = true,
                    -- bShow = bShow,
                    zorder = 20,
                    directPosition = true,
                    alignment = "_ctt",
                    width = 944,
                    height = 944
                },

            [2] = {url = "Mod/CodePku/cellar/MainLogin/MainLoginPassword.html", 
                    name = "MainLoginPassword", 
                    isShowTitleBar = false,
                    DestroyOnClose = true,
                    allowDrag = false,
                    enable_esc_key = true,
                    -- bShow = bShow,
                    zorder = 20,
                    directPosition = true,
                    alignment = "_ctt",
                    width = 944,
                    height = 944
                }
            };

            MainLogin.MainLoginPage = AdaptWindow:QuickWindow(params[IsPassword])

    
        local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')
        
        if not MainLoginPage then
            return false
        end
                    
        if PWDInfo then
            MainLoginPage:SetValue('account', PWDInfo.account or '')
    
            self.loginServer = PWDInfo.loginServer
            self.account = PWDInfo.account
        end
    
        self:Refresh() 
    end  
end

function MainLogin:Refresh(times)
    local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')

    if MainLoginPage then
        MainLoginPage:Refresh(times or 0.01)
    end
end

function MainLogin:Close()
    local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')

    if MainLoginPage then
        MainLoginPage:CloseWindow()
    end
end

-- methodIndex: 1-captcha, 2-password 3-quicklogin 4-QQ 5-WeChat //4 and 5 not opened
function MainLogin:LoginAction(methodIndex)
    -- 屏蔽微信登录和QQ登录  等做好了记得打开
    if methodIndex > 3 then
        GameLogic.AddBBS(nil, L"功能暂未开放", 3000, "255 0 0", 21);
        return
    end

    local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')

    if not MainLoginPage then
        return false
    end

    local loginServer = CodePkuService:GetEnv()
    if not loginServer then
        return false
    end

    local app_market = ParaEngine.GetAppCommandLineByParam("app_market", nil)
    local account = MainLoginPage:GetValue("account")
    

    local tokenNode = MainLoginPage:GetNode("mobile_token");
    local mobileToken = tokenNode:GetAttributeWithCode("value")

    local verifyCode = MainLoginPage:GetValue("verify_code")
    local password = MainLoginPage:GetValue('password')

    local agree = MainLoginPage:GetNode("agree");
    local agree_ctrl = agree:GetControl();
    local agree_val = agree_ctrl:isChecked();

    if (not account or account == "") and (methodIndex == 1 or methodIndex == 2) then
        GameLogic.AddBBS(nil, L"请输入手机号码", 3000, "255 0 0", 21)
        return false
    end

    if (methodIndex == 1) then
        if not mobileToken or mobileToken == "" then
            GameLogic.AddBBS(nil, L"请先获取验证码", 3000, "255 0 0", 21)
            return false
        end
        if not verifyCode or verifyCode == "" then
            GameLogic.AddBBS(nil, L"请输入验证码", 3000, "255 0 0", 21)
            return false
        end
    elseif (methodIndex == 2) then
        if not password or password == "" then
            GameLogic.AddBBS(nil, L"请输入密码", 3000, "255 0 0", 21)
            return false
        end
    end

    if not agree_val then
        GameLogic.AddBBS(nil, L"为了保证您的个人隐私和隐私安全，还请仔细阅读并同意用户服务协议和隐私政策", 3000, "255 0 0", 21)
        return false
    end

    -- Mod.CodePku.MsgBox:Show(L"正在登录，请稍后...", 8000, L"链接超时", 300, 120)

    local function HandleLogined()
        LOG.std('handle logined', "info", "codepku")
        Mod.CodePku.MsgBox:Close()
        local token = Mod.CodePku.Store:Get("user/token") or ""
        local random_name = Mod.CodePku.Store:Get("user/random_name")
        -- 防止用户游客登录的时候输入了电话号码
        if methodIndex == 3 then
            account = Mod.CodePku.Store:Get("user/mobile") or ""
        end

        local data = {
            loginServer = loginServer,
            account = account,
            token = token,
        }
        
        -- 防止游客玩家在选择名字性别的界面推出游戏导致的bug
        if random_name then
            data["random_name"] = random_name
        end
        
        CodePkuServiceSession:SaveSigninInfo(data)
        
        LOG.std('save sign in info')
        self:EnterUserConsole()

        local AfterLogined = Mod.CodePku.Store:Get('user/AfterLogined')

        if type(AfterLogined) == 'function' then
            AfterLogined(true)
            Mod.CodePku.Store:Remove('user/AfterLogined')
        end
    end

    if (methodIndex == 1) then
        local currentVisitorId = MainLogin:CurrentVisitorId()
        CodePkuServiceSession:Login(
            account,
            verifyCode,
            mobileToken,
            visitor_id,
            function(response, err)                        
                if err == 503 then
                    Mod.CodePku.MsgBox:Close()
                    return false
                end
                GameLogic.GetPlayerController():SaveLocalData('privacyPolicyState',true,true)
                MainLogin.verifyCode = ''
                CodePkuServiceSession:LoginResponse(response, err, HandleLogined)
            end
        )
    elseif (methodIndex == 2) then
        CodePkuServiceSession:LoginWithPwd(
            account,
            password,
            function(response, err)
                if err == 503 then
                    Mod.CodePku.MsgBox:Close()
                    return false
                end
                GameLogic.GetPlayerController():SaveLocalData('privacyPolicyState',true,true)
                MainLogin.verifyCode = ''
                CodePkuServiceSession:LoginResponse(response, err, HandleLogined)
            end
        )
    elseif (methodIndex == 3) then
        local visitor_id = MainLogin:GetVisitorUUID();
        CodePkuServiceSession:QuickLogin(
            visitor_id,
            app_market,
            function(response, err)
                if err == 503 then
                    Mod.CodePku.MsgBox:Close()
                    return false
                end
                GameLogic.GetPlayerController():SaveLocalData('privacyPolicyState',true,true)
                MainLogin.verifyCode = ''
                CodePkuServiceSession:LoginResponse(response, err, HandleLogined)
            end
        )
    end
end

function MainLogin:EnterUserConsole()
    local MainLoginPage = Mod.CodePku.Store:Get("page/MainLogin")

    if MainLoginPage then
        MainLoginPage:CloseWindow()
    end
    GameMainLogin:next_step({IsLoginModeSelected = true})
    -- ParaWorldLessons.CheckShowOnStartup(function(bBeginLessons)
    --     if not bBeginLessons then
    --         System.options.loginmode = "local"                    
    --     end
    -- end)
end

function MainLogin:SetAutoLogin()
    local LoginModalPage = Mod.CodePku.Store:Get("page/LoginModal")

    if not LoginModalPage then
        return false
    end

    local autoLogin = LoginModalPage:GetValue("autoLogin")
    local rememberMe = LoginModalPage:GetValue("rememberMe")
    local password = LoginModalPage:GetValue("password")
    self.loginServer = CodePkuService:GetEnv()
    self.account = string.lower(LoginModalPage:GetValue("account"))

    if autoLogin then
        LoginModalPage:SetValue("rememberMe", true)
    else
        LoginModalPage:SetValue("rememberMe", rememberMe)
    end
    
    LoginModalPage:SetValue("autoLogin", autoLogin)
    LoginModalPage:SetValue("password", password)

    self:Refresh()
end

function MainLogin:SetRememberMe()
    local LoginModalPage = Mod.CodePku.Store:Get("page/LoginModal")

    if not LoginModalPage then
        return false
    end

    local loginServer = CodePkuService:GetEnv()
    local password = LoginModalPage:GetValue("password")
    local rememberMe = LoginModalPage:GetValue("rememberMe")
    self.loginServer = CodePkuService:GetEnv()
    self.account = string.lower(LoginModalPage:GetValue("account"))

    if rememberMe then
        LoginModalPage:SetValue("autoLogin", autoLogin)
    else
        LoginModalPage:SetValue("autoLogin", false)
    end

    LoginModalPage:SetValue("rememberMe", rememberMe)
    LoginModalPage:SetValue("password", password)

    self:Refresh()
end

function MainLogin:GetHistoryUsers()
    LOG.std('history users', "info", "codepku", NPL.ToJson(SessionsData:GetSessions().allUsers))
    if self.account and #self.account > 0 then
        local allUsers = commonlib.Array:new(SessionsData:GetSessions().allUsers)
        local beExist = false

        for key, item in ipairs(allUsers) do
            item.selected = nil

            if item.value == self.account then
                item.selected = true
                beExist = true
            end
        end

        if not beExist then
            allUsers:push_front({ text = self.account, value = self.account, selected = true })
        end

        return allUsers
    else
        return SessionsData:GetSessions().allUsers
    end
end

function MainLogin:SelectAccount(username)
    local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')

    if not MainLoginPage then
        return false
    end

    local session = SessionsData:GetSessionByUsername(username)

    if not session then
        return false
    end

    self.loginServer = session and session.loginServer or 'ONLINE'
    self.account = session and session.account or ''

    MainLoginPage:SetValue("autoLogin", session.autoLogin)
    MainLoginPage:SetValue("rememberMe", session.rememberMe)
    MainLoginPage:SetValue("password", session.password)
    MainLoginPage:SetValue('showaccount', session.account or '')

    self:Refresh()
end

function MainLogin:RemoveAccount(username)
    local MainLoginPage = Mod.CodePku.Store:Get('page/MainLogin')

    if not MainLoginPage then
        return false
    end

    SessionsData:RemoveSession(username)

    if self.account == username then
        self.account = nil
        self.loginServer = nil
                
        MainLoginPage:SetValue("showaccount", "")
    end

    self:Refresh()
end

-- 来自worldshare的sessionData中的借鉴 获取游客的唯一标识符
function MainLogin:GetVisitorUUID()
    local function getUUID()
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end

    local UUIDData = GameLogic.GetPlayerController():LoadLocalData("UUIDData", {}, true)
    local currentParacraftDir = ParaIO.GetWritablePath()    
    
    if (UUIDData.softwareUUID and UUIDData.paracraftDir and UUIDData.paracraftDir == currentParacraftDir) then
        local machineID = UUIDData.machineID or "";
        local visitorUUId = UUIDData.softwareUUID .. "-" .. machineID;
        if visitorUUId ~= 'uuid-' and visitorUUId ~= 'uuid--' then 
            return visitorUUId;
        end
    end

    local machineID = ParaEngine.GetAttributeObject():GetField("MachineID", "");
    if not machineID or machineID == '' then
        machineID = getUUID().. '-' .. os.time()
    end
    UUIDData.paracraftDir = ParaIO.GetWritablePath()
    UUIDData.softwareUUID = "uuid";

    UUIDData.machineID = machineID
    GameLogic.GetPlayerController():SaveLocalData("UUIDData", UUIDData, true)
    return UUIDData.softwareUUID .. "-" .. machineID    
    -- LOG.std(nil, "MainLogin", "GetDeviceUUID", "UUIDData.softwareUUID = %s , UUIDData.machineID = %s", tostring(UUIDData.softwareUUID), tostring(UUIDData.machineID))    
end

function MainLogin:CurrentVisitorId()
    local UUIDData = GameLogic.GetPlayerController():LoadLocalData("UUIDData", {}, true)
    local currentParacraftDir = ParaIO.GetWritablePath()    
    
    if (UUIDData.softwareUUID and UUIDData.paracraftDir and UUIDData.paracraftDir == currentParacraftDir) then
        local machineID = UUIDData.machineID or "";
        local visitorUUId = UUIDData.softwareUUID .. "-" .. machineID;
        if visitorUUId ~= 'uuid-' and visitorUUId ~= 'uuid--' then 
            return visitorUUId;
        end
    end
    return nil;
end

function MainLogin:getMobileCode()
    local MainLoginPage = Mod.CodePku.Store:Get("page/MainLogin")

    if not MainLoginPage then
        return false
    end
        
    local mobile = MainLoginPage:GetValue("account")
    LOG.std(nil, "info", "codepku", "get mobile code: %s", mobile)

    if not mobile or mobile == "" then
        GameLogic.AddBBS(nil, L"手机号码不能为空", 3000, "255 0 0", 21)
        return false
    end
    

    -- Mod.CodePku.MsgBox:Show(L"正在获取验证码...", 8000, L"链接超时", 300, 120)

    CodePkuServiceSession:getMobileCode(
        mobile, 
        function (response, err)
            if err == 200 then  
                Mod.CodePku.MsgBox:Close()       
                GameLogic.AddBBS(nil, L"验证码获取成功", 3000, "255 0 0", 21)         
                LOG.std(nil, "info", "codepku", "get mobile code success")
                local mobileToken = response.data.mobile_token
                MainLoginPage:SetValue('mobile_token', mobileToken)          
                return true
            else 
                local errMsg = response.message or "获取验证码失败"
                -- Mod.CodePku.MsgBox:Close()   
                GameLogic.AddBBS(nil, errMsg, 3000, "255 0 0", 21)                         
                return false  
            end
        end
    )
end

function MainLogin:ShowLoginBackgroundPage()

    local params = {
        url = "Mod/CodePku/cellar/MainLogin/LoginBackgroundPage.html",
        name = "LoginBGPage", 
        DestroyOnClose = true,
        allowDrag = false,
        enable_esc_key = true,
        -- bShow = bShow,
        click_through = false, 
        zorder = -10,
        directPosition = true,
        alignment = "_ct",
        x = -1920/2,
        y = -1080/2,
        width = 1920,
        height = 1080,
        };
        MainLogin.LoginBGPage = AdaptWindow:QuickWindow(params)

end

function MainLogin:ShowUserAgreementModal()	

    local params = {
        url = "Mod/CodePku/cellar/UserAgreement/UserAgreement.html",
        name = "UserAgreement", 
        DestroyOnClose = true,
        allowDrag = false,
        enable_esc_key = true,
        -- bShow = bShow,
        click_through = false, 
        zorder = 30,
        directPosition = true,
        alignment = "_ct",
        x = -1920/2,
        y = -1080/2,
        width = 1920,
        height = 1080,
        };
        AdaptWindow:QuickWindow(params)

    -- Mod.CodePku.Utils.ShowWindow(568, 368, "Mod/CodePku/cellar/UserAgreement/UserAgreement.html", "UserAgreement")
end

function MainLogin:ShowPrivacyAgreementModal()	

    local params = {
        url = "Mod/CodePku/cellar/UserAgreement/PrivacyPolicy.html",
        name = "PrivacyAgreement", 
        DestroyOnClose = true,
        allowDrag = false,
        enable_esc_key = true,
        -- bShow = bShow,
        click_through = false, 
        zorder = 30,
        directPosition = true,
        alignment = "_ct",
        x = -1920/2,
        y = -1080/2,
        width = 1920,
        height = 1080,
        };
        AdaptWindow:QuickWindow(params)

end

function MainLogin:ShowLoadingPage()
    echo("MainLogin:ShowLoadingPage")    
    local url = "Mod/CodePku/cellar/MainLogin/Loading.html"
    local width, height=512, 300;

    Mod.CodePku.Utils.ShowWindow({
        url = url, 
        name = "Loading", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = -1,
        allowDrag = false,
        directPosition = true,
            align = "_ct",
            x = -width/2,
            y = -height/2,
            width = width,
            height = height,
        cancelShowAnimation = true,
    })
end

function MainLogin:CloseLoadingPage()
    echo("MainLogin:CloseLoadingPage")
    local LoadingPage = Mod.CodePku.Store:Get('page/Loading')

    if LoadingPage then
        LoadingPage:CloseWindow()
    end
end