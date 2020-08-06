--[[
Title: UserInfo
Author(s):  big
Date: 2018.06.21
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local UserInfo = NPL.load("(gl)Mod/CodePku/cellar/Login/UserInfo.lua")
------------------------------------------------------------
]]
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld")

local UserConsole = NPL.load("(gl)Mod/CodePku/cellar/UserConsole/Main.lua")
local LoginModal = NPL.load("../LoginModal/LoginModal.lua")
local HttpRequest = NPL.load("(gl)Mod/CodePku/service/HttpRequest.lua")
local CodePkuService = NPL.load("(gl)Mod/CodePku/service/CodePkuService.lua")
local CodePkuServiceSession = NPL.load("(gl)Mod/CodePku/service/CodePkuService/Session.lua")
local Store = NPL.load("(gl)Mod/CodePku/store/Store.lua")
local Config = NPL.load("(gl)Mod/CodePku/config/Config.lua")
local SessionsData = NPL.load("(gl)Mod/CodePku/database/SessionsData.lua")

local UserInfo = NPL.export()

local default_avatars = {
    "boy01",
}

local DefaultBoyAvatars = {
    "boy01",
};

local DefaultGirlAvatars = {
    "girl01",
}

local cur_index = 1

function UserInfo.IsSignedIn()
    return CodePkuService:IsSignedIn()
end

function UserInfo:CheckoutVerified()
    local isVerified = Mod.CodePku.Store:Get("user/isVerified")

    if self.IsSignedIn() and not isVerified then
        _guihelper.MessageBox(
            L"您需要到keepwork官网进行实名认证，认证成功后需重启paracraft即可正常操作，是否现在认证？",
            function(res)
                if (res and res == _guihelper.DialogResult.Yes) then
                    -- ParaGlobal.ShellExecute("open", format("%s/wiki/user_center", self:Site()), "", "", 1)
                end
            end,
            _guihelper.MessageBoxButtons.YesNo
        )

        return false
    else
        return true
    end
end

function UserInfo.GetValidAvatarFilename(playerName)
    if (playerName) then
        NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerAssetFile.lua")
        local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
        PlayerAssetFile:Init()
        return PlayerAssetFile:GetValidAssetByString(playerName)
    end
end

function UserInfo.IsMCVersion()
    if (System.options.mc) then
        return true
    else
        return false
    end
end

function UserInfo.ChangeName()
    InternetLoadWorld.changedName = true
    UserConsole:Refresh()
end

function UserInfo.CancelChangeName()
    InternetLoadWorld.changedName = false
    UserConsole:Refresh()
end

function UserInfo.SaveName()
    InternetLoadWorld.ChangeNickName()
end

function UserInfo.ChangeQQ()
    InternetLoadWorld.changedQQ = true
    UserConsole:Refresh()
end

function UserInfo.SaveQQ()
    InternetLoadWorld.changedQQ = false
    UserConsole:Refresh()
end

function UserInfo.GetUserNickName()
    return System.User.nickname or L"匿名"
end

function UserInfo:GetUserName()
    local username = Store:Get('user/username') or ''

    return username
end

-- for restart game
function UserInfo:LoginWithToken()
    local usertoken = CodePkuServiceSession:GetCurrentUserToken()

    if type(usertoken) ~= "string" or #usertoken <= 0 then
        return false
    end

    Mod.CodePku.MsgBox:Show(L"正在自动登陆，请稍后...", 8000, L"链接超时")

    CodePkuServiceSession:Profile(
        function(data, err)
            if err == 401 then
                Mod.CodePku.MsgBox:Close()
                -- token not exist
                GameLogic.AddBBS(nil, format("%s%d", L"自动登陆失败了， 错误码：", err), 3000, "255 0 0", 21)

                return false
            elseif err ~= 200 then
                Mod.CodePku.MsgBox:Close()
                GameLogic.AddBBS(nil, format("%s%d", L"自动登陆失败了， 错误码：", err), 3000, "255 0 0", 21)

                return false
            end

            if type(data) == 'table' and data.username then
                data.token = usertoken
                CodePkuServiceSession:LoginResponse(
                    data,
                    err,
                    function()
                        Mod.CodePku.MsgBox:Close()                        
                        if type(callback) == "function" then
                            callback()
                        end
                    end
                )
            end
        end,
        usertoken
    )
end

function UserInfo:CheckDoAutoSignin(callback)
    local info = CodePkuServiceSession:LoadSigninInfo()

    if not info or not info.autoLogin or not info.account or not info.password then
        return false
    end

    Mod.CodePku.MsgBox:Show(L"正在自动登陆，请稍后...", 8000, L"链接超时")

    CodePkuServiceSession:Profile(
        function(data, err)
            if err == 401 then
                -- login with token error when auto login
                CodePkuServiceSession:Login(
                    info.account,
                    info.password,
                    function(response, err)
                        if err ~= 200 then
                            Mod.CodePku.MsgBox:Close()

                            info.token = nil
                            info.autoLogin = false
                            SessionsData:SaveSession(info)

                            -- token not exist
                            GameLogic.AddBBS(nil, format("%s%d", L"自动登陆失败了， 错误码：", err), 3000, "255 0 0", 21)
                            return false
                        end

                        CodePkuServiceSession:LoginResponse(response, err, function()
                            Mod.CodePku.MsgBox:Close()

                            if err ~= 200 then
                                -- login fail
                                GameLogic.AddBBS(nil, format("%s%d", L"自动登陆失败了， 错误码：", err), 3000, "255 0 0", 21)
                                return false
                            end                            
    
                            local AfterLogined = Mod.CodePku.Store:Get('user/AfterLogined')
    
                            if type(AfterLogined) == 'function' then
                                AfterLogined(true)
                                Mod.CodePku.Store:Remove('user/AfterLogined')
                            end
    
                            if type(callback) == "function" then
                                callback()
                            end
                        end)
                    end
                )
                return false
            elseif err ~= 200 then
                Mod.CodePku.MsgBox:Close()
                GameLogic.AddBBS(nil, format("%s%d", L"自动登陆失败了， 错误码：", err), 3000, "255 0 0", 21)

                return false
            end

            if type(data) == 'table' and data.username then
                data.token = info.token
                CodePkuServiceSession:LoginResponse(
                    data,
                    err,
                    function()
                        Mod.CodePku.MsgBox:Close()                        

                        local AfterLogined = Mod.CodePku.Store:Get('user/AfterLogined')

                        if type(AfterLogined) == 'function' then
                            AfterLogined(true)
                            Mod.CodePku.Store:Remove('user/AfterLogined')
                        end

                        if type(callback) == "function" then
                            callback()
                        end
                    end
                )
            end
        end,
        info.token
    )

    return true
end

function UserInfo:OnClickLogin()
    Mod.CodePku.Store:Set("user/loginText", L"请先登录")
    LoginModal:Init(function()
        
    end)
end

local curIndex = 1
-- cycle through
-- @param btnName: if nil, we will load the default one if scene is not started.
function UserInfo:OnChangeAvatar(btnName)
    local UserConsolePage = Store:Get("page/UserConsole")

    local avatars = default_avatars;

    if System.User.info.gender == 1 then
        avatars = DefaultBoyAvatars;
    elseif System.User.info.gender == 2 then
        avatars = DefaultGirlAvatars;
    end
    
    if System.User.info.special_type == 1 then
        GameLogic.options:SetMainPlayerAssetName('codepku/model/LLS_AN.x')
    elseif System.User.info.special_type == 2 then
        GameLogic.options:SetMainPlayerAssetName('codepku/model/HLS_AN.x')
    elseif System.User.info.special_type == 3 then
        GameLogic.options:SetMainPlayerAssetName('codepku/model/WLS_AN.x')
    else
        filename = UserInfo.GetValidAvatarFilename(avatars[1])
        GameLogic.options:SetMainPlayerAssetName(filename)
    end
 
    -- if not btnName then
    --     local filename = GameLogic.options:GetMainPlayerAssetName()
    --     if not GameLogic.IsStarted then
    --         GameLogic.options:SetMainPlayerAssetName()
    --         filename = GameLogic.options:GetMainPlayerAssetName()
    --         if not filename then
    --             filename = UserInfo.GetValidAvatarFilename(avatars[cur_index])
    --             GameLogic.options:SetMainPlayerAssetName(filename)
    --         end
    --     end
    --     if filename and UserConsolePage then
    --         UserConsolePage:CallMethod("MyPlayer", "SetAssetFile", filename)
    --     end
    --     return
    -- end

    -- if (btnName == "pre") then
    --     curIndex = curIndex - 1
    -- else
    --     curIndex = curIndex + 1
    -- end

    -- curIndex = ((curIndex - 1) % (#avatars)) + 1
    
    -- local playerName = avatars[curIndex]

    -- if playerName and UserConsolePage then
    --     local filename = UserInfo.GetValidAvatarFilename(playerName)
    --     if (filename) then
    --         if (GameLogic.RunCommand) then
    --             GameLogic.RunCommand("/avatar " .. playerName)
    --         end
    --         GameLogic.options:SetMainPlayerAssetName(filename)
    --         UserConsolePage:CallMethod("MyPlayer", "SetAssetFile", playerName)
    --     end
    -- end
end

function UserInfo.LookPlayerInform()
    local cur_page = InternetLoadWorld.GetCurrentServerPage()
    local nid = cur_page.player_nid

    if nid then
        Map3DSystem.App.Commands.Call(Map3DSystem.options.ViewProfileCommand, nid)
    end
end

function UserInfo:CanSwitchUser()
    return not (System.options and System.options.isFromQQHall);
end

function UserInfo:Logout()
    if self.IsSignedIn() and self:CanSwitchUser() then
        CodePkuServiceSession:Logout()
        -- WorldList:RefreshCurrentServerList()
    end
end
