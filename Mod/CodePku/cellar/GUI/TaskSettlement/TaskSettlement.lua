--[[
Title: 任务结算
Author(s):  wanglj
Date: 2020.9.7
Desc: 任务结算界面
    --]]
local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow");

local TaskSettlementPage = NPL.export()

function TaskSettlementPage:GetuserInfo()
    local userInfo = {}
    local info = System.User.info
    userInfo.nickname = info.nickname or ''
    userInfo.avatar_url = info.avatar_url
    userInfo.avatar_frame_url = info.avatar_frame_url

    if not info.avatar_url or info.avatar_url ==''  then
        userInfo.avatar_url = 'codepku/image/textures/task_settlement/task_settlement.png#97 1246 124 126'
    end
    if not info.avatar_frame_url or info.avatar_frame_url ==''  then
        userInfo.avatar_frame_url = 'codepku/image/textures/task_settlement/task_settlement.png#280 1238 134 134'
    end
    return userInfo
end


function TaskSettlementPage:GetSubejectInfo()
    local subejectInfo = {}
    if TaskSettlementPage.data then
        subejectInfo.total_exp = TaskSettlementPage.data.total_exp or 0
        subejectInfo.subject_exp = TaskSettlementPage.data.subject_exp or 0
        subejectInfo.subject_name = TaskSettlementPage.data.subject_name
        subejectInfo.props = TaskSettlementPage.data.props or {}
    end

    local subjectUrls = {
        {subjectName='语文',subjectUrl='codepku/image/textures/subjects/subjects.png#161 49 69 83'},
        {subjectName='英语',subjectUrl='codepku/image/textures/subjects/subjects.png#256 56 75 68'},
        {subjectName='数学',subjectUrl='codepku/image/textures/subjects/subjects.png#381 49 72 87'},
        {subjectName='物理',subjectUrl='codepku/image/textures/subjects/subjects.png#503 72 75 60'},
        {subjectName='生物',subjectUrl='codepku/image/textures/subjects/subjects.png#618 57 71 75'},
        {subjectName='化学',subjectUrl='codepku/image/textures/subjects/subjects.png#742 57 62 71'},
        {subjectName='科学',subjectUrl='codepku/image/textures/subjects/subjects.png#834 57 86 71'},
        {subjectName='编程',subjectUrl='codepku/image/textures/subjects/subjects.png#36 180 79 76'},
        {subjectName='历史',subjectUrl='codepku/image/textures/subjects/subjects.png#149 185 73 66'},
    }

    for _,v in pairs(subjectUrls) do
        if v.subjectName..'经验' == subejectInfo.subject_name then
            subejectInfo.subject_name = v.subjectName
            subejectInfo.subject_url = v.subjectUrl
            return subejectInfo
        end
    end
    return subejectInfo
end


function TaskSettlementPage.GetProps(subjectInfo)
    if next(subjectInfo.props) == nil then
        return {
            {prop_id=1,prop_num=100,prop_name='玩学币'},
            {prop_id=1,prop_num=100,prop_name='玩学币'},
            {prop_id=2,prop_num=1,prop_name='玩学券'},
            {prop_id=2,prop_num=1,prop_name='玩学券'},
            {prop_id=11001,prop_num=1,prop_name='补签卡',prop_icon_url='https://scratch-works-staging-1253386414.file.myqcloud.com/game/admin/propIcons/11001.png'}}
    end
    return subjectInfo.props
end

TaskSettlementPage.props = TaskSettlementPage:GetProps()

function TaskSettlementPage:ShowPage(data)
    TaskSettlementPage.data = data
    --[[eg:
    {
        "total_exp": 0,
        "subject_exp": 0,
        "total_exp_name": "玩家经验",
        "subject_name": "语文经验",
        "props": [
            {
                "prop_id": 1,
                "prop_num": 0,
                "prop_name": "玩学币"
            },
            {
                "prop_id": 2,
                "prop_num": 0,
                "prop_name": "玩学券"
            }
        ]
    }    
    --]]

    local params = {
        url = "Mod/CodePku/cellar/GUI/TaskSettlement/TaskSettlement.html", 
        alignment = "_ct",
        x = -960,
        y = -540,
        width = 1920,
        height = 1080,
        zorder = 30,
        };
    TaskSettlementPage.window = AdaptWindow:QuickWindow(params)
end