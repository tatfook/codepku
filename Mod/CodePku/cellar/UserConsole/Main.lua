--[[
Title: login
Author(s):  junming
Date: 2020/05/27
Desc: 
use the lib:
------------------------------------------------------------
local UserConsole = NPL.load("(gl)Mod/CodePku/cellar/UserConsole/Main.lua")
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld")
local RemoteWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.RemoteWorld")
local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")
local SaveWorldHandler = commonlib.gettable("MyCompany.Aries.Game.SaveWorldHandler")
local GameMainLogin = commonlib.gettable("MyCompany.Aries.Game.MainLogin")
local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow")

local WorldShare = commonlib.gettable("Mod.CodePku")
local Encoding = commonlib.gettable("commonlib.Encoding")

local UserInfo = NPL.load("(gl)Mod/CodePku/cellar/UserConsole/UserInfo.lua")
local CodePkuServiceSession = NPL.load("(gl)Mod/CodePku/service/CodePkuService/Session.lua")
local CodePkuService = NPL.load("(gl)Mod/CodePku/service/CodePkuService.lua")
NPL.load("(gl)Mod/CodePku/cellar/GUI/GenAndName.lua")  
local MainLogin = NPL.load("(gl)Mod/CodePku/cellar/MainLogin/MainLogin.lua")

local UserConsole = NPL.export()

function UserConsole:ShowPage()
    UserInfo:OnChangeAvatar()

    NPL.load("(gl)Mod/CodePku/cellar/Notice/Notice.lua")
    local Notice = commonlib.gettable("Mod.CodePku.celler.Notice")

    --华为,ios审核版屏蔽公告
    local huaweiApprovalStatus = Mod.CodePku.BasicConfigTable.huawei_approval_status == 'on'  
    local isHuawei = ParaEngine.GetAppCommandLineByParam("app_market", "") == 'huawei';
    local iosApprovalStatus = Mod.CodePku.BasicConfigTable.ios_approval_status == 'on'
    local mock_ios = ParaEngine.GetAppCommandLineByParam("mock_ios", "") == "true"
    local isIOS = System.os.GetPlatform() == 'ios';
    if not (( huaweiApprovalStatus and isHuawei) or (iosApprovalStatus and (isIOS or mock_ios))) then
        Notice:ShowPage()    
    end

    local params = {
        url = "Mod/CodePku/cellar/UserConsole/StartLearning.html", 
        name = "StartLearning", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        allowDrag = false,
        enable_esc_key = true,
        -- bShow = bShow,
        click_through = false, 
        zorder = 20,
        directPosition = true,
        alignment = "_ct",
        x = -1920/2,
        y = -1080/2,
        width = 1920,
        height = 1080,
        };
        AdaptWindow:QuickWindow(params)

end

function UserConsole:ClosePage()
    local UserConsolePage = Mod.CodePku.Store:Get('page/StartLearning')

    if UserConsolePage then        
        UserConsolePage:CloseWindow()
    end

    if MainLogin then
        MainLogin.LoginBGPage:CloseWindow()
    end
end

function UserConsole:CourseEntry() 
    NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua");
    local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");   
    local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
    --判断是否是华为审核版
    local huaweiApprovalStatus = Mod.CodePku.BasicConfigTable.huawei_approval_status == 'on'  
    local isHuawei = ParaEngine.GetAppCommandLineByParam("app_market", "") == 'huawei';
    local flymeApprovalStatus = Mod.CodePku.BasicConfigTable.flyme_approval_status == 'on'  
    local isFlyMe = ParaEngine.GetAppCommandLineByParam("app_market", "") == 'flyme';
    local sogouApprovalStatus = Mod.CodePku.BasicConfigTable.sogou_approval_status == 'on'  
    local isSoGou = ParaEngine.GetAppCommandLineByParam("app_market", "") == 'sogou';
    local iosApprovalStatus = Mod.CodePku.BasicConfigTable.ios_approval_status == 'on'
    local mock_ios = ParaEngine.GetAppCommandLineByParam("mock_ios", "") == "true"
    local isIOS = System.os.GetPlatform() == 'ios';
    if isHuawei and huaweiApprovalStatus then 
        self:HandleWorldId(Mod.CodePku.BasicConfigTable.huawei_entry_world_id)
    elseif isFlyMe and flymeApprovalStatus then 
        self:HandleWorldId(Mod.CodePku.BasicConfigTable.flyme_entry_world_id)
    elseif isSoGou and sogouApprovalStatus then 
        self:HandleWorldId(Mod.CodePku.BasicConfigTable.sogou_entry_world_id)
    elseif isIOS or mock_ios then
        -- ios渠道审核
        if iosApprovalStatus then 
            -- ios审核中
            -- GameLogic.GetFilters():apply_filters("HideClientUpdaterNotice");
            self:HandleWorldId(Mod.CodePku.BasicConfigTable.ios_approval_entry_world_id)
            
        else
            -- ios审核通过
            -- GameLogic.GetFilters():apply_filters("ShowClientUpdaterNotice");
            CommandManager:Init();
            CommandManager:RunCommand(string.format("/ggs connect -app=CodePku %s", Mod.CodePku.BasicConfigTable.ios_entry_world_id))
        end
    else
        if UserConsole.BeginnerGuideFlag then
            self:HandleWorldId(Mod.CodePku.BasicConfigTable.beginner_guide_world_id)  
        else 
            CodePkuServiceSession:CourseEntryWorld(function (response, err)         
                if (err == 401) then
                    GameLogic.AddBBS(nil, L"请先登录", 3000, "255 0 0", 21)
                    -- todo 看下怎么回到登录页面
                    return false
                end   
                if (err ~= 200) then
                    GameLogic.AddBBS(nil, L"获取入口世界失败", 3000, "255 0 0", 21)
                    return false
                end

                CommandManager:Init();
                CommandManager:RunCommand(string.format("/ggs connect -app=CodePku %s", response.data.keepwork_project_id))                        
            end) 
        end
    end
            

    local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
    GameLogic.GetFilters():apply_filters("TaskSystemList", {type = "login"});-- 登录之后，触发任务系统计数
    GameLogic.GetFilters():apply_filters("Schoolyard.IncreaseVitality", {type = "login"});-- 登录之后，触发活跃度系统

    -- 登录之后，获取任务数据
    NPL.load("(gl)Mod/CodePku/cellar/Common/TouchMiniButtons/TaskSystem/TaskSystem.lua")
    local TaskSystem = commonlib.gettable("Mod.CodePku.Common.TaskSystem")
    TaskSystem:GetTask();

    -- 登陆之后，获取地址树
    local Schoolyard = NPL.load("(gl)Mod/CodePku/cellar/GUI/Schoolyard/Schoolyard.lua");
    Schoolyard.AreasTreeData = GameLogic.GetPlayerController():LoadLocalData(Schoolyard.key,false,true);
    if not Schoolyard.AreasTreeData then
        Schoolyard:GetAreasTree()
    end
    

    -- 拉取当前分线服务器数据
    NPL.load("(gl)Mod/CodePku/cellar/GUI/Branch/ChooseBranch.lua")
    local ChooseBranch = commonlib.gettable("Mod.CodePku.GUI.ChooseBranch")
    ChooseBranch:GetServerData()

    -- 初始化websocket
    local WebSocketClient = NPL.load("(gl)Mod/CodePku/cellar/Heartbeat/WebSocketClient.lua");
    WebSocketClient:StaticInit()

    -- 登陆之后，获取邮件信息
    NPL.load("(gl)Mod/CodePku/cellar/Mail/Mail.lua")
    local Mail = commonlib.gettable("Mod.CodePku.celler.Mail")
    Mail.StaticInit()
    
end

function UserConsole:Logout()
    CodePkuServiceSession:Logout()
    local StartLearningPage = Mod.CodePku.Store:Get('page/StartLearning')
    if StartLearningPage then
        StartLearningPage:CloseWindow()
    end
    GameMainLogin:next_step({IsLoginModeSelected = false})
end

function UserConsole:GetProjectId(url)
    if (tonumber(url or '') or 99999) < 99999 then
        return url
    end

    local pid = string.match(url or '', "^p(%d+)$")

    if not pid then
        pid = string.match(url or '', "/pbl/project/(%d+)")
    end

    return pid or false
end

function UserConsole:HandleWorldId(pid)
    if not pid then
        return false
    end

    pid = tonumber(pid)

    if pid == 14293 then
        NPL.load("(gl)Mod/CodePku/cellar/GUI/Home/HomeManage.lua")
        local HomeManage = commonlib.gettable("Mod.CodePku.Common.HomeManage")
        HomeManage:GetHomeWorld()
        return
    end

    -- 关闭家园区计时器
    GameLogic.GetFilters():apply_filters("Schoolyard.IncreaseVitality", {type = "home", time = "close"});   -- 未进入家园，家园区计时器如果存在，则需要关闭

    local function LoadWorld(world, refreshMode)
        if world then
            if refreshMode == 'never' then
                if not LocalService:IsFileExistInZip(world:GetLocalFileName(), ":worldconfig.txt") then
                    refreshMode = 'force'
                end
            end

            local url = world:GetLocalFileName()
            DownloadWorld.ShowPage(url)
            local mytimer = commonlib.Timer:new(
                {
                    callbackFunc = function(timer)
                        InternetLoadWorld.LoadWorld(
                            world,
                            nil,
                            refreshMode or "auto",
                            function(bSucceed, localWorldPath)          
                                DownloadWorld.Close()
                            end
                        )
                    end
                }
            );
            -- prevent recursive calls.
            mytimer:Change(1,nil);
        else
            _guihelper.MessageBox(L"无效的世界文件");
        end
    end

    CodePkuServiceSession:CourseWorldByKeepworkId(pid, function (response, error)        
        if (error == 401) then
            GameLogic.AddBBS(nil, L"请先登录", 3000, "255 0 0", 21)
            -- todo 看下怎么回到登录页面
            return false
        end   
        if (error ~= 200) then
            GameLogic.AddBBS(nil, L"获取世界失败", 3000, "255 0 0", 21)
            return false
        end
        local url = response and response.data and response.data.world
        commonlib.setfield("System.Codepku.Coursewares", response.data);

        if not url then
            GameLogic.AddBBS(nil, L"获取世界失败", 3000, "255 0 0", 21)
            return false
        end

        --
        local _data = response.data
        if not _data.owned then
            local TeachCourses = NPL.load("(gl)Mod/CodePku/cellar/GUI/SmallMap/FastEntrence/TeachCourses/TeachCourses.lua")
            TeachCourses.judgeCourseInfo = {
                id = _data.id,
                name = _data.name,
                description = _data.description,
                is_free = _data.is_free,
                owned = _data.owned,
                origin_price = _data.origin_price,
                price = _data.price,
                paid_unlock_method = _data.paid_unlock_method,
                cover_url = _data.cover_url,
    
                package_id = _data.course.id,
                package_name = _data.course.name,
                package_description = _data.course.description,
                package_cover = _data.course.cover,
                package_origin_price = _data.course.package_underline_price,
                package_price = _data.course.package_price,
                package_cover_url = _data.course.cover_url,
            }
    
            TeachCourses:ShowPage(3)
            return
        end
        --

        local world = RemoteWorld.LoadFromHref(url, "self")
        LoadWorld(world, 'auto')    
    end)
end

function UserConsole:ShowBeginnerPage()
    local params = {
        url = "Mod/CodePku/cellar/UserConsole/BeginnerGuide.html", 
        name = "StartLearning", 
        isShowTitleBar = false,
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
