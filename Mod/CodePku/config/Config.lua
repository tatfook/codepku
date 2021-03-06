--[[
Title: Config
Author(s):  big
Date: 2018.10.18
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local Config = NPL.load("(gl)Mod/CodePku/config/Config.lua")
------------------------------------------------------------
]]

local Config = NPL.export()

Config.env = {
  ONLINE = "ONLINE",
  STAGE = "STAGE",
  STAGING = "STAGING",
  DEV = "DEV",
  RELEASE = "RELEASE",
  LOCAL = "LOCAL"
}

Config.defaultEnv = (ParaEngine.GetAppCommandLineByParam("codepkuenv", nil) or Config.env.RELEASE)

Config.codepkuServer = {
  RELEASE = "https://game.codepku.com/api/game",
  STAGING = "https://game.staging.codepku.com/api/game",
  DEV = "https://game.dev.codepku.com/api/game",
  LOCAL = "http://game.local.codepku.com/api/game"
}

Config.defaultServer = Config.codepkuServer[Config.defaultEnv];

-- socket server config
Config.codepkuSocketServer = {    
    RELEASE = "ws://game-socket.codepku.com/chat",
    DEV = "ws://game-socket.dev.codepku.com/chat",    
    LOCAL = "ws://chat.local.codepku.com/chat"
}

Config.defaultSocketServer = Config.codepkuSocketServer[Config.defaultEnv]

Config.storageList = {
  ONLINE = "https://api.keepwork.com/storage/v0",
  STAGE = "http://api-dev.kp-para.cn/storage/v0",
  RELEASE = "http://api-rls.kp-para.cn/storage/v0",
  LOCAL = "http://api-dev.kp-para.cn/storage/v0",
}

Config.qiniuList = {
  ONLINE = "https://upload-z2.qiniup.com",
  STAGE = "https://upload-z2.qiniup.com",
  RELEASE = "https://upload-z2.qiniup.com",
  LOCAL = "https://upload-z2.qiniup.com"
}

Config.keepworkServerList = {
  ONLINE = "https://api.keepwork.com/core/v0",
  STAGE = "http://api-dev.kp-para.cn/core/v0",
  RELEASE = "http://api-rls.kp-para.cn/core/v0",
  LOCAL = "http://api-dev.kp-para.cn/core/v0",
}

Config.gitGatewayList = {
  ONLINE = "https://api.keepwork.com/git/v0",
  STAGE = "http://api-dev.kp-para.cn/git/v0",
  RELEASE = "http://api-rls.kp-para.cn/git/v0",
  LOCAL = "http://api-dev.kp-para.cn/git/v0"
}

Config.esGatewayList = {
  ONLINE = "https://api.keepwork.com/es/v0",
  STAGE = "http://api-dev.kp-para.cn/es/v0",
  RELEASE = "http://api-rls.kp-para.cn/es/v0",
  LOCAL = "http://api-dev.kp-para.cn/es/v0"
}

Config.lessonList = {
  ONLINE = "https://api.keepwork.com/lessonapi/v0",
  STAGE = "http://api-dev.kp-para.cn/lessonapi/v0",
  RELEASE = "http://api-rls.kp-para.cn/lessonapi/v0",
  LOCAL = "http://api-dev.kp-para.cn/lessonapi/v0"
}

Config.dataSourceApiList = {
  gitlab = {
    ONLINE = "https://git.keepwork.com/api/v4",
    STAGE = "http://git-dev.kp-para.cn/api/v4",
    RELEASE = "http://git-rls.kp-para.cn/api/v4",
    LOCAL = "http://git-dev.kp-para.cn/api/v4"
  }
}

Config.dataSourceRawList = {
  gitlab = {
    ONLINE = "https://git.keepwork.com",
    STAGE = "http://git-dev.kp-para.cn",
    RELEASE = "http://git-rls.kp-para.cn",
    LOCAL = "http://git-dev.kp-para.cn"
  }
}

Config.RecommendedWorldList = 'https://git.keepwork.com/gitlab_rls_official/keepworkdatasource/raw/master/official/paracraft/RecommendedWorldList.md'