--[[
Title: 联机客户端
Author(s): John Mai
Date: 2020-07-10 16:23:49
Desc: 玩学世界联机客户端
Example:
------------------------------------------------------------

-------------------------------------------------------
]]

NPL.load("Mod/GeneralGameServerMod/Core/Client/GeneralGameWorld.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Config.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Connection.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Log.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Common/Common.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Client/NetClientHandler.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Client/EntityMainPlayer.lua");
NPL.load("Mod/GeneralGameServerMod/Core/Client/EntityOtherPlayer.lua");
local NetClientHandler = commonlib.gettable("Mod.GeneralGameServerMod.Core.Client.NetClientHandler");
local EntityMainPlayer = commonlib.gettable("Mod.GeneralGameServerMod.Core.Client.EntityMainPlayer");
local EntityOtherPlayer = commonlib.gettable("Mod.GeneralGameServerMod.Core.Client.EntityOtherPlayer");
local Common = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Common");
local Log = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Log");
local Connection = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Connection");
local Config = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Config");
local GeneralGameWorld = commonlib.gettable("Mod.GeneralGameServerMod.Core.Client.GeneralGameWorld");
local Packets = commonlib.gettable("Mod.GeneralGameServerMod.Core.Common.Packets");

local OnlineClient = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("Mod.CodePku.OnlineClient"));

function OnlineClient:ctor()
    self.inited = false;
    self.options = {};
end

function OnlineClient:Init()

    LOG.std(nil, "info", "CodePku", "OnlineClient init")

    if (self.inited) then return self end;

    -- 禁用服务器 指定为客户端
    NPL.StartNetServer("127.0.0.1", "0");

    -- 监听世界加载完成事件
    GameLogic:Connect("WorldLoaded", self, self.OnWorldLoaded, "UniqueConnection");

    -- 禁用点击继续
    GameLogic.options:SetClickToContinue(false);

    self.inited = true;
    return self;
end

function OnlineClient:Exit()
    GameLogic:Disconnect("WorldLoaded", self, self.OnWorldLoaded, "DisconnectOne");
end

-- 获取世界类
function OnlineClient:GetGeneralGameWorldClass()
    return GeneralGameWorld;
end
-- 获取网络处理类
function OnlineClient:GetNetClientHandlerClass()
    return NetClientHandler;
end
-- 获取主玩家类
function OnlineClient:GetEntityMainPlayerClass()
    return EntityMainPlayer;
end
-- 获取其它玩家类
function OnlineClient:GetEntityOtherPlayerClass()
    return EntityOtherPlayer;
end

function OnlineClient:LoadWorld(options)
    -- 初始化
    self:Init();

    -- 保存选项
    self.options = options;

    -- 设定世界ID 优先取当前世界ID  其次用默认世界ID
    local curWorldId = GameLogic.options:GetProjectId();

    -- 确定世界ID
    options.worldId = options.worldId or curWorldId or Config.defaultWorldId;
    options.username = options.username or self:GetUserInfo().username;
    -- only reload world if world id does not match
    local isReloadWorld = options.worldId ~= curWorldId; 
    local worldId = options.worldId;

    -- 退出旧世界
    if (self.world) then self.world:OnExit(); end

    -- 标识替换, 其它方式loadworld不替换
    self.IsReplaceWorld = true;

    if (isReloadWorld) then
        GameLogic.RunCommand(string.format("/loadworld %d", worldId));
    else
        self:OnWorldLoaded();
    end
end

-- 世界加载
function OnlineClient:OnWorldLoaded() 
    -- 是否需要替换世界
    if (not self.IsReplaceWorld) then return end
    self.IsReplaceWorld = false;

    -- 更新当前世界ID
    local GeneralGameWorldClass = self:GetGeneralGameWorldClass() or GeneralGameWorld;
    self.world = GeneralGameWorldClass:new():Init(self);
    GameLogic.ReplaceWorld(self.world);

    -- 登录世界
    if (self.options.ip and self.options.port) then
        self.world:Login(self.options);
    else
        self:ConnectControlServer(self.options); -- 连接控制器服务, 获取世界服务
    end
end
--  正确流程: 登录成功 => 加载打开世界 => 替换世界


-- 连接控制服务器
function OnlineClient:ConnectControlServer(options)
    Log:Debug("ServerIp: %s, ServerPort: %s", Config.serverIp, Config.serverPort);
    self.controlServerConnection = Connection:new():InitByIpPort(Config.serverIp, Config.serverPort, self);
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

-- 发送获取世界服务器
function OnlineClient:handleWorldServer(packetWorldServer)
    local options = self.options;
    options.ip = packetWorldServer.ip;
    options.port = packetWorldServer.port;
    if (not options.ip or not options.port) then
        Log:Info("服务器繁忙, 暂无合适的世界服务器提供");
        return;
    end

    -- 登录世界
    self.world:Login(options);

    -- 关闭控制服务器的链接
    self.controlServerConnection:CloseConnection();
end

-- 获取当前认证用户信息
function OnlineClient:GetUserInfo()
    -- return {};
end

-- 获取当前系统世界信息
function OnlineClient:GetWorldInfo()
    -- return {};
end


-- 初始化成单列模式
OnlineClient:InitSingleton();