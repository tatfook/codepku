--[[
Title: OnlineClient
Author(s): John Mai
Date: 2020/8/2
Desc: 客户端入口文件
use the lib:
------------------------------------------------------------
NPL.load("Mod/CodePku/online/OnlineClient.lua");
local OnlineClient = commonlib.gettable("Mod.CodePku.Online.OnlineClient");
-------------------------------------------------------
]]
NPL.load("Mod/GeneralGameServerMod/Core/Common/Connection.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Log.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Common.lua");
NPL.load("Mod/CodePku/online/EntityOtherPlayer.lua");
NPL.load("Mod/CodePku/online/EntityMainPlayer.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Client/GeneralGameClient.lua");

local OnlineClient = commonlib.inherit(commonlib.gettable("Mod.GeneralGameServerMod.Core.Client.GeneralGameClient"), commonlib.gettable("Mod.CodePku.Online.OnlineClient"));
local EntityMainPlayer = commonlib.gettable("Mod.CodePku.Online.EntityMainPlayer");
local EntityOtherPlayer = commonlib.gettable("Mod.CodePku.Online.EntityOtherPlayer");
local Common = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Common");
local Log = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Log");
local Connection = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Connection");

local Config = NPL.load("(gl)Mod/CodePku/online/Config.lua");

local Packets = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Packets");

local moduleName = "Mod.CodePku.Online.OnlineClient";

-- 构造函数
function OnlineClient:ctor()

end

-- 初始化函数
function OnlineClient:Init()
    if (self.inited) then return end

    -- 基类初始化
    OnlineClient._super.Init(self);

    self.GetAssetsWhiteList().AddAsset("codepku/model/HLS_AN.x");
    self.GetAssetsWhiteList().AddAsset("codepku/model/LLS_AN.x");
    self.GetAssetsWhiteList().AddAsset("codepku/model/WLS_AN.x");

    self.GetAssetsWhiteList().AddAsset("codepku/model/HAO/hao.fbx");
    self.GetAssetsWhiteList().AddAsset("codepku/model/LI/lilaoshi.fbx");
    self.GetAssetsWhiteList().AddAsset("codepku/model/WANG/WANG.fbx");

    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy02.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy03.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy04.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy05.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy06.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/boy07.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/girl02.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/girl03.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/girl04.x");
    self.GetAssetsWhiteList().RemoveAsset("character/CC/02human/paperman/girl05.x");
    self.GetAssetsWhiteList().RemoveAsset("character/v3/Elf/Female/ElfFemale.xml");

    self.inited = true;
end

-- 获取世界类
function OnlineClient:GetGeneralGameWorldClass()
    return OnlineClient._super.GetGeneralGameWorldClass(self);  -- 不定制
end
-- 获取网络处理类
function OnlineClient:GetNetClientHandlerClass()
    return OnlineClient._super.GetNetClientHandlerClass(self);  -- 不定制
end

-- 获取主玩家类
function OnlineClient:GetEntityMainPlayerClass()
    return EntityMainPlayer;
end
-- 获取其它玩家类
function OnlineClient:GetEntityOtherPlayerClass()
    return EntityOtherPlayer;
end

-- 获取当前认证用户信息
function OnlineClient:GetUserInfo()
    return System.User;
end

-- 是否是匿名用户 移除匿名功能
function OnlineClient:IsAnonymousUser()    
    return false;
end

function OnlineClient:LoadWorld(options)
    -- 初始化
    self:Init();

    -- 保存选项
    self.options = options;

    -- 设定世界ID 优先取当前世界ID  其次用默认世界ID
    local curWorldId = GameLogic.options:GetProjectId();

    -- 确定世界ID
    options.worldId = options.worldId or curWorldId or Config.defaultOnlineServer.defaultWorldId;
    options.username = options.username or self:GetUserInfo().username;
    -- only reload world if world id does not match
    local isReloadWorld = options.worldId ~= curWorldId; 
    local worldId = options.worldId;

    -- 退出旧世界
    if (self.world) then self.world:OnExit(); end

    -- 标识替换, 其它方式loadworld不替换
    self.IsReplaceWorld = true;

    if (isReloadWorld) then
        if (options.url)then
            local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld")
            local RemoteWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.RemoteWorld")
            local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")

            local world = RemoteWorld.LoadFromHref(options.url, "self")
            local function LoadWorld(world, refreshMode)
                if world then
                    if refreshMode == 'never' then
                        if not LocalService:IsFileExistInZip(world:GetLocalFileName(), ":worldconfig.txt") then
                            refreshMode = 'force'
                        end
                    end

                    local url = world:GetLocalFileName()               
                    DownloadWorld.ShowPage(url)
                    echo("loadworld")
                    echo(world)
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

            LoadWorld(world, 'auto');
        else
            GameLogic.RunCommand(string.format("/loadworld %d", worldId));
        end
    else
        self:OnWorldLoaded();
    end
end

function OnlineClient:SelectServerAndWorld()
    if (self:IsShowWorldList()) then
        self.controlServerConnection:AddPacketToSendQueue(Packets.PacketGeneral:new():Init({
            action = "ServerWorldList"
        }));
    else
        
    end
    self.controlServerConnection:AddPacketToSendQueue(Packets.PacketWorldServer:new():Init({
        worldId = worldId,
        parallelWorldName = self.options.parallelWorldName,
    }));
end

-- 发送获取世界服务器
function OnlineClient:handleWorldServer(packetWorldServer)
    local options = self.options;
    options.ip = packetWorldServer.ip or Config.defaultOnlineServer.host;
    options.port = packetWorldServer.port or Config.defaultOnlineServer.port;
    if (not options.ip or not options.port) then
        Log:Info("服务器繁忙, 暂无合适的世界服务器提供");
        return;
    end

    -- 登录世界
    self.world:Login(options);

    -- 关闭控制服务器的链接
    self.controlServerConnection:CloseConnection();
end

-- 连接控制服务器
function OnlineClient:ConnectControlServer(options)
    Log:Debug("ServerIp: %s, ServerPort: %s", Config.defaultOnlineServer.host, Config.defaultOnlineServer.port);
    self.controlServerConnection = Connection:new():InitByIpPort(Config.defaultOnlineServer.host, Config.defaultOnlineServer.port, self);
    self.controlServerConnection:SetDefaultNeuronFile("Mod/GeneralGameServerMod/Core/Server/ControlServer.lua");
    self.controlServerConnection:Connect(5, function(success)
        if (not success) then
            return Log:Info("无法连接控制器服务器");
        end

        self.controlServerConnection:AddPacketToSendQueue(Packets.PacketWorldServer:new():Init({
            worldId = worldId,
            parallelWorldName = options.parallelWorldName,
        }));
    end);
end

-- 初始化成单列模式
OnlineClient:InitSingleton();