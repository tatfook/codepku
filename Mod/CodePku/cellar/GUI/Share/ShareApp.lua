--[[
Title: ShareApp
Author: loujiayu
Date: 2020/10/10
Desc:分享内容至手机其它app，目前限制为只分享图片，本质是使用CodePkuCommon/util/Share.lua里的Share.fire("type",{})
Example:
-----------------------------------------------
local ShareApp = NPL.load("(gl)Mod/CodePku/cellar/GUI/Share/ShareApp.lua");
ShareApp:fire(id, page)         不需要弹窗时使用该函数
ShareApp:ShowPage(id, page)     需要弹窗时使用该函数,会根据设备和场景判断是否有弹窗
@params: page 选传参数，可以不传，当需要当前页面刷新时传入当前页page
id 后台会根据id返回图片url
id=1    主界面
id=2    课程结算
id=3    彩蛋
id=4    游戏
id=11   单词爱跑酷
id=12   华夏游学记
id=13   站到最后
id=111  单词爱跑酷通用
id=112  单词爱跑酷专属1
id=113  单词爱跑酷专属2
id=114  单词爱跑酷专属3
id=121  华夏游学记通用
id=122  华夏游学记专属1
id=123  华夏游学记专属2
id=124  华夏游学记专属3
id=131  站到最后通用
id=132  站到最后专属1
id=133  站到最后专属2
id=134  站到最后专属3
-----------------------------------------------
]]


local ShareApp = NPL.export();
local request = NPL.load("(gl)Mod/CodePku/api/BaseRequest.lua")
local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow")
local Share = NPL.load("(gl)Mod/CodePkuCommon/util/Share.lua")
local shareImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/shareImageData.lua")


ShareApp.pcpopup_path = "codepku/image/textures/share_app/pcpopup.png"    -- PC端展示弹窗
ShareApp.pccancel_path = "codepku/image/textures/share_app/pccancel.png"    -- PC端取消按钮



-- 获取对应图标
function ShareApp.GetIconPathStr(index)
    return shareImageData:GetIconUrl(index)
end

-- 获取海报
function ShareApp:GetPoster(id, page)
    ShareApp.poster_id = id
    ShareApp.bShare = true
    local path = string.format("/posters/show?type=%d", id)
    request:get(path):next(function(response)
        -- 拿到返回值，根据返回值拼接share参数
        local data = response.data.data
        ShareApp.bShare = false
        ShareApp.poster_url = data.img_url or data.default_url
        if page then
            page:Refresh(0)
        end
    end):catch(function(e)
        GameLogic.AddBBS("CodeGlobals", e.data.message, 3000, "#FF0000");
    end);

end

-- 分享主逻辑
function ShareApp:ShareLogic(url, id)
    ShareApp.bShare = true
    Share:fire("image", {
        image = url,
        title = "分享海报"
    }, {
        onStart = function(e)
            -- 开始分享
            ShareApp.bShare = false
            ShareApp:GetStatisticData(id, e, 1)
        end,
        onResult = function(e)
            -- 分享结果
            ShareApp.bShare = false
            ShareApp:GetStatisticData(id, e, 2)
        end,
        onError = function(e)
            -- 分享失败
            ShareApp.bShare = false
        end,
        onCancel = function(e)
            -- 取消分享
            ShareApp.bShare = false
        end
    })
end

--[[
    @desc 触发操作数据统计计数
    @param flag 1分享前 2分享后
]]
function ShareApp:GetStatisticData(id, e, flag)
    if flag == 1 then
        local data = {}
        local platform = commonlib.Json.Decode(e).platform
        if id == 1 then --主界面
            if platform == "QQ" then
                data = {type = 77}
            elseif platform == "QZONE" then
                data = {type = 79}
            elseif platform == "WEIXIN" then
                data = {type = 81}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 83}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功前，触发操作数据统计计数
        elseif id == 2 then --教学区
            if platform == "QQ" then
                data = {type = 44}
            elseif platform == "QZONE" then
                data = {type = 46}
            elseif platform == "WEIXIN" then
                data = {type = 48}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 50}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功前，触发操作数据统计计数
        elseif id == 111 or id == 113 or id == 114 then--单词爱跑酷结束弹出框
            if platform == "QQ" then
                data = {type = 55}
            elseif platform == "QZONE" then
                data = {type = 57}
            elseif platform == "WEIXIN" then
                data = {type = 59}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 61}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功前，触发操作数据统计计数
        elseif id == 121 or id == 123 or id == 124 then --游学记结束弹出框
            if platform == "QQ" then
                data = {type = 66}
            elseif platform == "QZONE" then
                data = {type = 68}
            elseif platform == "WEIXIN" then
                data = {type = 70}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 72}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功前，触发操作数据统计计数
        elseif id == 131 or id == 133 or id == 134 then --站到最后结束弹出框
            if platform == "QQ" then
                data = {type = 88}
            elseif platform == "QZONE" then
                data = {type = 90}
            elseif platform == "WEIXIN" then
                data = {type = 92}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 94}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功前，触发操作数据统计计数
        end
    elseif flag == 2 then
        local data = {}
        local data2 = {}
        local platform = commonlib.Json.Decode(e).platform
        if id == 1 then --主界面
            data2 = {type = 75}
            if platform == "QQ" then
                data = {type = 78}
            elseif platform == "QZONE" then
                data = {type = 80}
            elseif platform == "WEIXIN" then
                data = {type = 82}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 84}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功，触发操作数据统计计数
            GameLogic.GetFilters():apply_filters("ClickStatistics", data2); -- 记录成功分享至某个平台的次数，触发操作数据统计计数
        elseif id == 2 then --教学区
            data2 = {type = 42}
            if platform == "QQ" then
                data = {type = 45}
            elseif platform == "QZONE" then
                data = {type = 47}
            elseif platform == "WEIXIN" then
                data = {type = 49}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 51}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功，触发操作数据统计计数
            GameLogic.GetFilters():apply_filters("ClickStatistics", data2); -- 记录成功分享至某个平台的次数，触发操作数据统计计数
        elseif id == 111 or id == 113 or id == 114 then--单词爱跑酷结束弹出框
            data2 = {type = 53}
            if platform == "QQ" then
                data = {type = 56}
            elseif platform == "QZONE" then
                data = {type = 58}
            elseif platform == "WEIXIN" then
                data = {type = 60}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 62}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功，触发操作数据统计计数
            GameLogic.GetFilters():apply_filters("ClickStatistics", data2); -- 记录成功分享至某个平台的次数，触发操作数据统计计数
        elseif id == 121 or id == 123 or id == 124 then --游学记结束弹出框
            data2 = {type = 64}
            if platform == "QQ" then
                data = {type = 67}
            elseif platform == "QZONE" then
                data = {type = 69}
            elseif platform == "WEIXIN" then
                data = {type = 71}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 73}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功，触发操作数据统计计数
            GameLogic.GetFilters():apply_filters("ClickStatistics", data2); -- 记录成功分享至某个平台的次数，触发操作数据统计计数
        elseif id == 131 or id == 132 or id == 134 then --站到最后弹出框
            data2 = {type = 86}
            if platform == "QQ" then
                data = {type = 89}
            elseif platform == "QZONE" then
                data = {type = 91}
            elseif platform == "WEIXIN" then
                data = {type = 93}
            elseif platform == "WEIXIN_CIRCLE" then
                data = {type = 95}
            end
            GameLogic.GetFilters():apply_filters("ClickStatistics", data); -- 分享成功，触发操作数据统计计数
            GameLogic.GetFilters():apply_filters("ClickStatistics", data2); -- 记录成功分享至某个平台的次数，触发操作数据统计计数
        end
    end
end

-- 分享
-- todo 本来重复分享同一个海报做了处理的，判断相同海报就不请求后台，直接分享。但是不知道为什么分享出去的海报为默认的海报，所以改成现在这样。后面有时间再来优化处理。
function ShareApp:fire(id, page)
    -- 防止开启多个分享界面
    if ShareApp.bShare then
        return
    end
    ShareApp.poster_id = id
    ShareApp.bShare = true
    local path = string.format("/posters/show?type=%d", id)
    request:get(path):next(function(response)
        -- 拿到返回值，根据返回值拼接share参数
        local data = response.data.data
        ShareApp.poster_url = data.img_url or data.default_url
        -- 拿到图片开始分享
        ShareApp:ShareLogic(ShareApp.poster_url, id)
        if page then
            page:Refresh(0)
        end
    end):catch(function(e)
        GameLogic.AddBBS("CodeGlobals", e.data.message, 3000, "#FF0000");
    end);
end

-- 通用分享函数。手机端主界面分享会有弹窗，其它地方调用直接走分享逻辑。PC端调用展示PC端专属分享页面。
function ShareApp:ShowPage(id, page)
    if id and page then
        ShareApp:GetPoster(id, page)
    end
    ShareApp.poster_id = id
    ShareApp.bShare = false
    -- 判断登陆设备，pc端和手机端展示不同的页面
    if System.os.IsMobilePlatform() then
        -- 手机端展示页面
        if id == 1 then
            -- 主界面分享，有弹窗
            local params = {
                url = "Mod/CodePku/cellar/GUI/Share/ShareApp.html",
                alignment="_lt", left = 0, top = 0, width = 1920 , height = 1080, zorder = 30,
            }
            if self.ui then
                self.ui:CloseWindow()
                self.ui = nil
            end
            self.ui = AdaptWindow:QuickWindow(params)
        else
            -- 其它界面分享，无弹窗
            ShareApp:fire(id, page)
        end

    else
        -- pc端展示页面
        local params = {
            url = "Mod/CodePku/cellar/GUI/Share/SharePC.html",
            alignment="_lt", left = 0, top = 0, width = 1920 , height = 1080, zorder = 30,
        }
        if self.ui then
            self.ui:CloseWindow()
            self.ui = nil
        end
        self.ui = AdaptWindow:QuickWindow(params)
    end
end