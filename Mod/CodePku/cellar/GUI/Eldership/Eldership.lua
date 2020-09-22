--[[
Title: eldership
Author: loujiayu
Date: 2020/9/1
-----------------------------------------------

local Eldership = NPL.load("(gl)Mod/CodePku/cellar/GUI/Eldership/Eldership.lua");
Eldership:ShowPage();
-----------------------------------------------
]]

local Eldership = NPL.export();
local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow");
local request = NPL.load("(gl)Mod/CodePku/api/BaseRequest.lua");
local UserInfoPage = NPL.load("(gl)Mod/CodePku/cellar/GUI/UserInfo.lua");


Eldership.iconPng = "codepku/image/textures/eldership/eldership.png"                -- 按键雪碧图
Eldership.backgroundPng = "codepku/image/textures/eldership/eldershipbg.png"        -- 我的家长背景图
Eldership.unbindPng = "codepku/image/textures/eldership/unbind.png"                 -- 解绑提示背景图

-- 存放所有使用的固定文本，unbindcontent这个名字是最早的时候写的，懒得改了
Eldership.unbindContent = {
    [1] = "我的家长:",
    [2] = "学习报告",
    [3] = "实时掌握孩子学情",
    [4] = "教学咨询",
    [5] = "一手教学课程全掌握",
    [6] = "充值代付",
    [7] = "消费充值全透明",
    [8] = "未绑定微信",
    [9] = "扫码直接关联学生或者",
    [10] = "截屏保存二维码 > 打开微信扫描二维码关联",
    [11] = "温馨提示：扫码后微信将自动关联学生账号，请勿分享至陌生人",
    [12] = "小朋友，解除微信绑定后无法再解锁课程，是否解除家长绑定？",
}

-- 设置默认的家长绑定信息，初始为未绑定
UserInfoPage.is_bind = 0  -- 1绑定,0未绑定
UserInfoPage.eldership = Eldership.unbindContent[8]

Eldership.iconData = {
    [1] = {url=Eldership.iconPng, left=40, top=44, width=107, height=129},
    [2] = {url=Eldership.iconPng, left=175, top=47, width=84, height=86},
    [3] = {url=Eldership.iconPng, left=304, top=46, width=113, height=71},
    [4] = {url=Eldership.iconPng, left=470, top=29, width=122, height=123},
    [5] = {url=Eldership.iconPng, left=647, top=45, width=67, height=85},
    [6] = {url=Eldership.iconPng, left=775, top=44, width=75, height=89},
    [7] = {url=Eldership.iconPng, left=908, top=46, width=73, height=81},
    [8] = {url=Eldership.iconPng, left=470, top=29, width=122, height=123},           -- 微信二维码,默认使用[4]的纯白背景
    -- [8] = {url=Eldership.iconPng, left=61, top=204, width=268, height=268},           -- 微信二维码，这个是玩学公众号
    [9] = {url=Eldership.iconPng, left=368, top=278, width=245, height=86},
    [10] = {url=Eldership.iconPng, left=694, top=278, width=245, height=86},
}

-- 获取对应图标
function Eldership.GetEldershipIconHTMLStr( id )
    local path=""
    id = tonumber(id)
    path = path..Eldership.iconData[id].url
    if Eldership.iconData[id].left then
      path = path..'#'
      path = path..tostring(Eldership.iconData[id].left)
      path = path..' '..tostring(Eldership.iconData[id].top)
      path = path..' '..tostring(Eldership.iconData[id].width)
      path = path..' '..tostring(Eldership.iconData[id].height)
    end
    LOG.std(nil, "Eldership", "GetEldershipIconHTMLStr", "path = %s", path)
    return path
end

-- 查询是否绑定
function Eldership:GetBindStatus()
  local path = '/users/bind-status'
  request:get(path):next(function(response)
    if (response.status == 200) then
        --获取绑定状态
        local data = response.data.data
        if data.bind_status then
          UserInfoPage.is_bind = 1
          UserInfoPage.eldership = data.user_wechat.wechat_nickname       -- 绑定的家长名称
        elseif not data.bind_status then
          UserInfoPage.is_bind = 0
          UserInfoPage.eldership = Eldership.unbindContent[8]     -- 未绑定
        end
      self.ui:Refresh(0)
    end
  end):catch(function(e)
    echo("ERROR: catched at Eldership:GetBindStatus")
    echo(e)
    GameLogic.AddBBS("CodeGlobals", e.data.message or L"网络开小差了，重试一下吧", 3000, "#FF0000");
  end);
end

-- in函数
function Eldership:items_in(list, str)
    for i=1,#list do
      if str == list[i] then
        return true
      end
    end
    return false
end

-- 请求绑定页面二维码
function Eldership:GetQR()
  local path = '/users/bind-qr-code'
  request:get(path):next(function(response)
    if (response.status == 200) then
    -- 设置二维码图片资源
      -- 校验ticket
      local data = response.data.data
      local qr_code_url = data.qr_code_url
      local ticket = data.ticket
      local qr_code_url_list = commonlib.split(qr_code_url, "=")
      if not self:items_in(qr_code_url_list, ticket) then
        echo("ERROR: catched at Eldership:GetQR, a wrong ticket")
        GameLogic.AddBBS("CodeGlobals", L"网络开小差了，重试一下吧", 3000, "#FF0000");
        return
      end
      -- 替换[8]为绑定二维码
      self.iconData[8] = {url = qr_code_url}
      -- 刷新页面
      self.ui:Refresh(0)
    end
  end):catch(function(e)
    echo("ERROR: catched at Eldership:GetQR")
    echo(e)
    GameLogic.AddBBS("CodeGlobals", e.data.message or L"网络开小差了，重试一下吧", 3000, "#FF0000");
  end);
end

-- 发送解绑请求
function Eldership:Unbind()
  local path = '/users/unbind'
  request:put(path):next(function(response)
    if (response.status == 200) then
      GameLogic.AddBBS("CodeGlobals", L"解绑成功", 3000, "#00FF00");
    end
  end):catch(function(e)
    echo("ERROR: catched at Eldership:Unbind")
    echo(e)
    GameLogic.AddBBS("CodeGlobals", e.data.message or L"网络开小差了，重试一下吧", 3000, "#FF0000");
  end);
    
end

-- 我的家长页面
function Eldership:ShowPage()
    params = {
      url="Mod/CodePku/cellar/GUI/Eldership/Eldership.html", 
      alignment="_lt", left = 0, top = 0, width = 1920 , height = 1080, zorder = 30
    };
    self.ui = AdaptWindow:QuickWindow(params)
end

-- 绑定页面
function Eldership:ShowBindPage()
    params = {
      url="Mod/CodePku/cellar/GUI/Eldership/EldershipBind.html", 
      alignment="_lt", left = 0, top = 0, width = 1920 , height = 1080, zorder = 30
    };
    self.ui = AdaptWindow:QuickWindow(params)
end

-- 解绑页面
function Eldership:ShowUnbindPage()
    params = {
      url="Mod/CodePku/cellar/GUI/Eldership/EldershipUnbind.html", 
      alignment="_lt", left = 0, top = 0, width = 1920 , height = 1080, zorder = 31
    };
    self.ui = AdaptWindow:QuickWindow(params)
end