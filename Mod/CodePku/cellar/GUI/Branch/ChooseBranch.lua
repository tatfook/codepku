--[[
Author:zouren
Date: 2020-10-22 19:07:23
Des:
use the lib:
------------------------------------
NPL.load("(gl)Mod/CodePku/cellar/GUI/Branch/ChooseBranch.lua")
local ChooseBranch = commonlib.gettable("Mod.CodePku.GUI.ChooseBranch")
ChooseBranch:ShowPage()
-----------------------------------
]]--
NPL.load("(gl)Mod/CodePku/cellar/GUI/Branch/BranchData.lua")
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua")
local branchImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/branchImageData.lua")
local common1ImageData = NPL.load("(gl)Mod/CodePku/cellar/imageLuaTable/common1ImageData.lua")

local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow")
local ChooseBranch = commonlib.gettable("Mod.CodePku.GUI.ChooseBranch")

ChooseBranch.ui = nil

ChooseBranch.branchStateTable = {}

ChooseBranch.currChooseBranch = 5

ChooseBranch.branchNameTalbe = {
    "甲子","乙丑","丙寅","丁卯","戊辰",
    "已巳","庚午","辛未","壬申","癸酉",
    "甲戌","乙亥","丙子","丁丑","戊寅",
    "已卯","庚辰","辛巳","壬午","癸未",
    "甲申","乙酉","丙戌","丁亥","戊子",
    "己丑","庚寅","辛卯","壬辰","癸巳",
    "甲午","乙未","丙申","丁酉","戊戌",
    "已亥","庚子","辛丑","壬寅","癸卯",
    "甲辰","乙巳","丙午","丁未","戊申",
    "已酉","庚戌","辛亥","壬子","癸丑",
    "甲寅","乙卯","丙辰","丁巳","戊午",
    "已未","庚申","辛酉","壬戌","癸亥",
}

ChooseBranch.HTMLStyleData = {
    [1] = { ["desc"] = "背景图片", ["position"] = "absolute", ["left"] = 624, ["top"] = 18, ["width"] = 699, ["height"] = 1000, ["background"] = "url("..branchImageData:GetIconUrl("branch_boot_01.png")..")",},
    [2] = { ["desc"] = "退出按钮", ["position"] = "absolute", ["left"] = 1213, ["top"] = 4, ["width"] = 77, ["height"] = 123, ["background"] = "url("..common1ImageData:GetIconUrl("comm_btn_close.png")..")",},
    [3] = { ["desc"] = "切换分线按钮", ["position"] = "absolute", ["left"] = 830, ["top"] = 957, ["width"] = 298, ["height"] = 101, ["background"] = "url("..common1ImageData:GetIconUrl("common_btn_green01.png")..")",},
    [4] = { ["desc"] = "爆满图标", ["position"] = "relative", ["left"] = 89, ["top"] = 186, ["width"] = 52, ["height"] = 52, ["background"] = "url("..branchImageData:GetIconUrl("branch_icon_r.png")..")",},
    [5] = { ["desc"] = "爆满文字", ["position"] = "relative", ["left"] = 161, ["top"] = 194, ["width"] = 104, ["height"] = 52, ["color"] = "#9e6c5e", ["font-family"] = "zkklt", ["font-size"] = "40px",},
    [6] = { ["desc"] = "繁忙图标", ["position"] = "relative", ["left"] = 278, ["top"] = 186, ["width"] = 52, ["height"] = 52, ["background"] = "url("..branchImageData:GetIconUrl("branch_icon_y.png")..")",},
    [7] = { ["desc"] = "繁忙文字", ["position"] = "relative", ["left"] = 350, ["top"] = 194, ["width"] = 104, ["height"] = 52, ["color"] = "#9e6c5e", ["font-family"] = "zkklt", ["font-size"] = "40px",},
    [8] = { ["desc"] = "流畅图标", ["position"] = "relative", ["left"] = 467, ["top"] = 186, ["width"] = 52, ["height"] = 52, ["background"] = "url("..branchImageData:GetIconUrl("branch_icon_g.png")..")",},
    [9] = { ["desc"] = "流畅文字", ["position"] = "relative", ["left"] = 539, ["top"] = 194, ["width"] = 104, ["height"] = 52, ["color"] = "#9e6c5e", ["font-family"] = "zkklt", ["font-size"] = "40px",},
    [10] = { ["desc"] = "标题文字", ["position"] = "relative", ["left"] = 210, ["top"] = 31, ["width"] = 400, ["height"] = 120, ["color"] = "#9e6c5e", ["font-family"] = "zkklt", ["font-size"] = "65px",},
    [11] = { ["desc"] = "滚动区域", ["position"] = "relative", ["left"] = 90, ["top"] = 256, ["width"] = 514, ["height"] = 670,},
    [12] = { ["desc"] = "分线栏背景(未选择)", ["width"] = 515, ["height"] = 106,["background"] = "url("..branchImageData:GetIconUrl("branch_boot_g.png")..")",},
    [13] = { ["desc"] = "分线栏背景(选中)", ["width"] = 515, ["height"] = 107,["background"] = "url("..branchImageData:GetIconUrl("branch_boot_w.png")..")",},
    [14] = { ["desc"] = "分线栏状态标签", ["position"] = "relative", ["left"] = 24, ["top"] = 30, ["width"] = 52, ["height"] = 52,["background"] = "url("..branchImageData:GetIconUrl("branch_icon_g.png")..")",},
    [15] = { ["desc"] = "分线栏文字",  ["position"] = "relative", ["left"] = 109, ["top"] = 32, ["width"] = 400, ["height"] = 60, ["color"] = "#813010", ["font-family"] = "zkklt", ["font-size"] = "48",},
    [16] = { ["desc"] = "切换分线按钮文字",  ["position"] = "relative", ["left"] = 49, ["top"] = 26, ["width"] = 199, ["height"] = 41,["background"] = "url("..branchImageData:GetIconUrl("branch_icon_g_mat.png")..")",},
}

function ChooseBranch:StaticInit()
    LOG.std("", "info", "ChooseBranch", "StaticInit");
    GameLogic:Connect("WorldLoaded", ChooseBranch, ChooseBranch.OnWorldLoaded, "UniqueConnection");
    GameLogic:Connect("WorldUnloaded", ChooseBranch, ChooseBranch.OnWorldUnloaded, "UniqueConnection");
end

function ChooseBranch.OnWorldLoaded()
    -- 清空原始分线数据缓存
    ChooseBranch.branchStateTable = nil
    commonlib.setfield(System.Codepku.branch.worldInfo, nil)

    -- 拉去分支数据的计时器
    local getDataTimer = commonlib.Timer:new({callbackFunc = function(timer)
        commonlib.log({"ontimer", timer.id, timer.delta, timer.lastTick})
        ChooseBranch:GetBranchStateData()
        if ChooseBranch.branchStateTable then
            getDataTimer:Change()
        end
    end})

    getDataTimer:Change(0, 1000)
end

function ChooseBranch.OnWorldUnloaded()
    ChooseBranch.branchStateTable = {}
end

function ChooseBranch:GetBranchStateData()
    -- todo   一堆逻辑要写
    local currWorldId = System and System.Codepku and System.Codepku.Coursewares and System.Codepku.Coursewares.keepwork_project_id
    local currWorldName = System and System.Codepku and System.Codepku.Coursewares and System.Codepku.Coursewares.name
    GameLogic.RunCommand("/ggs debug codepku")
    if System.Codepku and System.Codepku.branch and System.Codepku.branch.worldInfo then
        -- 当前所在世界的worldkey  用来判定当前ggs的服务器数据
        -- todo 记得这个数据来判定当前世界的分支数据
        local worldKey = System.Codepku.branch.worldKey
        ChooseBranch.branchStateTable = {}
        local worlds = System.Codepku.branch.worldInfo.worlds
        for key,value in pairs(worlds) do
            local refInfo = {}
            for each in string.gmatch(key, "%d+") do
                table.insert( refInfo, each )
            end
            local worldId = tonumber(refInfo[1])
            local worldName = tonumber(refInfo[2])
            local branchId = tonumber(refInfo[3])
            local playerNum = value
            if worldId == currWorldId then
                table.insert( ChooseBranch.branchStateTable,
                    {   
                        ["worldId"] = tonumber(worldId),
                        ["worldName"] = tonumber(worldName),
                        ["branchId"] = tonumber(branchId),
                        ["playerNum"] = tonumber(playerNum)
                    } 
                )
            end
        end
    end
end

function ChooseBranch:GetHTMLStyleStr(index)
    local htmlTable = ChooseBranch.HTMLStyleData[index]
    local styleStr = ""
    for k,v in pairs(htmlTable) do
        if k ~= "desc" then
            styleStr = styleStr..k..": "..v.."; "
        end
    end
    return styleStr
end

function ChooseBranch:changeBranch(index)
    ChooseBranch.currChooseBranch = index
    -- ChooseBranch:ShowPage(true)
end

function ChooseBranch:getBranchName(nameId)
    return ChooseBranch.branchNameTalbe[nameId]
end

-- 当且仅当bShow为false时为关闭页面
function ChooseBranch:ShowPage(bShow)
    --body
    if ChooseBranch.ui then
        ChooseBranch.ui:CloseWindow()
        ChooseBranch.ui = nil
    end
    if bShow == false then
        return
    end
    params = {
        name = "branch_choose",
        url = "Mod/CodePku/cellar/GUI/Branch/ChooseBranch.html",
        alignment="_ct",
        left = -960,
        top = -540,
        width = 1920,
        height = 1080,
        zorder = 20,
    }

    ChooseBranch.ui = AdaptWindow:QuickWindow(params)
end
