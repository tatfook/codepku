local UserInfoPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.UserInfoPage")
local UserInfo = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.UserInfo")
local request = NPL.load("(gl)Mod/CodePkuCommon/api/BaseRequest.lua");
local page;

function UserInfoPage.OnInit()
	UserInfoPage.OneTimeInit();
	page = document:GetPageCtrl();
end

function UserInfoPage.OneTimeInit()
	if(UserInfoPage.is_inited) then
		return;
	end
	UserInfoPage.is_inited = true;
end

-- clicked a block
function UserInfoPage.OnClickBlock(block_id)

end

-- 获取用户信息
function UserInfoPage.GetUserInfo()
    response = request:get('/users/profile',nil,{sync = true})
    if response.status == 200 then
        data = response.data.data
        UserInfo.name = data.nickname or data.mobile
        UserInfo.id = data.id
        UserInfo.gender = data.gender
    end
end

-- 获取道具信息
function UserInfoPage.GetItemInfo()
    --response = request:get('/some/url')
    -- 测试数据
    response = {
        [1] = {category_id=2, name='道具1', remain=200, max_stacked=99},
        [2] = {category_id=2, name='道具2', remain=100, max_stacked=99},
        [3] = {category_id=2, name='道具3', remain=99, max_stacked=99},
        [4] = {category_id=2, name='道具4', remain=66, max_stacked=99},
    }
    
    data = {}
    -- 拆分堆叠道具
    for i, v in ipairs(response) do
        if v.remain ~= v.max_stacked then -- 拆分堆叠数，1表示不拆分
            stack = math.floor(v.remain/ v.max_stacked) + 1
        else
            stack = 1
        end
        l = commonlib.deepcopy(response[i])
        s = 1
        while s < stack do
            l.remain = v.max_stacked
            table.insert(data, l)
            s = s + 1
        end
        if stack > 1 then
            v.remain = v.remain % v.max_stacked
        end
        table.insert(data, v)
    end
    return data
end

function UserInfoPage:ShowPage(PageIndex,bShow)
    -- NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/DesktopMenuPage.lua");
    -- local DesktopMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.DesktopMenuPage");
    UserInfoPage.bForceHide = bShow == false;
    UserInfoPage.PageIndex = PageIndex
    UserInfoPage.GetUserInfo()
    NPL.load("(gl)Mod/CodePku/cellar/GUI/Window/AdaptWindow.lua");
    local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow")
    AdaptWindow:QuickWindow({url="Mod/CodePku/cellar/GUI/UserInfo.html", 
    alignment="_ct", left = -960, top = -540, width = 1920, height = 1080,zorder =20})
end